import 'dart:convert';

class ExtractedProject {
  final String title;
  final String description;

  const ExtractedProject({
    required this.title,
    required this.description,
  });

  factory ExtractedProject.fromJson(Map<String, dynamic> json) {
    return ExtractedProject(
      title: json['title'] ?? 'Untitled Project',
      description: json['description'] ?? '',
    );
  }

  static List<ExtractedProject> listFromJson(String jsonStr) {
    try {
      final parsed = jsonDecode(jsonStr);
      if (parsed is List) {
        return parsed.map((e) => ExtractedProject.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
