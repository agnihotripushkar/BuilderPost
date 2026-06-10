import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/models/project_draft.dart';
import 'package:my_app/models/history_entry.dart';
import 'package:my_app/models/extracted_project.dart';

void main() {
  group('ProjectDraft', () {
    test('create() mints id + createdAt and keeps defaults', () {
      final d = ProjectDraft.create(title: 'T', description: 'D');
      expect(d.id, isNotEmpty);
      expect(d.platform, 'peerlist');
      expect(d.tone, 'professional');
      expect(d.imagePaths, isEmpty);
      expect(d.createdAt, isA<DateTime>());
    });

    test('json roundtrip preserves all fields', () {
      final d = ProjectDraft.create(
        title: 'BuilderPost',
        description: 'AI post generator',
        projectUrl: 'https://github.com/u/r',
        imagePaths: ['/a.png', '/b.png'],
        platform: 'linkedin',
        tone: 'witty',
      );
      final back = ProjectDraft.fromJson(d.toJson());
      expect(back, d);
    });

    test('list helpers roundtrip', () {
      final list = [
        ProjectDraft.create(title: 'A', description: 'a'),
        ProjectDraft.create(title: 'B', description: 'b'),
      ];
      final restored = ProjectDraft.listFromJson(ProjectDraft.listToJson(list));
      expect(restored, list);
    });

    test('copyWith changes only named field', () {
      final d = ProjectDraft.create(title: 'A', description: 'a');
      final c = d.copyWith(platform: 'x');
      expect(c.platform, 'x');
      expect(c.id, d.id);
      expect(c.title, d.title);
    });

    test('fromJson tolerates missing optional keys', () {
      final d = ProjectDraft.fromJson({
        'id': '1',
        'title': 'T',
        'description': 'D',
        'imagePaths': <String>[],
        'createdAt': DateTime.now().toIso8601String(),
      });
      expect(d.projectUrl, '');
      expect(d.platform, 'peerlist');
      expect(d.tone, 'professional');
    });
  });

  group('HistoryEntry', () {
    test('json roundtrip', () {
      final e = HistoryEntry.create(
        projectTitle: 'P',
        platform: 'x',
        tone: 'casual',
        content: 'hello world',
      );
      expect(HistoryEntry.fromJson(e.toJson()), e);
    });

    test('list helpers roundtrip', () {
      final list = [
        HistoryEntry.create(projectTitle: 'P', platform: 'x', tone: 't', content: 'c'),
      ];
      expect(HistoryEntry.listFromJson(HistoryEntry.listToJson(list)), list);
    });
  });

  group('ExtractedProject', () {
    test('listFromJson parses a JSON array', () {
      const raw = '[{"title":"A","description":"a"},{"title":"B","description":"b"}]';
      final list = ExtractedProject.listFromJson(raw);
      expect(list, hasLength(2));
      expect(list.first.title, 'A');
    });

    test('listFromJson returns [] on malformed input', () {
      expect(ExtractedProject.listFromJson('not json'), isEmpty);
      expect(ExtractedProject.listFromJson('{"not":"a list"}'), isEmpty);
    });

    test('fromJson defaults missing fields', () {
      final p = ExtractedProject.fromJson(<String, dynamic>{});
      expect(p.title, 'Untitled Project');
      expect(p.description, '');
    });
  });
}
