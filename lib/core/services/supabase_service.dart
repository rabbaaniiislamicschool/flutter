import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

@lazySingleton
class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  // ============ AUTH ============

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signInWithEmail(String email, String password) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<bool> signInWithGoogle() async {
    return _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.nikahkit://login-callback/',
    );
  }

  Future<AuthResponse> signInWithApple() async {
    return _client.auth.signInWithApple();
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<void> resetPassword(String email) {
    return _client.auth.resetPasswordForEmail(email);
  }

  // ============ DATABASE ============

  /// Query builder
  SupabaseQueryBuilder from(String table) => _client.from(table);

  /// Select with filters
  Future<List<Map<String, dynamic>>> select(
    String table, {
    String columns = '*',
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    var query = _client.from(table).select(columns);

    if (filters != null) {
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });
    }

    if (orderBy != null) {
      query = query.order(orderBy, ascending: ascending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    if (offset != null) {
      query = query.range(offset, offset + (limit ?? 10) - 1);
    }

    return await query;
  }

  /// Insert
  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(table)
        .insert(data)
        .select()
        .single();
    return response;
  }

  /// Update
  Future<Map<String, dynamic>> update(
    String table,
    Map<String, dynamic> data, {
    required String id,
    String idColumn = 'id',
  }) async {
    final response = await _client
        .from(table)
        .update(data)
        .eq(idColumn, id)
        .select()
        .single();
    return response;
  }

  /// Upsert
  Future<Map<String, dynamic>> upsert(
    String table,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(table)
        .upsert(data)
        .select()
        .single();
    return response;
  }

  /// Delete
  Future<void> delete(
    String table, {
    required String id,
    String idColumn = 'id',
  }) async {
    await _client.from(table).delete().eq(idColumn, id);
  }

  // ============ RPC (Remote Procedure Call) ============ [web:84]

  /// Call PostgreSQL function
  Future<T> rpc<T>(
    String functionName, {
    Map<String, dynamic>? params,
  }) async {
    final response = await _client.rpc(functionName, params: params);
    return response as T;
  }

  /// Example: Get invitation statistics
  Future<Map<String, dynamic>> getInvitationStats(String invitationId) {
    return rpc('get_invitation_stats', params: {'p_invitation_id': invitationId});
  }

  /// Example: Search guests with full-text search
  Future<List<Map<String, dynamic>>> searchGuests({
    required String invitationId,
    required String query,
  }) {
    return rpc('search_guests', params: {
      'p_invitation_id': invitationId,
      'p_query': query,
    });
  }

  /// Example: Check-in guest
  Future<Map<String, dynamic>> checkInGuest({
    required String guestId,
    required String checkedInBy,
  }) {
    return rpc('check_in_guest', params: {
      'p_guest_id': guestId,
      'p_checked_in_by': checkedInBy,
    });
  }

  // ============ STORAGE ============

  /// Upload file
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String? contentType,
  }) async {
    await _client.storage.from(bucket).uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: contentType),
    );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  /// Upload from file path
  Future<String> uploadFromPath({
    required String bucket,
    required String storagePath,
    required String filePath,
  }) async {
    final file = File(filePath);
    await _client.storage.from(bucket).upload(storagePath, file);
    return _client.storage.from(bucket).getPublicUrl(storagePath);
  }

  /// Delete file
  Future<void> deleteFile(String bucket, String path) {
    return _client.storage.from(bucket).remove([path]);
  }

  /// Get signed URL (for private files)
  Future<String> getSignedUrl(String bucket, String path, {
    int expiresIn = 3600,
  }) {
    return _client.storage.from(bucket).createSignedUrl(path, expiresIn);
  }

  // ============ REALTIME ============ [web:68]

  /// Subscribe to table changes
  RealtimeChannel subscribeToTable({
    required String table,
    required void Function(PostgresChangePayload) onInsert,
    void Function(PostgresChangePayload)? onUpdate,
    void Function(PostgresChangePayload)? onDelete,
    String? filter,
    String schema = 'public',
  }) {
    final channel = _client.channel('realtime:$table');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: schema,
          table: table,
          filter: filter != null ? PostgresChangeFilter.fromString(filter) : null,
          callback: onInsert,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: schema,
          table: table,
          callback: onUpdate ?? (_) {},
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: schema,
          table: table,
          callback: onDelete ?? (_) {},
        )
        .subscribe();

    return channel;
  }

  /// Subscribe to presence (who is online)
  RealtimeChannel subscribeToPresence({
    required String channelName,
    required void Function(List<dynamic>) onSync,
    required void Function(String, dynamic) onJoin,
    required void Function(String, dynamic) onLeave,
  }) {
    final channel = _client.channel(channelName);

    channel
        .onPresenceSync((payload) => onSync(payload))
        .onPresenceJoin((payload) {
          final key = payload.newPresences.first.presenceRef;
          onJoin(key, payload.newPresences.first.payload);
        })
        .onPresenceLeave((payload) {
          final key = payload.leftPresences.first.presenceRef;
          onLeave(key, payload.leftPresences.first.payload);
        })
        .subscribe();

    return channel;
  }

  /// Broadcast to channel
  RealtimeChannel subscribeToBroadcast({
    required String channelName,
    required String event,
    required void Function(Map<String, dynamic>) onMessage,
  }) {
    final channel = _client.channel(channelName);

    channel
        .onBroadcast(event: event, callback: (payload) => onMessage(payload))
        .subscribe();

    return channel;
  }

  /// Send broadcast message
  Future<void> broadcast({
    required RealtimeChannel channel,
    required String event,
    required Map<String, dynamic> payload,
  }) {
    return channel.sendBroadcastMessage(event: event, payload: payload);
  }

  // ============ EDGE FUNCTIONS ============ [web:77]

  /// Invoke edge function
  Future<FunctionResponse> invokeFunction(
    String functionName, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    HttpMethod method = HttpMethod.post,
  }) {
    return _client.functions.invoke(
      functionName,
      body: body,
      headers: headers,
      method: method,
    );
  }

  /// Create payment via edge function
  Future<Map<String, dynamic>> createPayment({
    required String type,
    required double amount,
    required String paymentMethod,
    required String customerName,
    required String customerEmail,
    String? customerPhone,
    String? packageType,
    String? invitationId,
    String? message,
    bool isAnonymous = false,
  }) async {
    final response = await invokeFunction('payment-create', body: {
      'type': type,
      'amount': amount,
      'payment_method': paymentMethod,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'package_type': packageType,
      'invitation_id': invitationId,
      'message': message,
      'is_anonymous': isAnonymous,
    });

    if (response.status != 200) {
      throw Exception('Payment creation failed: ${response.data}');
    }

    return response.data as Map<String, dynamic>;
  }

  /// Send WhatsApp notification via edge function
  Future<void> sendWhatsAppNotification({
    required String phone,
    required String message,
    String? mediaUrl,
  }) async {
    await invokeFunction('send-whatsapp', body: {
      'phone': phone,
      'message': message,
      'media_url': mediaUrl,
    });
  }

  /// Generate QR Code via edge function
  Future<String> generateQRCode({
    required String data,
    int size = 300,
  }) async {
    final response = await invokeFunction('generate-qr', body: {
      'data': data,
      'size': size,
    });

    return response.data['qr_url'] as String;
  }
}
