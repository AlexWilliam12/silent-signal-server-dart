import 'dart:io';

class HttpResponseBuilder {
  final HttpResponse response;
  HttpResponseBuilder._(this.response);

  static HttpResponseBuilder send(HttpResponse response) {
    return HttpResponseBuilder._(response);
  }

  HttpResponse ok(int code, {String? body}) {
    if (body != null) {
      return response
        ..statusCode = code
        ..headers.add('Content-Type', 'application/json')
        ..write('$body\n');
    }
    return response..statusCode = code;
  }

  HttpResponse error(int code, {String? body}) {
    if (body != null) {
      return response
        ..statusCode = code
        ..headers.add('Content-Type', 'text/plain')
        ..write('$body\n');
    }
    return response..statusCode = code;
  }
}
