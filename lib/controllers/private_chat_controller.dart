import 'dart:convert';
import 'dart:io';

import 'package:mime/mime.dart';
import 'package:silent_signal/database/message_repository.dart';
import 'package:silent_signal/database/user_repository.dart';
import 'package:silent_signal/models/sensitive_user.dart';
import 'package:silent_signal/server/http_response_builder.dart';

class PrivateChatController {
  final userRepository = SensitiveUserRepository();
  final messageRepository = MessageRepository();
  final broadcast = <String, WebSocket>{};

  Future<void> handleConnection(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    final user = await userRepository.fetchByUsername(claims['username']);
    if (user == null) {
      HttpResponseBuilder.send(request.response).error(
        HttpStatus.notFound,
        body: 'User Not Found',
      );
      return;
    }
    final uri = request.uri;
    if (!uri.hasQuery && uri.query != 'contact') {
      HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: "Query Key 'contact' Was Not Found",
      );
      return;
    }
    final parameter = uri.queryParameters['contact'];
    if (parameter == null || parameter.isEmpty) {
      HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: "Query Parameter Cannot Be Empty",
      );
      return;
    }
    final contact = await userRepository.fetchByUsername(parameter);
    if (contact == null) {
      HttpResponseBuilder.send(request.response).error(
        HttpStatus.notFound,
        body: 'Contact Not Found',
      );
      return;
    }
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: 'Invalid Websocket Request',
      );
      return;
    }
    final socket = await WebSocketTransformer.upgrade(request);
    broadcast[user.name] = socket;

    try {
      final messages = await messageRepository.fetchAllPrivateMessages(
        user.name,
      );
      socket.add(jsonEncode(messages));

      socket.listen(
        (message) async {
          if (message is String) {
            final response = await _handleMessage(user, contact, message);
            socket.add(response);
          } else if (message is List<int>) {
            final response = await _handleFile(user, contact, message);
            socket.add(response);
          } else {
            throw ArgumentError('Invalid Input Type');
          }
        },
        onDone: () {
          broadcast.remove(user.name);
        },
        onError: (error) {
          print(error);
          broadcast.remove(user.name);
        },
        cancelOnError: false,
      );
    } catch (e) {
      print(e);
      broadcast.remove(user.name);
      await socket.close();
      return;
    }
    socket.close(HttpStatus.ok);
  }

  Future<String> _handleMessage(
    SensitiveUser user,
    SensitiveUser contact,
    String message,
  ) async {
    try {
      return '';
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
      return '';
    } catch (e) {
      rethrow;
    }
  }
}
