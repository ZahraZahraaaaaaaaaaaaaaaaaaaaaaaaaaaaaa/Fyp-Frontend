import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../utils/notification_style.dart';

class NotificationToastEntry {
  NotificationToastEntry({
    required this.toastKey,
    required this.notification,
  });

  final String toastKey;
  final NotificationModel notification;
}

class NotificationProvider extends ChangeNotifier {
  NotificationProvider(this._api);

  final ApiService _api;
  static const Duration toastDuration = Duration(seconds: 4);

  List<NotificationModel> _items = [];
  final List<NotificationToastEntry> _activeToasts = [];
  int _unreadCount = 0;
  bool _loading = false;
  bool _loaded = false;
  int _toastSeq = 0;
  final Map<String, Timer> _toastTimers = {};
  bool _loginToastsShown = false;

  List<NotificationModel> get items => List.unmodifiable(_items);
  List<NotificationToastEntry> get activeToasts => List.unmodifiable(_activeToasts);
  int get unreadCount => _unreadCount;
  bool get loading => _loading;
  bool get hasUnread => _unreadCount > 0;

  void reset() {
    for (final t in _toastTimers.values) {
      t.cancel();
    }
    _toastTimers.clear();
    _items = [];
    _activeToasts.clear();
    _unreadCount = 0;
    _loading = false;
    _loaded = false;
    _toastSeq = 0;
    _loginToastsShown = false;
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
      _unreadCount = (res['unreadCount'] as num?)?.toInt() ?? _countUnread();
      _loaded = true;
    } catch (_) {
      // Keep prior state on failure.
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Merges session notifications into the dropdown and shows toasts (dynamic only).
  void ingestSessionNotifications(List<NotificationModel> incoming) {
    if (incoming.isEmpty) return;

    for (final n in incoming) {
      final idx = _items.indexWhere((i) => i.id == n.id);
      if (idx >= 0) {
        _items[idx] = n;
      } else {
        _items.insert(0, n);
      }

      if (NotificationStyle.isDynamicToastType(n.type)) {
        _enqueueToast(n);
      }
    }

    _unreadCount = _countUnread();
    _loaded = true;
    notifyListeners();
  }

  /// Call after sign-in / register: loads notifications, then welcome toasts once per session.
  Future<void> loadAfterAuth() async {
    await load(force: true);
    showOnboardingToastsIfNeeded();
  }

  /// Slide-in toasts for welcome (+ training reminder if unread). Not shown on cold app open.
  void showOnboardingToastsIfNeeded() {
    if (_loginToastsShown) return;
    _loginToastsShown = true;

    final onboarding = _items
        .where((n) => (n.type == 'welcome' || n.type == 'reminder') && !n.isRead)
        .toList();
    onboarding.sort((a, b) {
      if (a.type == 'welcome') return -1;
      if (b.type == 'welcome') return 1;
      return 0;
    });

    for (final n in onboarding) {
      _enqueueToast(n);
    }
    if (onboarding.isNotEmpty) {
      notifyListeners();
    }
  }

  void ingestFromApiMaps(List<dynamic> raw) {
    final list = raw
        .whereType<Map<String, dynamic>>()
        .map(NotificationModel.fromJson)
        .toList();
    ingestSessionNotifications(list);
  }

  void _enqueueToast(NotificationModel notification) {
    final toastKey = 'toast_${_toastSeq++}_${notification.id}';
    _activeToasts.insert(0, NotificationToastEntry(toastKey: toastKey, notification: notification));

    _toastTimers[toastKey]?.cancel();
    _toastTimers[toastKey] = Timer(toastDuration, () => dismissToast(toastKey));
  }

  void dismissToast(String toastKey) {
    _toastTimers.remove(toastKey)?.cancel();
    final before = _activeToasts.length;
    _activeToasts.removeWhere((t) => t.toastKey == toastKey);
    if (_activeToasts.length != before) {
      notifyListeners();
    }
  }

  int _countUnread() => _items.where((n) => !n.isRead).length;

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
        _unreadCount = _countUnread();
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
