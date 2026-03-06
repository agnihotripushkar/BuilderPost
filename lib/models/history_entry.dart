import 'dart:convert';
import 'package:uuid/uuid.dart';

class HistoryEntry {
  final String id;
  final String projectTitle;
  final String platform;
  final String tone;
  final String content;
  final DateTime savedAt;

  const HistoryEntry({
    required this.id,
    required this.projectTitle,
    required this.platform,
    required this.tone,
    required this.content,
    required this.savedAt,
  });

  factory HistoryEntry.create({
    required String projectTitle,
    required String platform,
    required String tone,
    required String content,
  }) {
    return HistoryEntry(
      id: const Uuid().v4(),
      projectTitle: projectTitle,
      platform: platform,
      tone: tone,
      content: content,
      savedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectTitle': projectTitle,
    'platform': platform,
    'tone': tone,
    'content': content,
    'savedAt': savedAt.toIso8601String(),
  };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
    id: json['id'] as String,
    projectTitle: json['projectTitle'] as String,
    platform: json['platform'] as String,
    tone: json['tone'] as String,
    content: json['content'] as String,
    savedAt: DateTime.parse(json['savedAt'] as String),
  );

  static List<HistoryEntry> listFromJson(String rawJson) {
    final list = jsonDecode(rawJson) as List;
    return list
        .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<HistoryEntry> entries) {
    return jsonEncode(entries.map((e) => e.toJson()).toList());
  }
}
