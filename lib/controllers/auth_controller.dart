import 'dart:convert';
import 'dart:io';

import 'package:silent_signal/database/user_repository.dart';
import 'package:silent_signal/models/sensitive_user.dart';
import 'package:silent_signal/server/http_response_builder.dart';
import 'package:silent_signal/utils/hash.dart';
import 'package:silent_signal/utils/jwt.dart';

class AuthController {
  final repository = SensitiveUserRepository();

  Future<HttpResponseBuilder> login(HttpRequest request) async {
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
              body: jsonEncode({'token': generateJWT(user.name)}),
            )
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.notFound,
              body: 'user not found',
            );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }

  Future<HttpResponseBuilder> register(HttpRequest request) async {
    try {
      final body = await utf8.decoder.bind(request).join();
      final json = jsonDecode(body);
      final isCreated = await repository.create(
        SensitiveUser.dto(
          name: json['username']!,
          password: json['password']!,
          credentialsHash: generateCredentialsHash(
            json['username']!,
            json['password']!,
          ),
        ),
      );
      return isCreated
          ? HttpResponseBuilder.send(request.response).ok(HttpStatus.ok)
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.internalServerError,
              body: 'unable to create user',
            );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }

  Future<HttpResponseBuilder> validateToken(HttpRequest request) async {
    try {
      final header = request.headers['Authorization'];
      if (header == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.forbidden,
          body: 'forbidden',
        );
      }
      final token = header.first.substring(7).trim();
      if (!validateJWT(token)) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.unauthorized,
          body: 'unauthorized request',
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

  Future<HttpResponseBuilder> validateHash(HttpRequest request) async {
    try {
      final body = await utf8.decoder.bind(request).join();
      final json = jsonDecode(body);
      final user = await repository.fetchByHash(json['credentials_hash']!);
      return user != null
          ? HttpResponseBuilder.send(request.response).ok(
              HttpStatus.ok,
              body: jsonEncode({'token': generateJWT(user.name)}),
            )
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.notFound,
              body: 'user not found',
            );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }
}
