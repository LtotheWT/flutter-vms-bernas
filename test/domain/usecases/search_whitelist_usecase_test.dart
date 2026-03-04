import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_filter_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_item_entity.dart';
import 'package:vms_bernas/domain/repositories/whitelist_repository.dart';
import 'package:vms_bernas/domain/usecases/search_whitelist_usecase.dart';

class _FakeWhitelistRepository implements WhitelistRepository {
  WhitelistSearchFilterEntity? capturedFilter;

  @override
  Future<List<WhitelistSearchItemEntity>> searchWhitelist({
    required WhitelistSearchFilterEntity filter,
  }) async {
    capturedFilter = filter;
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
}

void main() {
  test('forwards filter to repository', () async {
    final repository = _FakeWhitelistRepository();
    final useCase = SearchWhitelistUseCase(repository);
    const filter = WhitelistSearchFilterEntity(
      entity: 'AGYTEK',
      currentType: 'I',
      status: 'ACTIVE',
    );

    final result = await useCase(filter: filter);

    expect(repository.capturedFilter, filter);
    expect(result, hasLength(1));
  });
}
