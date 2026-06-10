import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'history_entry.freezed.dart';
part 'history_entry.g.dart';

@freezed
abstract class HistoryEntry with _$HistoryEntry {
  const factory HistoryEntry({
    required String id,
    required String projectTitle,
    required String platform,
    required String tone,
    required String content,
    required DateTime savedAt,
  }) = _HistoryEntry;

  factory HistoryEntry.create({
    required String projectTitle,
    required String platform,
    required String tone,
    required String content,
  }) =>
      HistoryEntry(
        id: const Uuid().v4(),
        projectTitle: projectTitle,
        platform: platform,
        tone: tone,
        content: content,
        savedAt: DateTime.now(),
      );

  factory HistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$HistoryEntryFromJson(json);

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
