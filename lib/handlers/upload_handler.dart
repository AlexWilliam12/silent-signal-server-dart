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
        case '/upload/user/picture':
          await controller.uploadUserPicture(request, claims);
          break;
        case '/upload/group/picture':
          await controller.uploadGroupPicture(request, claims);
          break;
        case '/upload/private/chat':
          await controller.uploadPrivateChatFile(request, claims);
          break;
        case '/upload/group/chat':
          await controller.uploadGroupChatFile(request, claims);
          break;
        default:
          request.response
            ..statusCode = HttpStatus.notFound
            ..headers.add('Content-Type', 'text/plain')
            ..write('route not found')
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
        case '/upload/user/picture':
          await controller.uploadUserPicture(request, claims);
          break;
        case '/upload/group/picture':
          await controller.uploadGroupPicture(request, claims);
          break;
        default:
          request.response
            ..statusCode = HttpStatus.notFound
            ..headers.add('Content-Type', 'text/plain')
            ..write('route not found')
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
