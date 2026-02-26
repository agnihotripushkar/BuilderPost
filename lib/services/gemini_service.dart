import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/extracted_project.dart';

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

  /// Extracts a list of projects from a PDF file (e.g., Resume or LinkedIn profile).
  Future<List<ExtractedProject>> extractProjectsFromPdf(String pdfPath) async {
    final systemContext = '''
You are an expert technical recruiter and resume parser.
I will provide you with a PDF document (a resume or LinkedIn profile).
Your job is to extract all software engineering, data science, or technical projects from this document.

For each project, you should extract its title and a description.
The description should combine any bullet points, summarizing what the project is, the tech stack used, and any achievements.

Output the result STRICTLY as a JSON array of objects, where each object has "title" and "description" keys.
Do not wrap the JSON in Markdown formatting blocks (e.g., no ```json ... ```). Output raw valid JSON only.

Example format:
[
  {
    "title": "E-commerce Backend",
    "description": "Built a scalable backend using Node.js and PostgreSQL. Handled 10k daily requests and reduced latency by 30%."
  }
]
''';

    final content = <Part>[TextPart(systemContext)];

    try {
      final file = File(pdfPath);
      final bytes = await file.readAsBytes();
      // Use application/pdf for Gemini 1.5 Flash PDF support
      content.add(DataPart('application/pdf', bytes));

      final response = await _model.generateContent([Content.multi(content)]);
      final rawText = response.text?.trim() ?? '[]';
      
      // Attempt to clean up markdown if the model hallucinated it anyway
      final cleanedText = _cleanJsonString(rawText);

      return ExtractedProject.listFromJson(cleanedText);
    } catch (e) {
      print('Error extracting from PDF: $e');
      return [];
    }
  }

  String _cleanJsonString(String raw) {
    var cleaned = raw.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    return cleaned.trim();
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
