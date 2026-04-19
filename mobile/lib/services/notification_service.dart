import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

import 'preferences_service.dart';

class NotificationService {
  static bool _initialized = false;
  static StreamSubscription<RemoteMessage>? _openedSubscription;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
      await FirebaseMessaging.instance.requestPermission();
      _initialized = true;
    } catch (_) {
      // Firebase optionnel tant que google-services.json n'est pas configuré.
    }
  }

  /// (Re)aligne les abonnements topics sur le seuil demande.
  /// Un seul topic reste actif cote app pour eviter les doublons FCM.
  static Future<void> syncThreshold(String threshold) async {
    if (!_initialized) return;
    try {
      final messaging = FirebaseMessaging.instance;
      final wanted = topicsForThreshold(threshold).toSet();
      const all = [
        'level-critique',
        'level-elevee',
        'level-moyenne',
        'level-faible',
      ];
      for (final topic in all) {
        if (wanted.contains(topic)) {
          await messaging.subscribeToTopic(topic);
        } else {
          await messaging.unsubscribeFromTopic(topic);
        }
      }
    } catch (_) {
      // silencieux : rien à faire si Firebase indispo
    }
  }

  static Future<void> bindRouter(GoRouter router) async {
    if (!_initialized || _openedSubscription != null) return;
    try {
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      _openItemFromMessage(router, initialMessage);
      _openedSubscription =
          FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _openItemFromMessage(router, message);
      });
    } catch (_) {
      // silencieux : rien Ã  faire si Firebase indispo
    }
  }

  static void _openItemFromMessage(GoRouter router, RemoteMessage? message) {
    final id = message?.data['item_id'];
    if (id is! String || id.isEmpty) return;
    router.go('/items/${Uri.encodeComponent(id)}');
  }
}
