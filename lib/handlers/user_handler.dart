import 'dart:io';

import 'package:silent_signal/controllers/user_controller.dart';
import 'package:silent_signal/server/http_handler.dart';

class UserHandler extends HttpHandler {
  final controller = UserController();

  @override
  Future<void> handleGet(HttpRequest request) async {
    final claims = await doFilter(request);
    if (claims != null) {
      await controller.fetch(request, claims);
    }
  }

  @override
  Future<void> handlePost(HttpRequest request) async {
    final claims = await doFilter(request);
    if (claims != null) {
      await controller.saveContact(request, claims);
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
