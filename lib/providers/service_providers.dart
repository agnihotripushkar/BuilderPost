import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_service.dart';
import '../services/github_service.dart';
import '../services/key_storage_service.dart';

/// Singleton GitHub service — no dependencies, safe to share.
final githubServiceProvider = Provider<GithubService>((_) => GithubService());

/// Builds a [GeminiService] for a given API key. Exposed as a provider so it
/// can be overridden with a fake in tests (the real one needs a live key).
typedef GeminiServiceFactory = GeminiService Function(String apiKey);

final geminiServiceFactoryProvider = Provider<GeminiServiceFactory>(
  (_) => (apiKey) => GeminiService(apiKey),
);

/// Reads the Gemini API key from secure storage.
/// Invalidate this provider after saving or clearing the key so all
/// dependents (ComposerNotifier, ResumeProjectsScreen) pick up the change.
final apiKeyProvider = FutureProvider<String?>((ref) => KeyStorageService.getKey());
