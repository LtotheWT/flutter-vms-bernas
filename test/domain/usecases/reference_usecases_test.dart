import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/ref_department_entity.dart';
import 'package:vms_bernas/domain/entities/ref_entity_entity.dart';
import 'package:vms_bernas/domain/entities/ref_location_entity.dart';
import 'package:vms_bernas/domain/entities/ref_personel_entity.dart';
import 'package:vms_bernas/domain/entities/ref_visitor_type_entity.dart';
import 'package:vms_bernas/domain/repositories/reference_repository.dart';
import 'package:vms_bernas/domain/usecases/get_departments_usecase.dart';
import 'package:vms_bernas/domain/usecases/get_entities_usecase.dart';
import 'package:vms_bernas/domain/usecases/get_locations_usecase.dart';
import 'package:vms_bernas/domain/usecases/get_personels_usecase.dart';
import 'package:vms_bernas/domain/usecases/get_visitor_types_usecase.dart';

class _FakeReferenceRepository implements ReferenceRepository {
  String? capturedEntity;
  String? capturedLocationEntity;
  String? capturedPersonelEntity;
  String? capturedPersonelSite;
  String? capturedPersonelDepartment;

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

  @override
  Future<List<RefPersonelEntity>> getPersonels({
    required String entity,
    required String site,
    required String department,
  }) async {
    capturedPersonelEntity = entity;
    capturedPersonelSite = site;
    capturedPersonelDepartment = department;
    return const [
      RefPersonelEntity(
        employeeId: 'EMP0001',
        employeeName: 'Suraya',
        department: 'ADC',
        entity: 'AGYTEK',
      ),
    ];
  }

  @override
  Future<List<RefVisitorTypeEntity>> getVisitorTypes() async {
    return const [
      RefVisitorTypeEntity(
        visitorType: '1_Visitor',
        typeDescription: 'Visitor/Vendor/Forwarder',
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

  test('GetPersonelsUseCase forwards filters and returns hosts', () async {
    final repository = _FakeReferenceRepository();
    final useCase = GetPersonelsUseCase(repository);

    final result = await useCase(
      entity: 'AGYTEK',
      site: 'FACTORY1',
      department: 'ADC',
    );

    expect(repository.capturedPersonelEntity, 'AGYTEK');
    expect(repository.capturedPersonelSite, 'FACTORY1');
    expect(repository.capturedPersonelDepartment, 'ADC');
    expect(result, hasLength(1));
    expect(result.first.employeeId, 'EMP0001');
  });

  test('GetVisitorTypesUseCase returns visitor types', () async {
    final repository = _FakeReferenceRepository();
    final useCase = GetVisitorTypesUseCase(repository);

    final result = await useCase();

    expect(result, hasLength(1));
    expect(result.first.visitorType, '1_Visitor');
  });
}
