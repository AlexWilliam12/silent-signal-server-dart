import 'dart:io';

import 'package:silent_signal/controllers/group_controller.dart';
import 'package:silent_signal/server/http_handler.dart';

class GroupHandler extends HttpHandler {
  final controller = GroupController();

  @override
  Future<void> handleGet(HttpRequest request) async {
    final claims = await doFilter(request);
    if (claims != null) {
      final path = request.uri.path;
      if (path == '/group') {
        await controller.fetchSingle(request);
      } else if (path == '/groups') {
        await controller.fetchAll(request);
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..headers.add('Content-Type', 'text/plain')
          ..write('route not found')
          ..close();
      }
    }
  }

  @override
  Future<void> handlePost(HttpRequest request) async {
    final claims = await doFilter(request);
    if (claims != null) {
      final path = request.uri.path;
      if (path == '/group') {
        await controller.create(request, claims);
      } else if (path == '/group/member') {
        await controller.saveMember(request, claims);
      } else {
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
      await controller.update(request, claims);
    }
  }

  @override
  Future<void> handleDelete(HttpRequest request) async {
    final claims = await doFilter(request);
    if (claims != null) {
      await controller.delete(request, claims);
    }
  }
}
