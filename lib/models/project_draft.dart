import 'dart:convert';
import 'package:uuid/uuid.dart';

class ProjectDraft {
  final String id;
  final String title;
  final String description;
  final String projectUrl;
  final List<String> imagePaths;
  final String platform; // 'peerlist' | 'linkedin' | 'x'
  final String tone; // 'witty' | 'professional' | 'academic' | 'casual'
  final DateTime createdAt;

  const ProjectDraft({
    required this.id,
    required this.title,
    required this.description,
    this.projectUrl = '',
    this.imagePaths = const [],
    this.platform = 'peerlist',
    this.tone = 'professional',
    required this.createdAt,
  });

  factory ProjectDraft.create({
    required String title,
    required String description,
    String projectUrl = '',
    List<String> imagePaths = const [],
    String platform = 'peerlist',
    String tone = 'professional',
  }) {
    return ProjectDraft(
      id: const Uuid().v4(),
      title: title,
      description: description,
      projectUrl: projectUrl,
      imagePaths: imagePaths,
      platform: platform,
      tone: tone,
      createdAt: DateTime.now(),
    );
  }

  ProjectDraft copyWith({
    String? title,
    String? description,
    String? projectUrl,
    List<String>? imagePaths,
    String? platform,
    String? tone,
  }) {
    return ProjectDraft(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectUrl: projectUrl ?? this.projectUrl,
      imagePaths: imagePaths ?? this.imagePaths,
      platform: platform ?? this.platform,
      tone: tone ?? this.tone,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'projectUrl': projectUrl,
    'imagePaths': imagePaths,
    'platform': platform,
    'tone': tone,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ProjectDraft.fromJson(Map<String, dynamic> json) => ProjectDraft(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    projectUrl: (json['projectUrl'] as String?) ?? '',
    imagePaths: List<String>.from(json['imagePaths'] as List),
    platform: (json['platform'] as String?) ?? 'peerlist',
    tone: (json['tone'] as String?) ?? 'professional',
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

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
