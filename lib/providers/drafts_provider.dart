import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project_draft.dart';

final draftsProvider =
    NotifierProvider<DraftsNotifier, List<ProjectDraft>>(DraftsNotifier.new);

class DraftsNotifier extends Notifier<List<ProjectDraft>> {
  static const _kKey = 'builder_post_drafts';

  @override
  List<ProjectDraft> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        state = ProjectDraft.listFromJson(raw);
      } catch (_) {
        state = [];
      }
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, ProjectDraft.listToJson(state));
  }

  Future<void> addDraft(ProjectDraft draft) async {
    state = [draft, ...state];
    await _save();
  }

  Future<void> updateDraft(ProjectDraft draft) async {
    state = state.map((d) => d.id == draft.id ? draft : d).toList();
    await _save();
  }

  Future<void> deleteDraft(String id) async {
    state = state.where((d) => d.id != id).toList();
    await _save();
  }
}
