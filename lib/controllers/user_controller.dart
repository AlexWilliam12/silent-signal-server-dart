import 'dart:convert';
import 'dart:io';

import 'package:silent_signal/database/user_repository.dart';
import 'package:silent_signal/server/http_response_builder.dart';

class UserController {
  final repository = SensitiveUserRepository();

  Future<HttpResponseBuilder> fetch(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    try {
      final user = await repository.fetchData(claims['username']);
      return HttpResponseBuilder.send(request.response).ok(
        HttpStatus.ok,
        body: jsonEncode(user),
      );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }

  Future<HttpResponseBuilder> update(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    try {
      final user = await repository.fetchByUsername(claims['username']);

      final body = await utf8.decoder.bind(request).join();
      final json = jsonDecode(body);

      user!.name = json['username'] ?? user.name;
      user.password = json['password'] ?? user.password;

      final isUpdated = await repository.update(user);
      return isUpdated
          ? HttpResponseBuilder.send(request.response).ok(
              HttpStatus.ok,
            )
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.internalServerError,
              body: 'unable to update user',
            );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }

  Future<HttpResponseBuilder> delete(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    try {
      final isDeleted = await repository.delete(claims['username']);
      return isDeleted
          ? HttpResponseBuilder.send(request.response).ok(
              HttpStatus.ok,
            )
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.internalServerError,
              body: 'unable to delete user',
            );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }

  Future<HttpResponseBuilder> saveContact(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    try {
      final parameter = request.uri.queryParameters['contact'];
      if (parameter == null || parameter.isEmpty) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.badRequest,
          body: "query parameter cannot be empty",
        );
      }
      final user = await repository.fetchByUsername(claims['username']);
      if (user == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.notFound,
          body: "User '${claims['username']}' Not Found",
        );
      }
      final contact = await repository.fetchByUsername(parameter);
      if (contact == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.notFound,
          body: "user '$parameter' not found",
        );
      }
      return await repository.saveContact(user.id!, contact.id!)
          ? HttpResponseBuilder.send(request.response).ok(
              HttpStatus.ok,
            )
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.internalServerError,
              body: 'unable to save contact',
            );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }

  Future<HttpResponseBuilder> enableTemporaryMessages(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    try {
      final user = await repository.fetchByUsername(claims['username']);

      final body = await utf8.decoder.bind(request).join();
      final json = jsonDecode(body);

      user!.temporaryMessageInterval = json['time'];
      final isUpdated = await repository.updateTemporaryMessages(
        user.name,
        user.temporaryMessageInterval,
      );
      return isUpdated
          ? HttpResponseBuilder.send(request.response).ok(HttpStatus.ok)
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.internalServerError,
              body: 'unable to update temporary messages',
            );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.internalServerError,
        body: e.toString(),
      );
    }
  }
}
