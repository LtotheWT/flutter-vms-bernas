import 'package:dio/dio.dart';

import '../models/invitation_create_request_dto.dart';
import '../models/invitation_create_response_dto.dart';
import '../models/invitation_listing_item_dto.dart';
import '../models/invitation_listing_request_dto.dart';
import 'network/remote_parsers.dart';

class InvitationRemoteDataSource {
  InvitationRemoteDataSource(this._dio);

  final Dio _dio;

  Future<InvitationCreateResponseDto> submitInvitation({
    required String accessToken,
    required String idempotencyKey,
    required InvitationCreateRequestDto request,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/wmsws/Invitations',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'accept': '*/*',
            'Idempotency-Key': idempotencyKey,
          },
        ),
      );

      return InvitationCreateResponseDto.fromJson(parseJsonMap(response.data));
    } on DioException catch (error) {
      final backendMessage = _extractBackendErrorMessage(error.response?.data);
      if (backendMessage != null && backendMessage.isNotEmpty) {
        throw InvitationException(backendMessage);
      }

      if (isConnectivityIssue(error)) {
        throw InvitationException(
          'Unable to submit invitation. Please try again.',
        );
      }

      throw InvitationException(
        'Failed to submit invitation. Please try again.',
      );
    } on FormatException {
      throw InvitationException(
        'Failed to submit invitation. Please try again.',
      );
    }
  }

  Future<List<InvitationListingItemDto>> listInvitations({
    required String accessToken,
    required InvitationListingRequestDto request,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/wmsws/Invitations/listing',
        data: request.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken', 'accept': '*/*'},
        ),
      );

      final list = parseJsonList(response.data);
      return list
          .map((item) => InvitationListingItemDto.fromJson(parseJsonMap(item)))
          .toList(growable: false);
    } on DioException catch (error) {
      if (isConnectivityIssue(error)) {
        throw InvitationException(
          'Unable to load invitation listing. Please try again.',
        );
      }

      throw InvitationException(
        'Failed to load invitation listing. Please try again.',
      );
    } on FormatException {
      throw InvitationException(
        'Failed to load invitation listing. Please try again.',
      );
    }
  }

  String? _extractBackendErrorMessage(dynamic data) {
    try {
      final map = parseJsonMap(data);
      final response = InvitationCreateResponseDto.fromJson(map);
      if (!response.status && response.message != null) {
        return response.message;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

class InvitationException implements Exception {
  InvitationException(this.message);

  final String message;

  @override
  String toString() => message;
}
