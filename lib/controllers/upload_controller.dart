import 'dart:io';
import 'dart:math';

import 'package:mime/mime.dart';
import 'package:silent_signal/configs/environment.dart';
import 'package:silent_signal/database/group_repository.dart';
import 'package:silent_signal/database/message_repository.dart';
import 'package:silent_signal/database/upload_repository.dart';
import 'package:silent_signal/database/user_repository.dart';
import 'package:silent_signal/models/group_message.dart';
import 'package:silent_signal/models/private_message.dart';
import 'package:silent_signal/models/user.dart';
import 'package:silent_signal/server/http_response_builder.dart';

class UploadController {
  final uploadRepository = UploadRepository();
  final userRepository = SensitiveUserRepository();
  final groupRepository = GroupRepository();
  final messageRepository = MessageRepository();

  Future<HttpResponseBuilder> uploadUserPicture(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    try {
      final user = await userRepository.fetchByUsername(claims['username']!);
      if (user == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.notFound,
          body: 'user not found',
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
          body: 'unable to upload picture',
        );
      }
      return await uploadRepository.saveUserPicture(user.id!, path)
          ? HttpResponseBuilder.send(request.response).created(path)
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.badRequest,
              body: 'unable to upload picture',
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
          body: 'user not found',
        );
      }
      final parameter = request.uri.queryParameters['groupName'];
      if (parameter == null || parameter.isEmpty) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.badRequest,
          body: "query key 'groupName' was not found",
        );
      }
      final group = await groupRepository.fetchByGroupNameAndCreator(
        parameter,
        user.id!,
      );
      if (group == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.notFound,
          body: 'group not found',
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
          body: 'unable to upload picture',
        );
      }
      return await uploadRepository.saveGroupPicture(group.id!, user.id!, path)
          ? HttpResponseBuilder.send(request.response).created(path)
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.badRequest,
              body: 'unable to upload picture',
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
    try {
      final sender = await userRepository.fetchByUsername(claims['username']!);
      if (sender == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.notFound,
          body: 'user not found',
        );
      }
      final recipientParameter = request.uri.queryParameters['recipient'];
      if (recipientParameter == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.badRequest,
          body: "query key 'recipient' was not found",
        );
      }
      final typeParameter = request.uri.queryParameters['type'];
      if (typeParameter == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.badRequest,
          body: "query key 'type' was not found",
        );
      }
      final recipient = await userRepository.fetchByUsername(
        recipientParameter,
      );
      if (recipient == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.notFound,
          body: 'recipient not found',
        );
      }
      final path = await _upload(request);
      if (path == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.internalServerError,
          body: 'unable to upload picture',
        );
      }
      return await messageRepository.savePrivateMessage(
        PrivateMessage.dto(
          type: typeParameter,
          content: path,
          isPending: true,
          sender: User.id(id: sender.id),
          recipient: User.id(id: recipient.id),
        ),
      )
          ? HttpResponseBuilder.send(request.response).created(path)
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.badRequest,
              body: 'unable to upload picture',
            );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }

  Future<HttpResponseBuilder> uploadGroupChatFile(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    try {
      final sender = await userRepository.fetchByUsername(claims['username']!);
      if (sender == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.notFound,
          body: 'user not found',
        );
      }
      final groupParameter = request.uri.queryParameters['group'];
      if (groupParameter == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.badRequest,
          body: "query key 'group' was not found",
        );
      }
      final typeParameter = request.uri.queryParameters['type'];
      if (typeParameter == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.badRequest,
          body: "query key 'type' was not found",
        );
      }
      final group = await groupRepository.fetchByGroupName(groupParameter);
      if (group == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.notFound,
          body: 'group not found',
        );
      }
      final path = await _upload(request);
      if (path == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.internalServerError,
          body: 'unable to upload picture',
        );
      }
      return await messageRepository.saveGroupMessage(
        GroupMessage.dto(
          type: typeParameter,
          content: path,
          sender: User.id(id: sender.id),
          group: group,
        ),
      )
          ? HttpResponseBuilder.send(request.response).created(path)
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.badRequest,
              body: 'unable to upload picture',
            );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }

  Future<HttpResponseBuilder> fetchFile(HttpRequest request) async {
    final parameter = request.uri.queryParameters['file'];
    if (parameter == null || parameter.isEmpty) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: "query key 'file' was not found",
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
        throw ArgumentError('boundary not found');
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
          throw ArgumentError('invalid content');
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final extension = filename.split('.').last;

        final file = '$timestamp${Random().nextInt(999999)}.$extension';
        final host = Environment.getProperty('SERVER_HOST')!;
        final port = Environment.getProperty('SERVER_PORT')!;
        await part.pipe(File('uploads/$file').openWrite());

        url = 'http://$host:$port/uploads?file=$file';
      }
      return url;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _delete(String path) async {
    try {
      await File(path).delete();
    } catch (e) {
      rethrow;
    }
  }
}
