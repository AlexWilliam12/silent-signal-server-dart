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
        final response = await controller.login(request);
        await response.close();
        break;
      case '/auth/register':
        final response = await controller.register(request);
        await response.close();
        break;
      case '/auth/validate-token':
        final response = await controller.validateToken(request);
        await response.close();
        break;
      case '/auth/validate-hash':
        final response = await controller.validateHash(request);
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
