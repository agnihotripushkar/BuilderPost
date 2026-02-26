import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_draft.dart';
import '../models/generated_post.dart';
import '../services/gemini_service.dart';
import '../services/github_service.dart';

enum ComposerStatus { idle, fetchingReadme, generating, done, error }

class ComposerState {
  final ProjectDraft draft;
  final ComposerStatus status;
  final GeneratedPost? generatedPost;
  final String? errorMessage;

  const ComposerState({
    required this.draft,
    this.status = ComposerStatus.idle,
    this.generatedPost,
    this.errorMessage,
  });

  ComposerState copyWith({
    ProjectDraft? draft,
    ComposerStatus? status,
    GeneratedPost? generatedPost,
    String? errorMessage,
  }) {
    return ComposerState(
      draft: draft ?? this.draft,
      status: status ?? this.status,
      generatedPost: generatedPost ?? this.generatedPost,
      errorMessage: errorMessage,
    );
  }
}

final composerProvider =
    StateNotifierProvider.autoDispose<ComposerNotifier, ComposerState>(
      (ref) => ComposerNotifier(),
    );

class ComposerNotifier extends StateNotifier<ComposerState> {
  final _gemini = GeminiService();
  final _github = GithubService();

  ComposerNotifier()
    : super(
        ComposerState(draft: ProjectDraft.create(title: '', description: '')),
      );

  void updateTitle(String v) =>
      state = state.copyWith(draft: state.draft.copyWith(title: v));

  void updateDescription(String v) =>
      state = state.copyWith(draft: state.draft.copyWith(description: v));

  void updateGithubUrl(String v) =>
      state = state.copyWith(draft: state.draft.copyWith(githubUrl: v));

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
    state = state.copyWith(status: ComposerStatus.generating);

    String? readmeContent;

    // Fetch GitHub README if URL provided
    if (state.draft.githubUrl.isNotEmpty) {
      state = state.copyWith(status: ComposerStatus.fetchingReadme);
      readmeContent = await _github.fetchReadme(state.draft.githubUrl);
    }

    state = state.copyWith(status: ComposerStatus.generating);

    try {
      final content = await _gemini.generatePost(
        description: state.draft.description,
        platform: state.draft.platform,
        tone: state.draft.tone,
        imagePaths: state.draft.imagePaths,
        readmeContent: readmeContent,
      );

      final post = GeneratedPost.create(
        draftId: state.draft.id,
        platform: state.draft.platform,
        content: content,
      );

      state = state.copyWith(
        status: ComposerStatus.done,
        generatedPost: post,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: ComposerStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = ComposerState(
      draft: ProjectDraft.create(title: '', description: ''),
    );
  }
}
