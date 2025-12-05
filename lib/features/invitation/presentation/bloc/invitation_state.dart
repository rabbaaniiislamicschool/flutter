part of 'invitation_bloc.dart';

@freezed
class InvitationState with _$InvitationState {
  const factory InvitationState.initial() = _Initial;
  const factory InvitationState.loading() = _Loading;
  const factory InvitationState.loaded({
    required List<InvitationEntity> invitations,
    InvitationEntity? selectedInvitation,
  }) = _Loaded;
  const factory InvitationState.created({
    required InvitationEntity invitation,
  }) = _Created;
  const factory InvitationState.updated({
    required InvitationEntity invitation,
  }) = _Updated;
  const factory InvitationState.deleted({
    required String id,
  }) = _Deleted;
  const factory InvitationState.published({
    required InvitationEntity invitation,
  }) = _Published;
  const factory InvitationState.error({
    required Failure failure,
  }) = _Error;
}
