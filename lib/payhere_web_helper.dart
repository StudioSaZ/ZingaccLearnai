import 'package:flutter/foundation.dart';
import 'universal_html_stub.dart' if (dart.library.html) 'dart:html' as html;

void startPayHereWebCheckout({
  required String merchantId,
  required String orderId,
  required double amount,
  required String currency,
  required String firstName,
  required String lastName,
  required String email,
  required String phone,
  required String address,
  required String city,
  required String country,
  required String returnUrl,
  required String cancelUrl,
  required String notifyUrl,
  bool isSandbox = true,
}) {
  final payHereUrl = isSandbox
      ? 'https://sandbox.payhere.lk/pay/checkout'
      : 'https://www.payhere.lk/pay/checkout';

  if (kIsWeb) {
    final mapForm = html.FormElement()
      ..action = payHereUrl
      ..method = 'POST';

    final parameters = {
      'merchant_id': merchantId,
      'return_url': returnUrl,
      'cancel_url': cancelUrl,
      'notify_url': notifyUrl,
      'order_id': orderId,
      'items': 'Zingacc Learn AI Subscription',
      'currency': currency,
      'amount': amount.toStringAsFixed(2),
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'country': country,
    };

    parameters.forEach((key, value) {
      final input = html.InputElement()
        ..type = 'hidden'
        ..name = key
        ..value = value;
      mapForm.append(input);
    });

    html.document.body?.append(mapForm);
    mapForm.submit();
    mapForm.remove();
  }
}