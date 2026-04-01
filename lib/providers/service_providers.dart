import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/github_service.dart';
import '../services/key_storage_service.dart';

/// Singleton GitHub service — no dependencies, safe to share.
final githubServiceProvider = Provider<GithubService>((_) => GithubService());

/// Reads the Gemini API key from secure storage.
/// Invalidate this provider after saving or clearing the key so all
/// dependents (ComposerNotifier, ResumeProjectsScreen) pick up the change.
final apiKeyProvider = FutureProvider<String?>((ref) => KeyStorageService.getKey());
