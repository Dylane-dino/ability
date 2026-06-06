import 'package:flutter/material.dart';

/// THE SUBJECT (Observable)
/// Extends ChangeNotifier to unlock the ability to broadcast system updates.
class CommunityNotificationProvider extends ChangeNotifier {
  // Private singleton setup to ensure state uniformity across all screens
  CommunityNotificationProvider._internal();
  static final CommunityNotificationProvider _instance =
      CommunityNotificationProvider._internal();
  factory CommunityNotificationProvider() => _instance;

  int _unreadCount = 0;
  List<String> _notifications = [];

  int get unreadCount => _unreadCount;
  List<String> get notifications => _notifications;

  /// Adds a notification and automatically triggers the Observer update loop.
  void addNotification(String message) {
    _notifications.insert(0, message); // Add to the top of the list
    _unreadCount++;

    // 🚀 THE OBSERVER TRIGGER: Broadcasts the change to all registered UI observers!
    notifyListeners();
  }

  /// Clears out the badge counter when checking notifications
  void clearBadge() {
    _unreadCount = 0;
    notifyListeners();
  }
}
