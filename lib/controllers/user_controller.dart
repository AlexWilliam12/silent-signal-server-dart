import 'dart:convert';
import 'dart:io';

import 'package:silent_signal/database/user_repository.dart';
import 'package:silent_signal/server/http_response_builder.dart';

class UserController {
  final repository = SensitiveUserRepository();

  Future<HttpResponse> fetch(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    try {
      final user = await repository.fetchByUsername(claims['username']);
      if (user != null) {
        return HttpResponseBuilder.send(request.response).ok(
          HttpStatus.ok,
          body: jsonEncode(user.toJson()),
        );
      } else {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.badRequest,
          body: 'User Not Found',
        );
      }
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }

  Future<HttpResponse> update(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    try {
      final user = await repository.fetchByUsername(claims['username']);
      if (user == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.notFound,
          body: 'User Not Found',
        );
      }
      final body = await utf8.decoder.bind(request).join();
      final json = jsonDecode(body);
      user.username = json['username'] ?? user.username;
      user.password = json['password'] ?? user.password;
      user.picture = json['picture'] ?? user.picture;
      return await repository.update(user)
          ? HttpResponseBuilder.send(request.response).ok(
              HttpStatus.ok,
            )
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.internalServerError,
              body: 'User Not Updated',
            );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }

  Future<HttpResponse> delete(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    try {
      return await repository.delete(claims['username'])
          ? HttpResponseBuilder.send(request.response).ok(
              HttpStatus.ok,
            )
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.internalServerError,
              body: 'User Not Deleted',
            );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }

  Future<HttpResponse> saveContact(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    try {
      final uri = request.uri;
      if (!uri.hasQuery && uri.query != 'contact') {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.badRequest,
          body: "Query Key 'contact' Was Not Found",
        );
      }
      final parameter = uri.queryParameters['contact'];
      if (parameter == null || parameter.isEmpty) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.badRequest,
          body: "Query Parameter Cannot Be Empty",
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
          body: "User '$parameter' Not Found",
        );
      }
      return await repository.saveContact(user.id, contact.id)
          ? HttpResponseBuilder.send(request.response).ok(
              HttpStatus.ok,
            )
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.internalServerError,
              body: 'Contact Not Saved',
            );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }
}
