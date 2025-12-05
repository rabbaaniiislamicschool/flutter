import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

@freezed
class UserEntity with _$UserEntity {
  const UserEntity._();

  const factory UserEntity({
    required String id,
    required String email,
    String? phone,
    String? fullName,
    String? avatarUrl,
    @Default(UserRole.user) UserRole role,
    @Default(SubscriptionTier.free) SubscriptionTier subscriptionTier,
    DateTime? subscriptionExpiresAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _UserEntity;

  bool get isPremium => subscriptionTier != SubscriptionTier.free;

  bool get isSubscriptionActive {
    if (subscriptionTier == SubscriptionTier.free) return true;
    if (subscriptionExpiresAt == null) return false;
    return subscriptionExpiresAt!.isAfter(DateTime.now());
  }

  bool get canCreateInvitation => isSubscriptionActive;
}

enum UserRole { user, admin, superAdmin }

enum SubscriptionTier { free, sakinah, mawaddah, warahmah }
