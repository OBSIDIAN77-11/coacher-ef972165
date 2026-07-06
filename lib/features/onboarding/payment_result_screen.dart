import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/tokens.dart';
import '../../data/repos/payment_repo.dart';
import '../../widgets/anim/fade_up.dart';
import '../../widgets/anim/spinner.dart';
import '../../widgets/coacher_button.dart';
import '../../widgets/shell.dart';

/// Landingspagina na terugkeer van de Mollie-checkout (web-redirect
/// `/payment-result?ref=<paymentId>`). Pollt de betaling tot een
/// eindstatus en toont het resultaat.
class PaymentResultScreen extends ConsumerStatefulWidget {
  const PaymentResultScreen({super.key, required this.paymentRef});

  final String? paymentRef;

  @override
  ConsumerState<PaymentResultScreen> createState() =>
      _PaymentResultScreenState();
}

class _PaymentResultScreenState extends ConsumerState<PaymentResultScreen> {
  String? _status;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final ref0 = widget.paymentRef;
    if (ref0 == null || ref0.isEmpty) {
      setState(() => _status = 'unknown');
      return;
    }
    try {
      final status = await ref
          .read(paymentRepoProvider)
          .waitForStatus(ref0, timeout: const Duration(seconds: 60));
      if (mounted) setState(() => _status = status);
    } catch (_) {
      if (mounted) setState(() => _status = 'unknown');
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;

    return Shell(
      scrollable: false,
      child: FadeUp(
        child: Center(
          child: status == null || status == 'open'
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spinner(size: 28, color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      'Betaling controleren…',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textS,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: status == 'paid'
                            ? AppGradients.primary
                            : null,
                        color: status == 'paid'
                            ? null
                            : const Color(0x1FFF4D6A),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: status == 'paid'
                            ? const [
                                BoxShadow(
                                    color: Color(0x732563EB),
                                    blurRadius: 50),
                              ]
                            : null,
                      ),
                      child: Icon(
                        status == 'paid' ? LucideIcons.check : LucideIcons.x,
                        color: status == 'paid'
                            ? Colors.white
                            : AppColors.red,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      status == 'paid'
                          ? 'Abonnement actief'
                          : 'Betaling niet gelukt',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textP,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 300,
                      child: Text(
                        status == 'paid'
                            ? 'Eerste maand gratis — daarna factureren we automatisch.'
                            : 'De betaling is niet afgerond. Je kunt het opnieuw proberen via Instellingen.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textS,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: CoacherButton(
                        size: ButtonSize.lg,
                        fullWidth: true,
                        onPressed: () => context.go('/'),
                        child: const Text('Naar de app →'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
