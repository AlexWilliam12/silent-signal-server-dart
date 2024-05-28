import 'dart:convert';
import 'dart:io';

import 'package:silent_signal/database/message_repository.dart';
import 'package:silent_signal/database/user_repository.dart';
import 'package:silent_signal/models/private_message.dart';
import 'package:silent_signal/models/sensitive_user.dart';
import 'package:silent_signal/models/user.dart';
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
        body: 'user not found',
      );
      return;
    }
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: 'invalid websocket request',
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
      _updatePendingMessageSituation(messages);

      socket.listen(
        (message) async {
          try {
            if (message is String) {
              await _handleMessage(user, jsonDecode(message));
              socket.add(message);
            } else {
              socket.add('invalid input type');
              await socket.close();
            }
          } catch (e) {
            socket.add(e.toString());
            await socket.close();
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
  }

  Future<void> _handleMessage(
    SensitiveUser sender,
    Map<String, dynamic> message,
  ) async {
    try {
      final recipient = await userRepository.fetchByUsername(
        message['recipient']!,
      );
      if (recipient == null) {
        throw ArgumentError('recipient not found');
      }
      final socket = broadcast[recipient.name];
      bool isPending = true;
      if (socket != null) {
        socket.add(
          jsonEncode({
            'sender': sender.name,
            'recipient': recipient.name,
            'type': message['type'],
            'content': message['content'],
          }),
        );
        isPending = false;
      }
      messageRepository.savePrivateMessage(
        PrivateMessage.dto(
          type: message['type'],
          content: message['content'],
          isPending: isPending,
          sender: User.id(id: sender.id),
          recipient: User.id(id: recipient.id),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  void _updatePendingMessageSituation(List<PrivateMessage> messages) async {
    if (messages.isNotEmpty) {
      final ids = messages.map((message) => message.id!).toList();
      await messageRepository.updatePrivateMessagePendingSituation(ids);
    }
  }
}
