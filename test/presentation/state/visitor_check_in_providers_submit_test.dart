import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_result_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_submission_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_submission_item_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_gallery_item_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_lookup_entity.dart';
import 'package:vms_bernas/domain/repositories/visitor_access_repository.dart';
import 'package:vms_bernas/domain/usecases/submit_visitor_check_in_usecase.dart';
import 'package:vms_bernas/domain/usecases/submit_visitor_check_out_usecase.dart';
import 'package:vms_bernas/presentation/state/visitor_check_in_providers.dart';

class _FakeVisitorAccessRepository implements VisitorAccessRepository {
  _FakeVisitorAccessRepository({this.error, this.submitDelay});

  final Object? error;
  final Duration? submitDelay;
  VisitorCheckInSubmissionEntity? capturedCheckInSubmission;
  VisitorCheckInSubmissionEntity? capturedCheckOutSubmission;

  @override
  Future<VisitorCheckInResultEntity> submitVisitorCheckIn({
    required VisitorCheckInSubmissionEntity submission,
  }) async {
    capturedCheckInSubmission = submission;
    if (submitDelay != null) {
      await Future<void>.delayed(submitDelay!);
    }
    if (error != null) {
      throw error!;
    }
    return const VisitorCheckInResultEntity(
      status: true,
      message: 'Checked-in successfully.',
    );
  }

  @override
  Future<VisitorCheckInResultEntity> submitVisitorCheckOut({
    required VisitorCheckInSubmissionEntity submission,
  }) async {
    capturedCheckOutSubmission = submission;
    if (submitDelay != null) {
      await Future<void>.delayed(submitDelay!);
    }
    if (error != null) {
      throw error!;
    }
    return const VisitorCheckInResultEntity(
      status: true,
      message: 'Checked-out successfully.',
    );
  }

  @override
  Future<VisitorLookupEntity> getVisitorLookup({
    required String code,
    required bool isCheckIn,
  }) async {
    throw UnimplementedError();
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
}

void main() {
  const submission = VisitorCheckInSubmissionEntity(
    userId: 'Ryan',
    entity: 'AGYTEK',
    site: 'FACTORY1',
    gate: 'F1_A',
    invitationId: 'IV20260200038',
    visitors: [
      VisitorCheckInSubmissionItemEntity(
        appId: '123456561231',
        physicalTag: '',
      ),
    ],
  );

  test('submit status toggles loading and returns result', () async {
    final repository = _FakeVisitorAccessRepository();
    final container = ProviderContainer(
      overrides: [
        submitVisitorCheckInUseCaseProvider.overrideWithValue(
          SubmitVisitorCheckInUseCase(repository),
        ),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen<VisitorCheckState>(
      visitorCheckControllerProvider,
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);

    final controller = container.read(visitorCheckControllerProvider.notifier);
    final result = await controller.submitCheckIn(submission: submission);

    final state = container.read(visitorCheckControllerProvider);
    expect(repository.capturedCheckInSubmission, submission);
    expect(result.status, isTrue);
    expect(state.isSubmitting, isFalse);
    expect(state.errorMessage, isNull);
  });

  test('submit failure returns error and sets state errorMessage', () async {
    final repository = _FakeVisitorAccessRepository(error: Exception('failed'));
    final container = ProviderContainer(
      overrides: [
        submitVisitorCheckInUseCaseProvider.overrideWithValue(
          SubmitVisitorCheckInUseCase(repository),
        ),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen<VisitorCheckState>(
      visitorCheckControllerProvider,
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);

    final controller = container.read(visitorCheckControllerProvider.notifier);
    final result = await controller.submitCheckIn(submission: submission);

    final state = container.read(visitorCheckControllerProvider);
    expect(result.status, isFalse);
    expect(result.message, 'failed');
    expect(state.errorMessage, 'failed');
    expect(state.isSubmitting, isFalse);
  });

  test('submit loading guard prevents duplicate submit', () async {
    final repository = _FakeVisitorAccessRepository(
      submitDelay: const Duration(milliseconds: 150),
    );
    final container = ProviderContainer(
      overrides: [
        submitVisitorCheckInUseCaseProvider.overrideWithValue(
          SubmitVisitorCheckInUseCase(repository),
        ),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen<VisitorCheckState>(
      visitorCheckControllerProvider,
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);

    final controller = container.read(visitorCheckControllerProvider.notifier);
    final firstFuture = controller.submitCheckIn(submission: submission);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    final secondResult = await controller.submitCheckIn(submission: submission);
    final firstResult = await firstFuture;

    expect(firstResult.status, isTrue);
    expect(secondResult.status, isFalse);
    expect(secondResult.message, 'Check-in is currently submitting.');
  });

  test('submit check-out status toggles loading and returns result', () async {
    final repository = _FakeVisitorAccessRepository();
    final container = ProviderContainer(
      overrides: [
        submitVisitorCheckOutUseCaseProvider.overrideWithValue(
          SubmitVisitorCheckOutUseCase(repository),
        ),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen<VisitorCheckState>(
      visitorCheckControllerProvider,
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);

    final controller = container.read(visitorCheckControllerProvider.notifier);
    final result = await controller.submitCheckOut(submission: submission);

    final state = container.read(visitorCheckControllerProvider);
    expect(repository.capturedCheckOutSubmission, submission);
    expect(result.status, isTrue);
    expect(state.isSubmitting, isFalse);
    expect(state.errorMessage, isNull);
  });

  test(
    'submit check-out failure returns error and sets state errorMessage',
    () async {
      final repository = _FakeVisitorAccessRepository(
        error: Exception('failed'),
      );
      final container = ProviderContainer(
        overrides: [
          submitVisitorCheckOutUseCaseProvider.overrideWithValue(
            SubmitVisitorCheckOutUseCase(repository),
          ),
        ],
      );
      addTearDown(container.dispose);
      final sub = container.listen<VisitorCheckState>(
        visitorCheckControllerProvider,
        (_, __) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      final controller = container.read(
        visitorCheckControllerProvider.notifier,
      );
      final result = await controller.submitCheckOut(submission: submission);

      final state = container.read(visitorCheckControllerProvider);
      expect(result.status, isFalse);
      expect(result.message, 'failed');
      expect(state.errorMessage, 'failed');
      expect(state.isSubmitting, isFalse);
    },
  );

  test('submit check-out loading guard prevents duplicate submit', () async {
    final repository = _FakeVisitorAccessRepository(
      submitDelay: const Duration(milliseconds: 150),
    );
    final container = ProviderContainer(
      overrides: [
        submitVisitorCheckOutUseCaseProvider.overrideWithValue(
          SubmitVisitorCheckOutUseCase(repository),
        ),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen<VisitorCheckState>(
      visitorCheckControllerProvider,
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);

    final controller = container.read(visitorCheckControllerProvider.notifier);
    final firstFuture = controller.submitCheckOut(submission: submission);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    final secondResult = await controller.submitCheckOut(
      submission: submission,
    );
    final firstResult = await firstFuture;

    expect(firstResult.status, isTrue);
    expect(secondResult.status, isFalse);
    expect(secondResult.message, 'Check-out is currently submitting.');
  });
}
