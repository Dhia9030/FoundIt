import 'dart:async';

import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  List<AppNotification> _notifications = [];
  User? _currentUser; 
  StreamSubscription? _notificationsSubscription; 

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  NotificationProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _currentUser = user;
      _cancelNotificationSubscription();
      if (_currentUser != null) {
        _startListeningToNotifications(_currentUser!.uid);
        _notificationService.updateFCMTokenForUser(_currentUser!.uid);
      } else {
        _notifications = [];
        notifyListeners();
      }
    });
  }
  void _startListeningToNotifications(String userId) {
    _notificationsSubscription = _notificationService.getUserNotifications(userId).listen((notiList) {
      _notifications = notiList;
      notifyListeners();
    }, onError: (error) {
      print("Error listening to notifications: $error");
    });
  }

  void _cancelNotificationSubscription() {
    _notificationsSubscription?.cancel();
    _notificationsSubscription = null;
  }

  Future<void> markAsRead(String notificationId) async {
    if (_currentUser == null) {
      print('Cannot mark as read: No authenticated user.');
      return;
    }
    await _notificationService.markNotificationAsRead(_currentUser!.uid, notificationId);

  }

  @override
  void dispose() {
    _cancelNotificationSubscription(); 
    super.dispose();
  }
}