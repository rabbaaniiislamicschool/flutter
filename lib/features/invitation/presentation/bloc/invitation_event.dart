part of 'invitation_bloc.dart';

@freezed
class InvitationEvent with _$InvitationEvent {
  const factory InvitationEvent.loadInvitations() = _LoadInvitations;
  const factory InvitationEvent.createInvitation({
    required CreateInvitationParams params,
  }) = _CreateInvitation;
  const factory InvitationEvent.updateInvitation({
    required String id,
    required UpdateInvitationParams params,
  }) = _UpdateInvitation;
  const factory InvitationEvent.deleteInvitation({
    required String id,
  }) = _DeleteInvitation;
  const factory InvitationEvent.publishInvitation({
    required String id,
  }) = _PublishInvitation;
  const factory InvitationEvent.selectInvitation({
    required InvitationEntity invitation,
  }) = _SelectInvitation;
}
