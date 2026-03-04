import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/whitelist_detail_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_filter_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_item_entity.dart';
import 'package:vms_bernas/domain/repositories/whitelist_repository.dart';
import 'package:vms_bernas/domain/usecases/search_whitelist_usecase.dart';
import 'package:vms_bernas/presentation/state/whitelist_check_providers.dart';

class _FakeWhitelistRepository implements WhitelistRepository {
  _FakeWhitelistRepository({this.shouldThrow = false});

  final bool shouldThrow;
  WhitelistSearchFilterEntity? lastFilter;

  @override
  Future<List<WhitelistSearchItemEntity>> searchWhitelist({
    required WhitelistSearchFilterEntity filter,
  }) async {
    lastFilter = filter;
    if (shouldThrow) {
      throw Exception('boom');
    }

    return const [
      WhitelistSearchItemEntity(
        entity: 'AGYTEK',
        vehiclePlate: 'RYAN1234',
        ic: 'RYAN',
        name: 'RYAN1234',
        status: 'ACTIVE',
        createBy: 'ryan',
        createDate: '2026-01-13 11:46:40',
        updateBy: '',
        updateDate: '',
      ),
    ];
  }

  @override
  Future<WhitelistDetailEntity> getWhitelistDetail({
    required String entity,
    required String vehiclePlate,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  test('initial load uses default entity and current type', () async {
    final repository = _FakeWhitelistRepository();
    final container = ProviderContainer(
      overrides: [
        searchWhitelistUseCaseProvider.overrideWithValue(
          SearchWhitelistUseCase(repository),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(whitelistCheckControllerProvider.notifier)
        .loadInitial(currentType: 'I', defaultEntity: 'AGYTEK');

    final state = container.read(whitelistCheckControllerProvider);
    expect(state.items, hasLength(1));
    expect(state.hasLoaded, isTrue);
    expect(
      repository.lastFilter,
      const WhitelistSearchFilterEntity(entity: 'AGYTEK', currentType: 'I'),
    );
  });

  test('applyFilters forwards and updates state', () async {
    final repository = _FakeWhitelistRepository();
    final container = ProviderContainer(
      overrides: [
        searchWhitelistUseCaseProvider.overrideWithValue(
          SearchWhitelistUseCase(repository),
        ),
      ],
    );
    addTearDown(container.dispose);

    const filter = WhitelistSearchFilterEntity(
      entity: 'AGYTEK',
      currentType: 'O',
      vehiclePlate: 'ABC',
      ic: 'IC1',
      status: 'ACTIVE',
    );

    await container
        .read(whitelistCheckControllerProvider.notifier)
        .applyFilters(filter);

    final state = container.read(whitelistCheckControllerProvider);
    expect(repository.lastFilter, filter);
    expect(state.activeFilter, filter);
    expect(state.errorMessage, isNull);
  });

  test('fetch failure sets error message', () async {
    final repository = _FakeWhitelistRepository(shouldThrow: true);
    final container = ProviderContainer(
      overrides: [
        searchWhitelistUseCaseProvider.overrideWithValue(
          SearchWhitelistUseCase(repository),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(whitelistCheckControllerProvider.notifier)
        .loadInitial(currentType: 'I', defaultEntity: 'AGYTEK');

    final state = container.read(whitelistCheckControllerProvider);
    expect(state.hasLoaded, isTrue);
    expect(state.errorMessage, 'boom');
  });
}
