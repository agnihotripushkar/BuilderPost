import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'extracted_project.freezed.dart';
part 'extracted_project.g.dart';

@freezed
abstract class ExtractedProject with _$ExtractedProject {
  const factory ExtractedProject({
    @Default('Untitled Project') String title,
    @Default('') String description,
  }) = _ExtractedProject;

  factory ExtractedProject.fromJson(Map<String, dynamic> json) =>
      _$ExtractedProjectFromJson(json);

  /// Lenient list parser — returns [] on any malformed input
  /// (Gemini occasionally emits non-JSON despite instructions).
  static List<ExtractedProject> listFromJson(String jsonStr) {
    try {
      final parsed = jsonDecode(jsonStr);
      if (parsed is List) {
        return parsed
            .map((e) => ExtractedProject.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
