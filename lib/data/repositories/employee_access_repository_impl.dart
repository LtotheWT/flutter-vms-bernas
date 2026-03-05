import '../../domain/entities/employee_info_entity.dart';
import '../../domain/entities/employee_submit_entity.dart';
import '../../domain/entities/employee_submit_result_entity.dart';
import '../../domain/repositories/employee_access_repository.dart';
import 'dart:typed_data';
import '../datasources/auth_local_data_source.dart';
import '../datasources/employee_access_remote_data_source.dart';
import '../models/employee_submit_request_dto.dart';

class EmployeeAccessRepositoryImpl implements EmployeeAccessRepository {
  EmployeeAccessRepositoryImpl(
    this._remoteDataSource,
    this._authLocalDataSource,
  );

  final EmployeeAccessRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;

  @override
  Future<EmployeeInfoEntity> getEmployeeInfo({required String code}) async {
    final accessToken = await _getAccessTokenOrThrow(
      missingMessage: 'Please login again to load employee info.',
    );
    final dto = await _remoteDataSource.getEmployeeInfo(
      accessToken: accessToken,
      code: code,
    );
    return dto.toEntity();
  }

  @override
  Future<Uint8List?> getEmployeeImage({required String employeeId}) async {
    final accessToken = await _getAccessTokenOrThrow(
      missingMessage: 'Please login again to load employee image.',
    );
    return _remoteDataSource.getEmployeeImage(
      accessToken: accessToken,
      employeeId: employeeId,
    );
  }

  @override
  Future<EmployeeSubmitResultEntity> submitEmployeeCheckIn({
    required EmployeeSubmitEntity submission,
    required String idempotencyKey,
  }) async {
    final accessToken = await _getAccessTokenOrThrow(
      missingMessage: 'Please login again to submit employee check-in.',
    );
    final dto = await _remoteDataSource.submitEmployeeCheckIn(
      accessToken: accessToken,
      idempotencyKey: idempotencyKey,
      request: EmployeeSubmitRequestDto.fromEntity(submission),
    );
    return dto.toEntity();
  }

  @override
  Future<EmployeeSubmitResultEntity> submitEmployeeCheckOut({
    required EmployeeSubmitEntity submission,
    required String idempotencyKey,
  }) async {
    final accessToken = await _getAccessTokenOrThrow(
      missingMessage: 'Please login again to submit employee check-out.',
    );
    final dto = await _remoteDataSource.submitEmployeeCheckOut(
      accessToken: accessToken,
      idempotencyKey: idempotencyKey,
      request: EmployeeSubmitRequestDto.fromEntity(submission),
    );
    return dto.toEntity();
  }

  Future<String> _getAccessTokenOrThrow({
    required String missingMessage,
  }) async {
    final session = await _authLocalDataSource.getSession();
    final accessToken = session?.accessToken.trim() ?? '';
    if (accessToken.isEmpty) {
      throw Exception(missingMessage);
    }
    return accessToken;
  }
}
