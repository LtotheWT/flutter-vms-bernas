import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/whitelist_detail_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_filter_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_item_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_submit_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_submit_result_entity.dart';
import 'package:vms_bernas/domain/repositories/whitelist_repository.dart';
import 'package:vms_bernas/domain/usecases/get_whitelist_detail_usecase.dart';

class _FakeWhitelistRepository implements WhitelistRepository {
  String? capturedEntity;
  String? capturedVehiclePlate;

  @override
  Future<WhitelistDetailEntity> getWhitelistDetail({
    required String entity,
    required String vehiclePlate,
  }) async {
    capturedEntity = entity;
    capturedVehiclePlate = vehiclePlate;
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

  @override
  Future<WhitelistSubmitResultEntity> submitWhitelistCheckIn({
    required WhitelistSubmitEntity submission,
    required String idempotencyKey,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<WhitelistSubmitResultEntity> submitWhitelistCheckOut({
    required WhitelistSubmitEntity submission,
    required String idempotencyKey,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  test('forwards detail identifiers to repository', () async {
    final repository = _FakeWhitelistRepository();
    final useCase = GetWhitelistDetailUseCase(repository);

    final detail = await useCase(entity: 'AGYTEK', vehiclePlate: 'www9233G');

    expect(repository.capturedEntity, 'AGYTEK');
    expect(repository.capturedVehiclePlate, 'www9233G');
    expect(detail.name, 'John');
  });
}
