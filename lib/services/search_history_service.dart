import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const _historyKey = 'search_history';
  static const _maxHistorySize = 10;

  Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historyKey) ?? [];
  }

  Future<void> addSearchTerm(String term) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = await getSearchHistory();

    // Remove duplicates
    history.removeWhere((item) => item.toLowerCase() == term.toLowerCase());

    // Add to the beginning
    history.insert(0, term);

    // Trim the list if it's too long
    if (history.length > _maxHistorySize) {
      history = history.sublist(0, _maxHistorySize);
    }

    await prefs.setStringList(_historyKey, history);
  }

  Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<void> removeSearchTerm(String term) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = await getSearchHistory();
    history.removeWhere((item) => item.toLowerCase() == term.toLowerCase());
    await prefs.setStringList(_historyKey, history);
  }
}
