import 'dart:io';
import 'dart:math';

import 'package:mime/mime.dart';
import 'package:silent_signal/database/upload_repository.dart';
import 'package:silent_signal/server/http_response_builder.dart';

class UploadController {
  final repository = UploadRepository();

  Future<HttpResponse> uploadUserPicture(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    _upload(request);
    return HttpResponseBuilder.send(request.response).error(200);
  }

  Future<HttpResponse> uploadGroupPicture(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    _upload(request);
    return HttpResponseBuilder.send(request.response).error(200);
  }

  Future<HttpResponse> uploadPrivateChatPicture(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    _upload(request);
    return HttpResponseBuilder.send(request.response).error(200);
  }

  Future<HttpResponse> uploadGroupChatPicture(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    _upload(request);
    return HttpResponseBuilder.send(request.response).error(200);
  }

  Future<HttpResponse> fetchGroupChatPicture(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    _upload(request);
    return HttpResponseBuilder.send(request.response).error(200);
  }

  Future<HttpResponse> fetchPrivateChatPicture(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    _upload(request);
    return HttpResponseBuilder.send(request.response).error(200);
  }

  Future<HttpResponse> fetchGroupPicture(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    _upload(request);
    return HttpResponseBuilder.send(request.response).error(200);
  }

  Future<HttpResponse> fetchUserPicture(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    _upload(request);
    return HttpResponseBuilder.send(request.response).error(200);
  }

  Future<void> _upload(HttpRequest request) async {
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
      await for (var part in stream) {
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

        // final type = lookupMimeType(filename);
        final file = File(
          'uploads/$timestamp${Random().nextInt(999999)}.$extension',
        );

        await part.pipe(file.openWrite());
      }
    } catch (e) {
      rethrow;
    }
  }
}
