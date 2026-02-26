import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Replace with your actual Gemini API key.
/// Get one at: https://aistudio.google.com/app/apikey
const _kGeminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _kGeminiApiKey);
  }

  Future<String> generatePost({
    required String description,
    required String platform,
    required String tone,
    List<String> imagePaths = const [],
    String? readmeContent,
  }) async {
    final platformPrompt = _platformPrompt(platform);
    final toneLabel = _toneLabel(tone);

    final systemContext = '''
You are an expert developer advocate who writes viral social media posts for the developer community.
Generate a single $platform post for the following project.

Platform requirements: $platformPrompt
Tone: $toneLabel

Project Description:
$description
${readmeContent != null ? '\nProject README / Context:\n$readmeContent' : ''}

Guidelines:
- Make it authentic, engaging, and platform-native.
- Use emojis where appropriate for $platform.
- Include relevant hashtags at the end.
- Format for $platform's best practices.
- Do NOT add any preamble like "Here is your post:". Just output the post directly.
''';

    final content = <Part>[TextPart(systemContext)];

    // Attach images (up to 3)
    for (final path in imagePaths.take(3)) {
      try {
        final file = File(path);
        final bytes = await file.readAsBytes();
        final mimeType = _mimeTypeFromPath(path);
        content.add(DataPart(mimeType, bytes));
      } catch (_) {
        // Skip unreadable images
      }
    }

    final response = await _model.generateContent([Content.multi(content)]);
    return response.text?.trim() ??
        'Unable to generate post. Please try again.';
  }

  String _platformPrompt(String platform) {
    switch (platform.toLowerCase()) {
      case 'peerlist':
        return 'Focus on Proof of Work, tech stack used, key challenges overcome, and what makes this project unique for developers.';
      case 'linkedin':
        return 'Focus on career growth, professional impact, business value, and achievements. Use a storytelling format.';
      case 'x':
        return 'Write a punchy thread-style hook (the first tweet) focused on "Build in Public." Max 280 characters for the opener. Then optionally add a 2-3 thread continuation.';
      default:
        return 'Write an engaging developer-focused post.';
    }
  }

  String _toneLabel(String tone) {
    switch (tone.toLowerCase()) {
      case 'witty':
        return 'Witty and humorous — use clever wordplay and light jokes while staying professional.';
      case 'professional':
        return 'Professional and polished — authoritative but approachable.';
      case 'academic':
        return 'Academic and technical — detailed, precise, and analytical.';
      case 'casual':
        return 'Casual and conversational — like talking to a friend in the dev community.';
      default:
        return 'Professional';
    }
  }

  String _mimeTypeFromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/png';
  }
}
