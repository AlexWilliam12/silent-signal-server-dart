import 'dart:convert';
import 'dart:io';

import 'package:mime/mime.dart';
import 'package:silent_signal/database/user_repository.dart';
import 'package:silent_signal/models/sensitive_user.dart';
import 'package:silent_signal/server/http_response_builder.dart';

class PrivateChatController {
  final userRepository = SensitiveUserRepository();
  final broadcast = <String, WebSocket>{};

  Future<HttpResponseBuilder> handleConnection(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    final user = await userRepository.fetchByUsername(claims['username']);
    if (user == null) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.notFound,
        body: 'User Not Found',
      );
    }
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
    final contact = await userRepository.fetchByUsername(parameter);
    if (contact == null) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.notFound,
        body: 'Contact Not Found',
      );
    }
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: 'Invalid Websocket Request',
      );
    }
    final socket = await WebSocketTransformer.upgrade(request);
    broadcast[user.name] = socket;

    socket.listen(
      (message) async {
        try {
          if (message is String) {
            final response = await _handleMessage(user, contact, message);
            socket.add(response);
          } else if (message is List<int>) {
            final response = await _handleFile(message);
            socket.add(response);
          } else {
            await socket.close(HttpStatus.badRequest, 'Invalid Input Type');
          }
        } catch (e) {
          await socket.close(HttpStatus.badRequest, e.toString());
        }
      },
      onDone: () {
        broadcast.remove(user.name);
      },
      onError: (error) {
        print(error);
        broadcast.remove(user.name);
      },
    );
    return HttpResponseBuilder.send(request.response).ok(HttpStatus.ok);
  }

  Future<String> _handleMessage(
    SensitiveUser user,
    SensitiveUser contact,
    String message,
  ) async {
    try {
      final json = jsonDecode(message);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> _handleFile(
    SensitiveUser user,
    SensitiveUser contact,
    List<int> message,
  ) async {
    try {
      final type = lookupMimeType('', headerBytes: message);
    } catch (e) {
      rethrow;
    }
  }
}
