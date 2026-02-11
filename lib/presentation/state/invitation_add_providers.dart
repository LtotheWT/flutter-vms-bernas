import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/reference_remote_data_source.dart';
import '../../data/repositories/reference_repository_impl.dart';
import '../../domain/repositories/reference_repository.dart';
import '../../domain/usecases/get_entities_usecase.dart';
import 'auth_session_providers.dart';
import 'entity_option.dart';

const Map<String, List<String>> _mockEntitySites = {
  'AGYTEK': ['FACTORY1 T', 'FACTORY2 T'],
  'Agytek2': ['SITE 1', 'SITE 2'],
  'Entity1': ['SITE 3'],
};

final referenceRemoteDataSourceProvider = Provider<ReferenceRemoteDataSource>((
  ref,
) {
  final dio = ref.read(dioClientProvider);
  return ReferenceRemoteDataSource(dio);
});

final referenceRepositoryProvider = Provider<ReferenceRepository>((ref) {
  final remoteDataSource = ref.read(referenceRemoteDataSourceProvider);
  return ReferenceRepositoryImpl(remoteDataSource);
});

final getEntitiesUseCaseProvider = Provider<GetEntitiesUseCase>((ref) {
  final repository = ref.read(referenceRepositoryProvider);
  return GetEntitiesUseCase(repository);
});

final entityOptionsProvider = FutureProvider.autoDispose<List<EntityOption>>((
  ref,
) async {
  final getSession = ref.read(getPersistedSessionUseCaseProvider);
  final session = await getSession();
  final accessToken = session?.accessToken.trim() ?? '';

  if (accessToken.isEmpty) {
    throw Exception('Please login again to load entities.');
  }

  final useCase = ref.read(getEntitiesUseCaseProvider);
  final entities = await useCase(accessToken: accessToken);

  return entities
      .map((entity) => EntityOption(value: entity.code, label: entity.name))
      .toList(growable: false);
});

Future<List<String>> _fetchSitesForEntity(String? entity) async {
  if (entity == null) return const [];
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return _mockEntitySites[entity] ?? const ['FACTORY1 T'];
}

final siteOptionsProvider = FutureProvider.autoDispose
    .family<List<String>, String?>(
      (ref, entity) => _fetchSitesForEntity(entity),
    );

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
    String? entity,
    String? site,
    String? department,
    String? personToVisit,
    String? visitorType,
    String? companyName,
    String? purpose,
    String? email,
    String? dateFrom,
    String? dateTo,
    bool? isSubmitting,
  }) {
    return InvitationAddState(
      entity: entity ?? this.entity,
      site: site ?? this.site,
      department: department ?? this.department,
      personToVisit: personToVisit ?? this.personToVisit,
      visitorType: visitorType ?? this.visitorType,
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
