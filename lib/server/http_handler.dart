import 'dart:io';

import 'package:silent_signal/utils/jwt.dart';

abstract class HttpHandler {
  Future<Map<String, dynamic>?> doFilter(HttpRequest request) async {
    final header = request.headers['Authorization'];
    if (header == null) {
      request.response
        ..statusCode = HttpStatus.forbidden
        ..headers.add('Content-Type', 'text/plain')
        ..write('Forbidden')
        ..close();
      return null;
    }
    final token = header.first.substring(7).trim();
    if (!validateJWT(token)) {
      request.response
        ..statusCode = HttpStatus.unauthorized
        ..headers.add('Content-Type', 'text/plain')
        ..write('Unauthorized Request')
        ..close();
      return null;
    }
    return getClaims(token);
  }

  Future<void> handleGet(HttpRequest request) async {
    throw UnimplementedError();
  }

  Future<void> handlePost(HttpRequest request) async {
    throw UnimplementedError();
  }

  Future<void> handlePut(HttpRequest request) async {
    throw UnimplementedError();
  }

  Future<void> handleDelete(HttpRequest request) async {
    throw UnimplementedError();
  }
}
