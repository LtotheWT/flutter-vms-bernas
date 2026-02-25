import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_result_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_submission_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_submission_item_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_lookup_entity.dart';
import 'package:vms_bernas/domain/repositories/visitor_access_repository.dart';
import 'package:vms_bernas/domain/usecases/submit_visitor_check_in_usecase.dart';
import 'package:vms_bernas/presentation/state/visitor_check_in_providers.dart';

class _FakeVisitorAccessRepository implements VisitorAccessRepository {
  _FakeVisitorAccessRepository({this.error, this.submitDelay});

  final Object? error;
  final Duration? submitDelay;
  VisitorCheckInSubmissionEntity? capturedSubmission;

  @override
  Future<VisitorCheckInResultEntity> submitVisitorCheckIn({
    required VisitorCheckInSubmissionEntity submission,
  }) async {
    capturedSubmission = submission;
    if (submitDelay != null) {
      await Future<void>.delayed(submitDelay!);
    }
    if (error != null) {
      throw error!;
    }
    return const VisitorCheckInResultEntity(
      success: true,
      message: 'Checked-in successfully.',
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

  test('submit success toggles loading and returns result', () async {
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
    expect(repository.capturedSubmission, submission);
    expect(result.success, isTrue);
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
    expect(result.success, isFalse);
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

    expect(firstResult.success, isTrue);
    expect(secondResult.success, isFalse);
    expect(secondResult.message, 'Check-in is currently submitting.');
  });
}
