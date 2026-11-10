import 'package:flutter/material.dart';

import 'ai_quota_service.dart';
import 'ai_quota_model.dart';

class AiQuotaTestScreen extends StatelessWidget {
  const AiQuotaTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TEST 1: Lifetime free questions
    final free = AiQuotaService.freeRemaining(0);

    // TEST 2: Saved questions
    final saved = AiQuotaService.savedPaidQuestions(
      carriedForward: 60,
      currentPackageRemaining: 0,
      topUpRemaining: 0,
    );

    // TEST 3: Monthly renewal
    final renewed = AiQuotaService.balanceAfterRenewal(
      savedPaidBalance: saved,
    );

    // TEST 4: Top-up
    final topUp = AiQuotaService.balanceAfterTopUp(
      savedPaidBalance: saved,
      topUpQuestions: 25,
    );

    // TEST 5-7: Expiry and carry-forward
    final now = DateTime(2026, 10, 12);

    final expiredAccount = AiQuotaModel(
      freeQuestionsUsed: 5,
      carriedForward: 60,
      currentPackageRemaining: 0,
      topUpRemaining: 25,
      subscriptionExpiresAt: DateTime(2026, 10, 1),
    );

    final activeAccount = AiQuotaModel(
      freeQuestionsUsed: 5,
      carriedForward: 85,
      currentPackageRemaining: 150,
      topUpRemaining: 0,
      subscriptionExpiresAt: DateTime(2026, 11, 11),
    );

    final results = <String, bool>{
      'Free Questions = 5': free == 5,
      'Saved Questions = 60': saved == 60,
      'Renewal = 210': renewed == 210,
      'Top-up = 85': topUp == 85,
      'Saved After Expiry = 85': expiredAccount.savedPaidBalance == 85,
      'Available While Expired = 0':
      expiredAccount.availablePaidBalance(now) == 0,
      'Available After Renewal = 235':
      activeAccount.availablePaidBalance(now) == 235,
    };

    final passed = results.values.where((value) => value).length;
    final total = results.length;
    final allPassed = passed == total;

    const background = Color(0xFF0A1C14); // Deep Dark Green
    const panel = Color(0xFF112A20); // Dark Green Panel
    const gold = Color(0xFFD4AF37); // Premium Gold

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: gold,
        title: const Text('AI Quota Tests', style: TextStyle(fontWeight: FontWeight.bold, color: gold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(
            allPassed ? Icons.check_circle : Icons.error,
            size: 70,
            color: allPassed ? Colors.greenAccent : Colors.redAccent,
          ),
          const SizedBox(height: 16),
          Text(
            allPassed
                ? 'ALL TESTS PASSED ($passed/$total)'
                : 'TESTS PASSED: $passed/$total',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: allPassed ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
          const SizedBox(height: 20),
          for (final entry in results.entries)
            Card(
              color: panel,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: gold.withOpacity(0.3)),
              ),
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Icon(
                  entry.value ? Icons.check_circle : Icons.cancel,
                  color: entry.value ? Colors.greenAccent : Colors.redAccent,
                ),
                title: Text(entry.key, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                trailing: Text(
                  entry.value ? 'PASS' : 'FAIL',
                  style: TextStyle(
                    color: entry.value ? Colors.greenAccent : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            'Calculation tests only. '
                'No Firebase data, payments or AI questions '
                'are changed.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}