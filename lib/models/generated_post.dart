class GeneratedPost {
  final String draftId;
  final String platform;
  final String content;
  final DateTime generatedAt;

  const GeneratedPost({
    required this.draftId,
    required this.platform,
    required this.content,
    required this.generatedAt,
  });

  factory GeneratedPost.create({
    required String draftId,
    required String platform,
    required String content,
  }) {
    return GeneratedPost(
      draftId: draftId,
      platform: platform,
      content: content,
      generatedAt: DateTime.now(),
    );
  }
}
