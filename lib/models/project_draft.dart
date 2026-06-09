import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'project_draft.freezed.dart';
part 'project_draft.g.dart';

@freezed
abstract class ProjectDraft with _$ProjectDraft {
  const factory ProjectDraft({
    required String id,
    required String title,
    required String description,
    @Default('') String projectUrl,
    @Default(<String>[]) List<String> imagePaths,
    @Default('peerlist') String platform, // 'peerlist' | 'linkedin' | 'x'
    @Default('professional') String tone, // 'witty' | 'professional' | 'academic' | 'casual'
    required DateTime createdAt,
  }) = _ProjectDraft;

  /// Convenience constructor that mints a fresh id + timestamp.
  factory ProjectDraft.create({
    required String title,
    required String description,
    String projectUrl = '',
    List<String> imagePaths = const [],
    String platform = 'peerlist',
    String tone = 'professional',
  }) =>
      ProjectDraft(
        id: const Uuid().v4(),
        title: title,
        description: description,
        projectUrl: projectUrl,
        imagePaths: imagePaths,
        platform: platform,
        tone: tone,
        createdAt: DateTime.now(),
      );

  factory ProjectDraft.fromJson(Map<String, dynamic> json) =>
      _$ProjectDraftFromJson(json);

  static List<ProjectDraft> listFromJson(String rawJson) {
    final list = jsonDecode(rawJson) as List;
    return list
        .map((e) => ProjectDraft.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<ProjectDraft> drafts) {
    return jsonEncode(drafts.map((d) => d.toJson()).toList());
  }
}
