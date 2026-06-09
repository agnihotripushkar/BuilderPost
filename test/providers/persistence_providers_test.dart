import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/models/project_draft.dart';
import 'package:my_app/models/history_entry.dart';
import 'package:my_app/providers/drafts_provider.dart';
import 'package:my_app/providers/history_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('DraftsNotifier', () {
    test('starts empty', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(draftsProvider), isEmpty);
    });

    test('addDraft prepends and persists', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final d = ProjectDraft.create(title: 'A', description: 'a');
      await c.read(draftsProvider.notifier).addDraft(d);

      expect(c.read(draftsProvider), [d]);

      // Persisted to prefs → a fresh container reloads it.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('builder_post_drafts'), isNotNull);
    });

    test('deleteDraft removes by id', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final notifier = c.read(draftsProvider.notifier);

      final a = ProjectDraft.create(title: 'A', description: 'a');
      final b = ProjectDraft.create(title: 'B', description: 'b');
      await notifier.addDraft(a);
      await notifier.addDraft(b);
      await notifier.deleteDraft(a.id);

      expect(c.read(draftsProvider), [b]);
    });

    test('reloads persisted drafts in a new container', () async {
      final c1 = ProviderContainer();
      final d = ProjectDraft.create(title: 'Persisted', description: 'x');
      await c1.read(draftsProvider.notifier).addDraft(d);
      c1.dispose();

      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      c2.read(draftsProvider); // trigger build → async _load
      await Future<void>.delayed(Duration.zero);
      expect(c2.read(draftsProvider).map((e) => e.id), [d.id]);
    });
  });

  group('HistoryNotifier', () {
    test('addEntry then deleteEntry', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final notifier = c.read(historyProvider.notifier);

      final e = HistoryEntry.create(
        projectTitle: 'P',
        platform: 'x',
        tone: 't',
        content: 'c',
      );
      await notifier.addEntry(e);
      expect(c.read(historyProvider), [e]);

      await notifier.deleteEntry(e.id);
      expect(c.read(historyProvider), isEmpty);
    });
  });
}
