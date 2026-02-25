import '../../domain/entities/invitation_list_item_entity.dart';
import '../../domain/entities/invitation_listing_filter_entity.dart';
import '../../domain/entities/invitation_submission_entity.dart';
import '../../domain/repositories/invitation_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/invitation_remote_data_source.dart';
import '../models/invitation_create_request_dto.dart';
import '../models/invitation_listing_request_dto.dart';

class InvitationRepositoryImpl implements InvitationRepository {
  InvitationRepositoryImpl(this._remoteDataSource, this._authLocalDataSource);

  final InvitationRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;

  @override
  Future<List<InvitationListItemEntity>> listInvitations({
    required InvitationListingFilterEntity filter,
  }) async {
    final session = await _authLocalDataSource.getSession();
    final accessToken = session?.accessToken.trim() ?? '';
    if (accessToken.isEmpty) {
      throw Exception('Please login again to load invitation listing.');
    }

    final userId = session?.username.trim() ?? '';
    if (userId.isEmpty) {
      throw Exception('Please login again to load invitation listing.');
    }

    final todayDateText = _toDateText(DateTime.now());
    final visitDateFrom = (filter.visitDateFrom?.trim().isNotEmpty ?? false)
        ? filter.visitDateFrom!.trim()
        : todayDateText;
    final visitDateTo = (filter.visitDateTo?.trim().isNotEmpty ?? false)
        ? filter.visitDateTo!.trim()
        : todayDateText;

    final requestDto = InvitationListingRequestDto(
      department: filter.department?.trim() ?? '',
      visitorType: filter.visitorType?.trim() ?? '',
      invitationId: filter.invitationId?.trim() ?? '',
      status: filter.statusCode?.trim() ?? '',
      site: filter.site?.trim() ?? '',
      entity: filter.entity?.trim() ?? '',
      userId: userId,
      visitFrom: _toDayBoundaryIsoUtc(visitDateFrom, isStart: true),
      visitTo: _toDayBoundaryIsoUtc(visitDateTo, isStart: false),
    );

    final dtos = await _remoteDataSource.listInvitations(
      accessToken: accessToken,
      request: requestDto,
    );
    final items = dtos.map((dto) => dto.toEntity()).toList(growable: false);

    if (!filter.upcomingOnly) {
      return items;
    }

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return items
        .where((item) {
          final parsed = DateTime.tryParse(item.visitDateFrom.trim());
          if (parsed == null) {
            return false;
          }
          final dateOnly = DateTime(parsed.year, parsed.month, parsed.day);
          return !dateOnly.isBefore(todayDate);
        })
        .toList(growable: false);
  }

  @override
  Future<InvitationSubmissionEntity> submitInvitation({
    required String idempotencyKey,
    required String entity,
    required String site,
    required String department,
    required String employeeId,
    required String visitorType,
    required String visitorName,
    required String purpose,
    required String email,
    required String visitFrom,
    required String visitTo,
  }) async {
    final session = await _authLocalDataSource.getSession();
    final accessToken = session?.accessToken.trim() ?? '';
    if (accessToken.isEmpty) {
      throw Exception('Please login again to submit invitation.');
    }

    final userId = session?.username.trim() ?? '';
    if (userId.isEmpty) {
      throw Exception('Please login again to submit invitation.');
    }

    final requestDto = InvitationCreateRequestDto(
      ccn: entity,
      userId: userId,
      site: site,
      dept: department,
      employee: employeeId,
      visitorType: visitorType,
      visitorName: visitorName,
      purpose: purpose,
      invitePurpose: purpose,
      email: email,
      visitFrom: _toIsoUtc(visitFrom),
      visitTo: _toIsoUtc(visitTo),
    );

    final response = await _remoteDataSource.submitInvitation(
      accessToken: accessToken,
      idempotencyKey: idempotencyKey,
      request: requestDto,
    );
    return response.toEntity();
  }

  String _toIsoUtc(String value) {
    final text = value.trim();
    final normalized = text.replaceFirst(' ', 'T');
    final parsed = DateTime.tryParse(normalized);
    if (parsed == null) {
      throw Exception('Invalid visit date/time format.');
    }
    return parsed.toUtc().toIso8601String();
  }

  String _toDateText(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _toDayBoundaryIsoUtc(String? value, {required bool isStart}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return '';
    }

    final parsed = DateTime.tryParse(text);
    if (parsed == null) {
      throw Exception('Invalid visit date format.');
    }

    final adjustedUtc = isStart
        ? DateTime.utc(parsed.year, parsed.month, parsed.day, 0, 0, 0)
        : DateTime.utc(parsed.year, parsed.month, parsed.day, 23, 59, 59, 999);
    return adjustedUtc.toIso8601String();
  }
}
