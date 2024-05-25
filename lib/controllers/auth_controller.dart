import 'dart:convert';
import 'dart:io';

import 'package:silent_signal/database/user_repository.dart';
import 'package:silent_signal/server/http_response_builder.dart';
import 'package:silent_signal/utils/hash.dart';
import 'package:silent_signal/utils/jwt.dart';

class AuthController {
  final repository = SensitiveUserRepository();

  Future<HttpResponse> login(HttpRequest request) async {
    try {
      final body = await utf8.decoder.bind(request).join();
      final json = jsonDecode(body);
      final user = await repository.fetchByCredentials(
        json['username'],
        json['password'],
      );
      return user != null
          ? HttpResponseBuilder.send(request.response).ok(
              HttpStatus.ok,
              body: jsonEncode({'token': generateJWT(user.username)}),
            )
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.notFound,
              body: 'User Not Found',
            );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }

  Future<HttpResponse> register(HttpRequest request) async {
    try {
      final body = await utf8.decoder.bind(request).join();
      final json = jsonDecode(body);
      final isCreated = await repository.create(
        json['username'],
        json['password'],
        generateCredentialsHash(json['username'], json['password']),
      );
      return isCreated
          ? HttpResponseBuilder.send(request.response).ok(HttpStatus.ok)
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.internalServerError,
              body: 'User Not Created',
            );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }

  Future<HttpResponse> validateToken(HttpRequest request) async {
    try {
      final header = request.headers['Authorization'];
      if (header == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.forbidden,
          body: 'Forbidden',
        );
      }
      final token = header.first.substring(7).trim();
      if (!validateJWT(token)) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.unauthorized,
          body: 'Unauthorized Request',
        );
      }
      return HttpResponseBuilder.send(request.response).ok(HttpStatus.ok);
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }

  Future<HttpResponse> validateHash(HttpRequest request) async {
    try {
      final body = await utf8.decoder.bind(request).join();
      final json = jsonDecode(body);
      final user = await repository.fetchByHash(json['credentials_hash']);
      return user != null
          ? HttpResponseBuilder.send(request.response).ok(
              HttpStatus.ok,
              body: jsonEncode({'token': generateJWT(user.username)}),
            )
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.notFound,
              body: 'User Not Found',
            );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }
}