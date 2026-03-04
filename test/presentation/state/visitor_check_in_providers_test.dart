import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vms_bernas/domain/entities/visitor_lookup_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_lookup_item_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_result_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_submission_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_delete_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_gallery_item_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_save_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_save_photo_submission_entity.dart';
import 'package:vms_bernas/domain/repositories/visitor_access_repository.dart';
import 'package:vms_bernas/domain/usecases/get_visitor_lookup_usecase.dart';
import 'package:vms_bernas/presentation/state/visitor_check_in_providers.dart';

class _FakeVisitorAccessRepository implements VisitorAccessRepository {
  _FakeVisitorAccessRepository({this.error});

  final Object? error;
  String? capturedCode;
  bool? capturedCheckIn;

  @override
  Future<VisitorLookupEntity> getVisitorLookup({
    required String code,
    required bool isCheckIn,
  }) async {
    capturedCode = code;
    capturedCheckIn = isCheckIn;
    if (error != null) {
      throw error!;
    }
    return const VisitorLookupEntity(
      invitationId: 'IV1',
      entity: 'AGYTEK',
      site: 'FACTORY1',
      siteDesc: 'FACTORY1 T',
      department: 'ADC',
      departmentDesc: 'ADMIN CENTER',
      purpose: 'MEETING',
      company: 'TEST',
      contactNumber: '0123',
      visitorType: '1_Visitor',
      inviteBy: 'Suraya',
      workLevel: '',
      vehiclePlateNumber: 'WWW0000',
      status: 'ARRIVED',
      visitDateFrom: '2026-02-25T00:00:00',
      visitDateTo: '2026-02-25T00:00:00',
      visitTimeFrom: '19:00:PM',
      visitTimeTo: '20:00:PM',
      visitors: [
        VisitorLookupItemEntity(
          name: 'NAME',
          icPassport: '123',
          physicalTag: '',
          email: '',
          contactNo: '',
          company: '',
          checkInTime: '',
          checkOutTime: '',
        ),
      ],
    );
  }

  @override
  Future<VisitorCheckInResultEntity> submitVisitorCheckIn({
    required VisitorCheckInSubmissionEntity submission,
  }) async {
    return const VisitorCheckInResultEntity(status: true, message: 'ok');
  }

  @override
  Future<VisitorCheckInResultEntity> submitVisitorCheckOut({
    required VisitorCheckInSubmissionEntity submission,
  }) async {
    return const VisitorCheckInResultEntity(status: true, message: 'ok');
  }

  @override
  Future<Uint8List?> getVisitorApplicantImage({
    required String invitationId,
    required String appId,
  }) async {
    return null;
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

  @override
  Future<VisitorDeletePhotoResultEntity> deleteVisitorGalleryPhoto({
    required int photoId,
  }) async {
    return const VisitorDeletePhotoResultEntity(success: true, message: 'ok');
  }
}

void main() {
  test('search status clears input and sets lookup', () async {
    final repository = _FakeVisitorAccessRepository();
    final container = ProviderContainer(
      overrides: [
        getVisitorLookupUseCaseProvider.overrideWithValue(
          GetVisitorLookupUseCase(repository),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(visitorCheckControllerProvider.notifier);

    controller.updateSearchInput('VIS|IV1|A|F');
    final ok = await controller.search(isCheckIn: true);

    final state = container.read(visitorCheckControllerProvider);
    expect(ok, isTrue);
    expect(repository.capturedCode, 'VIS|IV1|A|F');
    expect(repository.capturedCheckIn, isTrue);
    expect(state.searchInput, isEmpty);
    expect(state.lookup?.invitationId, 'IV1');
    expect(state.errorMessage, isNull);
  });

  test('search failure keeps input and sets error', () async {
    final repository = _FakeVisitorAccessRepository(
      error: Exception('bad code'),
    );
    final container = ProviderContainer(
      overrides: [
        getVisitorLookupUseCaseProvider.overrideWithValue(
          GetVisitorLookupUseCase(repository),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(visitorCheckControllerProvider.notifier);

    controller.updateSearchInput('VIS|BAD|A|F');
    final ok = await controller.search(isCheckIn: false);

    final state = container.read(visitorCheckControllerProvider);
    expect(ok, isFalse);
    expect(state.searchInput, 'VIS|BAD|A|F');
    expect(state.errorMessage, 'bad code');
  });

  test('loading guard blocks duplicate search', () async {
    final repository = _FakeVisitorAccessRepository();
    final container = ProviderContainer(
      overrides: [
        getVisitorLookupUseCaseProvider.overrideWithValue(
          GetVisitorLookupUseCase(repository),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(visitorCheckControllerProvider.notifier);
    controller.updateSearchInput('VIS|IV1|A|F');

    final first = controller.search(isCheckIn: true);
    final second = await controller.search(isCheckIn: true);

    expect(await first, isTrue);
    expect(second, isFalse);
  });
}
