import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const UserModel._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserModel({
    required String id,
    required String email,
    String? phone,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @Default('user') String role,
    @JsonKey(name: 'subscription_tier') @Default('free') String subscriptionTier,
    @JsonKey(name: 'subscription_expires_at') DateTime? subscriptionExpiresAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  UserEntity toEntity() => UserEntity(
    id: id,
    email: email,
    phone: phone,
    fullName: fullName,
    avatarUrl: avatarUrl,
    role: UserRole.values.firstWhere(
      (e) => e.name == role,
      orElse: () => UserRole.user,
    ),
    subscriptionTier: SubscriptionTier.values.firstWhere(
      (e) => e.name == subscriptionTier,
      orElse: () => SubscriptionTier.free,
    ),
    subscriptionExpiresAt: subscriptionExpiresAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
    id: entity.id,
    email: entity.email,
    phone: entity.phone,
    fullName: entity.fullName,
    avatarUrl: entity.avatarUrl,
    role: entity.role.name,
    subscriptionTier: entity.subscriptionTier.name,
    subscriptionExpiresAt: entity.subscriptionExpiresAt,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );
}
