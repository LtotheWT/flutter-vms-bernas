import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/ref_department_entity.dart';
import 'package:vms_bernas/domain/entities/ref_entity_entity.dart';
import 'package:vms_bernas/domain/entities/ref_location_entity.dart';
import 'package:vms_bernas/domain/repositories/reference_repository.dart';
import 'package:vms_bernas/domain/usecases/get_departments_usecase.dart';
import 'package:vms_bernas/domain/usecases/get_entities_usecase.dart';
import 'package:vms_bernas/domain/usecases/get_locations_usecase.dart';

class _FakeReferenceRepository implements ReferenceRepository {
  String? capturedEntity;
  String? capturedLocationEntity;

  @override
  Future<List<RefEntityEntity>> getEntities() async {
    return const [RefEntityEntity(code: 'AGYTEK', name: 'AGYTEK - Agytek1231')];
  }

  @override
  Future<List<RefDepartmentEntity>> getDepartments({
    required String entity,
  }) async {
    capturedEntity = entity;
    return const [
      RefDepartmentEntity(code: 'ADC', description: 'ADC - ADMIN CENTER'),
    ];
  }

  @override
  Future<List<RefLocationEntity>> getLocations({required String entity}) async {
    capturedLocationEntity = entity;
    return const [
      RefLocationEntity(
        site: 'FACTORY1',
        siteDescription: 'FACTORY1 - FACTORY1 T',
      ),
    ];
  }
}

void main() {
  test('GetEntitiesUseCase returns entities from repository', () async {
    final repository = _FakeReferenceRepository();
    final useCase = GetEntitiesUseCase(repository);

    final result = await useCase();

    expect(result, hasLength(1));
    expect(result.first.code, 'AGYTEK');
  });

  test(
    'GetDepartmentsUseCase forwards entity and returns departments',
    () async {
      final repository = _FakeReferenceRepository();
      final useCase = GetDepartmentsUseCase(repository);

      final result = await useCase(entity: 'AGYTEK');

      expect(repository.capturedEntity, 'AGYTEK');
      expect(result, hasLength(1));
      expect(result.first.code, 'ADC');
    },
  );

  test('GetLocationsUseCase forwards entity and returns locations', () async {
    final repository = _FakeReferenceRepository();
    final useCase = GetLocationsUseCase(repository);

    final result = await useCase(entity: 'AGYTEK');

    expect(repository.capturedLocationEntity, 'AGYTEK');
    expect(result, hasLength(1));
    expect(result.first.site, 'FACTORY1');
  });
}
