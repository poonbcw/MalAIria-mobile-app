import '../models/history_item.dart';

class HistoryStorage {
  static final List<HistoryItem> _items = [];

  static List<HistoryItem> get items => _items;

  static void add(HistoryItem item) {
    _items.insert(0, item);
  }

  static void clear() {
    _items.clear();
  }
}
