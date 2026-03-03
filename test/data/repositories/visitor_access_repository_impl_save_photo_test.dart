import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/auth_local_data_source.dart';
import 'package:vms_bernas/data/datasources/visitor_access_remote_data_source.dart';
import 'package:vms_bernas/data/models/auth_session_dto.dart';
import 'package:vms_bernas/data/models/visitor_save_photo_request_dto.dart';
import 'package:vms_bernas/data/models/visitor_save_photo_response_dto.dart';
import 'package:vms_bernas/data/repositories/visitor_access_repository_impl.dart';
import 'package:vms_bernas/domain/entities/visitor_save_photo_submission_entity.dart';

class _FakeAuthLocalDataSource extends AuthLocalDataSource {
  _FakeAuthLocalDataSource(this._session) : super(const FlutterSecureStorage());

  final AuthSessionDto? _session;

  @override
  Future<AuthSessionDto?> getSession() async => _session;
}

class _FakeVisitorAccessRemoteDataSource extends VisitorAccessRemoteDataSource {
  _FakeVisitorAccessRemoteDataSource() : super(Dio());

  String? capturedAccessToken;
  VisitorSavePhotoRequestDto? capturedRequest;

  @override
  Future<VisitorSavePhotoResponseDto> saveVisitorPhoto({
    required String accessToken,
    required VisitorSavePhotoRequestDto request,
  }) async {
    capturedAccessToken = accessToken;
    capturedRequest = request;
    return const VisitorSavePhotoResponseDto(
      success: true,
      message: 'Photo saved successfully',
      photoId: 88,
    );
  }
}

void main() {
  test('throws when token is missing for save photo', () async {
    final repository = VisitorAccessRepositoryImpl(
      _FakeVisitorAccessRemoteDataSource(),
      _FakeAuthLocalDataSource(null),
    );

    expect(
      () => repository.saveVisitorPhoto(
        submission: const VisitorSavePhotoSubmissionEntity(
          imageBase64: 'abc',
          photoDescription: '',
          invitationId: 'IV20260300016',
          entity: 'AGYTEK',
          site: 'FACTORY1',
          uploadedBy: 'Ryan',
        ),
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('maps save photo result when token exists', () async {
    final remote = _FakeVisitorAccessRemoteDataSource();
    final repository = VisitorAccessRepositoryImpl(
      remote,
      _FakeAuthLocalDataSource(
        const AuthSessionDto(
          username: 'Ryan',
          fullname: 'Ryan',
          entity: 'AGYTEK',
          accessToken: 'token123',
          defaultSite: 'FACTORY1',
          defaultGate: 'F1_A',
        ),
      ),
    );

    final result = await repository.saveVisitorPhoto(
      submission: const VisitorSavePhotoSubmissionEntity(
        imageBase64: 'abc',
        photoDescription: 'desc',
        invitationId: 'IV20260300016',
        entity: 'AGYTEK',
        site: 'FACTORY1',
        uploadedBy: 'Ryan',
      ),
    );

    expect(remote.capturedAccessToken, 'token123');
    expect(remote.capturedRequest?.invitationId, 'IV20260300016');
    expect(result.success, isTrue);
    expect(result.message, 'Photo saved successfully');
    expect(result.photoId, 88);
  });
}
