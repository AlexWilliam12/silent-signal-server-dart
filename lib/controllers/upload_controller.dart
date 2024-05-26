import 'dart:io';
import 'dart:math';

import 'package:mime/mime.dart';
import 'package:silent_signal/configs/environment.dart';
import 'package:silent_signal/database/group_repository.dart';
import 'package:silent_signal/database/upload_repository.dart';
import 'package:silent_signal/database/user_repository.dart';
import 'package:silent_signal/server/http_response_builder.dart';

class UploadController {
  final uploadRepository = UploadRepository();
  final userRepository = SensitiveUserRepository();
  final groupRepository = GroupRepository();

  Future<HttpResponseBuilder> uploadUserPicture(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    try {
      final user = await userRepository.fetchByUsername(claims['username']!);
      if (user == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.notFound,
          body: 'User Not Found',
        );
      }
      if (user.picture != null) {
        final path = 'uploads/${user.picture!.substring(
          user.picture!.lastIndexOf('=') + 1,
        )}';
        await _delete(path);
      }
      final path = await _upload(request);
      if (path == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.internalServerError,
          body: 'Unable To Upload Picture',
        );
      }
      return await uploadRepository.saveUserPicture(user.id, path)
          ? HttpResponseBuilder.send(request.response).ok(HttpStatus.ok)
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.badRequest,
              body: 'Unable To Upload Picture',
            );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }

  Future<HttpResponseBuilder> uploadGroupPicture(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    try {
      final user = await userRepository.fetchByUsername(claims['username']!);
      if (user == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.notFound,
          body: 'User Not Found',
        );
      }
      final uri = request.uri;
      if (!uri.hasQuery && uri.query != 'groupName') {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.badRequest,
          body: "Query Key 'groupName' Was Not Found",
        );
      }
      final parameter = uri.queryParameters['groupName'];
      if (parameter == null || parameter.isEmpty) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.badRequest,
          body: "Query Parameter Cannot Be Empty",
        );
      }
      final group = await groupRepository.fetchByGroupNameAndCreator(
        parameter,
        user.id,
      );
      if (group == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.notFound,
          body: 'Group Not Found',
        );
      }
      if (group.picture != null) {
        final path = 'uploads/${group.picture!.substring(
          group.picture!.lastIndexOf('=') + 1,
        )}';
        await _delete(path);
      }
      final path = await _upload(request);
      if (path == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.internalServerError,
          body: 'Unable To Upload Picture',
        );
      }
      return await uploadRepository.saveGroupPicture(group.id, user.id, path)
          ? HttpResponseBuilder.send(request.response).ok(HttpStatus.ok)
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.badRequest,
              body: 'Unable To Upload Picture',
            );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }

  Future<HttpResponseBuilder> uploadPrivateChatFile(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    await _upload(request);
    return HttpResponseBuilder.send(request.response).ok(200);
  }

  Future<HttpResponseBuilder> uploadGroupChatFile(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    await _upload(request);
    return HttpResponseBuilder.send(request.response).ok(200);
  }

  Future<HttpResponseBuilder> fetchFile(HttpRequest request) async {
    final uri = request.uri;
    if (!uri.hasQuery && uri.query != 'file') {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: "Query Key 'file' Was Not Found",
      );
    }
    final parameter = uri.queryParameters['file'];
    if (parameter == null || parameter.isEmpty) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: "Query Parameter Cannot Be Empty",
      );
    }
    final path = 'uploads/$parameter';
    final file = File(path);
    if (!await file.exists()) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.notFound,
        body: 'Picture Not Found',
      );
    }
    final type = lookupMimeType(path) ?? 'application/octet-stream';
    return HttpResponseBuilder.send(request.response).file(type, file);
  }

  Future<String?> _upload(HttpRequest request) async {
    try {
      if (request.headers.contentType!.mimeType != 'multipart/form-data') {
        throw ArgumentError('Invalid Content Type');
      }
      final boundary = request.headers.contentType!.parameters['boundary'];
      if (boundary == null) {
        throw ArgumentError('Boundary Not Found');
      }
      final transformer = MimeMultipartTransformer(boundary);
      final stream = request.cast<List<int>>().transform(transformer);

      String? url;
      await for (final part in stream) {
        final disposition = part.headers['content-disposition'];
        if (disposition == null) continue;

        final header = HeaderValue.parse(disposition, parameterSeparator: ';');
        final name = header.parameters['name'];
        final filename = header.parameters['filename'];

        if (name != 'file' || filename == null) {
          throw ArgumentError('Invalid Content');
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final extension = filename.split('.').last;

        final filenamePath = '$timestamp${Random().nextInt(999999)}.$extension';
        final file = File('uploads/$filenamePath');
        final host = Environment.getProperty('SERVER_HOST')!;
        final port = Environment.getProperty('SERVER_PORT')!;
        await part.pipe(file.openWrite());

        url = 'http://$host:$port/uploads?file=$filenamePath';
      }
      return url;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _delete(String path) async {
    try {
      final file = File(path);
      await file.delete();
    } catch (e) {
      rethrow;
    }
  }
}
