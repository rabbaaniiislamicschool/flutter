import 'package:freezed_annotation/freezed_annotation.dart';

part 'invitation_entity.freezed.dart';

@freezed
class InvitationEntity with _$InvitationEntity {
  const factory InvitationEntity({
    required String id,
    required String userId,
    String? themeId,
    required String slug,
    String? customDomain,
    @Default(InvitationStatus.draft) InvitationStatus status,
    DateTime? publishedAt,
    DateTime? expiresAt,
    required CoupleData groomData,
    required CoupleData brideData,
    @Default(InvitationSettings()) InvitationSettings settings,
    @Default(0) int viewCount,
    required DateTime createdAt,
    DateTime? updatedAt,
    List<InvitationEvent>? events,
    List<LoveStory>? loveStories,
    List<GalleryItem>? galleries,
  }) = _InvitationEntity;
}

@freezed
class CoupleData with _$CoupleData {
  const factory CoupleData({
    required String fullName,
    String? nickname,
    String? fatherName,
    String? motherName,
    String? childOrder,
    String? photoUrl,
    String? instagram,
  }) = _CoupleData;
}

@freezed
class InvitationEvent with _$InvitationEvent {
  const factory InvitationEvent({
    required String id,
    required String invitationId,
    required EventType eventType,
    String? eventName,
    required DateTime eventDate,
    DateTime? startTime,
    DateTime? endTime,
    required String venueName,
    String? venueAddress,
    String? mapsUrl,
    double? latitude,
    double? longitude,
    String? livestreamUrl,
    String? notes,
    @Default(0) int sortOrder,
  }) = _InvitationEvent;
}

@freezed
class LoveStory with _$LoveStory {
  const factory LoveStory({
    required String id,
    required String invitationId,
    String? title,
    String? description,
    DateTime? storyDate,
    String? imageUrl,
    @Default(0) int sortOrder,
  }) = _LoveStory;
}

@freezed
class GalleryItem with _$GalleryItem {
  const factory GalleryItem({
    required String id,
    required String invitationId,
    required String imageUrl,
    String? caption,
    @Default(0) int sortOrder,
  }) = _GalleryItem;
}

@freezed
class InvitationSettings with _$InvitationSettings {
  const factory InvitationSettings({
    String? backsoundUrl,
    @Default(true) bool showCountdown,
    @Default(true) bool showGuestbook,
    @Default(true) bool showRsvp,
    @Default(false) bool showEnvelope,
    @Default(true) bool showMaps,
    @Default(true) bool showLoveStory,
    @Default(true) bool showGallery,
  }) = _InvitationSettings;
}

enum InvitationStatus { draft, published, expired }
enum EventType { akad, resepsi, ngunduhMantu, walimah, other }
