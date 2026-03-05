import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/auth_local_data_source.dart';
import 'package:vms_bernas/data/datasources/visitor_access_remote_data_source.dart';
import 'package:vms_bernas/data/models/auth_session_dto.dart';
import 'package:vms_bernas/data/models/visitor_delete_photo_response_dto.dart';
import 'package:vms_bernas/data/repositories/visitor_access_repository_impl.dart';

class _FakeAuthLocalDataSource extends AuthLocalDataSource {
  _FakeAuthLocalDataSource(this._session) : super(const FlutterSecureStorage());

  final AuthSessionDto? _session;

  @override
  Future<AuthSessionDto?> getSession() async => _session;
}

class _FakeVisitorAccessRemoteDataSource extends VisitorAccessRemoteDataSource {
  _FakeVisitorAccessRemoteDataSource() : super(Dio());

  String? capturedToken;
  int? capturedPhotoId;

  @override
  Future<VisitorDeletePhotoResponseDto> deleteVisitorGalleryPhoto({
    required String accessToken,
    required int photoId,
  }) async {
    capturedToken = accessToken;
    capturedPhotoId = photoId;
    return const VisitorDeletePhotoResponseDto(
      status: true,
      message: 'Deleted',
    );
  }
}

void main() {
  test('throws when token missing', () async {
    final repository = VisitorAccessRepositoryImpl(
      _FakeVisitorAccessRemoteDataSource(),
      _FakeAuthLocalDataSource(null),
    );

    expect(
      () => repository.deleteVisitorGalleryPhoto(photoId: 1),
      throwsA(isA<Exception>()),
    );
  });

  test('maps delete response', () async {
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

    final result = await repository.deleteVisitorGalleryPhoto(photoId: 32);
    expect(remote.capturedToken, 'token123');
    expect(remote.capturedPhotoId, 32);
    expect(result.success, isTrue);
    expect(result.message, 'Deleted');
  });
}
