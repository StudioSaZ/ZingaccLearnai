import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class BackendQuotaService {
  static const String baseUrl = 'http://127.0.0.1:3000';

  static Future<Map<String, dynamic>> getBalance() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Please sign in first.');
    }

    final token = await user.getIdToken();

    if (token == null || token.isEmpty) {
      throw Exception('Firebase ID token is unavailable.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/quota/balance'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 20));

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid backend response.');
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Quota API failed: HTTP ${response.statusCode}',
      );
    }

    return decoded;
  }
}