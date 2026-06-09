import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/services/github_service.dart';

/// Returns canned responses keyed by full request URL; 404 for anything else.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.routes);
  final Map<String, (int, String)> routes;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final entry = routes[options.uri.toString()];
    if (entry == null) return ResponseBody.fromString('not found', 404);
    return ResponseBody.fromString(
      entry.$2,
      entry.$1,
      headers: {
        Headers.contentTypeHeader: ['text/plain'],
      },
    );
  }
}

GithubService _service(Map<String, (int, String)> routes) {
  final dio = Dio(BaseOptions(responseType: ResponseType.plain))
    ..httpClientAdapter = _FakeAdapter(routes);
  return GithubService(dio: dio);
}

void main() {
  const mainUrl = 'https://raw.githubusercontent.com/u/r/main/README.md';
  const masterUrl = 'https://raw.githubusercontent.com/u/r/master/README.md';

  test('maps github.com repo URL to raw main README', () async {
    final svc = _service({mainUrl: (200, '# Hello from main')});
    final readme = await svc.fetchReadme('https://github.com/u/r');
    expect(readme, '# Hello from main');
  });

  test('falls back to master when main 404s', () async {
    final svc = _service({masterUrl: (200, '# Hello from master')});
    final readme = await svc.fetchReadme('https://github.com/u/r');
    expect(readme, '# Hello from master');
  });

  test('uses an already-raw URL directly', () async {
    final svc = _service({mainUrl: (200, 'raw body')});
    final readme = await svc.fetchReadme(mainUrl);
    expect(readme, 'raw body');
  });

  test('returns null for a non-github URL', () async {
    final svc = _service({});
    expect(await svc.fetchReadme('https://example.com/foo'), isNull);
  });

  test('returns null when README is missing everywhere', () async {
    final svc = _service({});
    expect(await svc.fetchReadme('https://github.com/u/r'), isNull);
  });
}
