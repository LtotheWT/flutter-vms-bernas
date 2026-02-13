import '../../domain/entities/invitation_submission_entity.dart';
import '../../domain/repositories/invitation_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/invitation_remote_data_source.dart';
import '../models/invitation_create_request_dto.dart';

class InvitationRepositoryImpl implements InvitationRepository {
  InvitationRepositoryImpl(this._remoteDataSource, this._authLocalDataSource);

  final InvitationRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;

  @override
  Future<InvitationSubmissionEntity> submitInvitation({
    required String idempotencyKey,
    required String entity,
    required String site,
    required String department,
    required String employeeId,
    required String visitorType,
    required String visitorName,
    required String purpose,
    required String email,
    required String visitFrom,
    required String visitTo,
  }) async {
    final session = await _authLocalDataSource.getSession();
    final accessToken = session?.accessToken.trim() ?? '';
    if (accessToken.isEmpty) {
      throw Exception('Please login again to submit invitation.');
    }

    final userId = session?.username.trim() ?? '';
    if (userId.isEmpty) {
      throw Exception('Please login again to submit invitation.');
    }

    final requestDto = InvitationCreateRequestDto(
      ccn: entity,
      userId: userId,
      site: site,
      dept: department,
      employee: employeeId,
      visitorType: visitorType,
      visitorName: visitorName,
      purpose: purpose,
      invitePurpose: purpose,
      email: email,
      visitFrom: _toIsoUtc(visitFrom),
      visitTo: _toIsoUtc(visitTo),
    );

    final response = await _remoteDataSource.submitInvitation(
      accessToken: accessToken,
      idempotencyKey: idempotencyKey,
      request: requestDto,
    );
    return response.toEntity();
  }

  String _toIsoUtc(String value) {
    final text = value.trim();
    final normalized = text.replaceFirst(' ', 'T');
    final parsed = DateTime.tryParse(normalized);
    if (parsed == null) {
      throw Exception('Invalid visit date/time format.');
    }
    return parsed.toUtc().toIso8601String();
  }
}
