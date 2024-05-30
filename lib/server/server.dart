import 'dart:io';

import 'package:silent_signal/configs/environment.dart';
import 'package:silent_signal/handlers/auth_handler.dart';
import 'package:silent_signal/handlers/group_handler.dart';
import 'package:silent_signal/handlers/upload_handler.dart';
import 'package:silent_signal/handlers/user_handler.dart';
import 'package:silent_signal/handlers/websocket_handler.dart';
import 'package:silent_signal/server/http_handler.dart';
import 'package:silent_signal/server/http_method.dart';

class Server {
  static final Map<String, HttpHandler> _router = _getRoutes();

  Future<void> start() async {
    final server = await HttpServer.bind(
      InternetAddress(Environment.getProperty('SERVER_HOST')!),
      int.parse(Environment.getProperty('SERVER_PORT')!),
    );
    print(
      'Server is running at http://${server.address.address}:${server.port}',
    );

    await for (final request in server) {
      _handleRequest(request);
    }
  }

  Future<void> _handleRequest(HttpRequest request) async {
    try {
      final path = '${request.uri.path} ${request.method}'.trim();
      final handler = _router[path];
      if (handler != null) {
        HttpMethod? method = HttpMethod.values.firstWhere(
          (e) => e.name == request.method,
        );
        switch (method) {
          case HttpMethod.GET:
            if (request.headers.value('upgrade') == 'websocket') {
              await handler.handleRequest(request);
            } else {
              await handler.handleGet(request);
            }
            break;
          case HttpMethod.POST:
            await handler.handlePost(request);
            break;
          case HttpMethod.PUT:
            await handler.handlePut(request);
            break;
          case HttpMethod.DELETE:
            await handler.handleDelete(request);
            break;
          default:
            request.response
              ..statusCode = HttpStatus.methodNotAllowed
              ..headers.add('Content-Type', 'texte/plain')
              ..write('method not implemented')
              ..close();
        }
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..headers.add('Content-Type', 'texte/plain')
          ..write('route not found')
          ..close();
      }
    } catch (e) {
      print(e);
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.add('Content-Type', 'texte/plain')
        ..write(e.toString())
        ..close();
    }
  }

  static Map<String, HttpHandler> _getRoutes() {
    return {
      '/auth/login ${HttpMethod.POST.name}': AuthHandler(),
      '/auth/register ${HttpMethod.POST.name}': AuthHandler(),
      '/auth/validate/token ${HttpMethod.POST.name}': AuthHandler(),
      '/auth/validate/hash ${HttpMethod.POST.name}': AuthHandler(),
      '/user ${HttpMethod.GET.name}': UserHandler(),
      '/user ${HttpMethod.PUT.name}': UserHandler(),
      '/user ${HttpMethod.DELETE.name}': UserHandler(),
      '/user/contact ${HttpMethod.POST.name}': UserHandler(),
      '/user/temporary/messages ${HttpMethod.POST.name}': UserHandler(),
      '/group ${HttpMethod.GET.name}': GroupHandler(),
      '/group ${HttpMethod.POST.name}': GroupHandler(),
      '/group ${HttpMethod.PUT.name}': GroupHandler(),
      '/group ${HttpMethod.DELETE.name}': GroupHandler(),
      '/groups ${HttpMethod.GET.name}': GroupHandler(),
      '/group/member ${HttpMethod.POST.name}': GroupHandler(),
      '/uploads ${HttpMethod.GET.name}': UploadHandler(),
      '/upload/user/picture ${HttpMethod.POST.name}': UploadHandler(),
      '/upload/user/picture ${HttpMethod.PUT.name}': UploadHandler(),
      '/upload/group/picture ${HttpMethod.POST.name}': UploadHandler(),
      '/upload/group/picture ${HttpMethod.PUT.name}': UploadHandler(),
      '/upload/private/chat ${HttpMethod.POST.name}': UploadHandler(),
      '/upload/group/chat ${HttpMethod.POST.name}': UploadHandler(),
      '/chat/private ${HttpMethod.GET.name}': WebsocketHandler(),
      '/chat/group ${HttpMethod.GET.name}': WebsocketHandler(),
    };
  }
}
