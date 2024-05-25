import 'dart:io';

import 'package:silent_signal/controllers/upload_controller.dart';
import 'package:silent_signal/server/http_handler.dart';

class UploadHandler extends HttpHandler {
  final controller = UploadController();

  @override
  Future<void> handleGet(HttpRequest request) async {
    final claims = await doFilter(request);
    if (claims != null) {
      final path = request.uri.path;
      switch (path) {
        case '/upload/picture/user':
          final response = await controller.fetchUserPicture(
            request,
            claims,
          );
          await response.close();
          break;
        case '/upload/picture/group':
          final response = await controller.fetchGroupPicture(
            request,
            claims,
          );
          await response.close();
          break;
        case '/upload/chat/user':
          final response = await controller.fetchPrivateChatPicture(
            request,
            claims,
          );
          await response.close();
          break;
        case '/upload/chat/group':
          final response = await controller.fetchGroupChatPicture(
            request,
            claims,
          );
          await response.close();
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
  Future<void> handlePost(HttpRequest request) async {
    final claims = await doFilter(request);
    if (claims != null) {
      final path = request.uri.path;
      switch (path) {
        case '/upload/picture/user':
          final response = await controller.uploadUserPicture(
            request,
            claims,
          );
          await response.close();
          break;
        case '/upload/picture/group':
          final response = await controller.uploadGroupPicture(
            request,
            claims,
          );
          await response.close();
          break;
        case '/upload/chat/user':
          final response = await controller.uploadPrivateChatPicture(
            request,
            claims,
          );
          await response.close();
          break;
        case '/upload/chat/group':
          final response = await controller.uploadGroupChatPicture(
            request,
            claims,
          );
          await response.close();
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
          break;
        case '/upload/picture/group':
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
