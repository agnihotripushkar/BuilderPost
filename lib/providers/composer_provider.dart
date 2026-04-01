import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_entry.dart';
import '../models/project_draft.dart';
import '../models/generated_post.dart';
import '../services/gemini_service.dart';
import '../providers/service_providers.dart';
import '../providers/history_provider.dart';

enum ComposerStatus { idle, fetchingReadme, generating, done, error }

class ComposerState {
  final ProjectDraft draft;
  final ComposerStatus status;
  final List<GeneratedPost>? generatedPosts;
  final String? errorMessage;

  const ComposerState({
    required this.draft,
    this.status = ComposerStatus.idle,
    this.generatedPosts,
    this.errorMessage,
  });

  ComposerState copyWith({
    ProjectDraft? draft,
    ComposerStatus? status,
    List<GeneratedPost>? generatedPosts,
    String? errorMessage,
  }) {
    return ComposerState(
      draft: draft ?? this.draft,
      status: status ?? this.status,
      generatedPosts: generatedPosts ?? this.generatedPosts,
      errorMessage: errorMessage,
    );
  }
}

final composerProvider =
    AutoDisposeNotifierProvider<ComposerNotifier, ComposerState>(
      ComposerNotifier.new,
    );

class ComposerNotifier extends AutoDisposeNotifier<ComposerState> {
  @override
  ComposerState build() {
    return ComposerState(draft: ProjectDraft.create(title: '', description: ''));
  }

  void updateTitle(String v) =>
      state = state.copyWith(draft: state.draft.copyWith(title: v));

  void updateDescription(String v) =>
      state = state.copyWith(draft: state.draft.copyWith(description: v));

  void updateProjectUrl(String v) =>
      state = state.copyWith(draft: state.draft.copyWith(projectUrl: v));

  void updatePlatform(String v) =>
      state = state.copyWith(draft: state.draft.copyWith(platform: v));

  void updateTone(String v) =>
      state = state.copyWith(draft: state.draft.copyWith(tone: v));

  void addImage(String path) {
    if (state.draft.imagePaths.length >= 3) return;
    state = state.copyWith(
      draft: state.draft.copyWith(
        imagePaths: [...state.draft.imagePaths, path],
      ),
    );
  }

  void removeImage(int index) {
    final updated = [...state.draft.imagePaths];
    updated.removeAt(index);
    state = state.copyWith(draft: state.draft.copyWith(imagePaths: updated));
  }

  Future<void> generate() async {
    final apiKey = await ref.read(apiKeyProvider.future);
    if (apiKey == null) {
      state = state.copyWith(
        status: ComposerStatus.error,
        errorMessage: 'No API key found. Please add your Gemini API key in Settings.',
      );
      return;
    }

    state = state.copyWith(status: ComposerStatus.generating);

    String? readmeContent;
    final url = state.draft.projectUrl;

    if (url.isNotEmpty && url.contains('github.com')) {
      state = state.copyWith(status: ComposerStatus.fetchingReadme);
      readmeContent = await ref.read(githubServiceProvider).fetchReadme(url);
    }

    state = state.copyWith(status: ComposerStatus.generating);

    final gemini = GeminiService(apiKey);

    try {
      final results = await Future.wait(
        List.generate(
          3,
          (_) => gemini.generatePost(
            description: state.draft.description,
            platform: state.draft.platform,
            tone: state.draft.tone,
            imagePaths: state.draft.imagePaths,
            readmeContent: readmeContent,
            projectUrl: url.isNotEmpty ? url : null,
          ),
        ),
      );

      final posts = results
          .map(
            (content) => GeneratedPost.create(
              draftId: state.draft.id,
              platform: state.draft.platform,
              content: content,
            ),
          )
          .toList();

      state = state.copyWith(
        status: ComposerStatus.done,
        generatedPosts: posts,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: ComposerStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Appends [hint] to [originalDescription] and regenerates.
  /// Passing [originalDescription] ensures refinements always build on the
  /// unmodified project description, not a previously-appended hint.
  Future<void> regenerateWithHint(
    String hint, {
    required String originalDescription,
  }) async {
    if (hint.isNotEmpty) {
      state = state.copyWith(
        draft: state.draft.copyWith(
          description: '$originalDescription\n\nUser refinement request: $hint',
        ),
      );
    }
    await generate();
  }

  /// Saves the post at [postIndex] from the current generated results to the
  /// history list. No-op if no posts are available or index is out of range.
  Future<void> saveToHistory(int postIndex) async {
    final posts = state.generatedPosts;
    if (posts == null || postIndex >= posts.length) return;

    final post = posts[postIndex];
    final title =
        state.draft.title.isEmpty ? 'Untitled Project' : state.draft.title;

    final entry = HistoryEntry.create(
      projectTitle: title,
      platform: post.platform,
      tone: state.draft.tone,
      content: post.content,
    );

    await ref.read(historyProvider.notifier).addEntry(entry);
  }

  void reset() {
    state = ComposerState(
      draft: ProjectDraft.create(title: '', description: ''),
    );
  }
}
