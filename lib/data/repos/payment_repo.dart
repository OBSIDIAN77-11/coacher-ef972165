import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase.dart';

final paymentRepoProvider = Provider<PaymentRepo>((ref) => PaymentRepo());

class CreatedPayment {
  const CreatedPayment({required this.paymentId, required this.checkoutUrl});

  final String paymentId;
  final String checkoutUrl;
}

class PaymentRepo {
  /// Maakt via de Edge Function een Mollie-betaling aan en geeft de
  /// checkout-URL terug. Vereist een ingelogde sessie.
  Future<CreatedPayment> createPayment({
    required String plan,
    String? method,
  }) async {
    final res = await supabase.functions.invoke(
      'mollie-create-payment',
      body: {
        'plan': plan,
        'method': method,
        'platform': kIsWeb ? 'web' : 'app',
      },
    );
    final data = res.data as Map<String, dynamic>;
    final checkoutUrl = data['checkoutUrl'] as String?;
    final paymentId = data['paymentId'] as String?;
    if (checkoutUrl == null || paymentId == null) {
      throw Exception(data['error'] ?? 'Betaling aanmaken mislukt');
    }
    return CreatedPayment(paymentId: paymentId, checkoutUrl: checkoutUrl);
  }

  /// Pollt de betaal-rij (RLS: alleen eigen rijen) tot een eindstatus of
  /// timeout. Geeft de laatste status terug ('open' bij timeout).
  Future<String> waitForStatus(
    String paymentId, {
    Duration interval = const Duration(seconds: 2),
    Duration timeout = const Duration(minutes: 5),
  }) async {
    final deadline = DateTime.now().add(timeout);
    var status = 'open';
    while (DateTime.now().isBefore(deadline)) {
      final row = await supabase
          .from('payments')
          .select('status')
          .eq('id', paymentId)
          .maybeSingle();
      status = (row?['status'] as String?) ?? 'open';
      if (status != 'open') return status;
      await Future.delayed(interval);
    }
    return status;
  }
}
