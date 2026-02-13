import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/reference_remote_data_source.dart';
import '../../data/repositories/reference_repository_impl.dart';
import '../../domain/repositories/reference_repository.dart';
import '../../domain/usecases/get_departments_usecase.dart';
import '../../domain/usecases/get_entities_usecase.dart';
import '../../domain/usecases/get_locations_usecase.dart';
import '../../domain/usecases/get_personels_usecase.dart';
import '../../domain/usecases/get_visitor_types_usecase.dart';
import 'auth_session_providers.dart';
import 'department_option.dart';
import 'entity_option.dart';
import 'host_option.dart';
import 'site_option.dart';
import 'visitor_type_option.dart';

final referenceRemoteDataSourceProvider = Provider<ReferenceRemoteDataSource>((
  ref,
) {
  final dio = ref.read(dioClientProvider);
  return ReferenceRemoteDataSource(dio);
});

final referenceRepositoryProvider = Provider<ReferenceRepository>((ref) {
  final remoteDataSource = ref.read(referenceRemoteDataSourceProvider);
  final localDataSource = ref.read(authLocalDataSourceProvider);
  return ReferenceRepositoryImpl(remoteDataSource, localDataSource);
});

final getEntitiesUseCaseProvider = Provider<GetEntitiesUseCase>((ref) {
  final repository = ref.read(referenceRepositoryProvider);
  return GetEntitiesUseCase(repository);
});

final getDepartmentsUseCaseProvider = Provider<GetDepartmentsUseCase>((ref) {
  final repository = ref.read(referenceRepositoryProvider);
  return GetDepartmentsUseCase(repository);
});

final getLocationsUseCaseProvider = Provider<GetLocationsUseCase>((ref) {
  final repository = ref.read(referenceRepositoryProvider);
  return GetLocationsUseCase(repository);
});

final getPersonelsUseCaseProvider = Provider<GetPersonelsUseCase>((ref) {
  final repository = ref.read(referenceRepositoryProvider);
  return GetPersonelsUseCase(repository);
});

final getVisitorTypesUseCaseProvider = Provider<GetVisitorTypesUseCase>((ref) {
  final repository = ref.read(referenceRepositoryProvider);
  return GetVisitorTypesUseCase(repository);
});

final entityOptionsProvider = FutureProvider.autoDispose<List<EntityOption>>((
  ref,
) async {
  final useCase = ref.read(getEntitiesUseCaseProvider);
  final entities = await useCase();

  return entities
      .map((entity) => EntityOption(value: entity.code, label: entity.name))
      .toList(growable: false);
}, retry: (_, __) => null);

final departmentOptionsProvider = FutureProvider.autoDispose
    .family<List<DepartmentOption>, String?>((ref, entity) async {
      final entityCode = entity?.trim() ?? '';
      if (entityCode.isEmpty) {
        return const <DepartmentOption>[];
      }

      final useCase = ref.read(getDepartmentsUseCaseProvider);
      final departments = await useCase(entity: entityCode);

      return departments
          .map(
            (department) => DepartmentOption(
              value: department.code,
              label: department.description,
            ),
          )
          .toList(growable: false);
    }, retry: (_, __) => null);

final siteOptionsProvider = FutureProvider.autoDispose
    .family<List<SiteOption>, String?>((ref, entity) async {
      final entityCode = entity?.trim() ?? '';
      if (entityCode.isEmpty) {
        return const <SiteOption>[];
      }

      final useCase = ref.read(getLocationsUseCaseProvider);
      final locations = await useCase(entity: entityCode);

      return locations
          .map(
            (location) => SiteOption(
              value: location.site,
              label: location.siteDescription,
            ),
          )
          .toList(growable: false);
    }, retry: (_, __) => null);

@immutable
class HostLookupParams extends Equatable {
  const HostLookupParams({
    required this.entity,
    required this.site,
    required this.department,
  });

  final String? entity;
  final String? site;
  final String? department;

  @override
  List<Object?> get props => [entity, site, department];
}

final hostOptionsProvider = FutureProvider.autoDispose
    .family<List<HostOption>, HostLookupParams>((ref, params) async {
      final entityCode = params.entity?.trim() ?? '';
      final siteCode = params.site?.trim() ?? '';
      final departmentCode = params.department?.trim() ?? '';
      if (entityCode.isEmpty || siteCode.isEmpty || departmentCode.isEmpty) {
        return const <HostOption>[];
      }

      final useCase = ref.read(getPersonelsUseCaseProvider);
      final personels = await useCase(
        entity: entityCode,
        site: siteCode,
        department: departmentCode,
      );

      return personels
          .map(
            (personel) => HostOption(
              value: personel.employeeId,
              label: personel.employeeName,
            ),
          )
          .toList(growable: false);
    }, retry: (_, __) => null);

final visitorTypeOptionsProvider =
    FutureProvider.autoDispose<List<VisitorTypeOption>>((ref) async {
      final useCase = ref.read(getVisitorTypesUseCaseProvider);
      final visitorTypes = await useCase();

      return visitorTypes
          .map(
            (visitorType) => VisitorTypeOption(
              value: visitorType.visitorType,
              label: visitorType.typeDescription,
            ),
          )
          .toList(growable: false);
    }, retry: (_, __) => null);
