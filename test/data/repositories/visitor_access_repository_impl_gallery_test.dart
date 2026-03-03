import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/auth_local_data_source.dart';
import 'package:vms_bernas/data/datasources/visitor_access_remote_data_source.dart';
import 'package:vms_bernas/data/models/auth_session_dto.dart';
import 'package:vms_bernas/data/models/visitor_gallery_item_dto.dart';
import 'package:vms_bernas/data/repositories/visitor_access_repository_impl.dart';

class _FakeAuthLocalDataSource extends AuthLocalDataSource {
  _FakeAuthLocalDataSource(this._session) : super(const FlutterSecureStorage());

  final AuthSessionDto? _session;

  @override
  Future<AuthSessionDto?> getSession() async => _session;
}

class _FakeVisitorAccessRemoteDataSource extends VisitorAccessRemoteDataSource {
  _FakeVisitorAccessRemoteDataSource() : super(Dio());

  String? capturedAccessToken;
  String? capturedInvitationId;
  int? capturedPhotoId;

  @override
  Future<List<VisitorGalleryItemDto>> getVisitorGalleryList({
    required String accessToken,
    required String invitationId,
  }) async {
    capturedAccessToken = accessToken;
    capturedInvitationId = invitationId;
    return const [
      VisitorGalleryItemDto(
        photoId: 29,
        photoDesc: 'string',
        url: '/visitor/photo/29',
      ),
    ];
  }

  @override
  Future<Uint8List?> getVisitorGalleryPhoto({
    required String accessToken,
    required int photoId,
  }) async {
    capturedAccessToken = accessToken;
    capturedPhotoId = photoId;
    return Uint8List.fromList([1, 2, 3]);
  }
}

void main() {
  test('throws when auth token is missing for gallery list', () async {
    final repository = VisitorAccessRepositoryImpl(
      _FakeVisitorAccessRemoteDataSource(),
      _FakeAuthLocalDataSource(null),
    );

    expect(
      () => repository.getVisitorGalleryList(invitationId: 'IV1'),
      throwsA(isA<Exception>()),
    );
  });

  test('maps gallery list items when session exists', () async {
    final remote = _FakeVisitorAccessRemoteDataSource();
    final repository = VisitorAccessRepositoryImpl(
      remote,
      _FakeAuthLocalDataSource(
        const AuthSessionDto(
          username: 'Ryan',
          fullname: 'Ryan',
          entity: "AGYTEK",
          accessToken: 'token123',
          defaultSite: 'FACTORY1',
          defaultGate: 'F1_A',
        ),
      ),
    );

    final items = await repository.getVisitorGalleryList(
      invitationId: 'IV20260300016',
    );

    expect(remote.capturedAccessToken, 'token123');
    expect(remote.capturedInvitationId, 'IV20260300016');
    expect(items.length, 1);
    expect(items.first.photoId, 29);
  });

  test('loads gallery photo bytes when session exists', () async {
    final remote = _FakeVisitorAccessRemoteDataSource();
    final repository = VisitorAccessRepositoryImpl(
      remote,
      _FakeAuthLocalDataSource(
        const AuthSessionDto(
          username: 'Ryan',
          fullname: 'Ryan',
          entity: "AGYTEK",
          accessToken: 'token123',
          defaultSite: 'FACTORY1',
          defaultGate: 'F1_A',
        ),
      ),
    );

    final bytes = await repository.getVisitorGalleryPhoto(photoId: 29);
    expect(remote.capturedPhotoId, 29);
    expect(bytes, [1, 2, 3]);
  });
}
