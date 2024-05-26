import 'dart:io';

import 'package:silent_signal/controllers/group_chat_controller.dart';
import 'package:silent_signal/controllers/private_chat_controller.dart';
import 'package:silent_signal/server/http_handler.dart';

class WebsocketHandler extends HttpHandler {
  @override
  Future<void> handleRequest(HttpRequest request) async {
    final claims = await doFilter(request);
    if (claims != null) {
      final path = request.uri.path;
      if (path == '/chat/private') {
        await PrivateChatController().handleConnection(request, claims);
      } else if (path == '/chat/group') {
        await GroupChatController().handleConnection(request, claims);
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('Route Not Found')
          ..close();
      }
    }
  }
}
