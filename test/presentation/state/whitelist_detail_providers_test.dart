import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/whitelist_detail_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_filter_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_item_entity.dart';
import 'package:vms_bernas/domain/repositories/whitelist_repository.dart';
import 'package:vms_bernas/domain/usecases/get_whitelist_detail_usecase.dart';
import 'package:vms_bernas/presentation/state/whitelist_detail_providers.dart';

class _FakeWhitelistRepository implements WhitelistRepository {
  _FakeWhitelistRepository({this.shouldThrow = false});

  final bool shouldThrow;
  String? lastEntity;
  String? lastVehiclePlate;

  @override
  Future<WhitelistDetailEntity> getWhitelistDetail({
    required String entity,
    required String vehiclePlate,
  }) async {
    lastEntity = entity;
    lastVehiclePlate = vehiclePlate;
    if (shouldThrow) {
      throw Exception('detail failed');
    }
    return const WhitelistDetailEntity(
      entity: 'AGYTEK',
      vehiclePlate: 'www9233G',
      ic: '123456789012',
      name: 'John',
      status: 'ACTIVE',
      createBy: 'admin',
      createDate: '2025-12-03 10:23:10',
      updateBy: 'admin',
      updateDate: '2025-12-03 10:48:15',
    );
  }

  @override
  Future<List<WhitelistSearchItemEntity>> searchWhitelist({
    required WhitelistSearchFilterEntity filter,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  test('load success updates detail state', () async {
    final repository = _FakeWhitelistRepository();
    final container = ProviderContainer(
      overrides: [
        getWhitelistDetailUseCaseProvider.overrideWithValue(
          GetWhitelistDetailUseCase(repository),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(whitelistDetailControllerProvider.notifier)
        .load(entity: 'AGYTEK', vehiclePlate: 'www9233G', checkType: 'I');

    final state = container.read(whitelistDetailControllerProvider);
    expect(repository.lastEntity, 'AGYTEK');
    expect(repository.lastVehiclePlate, 'www9233G');
    expect(state.detail, isNotNull);
    expect(state.detail?.name, 'John');
    expect(state.errorMessage, isNull);
    expect(state.hasLoaded, isTrue);
    expect(state.checkType, 'I');
  });

  test('load failure sets error state', () async {
    final repository = _FakeWhitelistRepository(shouldThrow: true);
    final container = ProviderContainer(
      overrides: [
        getWhitelistDetailUseCaseProvider.overrideWithValue(
          GetWhitelistDetailUseCase(repository),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(whitelistDetailControllerProvider.notifier)
        .load(entity: 'AGYTEK', vehiclePlate: 'www9233G', checkType: 'O');

    final state = container.read(whitelistDetailControllerProvider);
    expect(state.detail, isNull);
    expect(state.errorMessage, 'detail failed');
    expect(state.hasLoaded, isTrue);
    expect(state.checkType, 'O');
  });
}
