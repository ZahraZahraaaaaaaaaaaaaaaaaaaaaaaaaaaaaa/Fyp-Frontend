import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider(this._api);

  final ApiService _api;

  List<NotificationModel> _items = [];
  int _unreadCount = 0;
  bool _loading = false;
  bool _loaded = false;

  List<NotificationModel> get items => List.unmodifiable(_items);
  int get unreadCount => _unreadCount;
  bool get loading => _loading;
  bool get hasUnread => _unreadCount > 0;

  void reset() {
    _items = [];
    _unreadCount = 0;
    _loading = false;
    _loaded = false;
    notifyListeners();
  }

  Future<void> load({bool force = false}) async {
    if (_loading) return;
    if (_loaded && !force) return;
    _loading = true;
    notifyListeners();
    try {
      final res = await _api.fetchNotifications();
      final list = res['notifications'];
      _items = list is List
          ? list
              .whereType<Map<String, dynamic>>()
              .map(NotificationModel.fromJson)
              .toList()
          : [];
      _unreadCount = (res['unreadCount'] as num?)?.toInt() ?? 0;
      _loaded = true;
    } catch (_) {
      // Keep prior state on failure.
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _api.markNotificationRead(id);
      final idx = _items.indexWhere((n) => n.id == id);
      if (idx >= 0 && !_items[idx].isRead) {
        _items[idx] = NotificationModel(
          id: _items[idx].id,
          title: _items[idx].title,
          message: _items[idx].message,
          type: _items[idx].type,
          isRead: true,
          createdAt: _items[idx].createdAt,
        );
        _unreadCount = (_unreadCount - 1).clamp(0, _items.length);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await _api.markAllNotificationsRead();
      _items = _items
          .map(
            (n) => NotificationModel(
              id: n.id,
              title: n.title,
              message: n.message,
              type: n.type,
              isRead: true,
              createdAt: n.createdAt,
            ),
          )
          .toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (_) {}
  }
}
