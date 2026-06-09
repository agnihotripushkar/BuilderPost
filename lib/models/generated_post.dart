import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated_post.freezed.dart';

@freezed
abstract class GeneratedPost with _$GeneratedPost {
  const factory GeneratedPost({
    required String draftId,
    required String platform,
    required String content,
    required DateTime generatedAt,
  }) = _GeneratedPost;

  factory GeneratedPost.create({
    required String draftId,
    required String platform,
    required String content,
  }) =>
      GeneratedPost(
        draftId: draftId,
        platform: platform,
        content: content,
        generatedAt: DateTime.now(),
      );
}
