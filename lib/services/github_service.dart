import 'package:http/http.dart' as http;

class GithubService {
  /// Fetches the raw README content from a GitHub repository URL.
  /// Accepts URLs like:
  ///   - https://github.com/user/repo
  ///   - https://github.com/user/repo/tree/main
  ///   - https://raw.githubusercontent.com/user/repo/main/README.md
  Future<String?> fetchReadme(String url) async {
    try {
      final rawUrl = _toRawUrl(url);
      if (rawUrl == null) return null;

      final response = await http.get(Uri.parse(rawUrl));
      if (response.statusCode == 200) {
        return response.body;
      }
      return null;
    } catch (_) {
      return null;
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

    // Try main branch first, then master
    return 'https://raw.githubusercontent.com/$user/$repo/main/README.md';
  }
}
