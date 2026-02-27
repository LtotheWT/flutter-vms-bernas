import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:vms_bernas/domain/entities/permanent_contractor_info_entity.dart';
import 'package:vms_bernas/domain/entities/ref_department_entity.dart';
import 'package:vms_bernas/domain/entities/ref_entity_entity.dart';
import 'package:vms_bernas/domain/entities/ref_location_entity.dart';
import 'package:vms_bernas/domain/entities/ref_personel_entity.dart';
import 'package:vms_bernas/domain/entities/ref_visitor_type_entity.dart';
import 'package:vms_bernas/domain/repositories/reference_repository.dart';
import 'package:vms_bernas/domain/usecases/get_permanent_contractor_info_usecase.dart';
import 'package:vms_bernas/presentation/pages/permanent_contractor_check_page.dart';
import 'package:vms_bernas/presentation/state/permanent_contractor_check_providers.dart';
import 'package:vms_bernas/presentation/state/reference_providers.dart';

class _FakeReferenceRepository implements ReferenceRepository {
  _FakeReferenceRepository({this.error, this.imageBytes});

  final Object? error;
  final Uint8List? imageBytes;

  @override
  Future<PermanentContractorInfoEntity> getPermanentContractorInfo({
    required String code,
  }) async {
    if (error != null) {
      throw error!;
    }
    return const PermanentContractorInfoEntity(
      contractorId: 'C0023',
      contractorName: 'Dylan Myer',
      contractorIc: '',
      hpNo: '0111111111',
      email: 'angypin8978@gmail.com',
      company: 'MMG (M) SDN BHD',
      validWorkingDateFrom: '2026-01-01T00:00:00',
      validWorkingDateTo: '2026-12-31T00:00:00',
    );
  }

  @override
  Future<List<RefEntityEntity>> getEntities() async => const [];

  @override
  Future<List<RefDepartmentEntity>> getDepartments({
    required String entity,
  }) async => const [];

  @override
  Future<List<RefLocationEntity>> getLocations({
    required String entity,
  }) async => const [];

  @override
  Future<List<RefPersonelEntity>> getPersonels({
    required String entity,
    required String site,
    required String department,
  }) async => const [];

  @override
  Future<List<RefVisitorTypeEntity>> getVisitorTypes() async => const [];

  @override
  Future<Uint8List?> getPermanentContractorImage({
    required String contractorId,
  }) async => imageBytes;
}

Widget _buildApp({required ReferenceRepository repository}) {
  return ProviderScope(
    overrides: [
      referenceRepositoryProvider.overrideWithValue(repository),
      getPermanentContractorInfoUseCaseProvider.overrideWithValue(
        GetPermanentContractorInfoUseCase(repository),
      ),
    ],
    child: const MaterialApp(
      home: PermanentContractorCheckPage(
        initialCheckType: PermanentContractorCheckType.checkOut,
      ),
    ),
  );
}

void main() {
  testWidgets('renders with preselected check type from route context', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp(repository: _FakeReferenceRepository()));
    await tester.pump();

    expect(find.text('Check-Out'), findsOneWidget);
  });

  testWidgets('search success shows info and clears input', (tester) async {
    await tester.pumpWidget(_buildApp(repository: _FakeReferenceRepository()));

    await tester.enterText(find.byType(TextFormField).first, 'CON|C0023||');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pump();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find
          .byKey(const Key('permanent-contractor-photo-thumbnail'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
    }

    expect(find.text('C0023'), findsOneWidget);
    expect(find.text('Dylan Myer'), findsOneWidget);
    expect(find.text('CON|C0023||'), findsNothing);
  });

  testWidgets('search failure shows error and keeps input', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        repository: _FakeReferenceRepository(error: Exception('failed')),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'CON|BAD||');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('failed'), findsOneWidget);
    expect(find.text('CON|BAD||'), findsOneWidget);
  });

  testWidgets('shows contractor image and opens fullscreen on tap', (
    tester,
  ) async {
    final repository = _FakeReferenceRepository(
      imageBytes: base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO5mWz8AAAAASUVORK5CYII=',
      ),
    );
    await tester.pumpWidget(_buildApp(repository: repository));

    await tester.enterText(find.byType(TextFormField).first, 'CON|C0023||');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('permanent-contractor-photo-thumbnail')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('permanent-contractor-photo-thumbnail')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.byKey(const Key('permanent-contractor-photo-fullscreen')),
      findsOneWidget,
    );
  });
}
