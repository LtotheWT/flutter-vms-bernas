import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/reference_remote_data_source.dart';
import '../../data/repositories/reference_repository_impl.dart';
import '../../domain/repositories/reference_repository.dart';
import '../../domain/usecases/get_departments_usecase.dart';
import '../../domain/usecases/get_entities_usecase.dart';
import '../../domain/usecases/get_locations_usecase.dart';
import 'auth_session_providers.dart';
import 'department_option.dart';
import 'entity_option.dart';
import 'site_option.dart';

const Object _unset = Object();

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
class InvitationAddState {
  const InvitationAddState({
    this.entity,
    this.site,
    this.department,
    this.personToVisit,
    this.visitorType,
    this.companyName = '',
    this.purpose = '',
    this.email = '',
    this.dateFrom = '',
    this.dateTo = '',
    this.isSubmitting = false,
  });

  final String? entity;
  final String? site;
  final String? department;
  final String? personToVisit;
  final String? visitorType;
  final String companyName;
  final String purpose;
  final String email;
  final String dateFrom;
  final String dateTo;
  final bool isSubmitting;

  InvitationAddState copyWith({
    Object? entity = _unset,
    Object? site = _unset,
    Object? department = _unset,
    Object? personToVisit = _unset,
    Object? visitorType = _unset,
    String? companyName,
    String? purpose,
    String? email,
    String? dateFrom,
    String? dateTo,
    bool? isSubmitting,
  }) {
    return InvitationAddState(
      entity: entity == _unset ? this.entity : entity as String?,
      site: site == _unset ? this.site : site as String?,
      department: department == _unset
          ? this.department
          : department as String?,
      personToVisit: personToVisit == _unset
          ? this.personToVisit
          : personToVisit as String?,
      visitorType: visitorType == _unset
          ? this.visitorType
          : visitorType as String?,
      companyName: companyName ?? this.companyName,
      purpose: purpose ?? this.purpose,
      email: email ?? this.email,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

final invitationAddControllerProvider =
    NotifierProvider<InvitationAddController, InvitationAddState>(
      InvitationAddController.new,
    );

class InvitationAddController extends Notifier<InvitationAddState> {
  @override
  InvitationAddState build() => const InvitationAddState();

  void updateEntity(String? value) {
    state = state.copyWith(entity: value);
  }

  void updateSite(String? value) {
    state = state.copyWith(site: value);
  }

  void updateDepartment(String? value) {
    state = state.copyWith(department: value);
  }

  void updatePersonToVisit(String? value) {
    state = state.copyWith(personToVisit: value);
  }

  void updateVisitorType(String? value) {
    state = state.copyWith(visitorType: value);
  }

  void updateCompanyName(String value) {
    state = state.copyWith(companyName: value);
  }

  void updatePurpose(String value) {
    state = state.copyWith(purpose: value);
  }

  void updateEmail(String value) {
    state = state.copyWith(email: value);
  }

  void updateDateFrom(String value) {
    state = state.copyWith(dateFrom: value);
  }

  void updateDateTo(String value) {
    state = state.copyWith(dateTo: value);
  }

  void clear() {
    state = const InvitationAddState();
  }

  Future<void> submitMock() async {
    if (state.isSubmitting) {
      return;
    }
    state = state.copyWith(isSubmitting: true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    state = state.copyWith(isSubmitting: false);
  }
}
