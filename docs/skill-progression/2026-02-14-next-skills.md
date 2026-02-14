# Skill Progression Map (2026-02-14)

Scope: commits since last automation run (`2026-02-13T02:00:08Z`).

## Evidence snapshot

- `5bb37d5` implemented invitation API end-to-end (datasource, DTOs, repository, domain, usecase, presentation state/page, tests).
- `959886c`, `8585ef2`, `e6e6f58` added site/personel/visitor-type reference APIs with DTO/domain/usecase/repository layers and tests.
- `bb0d3a2`, `cf390fd`, `1752059`, `b153532` repeatedly refactored invitation add/listing flows and extracted shared UI/state helpers.
- New focused tests landed for helper/state formatting (`test/presentation/state/async_option_helpers_test.dart`, `test/presentation/state/option_label_formatters_test.dart`) and DTO/usecase paths.

## Next skills to deepen

### 1) Repository Failure Taxonomy + Mapping Discipline

Why now (concrete evidence):
- Multiple API integrations landed across invitation + reference data in a short window.
- Data/domain boundaries are expanding quickly; consistency risk rises with each new endpoint.

Target files:
- `lib/data/repositories/invitation_repository_impl.dart`
- `lib/data/repositories/reference_repository_impl.dart`
- `lib/data/datasources/invitation_remote_data_source.dart`
- `lib/data/datasources/reference_remote_data_source.dart`

Checklist:
- Define a sealed/enum-like domain failure taxonomy (`network`, `unauthorized`, `validation`, `server`, `unknown`).
- Ensure every repository catches transport errors and maps to the taxonomy.
- Ensure usecases return/throw only domain-level failures, never Dio/raw exceptions.
- Add one table-driven test per repository method covering all mapped failure classes.
- Add one "unexpected payload" test per DTO mapper for safe fallback behavior.

Template (repository mapping skeleton):
```dart
Future<T> mapDataCall<T>(Future<T> Function() run) async {
  try {
    return await run();
  } on DioException catch (e) {
    throw mapDioToDomainFailure(e);
  } on FormatException {
    throw const DomainFailure.validation('Malformed response payload');
  } catch (_) {
    throw const DomainFailure.unknown();
  }
}
```

Definition of done:
- All repository tests assert domain failures, not transport exceptions.
- No presentation/provider code branches on Dio types.

### 2) Riverpod Async Option Orchestration (Load/Error/Retry/Cache)

Why now (concrete evidence):
- Strong churn in invitation form state and option loading helpers (`async_option_helpers.dart`, `invitation_add_providers.dart`, `reference_providers.dart`).
- UX refactors indicate repeated adjustments around option readiness and labels.

Target files:
- `lib/presentation/state/async_option_helpers.dart`
- `lib/presentation/state/invitation_add_providers.dart`
- `lib/presentation/state/reference_providers.dart`

Checklist:
- Introduce one shared `AsyncOptionState<T>` view model (loading/data/error + stale timestamp).
- Centralize retry entry point per option provider (`invalidate` + refetch policy).
- Implement TTL-based cache rule for reference options (e.g. 5-10 min).
- Ensure dependent option reset logic is deterministic when parent changes.
- Add tests for `loading -> data`, `loading -> error`, `error -> retry -> data`, and stale cache refresh.

Template (provider pattern):
```dart
@riverpod
Future<List<SiteOption>> siteOptions(SiteOptionsRef ref, String? entityId) async {
  if (entityId == null || entityId.isEmpty) return const [];

  final repo = ref.watch(referenceRepositoryProvider);
  final now = DateTime.now();
  final cache = ref.watch(siteOptionsCacheProvider(entityId));
  if (cache != null && now.difference(cache.fetchedAt) < const Duration(minutes: 10)) {
    return cache.data;
  }

  final data = await repo.getSites(entityId);
  ref.read(siteOptionsCacheProvider(entityId).notifier).state = CachedOptions(data, now);
  return data;
}
```

Definition of done:
- Invitation form has one consistent option-loading behavior across entity/site/department/host/visitor type.
- Retry UX path is explicit and test-covered.

### 3) Shared Form Row Contracts + Widget Test Harness

Why now (concrete evidence):
- Shared UI widgets were updated repeatedly (`labeled_form_rows.dart`, `searchable_option_sheet.dart`) while invitation pages changed in parallel.
- This is a signal to lock UX contracts with tests before the next refactor cycle.

Target files:
- `lib/presentation/widgets/labeled_form_rows.dart`
- `lib/presentation/widgets/searchable_option_sheet.dart`
- `lib/presentation/pages/invitation_add_page.dart`

Checklist:
- Define explicit contract for each shared row type (`label`, `required marker`, `helper`, `error`, `enabled`).
- Standardize keyboard and bottom-sheet open behavior for searchable rows.
- Add widget tests for label/error/helper rendering combinations.
- Add widget tests for selection sheet filtering, empty-state text, and selection callback.
- Remove any page-private row/selector variants that duplicate shared widgets.

Template (widget test skeleton):
```dart
testWidgets('searchable sheet returns selected option', (tester) async {
  String? selected;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SearchableOptionSheet<String>(
          title: 'Select site',
          options: const ['A', 'B'],
          labelBuilder: (v) => v,
          onSelected: (v) => selected = v,
        ),
      ),
    ),
  );

  await tester.enterText(find.byType(TextField), 'B');
  await tester.tap(find.text('B'));
  expect(selected, 'B');
});
```

Definition of done:
- Shared widgets define the UX contract; pages only compose them.
- Critical interaction paths covered by widget tests.

### 4) Auth Session + Router Guard Reliability

Why now (concrete evidence):
- Auth local/session providers and router/splash/login were touched together during API rollout.
- Routing without explicit guard tests regresses easily when auth behavior evolves.

Target files:
- `lib/presentation/state/auth_session_providers.dart`
- `lib/presentation/app/router.dart`
- `lib/presentation/pages/splash_page.dart`
- `lib/presentation/pages/login_page.dart`

Checklist:
- Define a single auth-state source (`loading`, `authenticated`, `unauthenticated`).
- Encode redirect rules in one place (`router.dart`) with deterministic precedence.
- Ensure splash transitions are state-driven (avoid timing-only logic for authenticated users).
- Add router tests for: cold start authenticated, cold start unauthenticated, logout redirect, expired token path.
- Ensure session persistence load failure falls back safely to unauthenticated.

Template (redirect rule skeleton):
```dart
String? authRedirect(AuthState auth, GoRouterState state) {
  final path = state.uri.path;
  if (auth.isLoading) return path == '/' ? null : '/';
  if (auth.isAuthenticated) {
    if (path == '/' || path == '/login') return '/home';
    return null;
  }
  if (path == '/login' || path == '/') return null;
  return '/login';
}
```

Definition of done:
- Redirect behavior is test-covered and no longer dependent on timing hacks.

## Suggested 2-week execution order

1. Week 1: Skill 1 (failure mapping) + Skill 2 (async option orchestration).
2. Week 2: Skill 3 (shared widget contracts/tests) + Skill 4 (auth/router guard tests).

Rationale:
- First stabilize data/state contracts, then lock UI and routing behavior.
