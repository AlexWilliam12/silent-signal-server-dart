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
      print(e);
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
      print(e);
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
      print(e);
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
      final parameter = request.uri.queryParameters['name'];
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
      print(e);
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }

  Future<HttpResponseBuilder> deleteContact(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    try {
      final user = await repository.fetchData(claims['username']);
      if (user == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.notFound,
          body: "User '${claims['username']}' Not Found",
        );
      }
      final body = await utf8.decoder.bind(request).join();
      final json = jsonDecode(body) as List;

      final contacts = user.contacts.map((contact) => contact.name!).where(
        (contact) {
          for (var element in json) {
            if (element['name'] == contact) {
              return true;
            }
          }
          return false;
        },
      ).toList();

      return await repository.deleteContacts(user.id!, contacts)
          ? HttpResponseBuilder.send(request.response).ok(
              HttpStatus.ok,
            )
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.internalServerError,
              body: 'unable to save contact',
            );
    } catch (e) {
      print(e);
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

      final isUpdated = await repository.updateTemporaryMessages(
        user!.name,
        json['time'],
      );
      return isUpdated
          ? HttpResponseBuilder.send(request.response).ok(HttpStatus.ok)
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.internalServerError,
              body: 'unable to update temporary messages',
            );
    } catch (e) {
      print(e);
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.internalServerError,
        body: e.toString(),
      );
    }
  }
}
