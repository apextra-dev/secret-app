import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UserStateNetwork with WidgetsBindingObserver {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<DatabaseEvent>? _connectedSubscription;

  bool _isInitialized = false;
  String? _currentUid;

  void startTracking() {
    final uid = _auth.currentUser?.uid;
    if (uid == null || _isInitialized) return;

    WidgetsBinding.instance.addObserver(this);

    _isInitialized = true;
    _currentUid = uid;

    final userStatusRef = _db.ref().child('users').child(uid).child('status');

    _connectedSubscription = _db.ref('.info/connected').onValue.listen((
      event,
    ) async {
      final connected = event.snapshot.value as bool? ?? false;

      if (connected) {
        await userStatusRef.onDisconnect().set({
          'state': 'offline',
          'lastChanged': ServerValue.timestamp,
        });

        await userStatusRef.set({
          'state': 'online',
          'lastChanged': ServerValue.timestamp,
        });
      }
    });
  }

  Future<void> stopTracking() async {
    WidgetsBinding.instance.removeObserver(this);
    await _connectedSubscription?.cancel();
    _connectedSubscription = null;

    if (_currentUid != null) {
      final userStatusRef = _db
          .ref()
          .child('users')
          .child(_currentUid!)
          .child('status');

      try {
        await userStatusRef.onDisconnect().cancel();
        await userStatusRef.set({
          'state': 'offline',
          'last_changed': ServerValue.timestamp,
        });
      } catch (e) {
        print("Ошибка при закрытии статуса: $e");
      }
      _currentUid = null;
    }

    _isInitialized = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_currentUid == null) return;

    final userStatusRef = _db
        .ref()
        .child('users')
        .child(_currentUid!)
        .child('status');

    if (state == AppLifecycleState.resumed) {
      _isInitialized = false;
      startTracking();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      userStatusRef.set({
        'state': 'offline',
        'last_changed': ServerValue.timestamp,
      });
    }
  }
}
