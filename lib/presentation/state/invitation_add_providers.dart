import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/invitation_remote_data_source.dart';
import '../../data/datasources/reference_remote_data_source.dart';
import '../../data/repositories/invitation_repository_impl.dart';
import '../../data/repositories/reference_repository_impl.dart';
import '../../domain/repositories/invitation_repository.dart';
import '../../domain/repositories/reference_repository.dart';
import '../../domain/usecases/get_departments_usecase.dart';
import '../../domain/usecases/get_entities_usecase.dart';
import '../../domain/usecases/get_locations_usecase.dart';
import '../../domain/usecases/get_personels_usecase.dart';
import '../../domain/usecases/get_visitor_types_usecase.dart';
import '../../domain/usecases/submit_invitation_usecase.dart';
import 'auth_session_providers.dart';
import 'department_option.dart';
import 'entity_option.dart';
import 'host_option.dart';
import 'site_option.dart';
import 'visitor_type_option.dart';

const Object _unset = Object();

final referenceRemoteDataSourceProvider = Provider<ReferenceRemoteDataSource>((
  ref,
) {
  final dio = ref.read(dioClientProvider);
  return ReferenceRemoteDataSource(dio);
});

final invitationRemoteDataSourceProvider = Provider<InvitationRemoteDataSource>(
  (ref) {
    final dio = ref.read(dioClientProvider);
    return InvitationRemoteDataSource(dio);
  },
);

final referenceRepositoryProvider = Provider<ReferenceRepository>((ref) {
  final remoteDataSource = ref.read(referenceRemoteDataSourceProvider);
  final localDataSource = ref.read(authLocalDataSourceProvider);
  return ReferenceRepositoryImpl(remoteDataSource, localDataSource);
});

final invitationRepositoryProvider = Provider<InvitationRepository>((ref) {
  final remoteDataSource = ref.read(invitationRemoteDataSourceProvider);
  final localDataSource = ref.read(authLocalDataSourceProvider);
  return InvitationRepositoryImpl(remoteDataSource, localDataSource);
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

final submitInvitationUseCaseProvider = Provider<SubmitInvitationUseCase>((
  ref,
) {
  final repository = ref.read(invitationRepositoryProvider);
  return SubmitInvitationUseCase(repository);
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
    this.idempotencyKey,
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
  final String? idempotencyKey;
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
    Object? idempotencyKey = _unset,
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
      idempotencyKey: idempotencyKey == _unset
          ? this.idempotencyKey
          : idempotencyKey as String?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

@immutable
class InvitationSubmitResult {
  const InvitationSubmitResult({required this.success, required this.message});

  final bool success;
  final String message;
}

final invitationAddControllerProvider =
    NotifierProvider.autoDispose<InvitationAddController, InvitationAddState>(
      InvitationAddController.new,
    );

class InvitationAddController extends Notifier<InvitationAddState> {
  static const Uuid _uuid = Uuid();

  @override
  InvitationAddState build() => const InvitationAddState();

  void updateEntity(String? value) {
    if (state.entity == value) return;
    state = state.copyWith(entity: value, idempotencyKey: null);
  }

  void updateSite(String? value) {
    if (state.site == value) return;
    state = state.copyWith(site: value, idempotencyKey: null);
  }

  void updateDepartment(String? value) {
    if (state.department == value) return;
    state = state.copyWith(department: value, idempotencyKey: null);
  }

  void updatePersonToVisit(String? value) {
    if (state.personToVisit == value) return;
    state = state.copyWith(personToVisit: value, idempotencyKey: null);
  }

  void updateVisitorType(String? value) {
    if (state.visitorType == value) return;
    state = state.copyWith(visitorType: value, idempotencyKey: null);
  }

  void updateCompanyName(String value) {
    if (state.companyName == value) return;
    state = state.copyWith(companyName: value, idempotencyKey: null);
  }

  void updatePurpose(String value) {
    if (state.purpose == value) return;
    state = state.copyWith(purpose: value, idempotencyKey: null);
  }

  void updateEmail(String value) {
    if (state.email == value) return;
    state = state.copyWith(email: value, idempotencyKey: null);
  }

  void updateDateFrom(String value) {
    if (state.dateFrom == value) return;
    state = state.copyWith(dateFrom: value, idempotencyKey: null);
  }

  void updateDateTo(String value) {
    if (state.dateTo == value) return;
    state = state.copyWith(dateTo: value, idempotencyKey: null);
  }

  void clear() {
    state = const InvitationAddState();
  }

  Future<InvitationSubmitResult> submit() async {
    if (state.isSubmitting) {
      return const InvitationSubmitResult(
        success: false,
        message: 'Invitation is currently submitting.',
      );
    }

    final idempotencyKey = state.idempotencyKey ?? _uuid.v4();
    state = state.copyWith(isSubmitting: true, idempotencyKey: idempotencyKey);

    try {
      final useCase = ref.read(submitInvitationUseCaseProvider);
      final response = await useCase(
        idempotencyKey: idempotencyKey,
        entity: state.entity?.trim() ?? '',
        site: state.site?.trim() ?? '',
        department: state.department?.trim() ?? '',
        employeeId: state.personToVisit?.trim() ?? '',
        visitorType: state.visitorType?.trim() ?? '',
        visitorName: state.companyName.trim(),
        purpose: state.purpose.trim(),
        email: state.email.trim(),
        visitFrom: state.dateFrom.trim(),
        visitTo: state.dateTo.trim(),
      );

      if (response.status) {
        return InvitationSubmitResult(
          success: true,
          message: response.message ?? 'Invitation submitted.',
        );
      }

      return InvitationSubmitResult(
        success: false,
        message: response.message ?? 'Failed to submit invitation.',
      );
    } catch (error) {
      final text = error.toString().trim();
      return InvitationSubmitResult(
        success: false,
        message: text.startsWith('Exception:')
            ? text.replaceFirst('Exception:', '').trim()
            : (text.isEmpty ? 'Failed to submit invitation.' : text),
      );
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}
