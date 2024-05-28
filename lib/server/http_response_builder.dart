import 'dart:io';

class HttpResponseBuilder {
  final HttpResponse response;
  HttpResponseBuilder._(this.response);

  static HttpResponseBuilder send(HttpResponse response) {
    return HttpResponseBuilder._(response);
  }

  HttpResponseBuilder ok(int code, {String? body}) {
    if (body != null) {
      response
        ..statusCode = code
        ..headers.add('Content-Type', 'application/json')
        ..write('$body\n')
        ..close();
    } else {
      response
        ..statusCode = code
        ..close();
    }
    return this;
  }

  HttpResponseBuilder created(String path) {
    response
      ..statusCode = HttpStatus.created
      ..headers.set(HttpHeaders.locationHeader, Uri.parse(path).toString())
      ..close();
    return this;
  }

  HttpResponseBuilder error(int code, {String? body}) {
    if (body != null) {
      response
        ..statusCode = code
        ..headers.add('Content-Type', 'text/plain')
        ..write('$body\n')
        ..close();
    } else {
      response
        ..statusCode = code
        ..close();
    }
    return this;
  }

  Future<HttpResponseBuilder> file(String mimeType, File file) async {
    response.headers.contentType = ContentType.parse(mimeType);
    await file.openRead().pipe(response);
    return this;
  }
}
