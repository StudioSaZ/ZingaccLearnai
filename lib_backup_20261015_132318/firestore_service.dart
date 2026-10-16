import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/foundation.dart';

/// Transitional sandbox service. Production AI quota must be enforced server-side.

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static const int monthlyFreeCoins = 0; // Disabled: no monthly free coins.

  static bool get _isAdminTest =>
      _auth.currentUser?.email?.trim().toLowerCase() ==
          'ajafernando67@gmail.com';

  static String createCoinRequestId() =>
      _db.collection('_coin_request_ids').doc().id;

  static String _monthKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  static int _asInt(Object? v, [int fallback = 0]) =>
      v is num ? v.toInt() : fallback;

  /// Read-only entitlement display. Admin must set these fields via Firebase Console

  /// or a trusted backend, never from the app client.

  static Future<bool> hasActiveSubscription({required String grade}) async {
    final user = _auth.currentUser;

    if (user == null) return false;

    final snapshot = await _db.collection('users').doc(user.uid).get();

    final data = snapshot.data();

    if (data == null) return false;
    if (_isAdminTest && data['is_admin'] == true) return true;
    if (data['selected_grade'] != grade) return false;

    final expiry = data['subscription_expires_at'];

    return data['subscription_status'] == 'active' &&
        expiry is Timestamp &&
        expiry.toDate().isAfter(DateTime.now().toUtc());
  }

  static Future<int> getFreeQuestionsRemaining() async {
    final user = _auth.currentUser;

    if (user == null) return 0;

    final data = (await _db.collection('users').doc(user.uid).get()).data();

    if (_isAdminTest && data?['is_admin'] == true) return 5;
    final used = _asInt(data?['free_questions_used']);

    return (5 - used).clamp(0, 5).toInt();
  }

  /// TEST quota: 5 lifetime free AI actions, or active paid access for one grade.

  /// This is NOT tamper-proof billing; a trusted server is required for release.

  static Future<bool> authorizeAiRequest({
    required String requestId,
    required String grade,
  }) async {
    final user = _auth.currentUser;

    if (user == null || requestId.trim().isEmpty) return false;

    final userRef = _db.collection('users').doc(user.uid);

    final requestRef = userRef.collection('ai_usage').doc(requestId);

    return _db.runTransaction<bool>((tx) async {
      final prior = await tx.get(requestRef);

      final snap = await tx.get(userRef);

      if (prior.exists) return prior.data()?['status'] == 'reserved';

      if (!snap.exists) return false;

      final data = snap.data() ?? <String, dynamic>{};

      // Test-only admin bypass; production requires trusted server claims.
      if (_isAdminTest && data['is_admin'] == true) return true;
      if (data['selected_grade'] != grade) return false;

      final expiry = data['subscription_expires_at'];

      final paid = data['subscription_status'] == 'active' &&
          expiry is Timestamp &&
          expiry.toDate().isAfter(DateTime.now().toUtc());

      final used = _asInt(data['free_questions_used']);

      if (!paid && used >= 5) return false;

      if (!paid) {
        tx.update(userRef, {'free_questions_used': used + 1});
      }

      tx.set(requestRef, {
        'status': 'reserved',
        'grade': grade,
        'is_paid': paid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }

  /// Return one free action when AI generation fails; idempotent.

  static Future<bool> refundAiRequest({required String requestId}) async {
    final user = _auth.currentUser;

    if (user == null || requestId.trim().isEmpty) return false;

    final userRef = _db.collection('users').doc(user.uid);

    final requestRef = userRef.collection('ai_usage').doc(requestId);

    return _db.runTransaction<bool>((tx) async {
      final request = await tx.get(requestRef);

      final userSnap = await tx.get(userRef);

      if (!request.exists ||
          !userSnap.exists ||
          request.data()?['status'] != 'reserved') return false;

      final isPaid = request.data()?['is_paid'] == true;

      final used = _asInt(userSnap.data()?['free_questions_used']);

      if (!isPaid) {
        if (used <= 0) return false;

        tx.update(userRef, {'free_questions_used': used - 1});
      }

      tx.update(requestRef, {
        'status': 'refunded',
        'refundedAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }

  /// Backwards compatible sandbox wallet initialization.

  static Future<void> setupNewUserOrGiveMonthlyCoins() async {
    final user = _auth.currentUser;

    if (user == null) return;

    final ref = _db.collection('users').doc(user.uid);

    final month = _monthKey(DateTime.now());

    await _db.runTransaction<void>((tx) async {
      final snap = await tx.get(ref);

      if (!snap.exists) {
        tx.set(ref, {
          'email': user.email,
          'free_coins': monthlyFreeCoins,
          'paid_coins': 0,
          'coins': monthlyFreeCoins,
          'last_free_month': month,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return;
      }

      final data = snap.data() ?? <String, dynamic>{};

      final paid = _asInt(data['paid_coins']);

      if (data['last_free_month'] != month) {
        tx.set(
            ref,
            {
              'email': data['email'] ?? user.email,
              'free_coins': _asInt(data['free_coins']),
              'paid_coins': paid,
              'coins': _asInt(data['free_coins']) + paid,
              'last_free_month': month,
            },
            SetOptions(merge: true));
      } else if (!data.containsKey('free_coins') ||
          !data.containsKey('paid_coins')) {
        final free = data.containsKey('free_coins')
            ? _asInt(data['free_coins'])
            : (_asInt(data['coins']) - paid).clamp(0, 1000000000).toInt();

        tx.set(
            ref,
            {
              'email': data['email'] ?? user.email,
              'free_coins': free,
              'paid_coins': paid,
              'coins': free + paid,
            },
            SetOptions(merge: true));
      }
    });
  }

  static Future<bool> deductCoins(
      {int cost = 10, required String requestId}) async {
    if (cost <= 0 || requestId.trim().isEmpty) return false;

    final user = _auth.currentUser;

    if (user == null) return false;

    if (_isAdminTest) {
      debugPrint('TEST ADMIN bypass: not secure for production.');

      return true;
    }

    final userRef = _db.collection('users').doc(user.uid);

    final requestRef = userRef.collection('coin_transactions').doc(requestId);

    final month = _monthKey(DateTime.now());

    return _db.runTransaction<bool>((tx) async {
      final previous = await tx.get(requestRef);

      final snap = await tx.get(userRef);

      if (previous.exists) return previous.data()?['status'] == 'charged';

      if (!snap.exists) return false;

      final data = snap.data() ?? <String, dynamic>{};

      final paid = _asInt(data['paid_coins']);

      var free = data.containsKey('free_coins')
          ? _asInt(data['free_coins'])
          : _asInt(data['coins']) - paid;

      if (free < 0) free = 0;

      // No monthly free-coin refill. Existing legacy balance is preserved.

      if (free + paid < cost) return false;

      final freeDebit = free >= cost ? cost : free;

      final paidDebit = cost - freeDebit;

      final nextFree = free - freeDebit;

      final nextPaid = paid - paidDebit;

      tx.set(
          userRef,
          {
            'email': data['email'] ?? user.email,
            'free_coins': nextFree,
            'paid_coins': nextPaid,
            'coins': nextFree + nextPaid,
            'last_free_month': month,
          },
          SetOptions(merge: true));

      tx.set(requestRef, {
        'cost': cost,
        'free_coins_debited': freeDebit,
        'paid_coins_debited': paidDebit,
        'status': 'charged',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }

  static Future<bool> refundCoins({required String requestId}) async {
    if (requestId.trim().isEmpty) return false;

    final user = _auth.currentUser;

    if (user == null || _isAdminTest) return false;

    final userRef = _db.collection('users').doc(user.uid);

    final requestRef = userRef.collection('coin_transactions').doc(requestId);

    return _db.runTransaction<bool>((tx) async {
      final requestSnap = await tx.get(requestRef);

      final userSnap = await tx.get(userRef);

      if (!requestSnap.exists || !userSnap.exists) return false;

      final request = requestSnap.data() ?? <String, dynamic>{};

      if (request['status'] != 'charged') return false;

      final data = userSnap.data() ?? <String, dynamic>{};

      final nextFree =
          _asInt(data['free_coins']) + _asInt(request['free_coins_debited']);

      final nextPaid =
          _asInt(data['paid_coins']) + _asInt(request['paid_coins_debited']);

      tx.set(
          userRef,
          {
            'free_coins': nextFree,
            'paid_coins': nextPaid,
            'coins': nextFree + nextPaid,
          },
          SetOptions(merge: true));

      tx.update(requestRef, {
        'status': 'refunded',
        'refundedAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }

  static Future<void> saveToHistory({
    required String subject,
    required String level,
    required String question,
    required String answer,
  }) async {
    final user = _auth.currentUser;

    if (user == null) return;

    await _db.collection('users').doc(user.uid).collection('history').add({
      'subject': subject,
      'level': level,
      'question': question,
      'answer': answer,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
