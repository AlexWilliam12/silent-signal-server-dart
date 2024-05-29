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
  static final broadcast = <String, WebSocket>{};

  Future<void> handleConnection(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    final user = await userRepository.fetchByUsername(claims['username']);
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: 'invalid websocket request',
      );
      return;
    }
    final socket = await WebSocketTransformer.upgrade(request);
    broadcast[user!.name] = socket;

    try {
      final messages = await messageRepository.fetchAllPrivateMessages(
        user.name,
      );
      socket.add(jsonEncode(messages));
      _updatePendingSituation(messages);

      socket.listen(
        (content) async {
          try {
            if (content is String) {
              final message = jsonDecode(content);
              await _handleMessage(user, message);
              socket.add(
                jsonEncode({
                  'sender': user.name,
                  'recipient': message['recipient'],
                  'type': message['type'],
                  'content': message['content'],
                }),
              );
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
    }
  }

  Future<void> _handleMessage(SensitiveUser sender, message) async {
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
          isTemporaryMessage: sender.temporaryMessageInterval != null,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _updatePendingSituation(List<PrivateMessage> messages) async {
    if (messages.isNotEmpty) {
      final ids = messages.map((message) => message.id!).toList();
      await messageRepository.updatePrivateMessagesPendingSituation(ids);
    }
  }
}
