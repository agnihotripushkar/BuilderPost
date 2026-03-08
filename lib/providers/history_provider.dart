import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_entry.dart';

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<HistoryEntry>>(
      (ref) => HistoryNotifier(),
    );

class HistoryNotifier extends StateNotifier<List<HistoryEntry>> {
  static const _kKey = 'builder_post_history';

  HistoryNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        state = HistoryEntry.listFromJson(raw);
      } catch (_) {
        state = [];
      }
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, HistoryEntry.listToJson(state));
  }

  Future<void> addEntry(HistoryEntry entry) async {
    state = [entry, ...state];
    await _save();
  }

  Future<void> deleteEntry(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _save();
  }
}
