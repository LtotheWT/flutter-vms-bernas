import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_result_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_submission_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_delete_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_gallery_item_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_lookup_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_save_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_save_photo_submission_entity.dart';
import 'package:vms_bernas/domain/repositories/visitor_access_repository.dart';
import 'package:vms_bernas/presentation/state/visitor_check_in_providers.dart';

class _FakeVisitorAccessRepository implements VisitorAccessRepository {
  int galleryListCallCount = 0;
  int galleryPhotoCallCount = 0;
  Object? galleryListError;
  final List<VisitorGalleryItemEntity> galleryItems = const [
    VisitorGalleryItemEntity(
      photoId: 29,
      photoDesc: 'string',
      url: '/visitor/photo/29',
    ),
  ];
  final Map<int, Uint8List?> photoById = <int, Uint8List?>{};

  @override
  Future<List<VisitorGalleryItemEntity>> getVisitorGalleryList({
    required String invitationId,
  }) async {
    galleryListCallCount += 1;
    if (galleryListError != null) {
      throw galleryListError!;
    }
    return galleryItems;
  }

  @override
  Future<Uint8List?> getVisitorGalleryPhoto({required int photoId}) async {
    galleryPhotoCallCount += 1;
    return photoById[photoId];
  }

  @override
  Future<Uint8List?> getVisitorApplicantImage({
    required String invitationId,
    required String appId,
  }) async => null;

  @override
  Future<VisitorLookupEntity> getVisitorLookup({
    required String code,
    required bool isCheckIn,
  }) async => throw UnimplementedError();

  @override
  Future<VisitorCheckInResultEntity> submitVisitorCheckIn({
    required VisitorCheckInSubmissionEntity submission,
  }) async => throw UnimplementedError();

  @override
  Future<VisitorCheckInResultEntity> submitVisitorCheckOut({
    required VisitorCheckInSubmissionEntity submission,
  }) async => throw UnimplementedError();

  @override
  Future<VisitorSavePhotoResultEntity> saveVisitorPhoto({
    required VisitorSavePhotoSubmissionEntity submission,
  }) async => const VisitorSavePhotoResultEntity(
    success: true,
    message: 'ok',
    photoId: 1,
  );

  @override
  Future<VisitorDeletePhotoResultEntity> deleteVisitorGalleryPhoto({
    required int photoId,
  }) async => const VisitorDeletePhotoResultEntity(
    success: true,
    message: 'deleted',
  );
}

void main() {
  test(
    'gallery list provider returns empty when invitationId is blank',
    () async {
      final repository = _FakeVisitorAccessRepository();
      final container = ProviderContainer(
        overrides: [
          visitorAccessRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen<AsyncValue<List<VisitorGalleryItemEntity>>>(
        visitorGalleryListProvider(' '),
        (_, __) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      await Future<void>.delayed(Duration.zero);
      expect(sub.read().value, isEmpty);
      expect(repository.galleryListCallCount, 0);
    },
  );

  test('gallery list provider surfaces repository error', () async {
    final repository = _FakeVisitorAccessRepository()
      ..galleryListError = Exception('gallery failed');
    final container = ProviderContainer(
      overrides: [
        visitorAccessRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final subscription = container
        .listen<AsyncValue<List<VisitorGalleryItemEntity>>>(
          visitorGalleryListProvider('IV1'),
          (_, __) {},
          fireImmediately: true,
        );
    addTearDown(subscription.close);

    await Future<void>.delayed(Duration.zero);
    expect(subscription.read().hasError, isTrue);
  });

  test(
    'gallery photo provider uses in-memory cache for same photoId',
    () async {
      final repository = _FakeVisitorAccessRepository()
        ..photoById[29] = Uint8List.fromList([1, 2, 3]);
      final container = ProviderContainer(
        overrides: [
          visitorAccessRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final first = await container.read(
        visitorGalleryPhotoProvider(
          const VisitorGalleryPhotoKey(photoId: 29),
        ).future,
      );
      container.invalidate(
        visitorGalleryPhotoProvider(const VisitorGalleryPhotoKey(photoId: 29)),
      );
      final second = await container.read(
        visitorGalleryPhotoProvider(
          const VisitorGalleryPhotoKey(photoId: 29),
        ).future,
      );

      expect(first, [1, 2, 3]);
      expect(second, [1, 2, 3]);
      expect(repository.galleryPhotoCallCount, 1);
    },
  );

  test('gallery local items append/remove updates local state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(visitorGalleryLocalItemsProvider.notifier).append(
      invitationId: 'IV1',
      item: const VisitorGalleryItemEntity(
        photoId: 99,
        photoDesc: 'new',
        url: '/visitor/photo/99',
      ),
    );
    var map = container.read(visitorGalleryLocalItemsProvider);
    expect(map['IV1']?.first.photoId, 99);

    container.read(visitorGalleryLocalItemsProvider.notifier).remove(
      invitationId: 'IV1',
      photoId: 99,
    );
    map = container.read(visitorGalleryLocalItemsProvider);
    expect(map['IV1'], isNull);
  });
}
