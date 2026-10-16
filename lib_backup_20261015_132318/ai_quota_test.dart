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

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Quota Tests'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(
            allPassed ? Icons.check_circle : Icons.error,
            size: 70,
            color: allPassed ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            allPassed
                ? 'ALL TESTS PASSED ($passed/$total)'
                : 'TESTS PASSED: $passed/$total',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          for (final entry in results.entries)
            Card(
              child: ListTile(
                leading: Icon(
                  entry.value ? Icons.check_circle : Icons.cancel,
                  color: entry.value ? Colors.green : Colors.red,
                ),
                title: Text(entry.key),
                trailing: Text(
                  entry.value ? 'PASS' : 'FAIL',
                  style: TextStyle(
                    color: entry.value ? Colors.green : Colors.red,
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
          ),
        ],
      ),
    );
  }
}
