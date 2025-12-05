import 'dart:async';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Hook untuk subscribe ke Supabase Realtime [web:68]
RealtimeChannel useSupabaseRealtime({
  required String table,
  required void Function(PostgresChangePayload payload) onInsert,
  void Function(PostgresChangePayload payload)? onUpdate,
  void Function(PostgresChangePayload payload)? onDelete,
  String? schema,
  String? filter,
}) {
  final supabase = Supabase.instance.client;

  final channel = useMemoized(() {
    return supabase.channel('realtime:$table');
  }, [table]);

  useEffect(() {
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: schema ?? 'public',
          table: table,
          filter: filter != null ? PostgresChangeFilter.fromString(filter) : null,
          callback: onInsert,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: schema ?? 'public',
          table: table,
          callback: onUpdate ?? (_) {},
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: schema ?? 'public',
          table: table,
          callback: onDelete ?? (_) {},
        )
        .subscribe();

    return () {
      channel.unsubscribe();
    };
  }, [channel]);

  return channel;
}

/// Hook untuk fetch data dengan loading state
AsyncSnapshot<T> useSupabaseQuery<T>({
  required Future<T> Function() query,
  List<Object?> keys = const [],
}) {
  final future = useMemoized(query, keys);
  return useFuture(future);
}
