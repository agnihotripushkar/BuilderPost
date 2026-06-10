import 'package:dio/dio.dart';

class GithubService {
  final Dio _dio;

  GithubService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              // README is plain text — don't let Dio try to JSON-decode it.
              responseType: ResponseType.plain,
            ));

  /// Fetches the raw README content from a GitHub repository URL.
  /// Accepts URLs like:
  ///   - https://github.com/user/repo
  ///   - https://github.com/user/repo/tree/main
  ///   - https://raw.githubusercontent.com/user/repo/main/README.md
  Future<String?> fetchReadme(String url) async {
    final rawUrl = _toRawUrl(url);
    if (rawUrl == null) return null;

    // Try the requested/derived branch, then fall back to `master`.
    for (final candidate in _candidates(rawUrl)) {
      try {
        final response = await _dio.get<String>(candidate);
        if (response.statusCode == 200 && response.data != null) {
          return response.data;
        }
      } on DioException {
        // Try next candidate (404 on `main` is common for older repos).
        continue;
      }
    }
    return null;
  }

  /// Yields the raw URL plus a `master`-branch fallback when applicable.
  Iterable<String> _candidates(String rawUrl) sync* {
    yield rawUrl;
    if (rawUrl.contains('/main/')) {
      yield rawUrl.replaceFirst('/main/', '/master/');
    }
  }

  String? _toRawUrl(String url) {
    // Already a raw URL
    if (url.contains('raw.githubusercontent.com')) return url;

    // Parse github.com/user/repo
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.host.contains('github.com')) return null;

    final segments = uri.pathSegments;
    if (segments.length < 2) return null;

    final user = segments[0];
    final repo = segments[1];

    return 'https://raw.githubusercontent.com/$user/$repo/main/README.md';
  }
}
