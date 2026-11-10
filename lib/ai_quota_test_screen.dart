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

    const background = Color(0xFF0A1C14); // Deep Dark Green
    const panel = Color(0xFF112A20); // Dark Green Panel
    const gold = Color(0xFFD4AF37); // Premium Gold

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: gold,
        title: const Text('AI Quota Test', style: TextStyle(fontWeight: FontWeight.bold, color: gold)),
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
            allPassed ? 'ALL TESTS PASSED' : 'TEST FAILED',
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
            'Preview test only. No AI questions, '
                'Firebase data or payments are changed.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}