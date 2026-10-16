import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static const int monthlyFreeCoins = 0;

  static bool get _isAdminTest =>
      _auth.currentUser?.email?.trim().toLowerCase() ==
          'ajafernando67@gmail.com';

  static String createCoinRequestId() =>
      _db.collection('_coin_request_ids').doc().id;

  static String _monthKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  static int _asInt(Object? v, [int fallback = 0]) =>
      v is num ? v.toInt() : fallback;

  static Future<bool> hasActiveSubscription({required String grade}) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final snapshot = await _db.collection('users').doc(user.uid).get();
    final data = snapshot.data();
    if (data == null) return false;

    if (_isAdminTest && data['is_admin'] == true) return true;

    final paidRemaining = _asInt(data['paid_questions_remaining']);
    if (paidRemaining > 0) return true;

    final expiry = data['subscription_expires_at'];
    return data['subscription_status'] == 'active' &&
        expiry is Timestamp &&
        expiry.toDate().isAfter(DateTime.now().toUtc());
  }

  static Future<int> getFreeQuestionsRemaining() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final data = (await _db.collection('users').doc(user.uid).get()).data();
    if (_isAdminTest && data?['is_admin'] == true) return 2;

    // නොමිලේ ප්‍රශ්න 2ක් පමණක් ලබාදීම
    final used = _asInt(data?['free_questions_used']);
    return (2 - used).clamp(0, 2).toInt();
  }

  static Future<int> getPaidQuestionsRemaining() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final data = (await _db.collection('users').doc(user.uid).get()).data();
    return _asInt(data?['paid_questions_remaining']);
  }

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

      if (_isAdminTest && data['is_admin'] == true) return true;

      final used = _asInt(data['free_questions_used']);
      final paidRemaining = _asInt(data['paid_questions_remaining']);

      final expiry = data['subscription_expires_at'];
      final legacyPaid = data['subscription_status'] == 'active' &&
          expiry is Timestamp &&
          expiry.toDate().isAfter(DateTime.now().toUtc());

      bool isPaid = false;

      // 5 වෙනුවට 2 භාවිතා කිරීම
      if (used < 2) {
        tx.update(userRef, {'free_questions_used': used + 1});
      } else if (paidRemaining > 0) {
        tx.update(userRef, {'paid_questions_remaining': paidRemaining - 1});
        isPaid = true;
      } else if (legacyPaid) {
        isPaid = true;
      } else {
        return false;
      }

      tx.set(requestRef, {
        'status': 'reserved',
        'grade': grade,
        'is_paid': isPaid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }

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
      final data = userSnap.data() ?? <String, dynamic>{};

      if (isPaid) {
        final expiry = data['subscription_expires_at'];
        final legacyPaid = data['subscription_status'] == 'active' &&
            expiry is Timestamp &&
            expiry.toDate().isAfter(DateTime.now().toUtc());

        if (!legacyPaid) {
          final paidRemaining = _asInt(data['paid_questions_remaining']);
          tx.update(userRef, {'paid_questions_remaining': paidRemaining + 1});
        }
      } else {
        final used = _asInt(data['free_questions_used']);
        if (used > 0) {
          tx.update(userRef, {'free_questions_used': used - 1});
        }
      }

      tx.update(requestRef, {
        'status': 'refunded',
        'refundedAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }

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
          'free_questions_used': 0,
          'paid_questions_remaining': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return;
      }
    });
  }

  // වෙනත් Payment ක්‍රම ඉවත් කර ඇත, මන්ද අප භාවිතා කරන්නේ Manual WhatsApp ක්‍රමයයි.
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