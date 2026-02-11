import 'dart:convert';

import 'package:dio/dio.dart';

bool isConnectivityIssue(DioException error) {
  return error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.connectionError;
}

Map<String, dynamic> parseJsonMap(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data;
  }

  if (data is Map) {
    return data.map((key, value) => MapEntry(key.toString(), value));
  }

  if (data is String) {
    final decoded = jsonDecode(data);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
  }

  throw const FormatException('Invalid response format');
}

List<dynamic> parseJsonList(dynamic data) {
  if (data is List<dynamic>) {
    return data;
  }

  if (data is String) {
    final decoded = jsonDecode(data);
    if (decoded is List<dynamic>) {
      return decoded;
    }
  }

  throw const FormatException('Invalid response format');
}
