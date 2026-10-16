import 'package:flutter/material.dart';
import 'ai_quota_service.dart';
import 'ai_quota_model.dart';

class AiQuotaTestScreen extends StatelessWidget {
  const AiQuotaTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final free = AiQuotaService.freeRemaining(0);

    final saved = AiQuotaService.savedPaidQuestions(
      carriedForward: 60,
      currentPackageRemaining: 0,
      topUpRemaining: 0,
    );

    final renewed = AiQuotaService.balanceAfterRenewal(
      savedPaidBalance: saved,
    );

    final topUp = AiQuotaService.balanceAfterTopUp(
      savedPaidBalance: saved,
      topUpQuestions: 25,
    );

    final results = <String, bool>{
      'Free Questions = 5': free == 5,
      'Saved Questions = 60': saved == 60,
      'Renewal = 210': renewed == 210,
      'Top-up = 85': topUp == 85,
      'Saved After Expiry = 85':
      AiQuotaModel(
        carriedForward: 60,
        topUpRemaining: 25,
        subscriptionExpiresAt: DateTime(2026, 10, 1),
      ).savedPaidBalance == 85,

      'Available While Expired = 0':
      AiQuotaModel(
        carriedForward: 60,
        topUpRemaining: 25,
        subscriptionExpiresAt: DateTime(2026, 10, 1),
      ).availablePaidBalance(DateTime(2026, 10, 12)) == 0,

      'Available After Renewal = 235':
      AiQuotaModel(
        carriedForward: 85,
        currentPackageRemaining: 150,
        subscriptionExpiresAt: DateTime(2026, 11, 11),
      ).availablePaidBalance(DateTime(2026, 10, 12)) == 235,
    };

    final allPassed = results.values.every((value) => value);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Quota Test'),
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
            allPassed ? 'ALL TESTS PASSED' : 'TEST FAILED',
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
                trailing: Text(entry.value ? 'PASS' : 'FAIL'),
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            'Preview test only. No AI questions, '
                'Firebase data or payments are changed.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
