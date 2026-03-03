import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_result_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_submission_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_gallery_item_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_save_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_save_photo_submission_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_lookup_entity.dart';
import 'package:vms_bernas/domain/repositories/visitor_access_repository.dart';
import 'package:vms_bernas/presentation/state/visitor_check_in_providers.dart';

class _FakeVisitorAccessRepository implements VisitorAccessRepository {
  int imageCallCount = 0;
  final Map<String, Uint8List?> imageByKey = <String, Uint8List?>{};

  @override
  Future<Uint8List?> getVisitorApplicantImage({
    required String invitationId,
    required String appId,
  }) async {
    imageCallCount += 1;
    return imageByKey['$invitationId|$appId'];
  }

  @override
  Future<VisitorLookupEntity> getVisitorLookup({
    required String code,
    required bool isCheckIn,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<VisitorCheckInResultEntity> submitVisitorCheckIn({
    required VisitorCheckInSubmissionEntity submission,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<VisitorCheckInResultEntity> submitVisitorCheckOut({
    required VisitorCheckInSubmissionEntity submission,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<VisitorGalleryItemEntity>> getVisitorGalleryList({
    required String invitationId,
  }) async {
    return const <VisitorGalleryItemEntity>[];
  }

  @override
  Future<Uint8List?> getVisitorGalleryPhoto({required int photoId}) async {
    return null;
  }

  @override
  Future<VisitorSavePhotoResultEntity> saveVisitorPhoto({
    required VisitorSavePhotoSubmissionEntity submission,
  }) async {
    return const VisitorSavePhotoResultEntity(
      success: true,
      message: 'ok',
      photoId: 1,
    );
  }
}

void main() {
  test('returns null without fetch when appId is empty', () async {
    final repository = _FakeVisitorAccessRepository();
    final container = ProviderContainer(
      overrides: [
        visitorAccessRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      visitorApplicantImageProvider(
        const VisitorPhotoKey(invitationId: 'IV1', appId: ''),
      ).future,
    );
    expect(result, isNull);
    expect(repository.imageCallCount, 0);
  });

  test('uses in-memory cache for same key', () async {
    final repository = _FakeVisitorAccessRepository();
    repository.imageByKey['IV1|APP1'] = Uint8List.fromList([1, 2, 3]);
    final container = ProviderContainer(
      overrides: [
        visitorAccessRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final first = await container.read(
      visitorApplicantImageProvider(
        const VisitorPhotoKey(invitationId: 'IV1', appId: 'APP1'),
      ).future,
    );
    container.invalidate(
      visitorApplicantImageProvider(
        const VisitorPhotoKey(invitationId: 'IV1', appId: 'APP1'),
      ),
    );
    final second = await container.read(
      visitorApplicantImageProvider(
        const VisitorPhotoKey(invitationId: 'IV1', appId: 'APP1'),
      ).future,
    );

    expect(first, [1, 2, 3]);
    expect(second, [1, 2, 3]);
    expect(repository.imageCallCount, 1);
  });

  test('different key triggers another fetch', () async {
    final repository = _FakeVisitorAccessRepository();
    repository.imageByKey['IV1|APP1'] = Uint8List.fromList([1]);
    repository.imageByKey['IV1|APP2'] = Uint8List.fromList([2]);
    final container = ProviderContainer(
      overrides: [
        visitorAccessRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(
      visitorApplicantImageProvider(
        const VisitorPhotoKey(invitationId: 'IV1', appId: 'APP1'),
      ).future,
    );
    await container.read(
      visitorApplicantImageProvider(
        const VisitorPhotoKey(invitationId: 'IV1', appId: 'APP2'),
      ).future,
    );

    expect(repository.imageCallCount, 2);
  });
}
