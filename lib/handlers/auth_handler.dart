import 'dart:io';

import 'package:silent_signal/controllers/auth_controller.dart';
import 'package:silent_signal/server/http_handler.dart';

class AuthHandler extends HttpHandler {
  @override
  Future<void> handlePost(HttpRequest request) async {
    final path = request.uri.path;
    final controller = AuthController();
    switch (path) {
      case '/auth/login':
        await controller.login(request);
        break;
      case '/auth/register':
        await controller.register(request);
        break;
      case '/auth/validate/token':
        await controller.validateToken(request);
        break;
      case '/auth/validate/hash':
        await controller.validateHash(request);
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
