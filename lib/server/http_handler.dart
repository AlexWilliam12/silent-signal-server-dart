import 'dart:io';

import 'package:silent_signal/utils/jwt.dart';

abstract class HttpHandler {
  Future<Map<String, dynamic>?> doFilter(HttpRequest request) async {
    try {
      final header = request.headers['Authorization'];
      if (header != null) {
        final token = header.first.substring(7).trim();
        if (validateJWT(token)) {
          return getClaims(token);
        } else {
          request.response
            ..statusCode = HttpStatus.unauthorized
            ..headers.add('Content-Type', 'text/plain')
            ..write('unauthorized request')
            ..close();
        }
      } else {
        request.response
          ..statusCode = HttpStatus.forbidden
          ..headers.add('Content-Type', 'text/plain')
          ..write('forbidden')
          ..close();
      }
    } catch (e) {
      print(e);
      request.response
        ..statusCode = HttpStatus.badRequest
        ..headers.add('Content-Type', 'text/plain')
        ..write(e.toString())
        ..close();
    }
    return null;
  }

  Future<void> handleRequest(HttpRequest request) async {
    throw UnimplementedError();
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
