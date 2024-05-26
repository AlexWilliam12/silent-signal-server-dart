import 'dart:io';

import 'package:silent_signal/controllers/upload_controller.dart';
import 'package:silent_signal/server/http_handler.dart';

class UploadHandler extends HttpHandler {
  final controller = UploadController();

  @override
  Future<void> handleGet(HttpRequest request) async {
    final claims = await doFilter(request);
    if (claims != null) {
      await controller.fetchFile(request);
    }
  }

  @override
  Future<void> handlePost(HttpRequest request) async {
    final claims = await doFilter(request);
    if (claims != null) {
      final path = request.uri.path;
      switch (path) {
        case '/upload/picture/user':
          await controller.uploadUserPicture(request, claims);
          break;
        case '/upload/picture/group':
          await controller.uploadGroupPicture(request, claims);
          break;
        case '/upload/chat/user':
          await controller.uploadPrivateChatFile(request, claims);
          break;
        case '/upload/chat/group':
          await controller.uploadGroupChatFile(request, claims);
          break;
        default:
          request.response
            ..statusCode = HttpStatus.notFound
            ..write('Route Not Found')
            ..close();
      }
    }
  }

  @override
  Future<void> handlePut(HttpRequest request) async {
    final claims = await doFilter(request);
    if (claims != null) {
      final path = request.uri.path;
      switch (path) {
        case '/upload/picture/user':
          await controller.uploadUserPicture(request, claims);
          break;
        case '/upload/picture/group':
          await controller.uploadGroupPicture(request, claims);
          break;
        case '/upload/chat/user':
          await controller.uploadPrivateChatFile(request, claims);
          break;
        case '/upload/chat/group':
          await controller.uploadGroupChatFile(request, claims);
          break;
        default:
          request.response
            ..statusCode = HttpStatus.notFound
            ..write('Route Not Found')
            ..close();
      }
    }
  }

  @override
  Future<void> handleDelete(HttpRequest request) async {
    final claims = await doFilter(request);
    if (claims != null) {}
  }
}
