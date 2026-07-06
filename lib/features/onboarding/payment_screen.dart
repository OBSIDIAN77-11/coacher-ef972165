import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/tokens.dart';
import '../../core/supabase.dart';
import '../../data/models/role.dart';
import '../../data/repos/payment_repo.dart';
import '../../widgets/anim/fade_up.dart';
import '../../widgets/app_field.dart';
import '../../widgets/coacher_button.dart';
import '../../widgets/shell.dart';

enum PayMethod { ideal, card, incasso }

enum PlanKey { starter, pro, unlimited }

class _Plan {
  const _Plan(this.key, this.name, this.price, this.clients,
      {this.highlight = false});

  final PlanKey key;
  final String name;
  final int price;
  final String clients;
  final bool highlight;
}

const _coachPlans = [
  _Plan(PlanKey.starter, 'Starter', 29, 'Tot 15 cliënten'),
  _Plan(PlanKey.pro, 'Pro', 59, 'Tot 75 cliënten', highlight: true),
  _Plan(PlanKey.unlimited, 'Unlimited', 99, 'Onbeperkt cliënten'),
];

const _coachFeatures = [
  'Alle functies',
  "Onbeperkt schema's",
  'Chat',
  'Progress tracking',
  'Foto uploads',
  'Check-ins',
  'Analytics',
];

const _banks = ['ABN AMRO', 'ING', 'Rabobank', 'SNS', 'Bunq', 'Revolut'];

const _methods = [
  (PayMethod.ideal, 'iDEAL', LucideIcons.landmark),
  (PayMethod.card, 'Creditcard', LucideIcons.creditCard),
  (PayMethod.incasso, 'Incasso', LucideIcons.repeat),
];

/// Port van Payment.tsx, gekoppeld aan Mollie (testmodus) via de
/// Edge Function mollie-create-payment. Zonder ingelogde sessie (e-mail
/// nog niet bevestigd tijdens onboarding) valt de submit terug op de
/// mock-flow uit de bron.
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({
    super.key,
    required this.role,
    required this.onSkip,
    required this.onDone,
  });

  final Role role;
  final VoidCallback onSkip;
  final VoidCallback onDone;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PlanKey _plan = PlanKey.pro;
  PayMethod? _method;
  String? _bank;
  var _success = false;
  var _loading = false;
  var _err = '';
  Timer? _timer;

  bool get _isCoach => widget.role == Role.coach;

  _Plan get _selectedPlan => _coachPlans.firstWhere((p) => p.key == _plan);

  bool get _canPay => _method == PayMethod.ideal ? _bank != null : _method != null;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canPay || _loading) return;

    // Geen sessie (e-mail nog niet bevestigd): mock-gedrag zoals de bron.
    if (supabase.auth.currentSession == null) {
      _timer = Timer(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _success = true);
      });
      return;
    }

    setState(() {
      _err = '';
      _loading = true;
    });
    try {
      final repo = ref.read(paymentRepoProvider);
      final created = await repo.createPayment(
        plan: _isCoach ? _plan.name : 'klant',
        method: switch (_method) {
          PayMethod.ideal => 'ideal',
          PayMethod.card => 'card',
          PayMethod.incasso => 'incasso',
          null => null,
        },
      );
      await launchUrl(
        Uri.parse(created.checkoutUrl),
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_self',
      );
      // Poll tot Mollie de webhook heeft afgevuurd (testcheckout:
      // status "Paid" kiezen). Op web neemt /payment-result het over
      // na de redirect; dit vangt het geval dat de tab open blijft.
      final status = await repo.waitForStatus(created.paymentId);
      if (!mounted) return;
      if (status == 'paid') {
        setState(() => _success = true);
      } else if (status != 'open') {
        setState(() => _err = 'Betaling niet gelukt ($status). Probeer opnieuw.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _err = 'Betaling starten mislukt. Probeer opnieuw.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) return _SuccessView(method: _method, bank: _bank, onDone: widget.onDone);

    return Shell(
      child: FadeUp(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text(
              'ABONNEMENT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.textM,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Betaling instellen',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.textP,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isCoach
                  ? 'Kies je plan en betaalmethode — eerste maand gratis.'
                  : 'Kies hoe je wilt betalen — eerste maand is gratis.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textS,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_isCoach) ...[
              const SizedBox(height: 20),
              for (final p in _coachPlans) ...[
                _PlanCard(
                  plan: p,
                  active: _plan == p.key,
                  onTap: () => setState(() => _plan = p.key),
                ),
                const SizedBox(height: 10),
              ],
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'INBEGREPEN IN ELK PLAN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textM,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        for (final f in _coachFeatures)
                          Text(
                            '✅ $f',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textS,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                for (final (i, m) in _methods.indexed) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: _MethodCard(
                      label: m.$2,
                      icon: m.$3,
                      active: _method == m.$1,
                      onTap: () => setState(() {
                        _method = m.$1;
                        if (m.$1 != PayMethod.ideal) _bank = null;
                      }),
                    ),
                  ),
                ],
              ],
            ),
            if (_method == PayMethod.ideal) ...[
              const SizedBox(height: 16),
              FadeUp(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KIES JE BANK',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textS,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 4.5,
                      children: [
                        for (final b in _banks)
                          _BankCard(
                            label: b,
                            active: _bank == b,
                            onTap: () => setState(() => _bank = b),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppGradients.soft,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0x402563EB)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isCoach
                              ? 'Coach — ${_selectedPlan.name}'
                              : 'Klant — Begeleiding',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textP,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Maandelijks opzegbaar',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textS,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        '€0,00',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        _isCoach
                            ? 'daarna €${_selectedPlan.price}/mnd'
                            : 'eerste maand gratis',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textS,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            const SizedBox(height: 24),
            if (_err.isNotEmpty) ...[
              FieldErrorText(_err),
              const SizedBox(height: 8),
            ],
            CoacherButton(
              size: ButtonSize.lg,
              fullWidth: true,
              loading: _loading,
              onPressed: _canPay ? _submit : null,
              child: Text(_method == PayMethod.ideal
                  ? 'Activeren via iDEAL'
                  : 'Abonnement activeren'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Betalingen verwerkt door Mollie · SSL beveiligd',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textM,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: widget.onSkip,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Later instellen',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textS,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({
    required this.method,
    required this.bank,
    required this.onDone,
  });

  final PayMethod? method;
  final String? bank;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final via = switch (method) {
      PayMethod.ideal => bank ?? 'iDEAL',
      PayMethod.card => 'creditcard',
      _ => 'incasso',
    };

    return Shell(
      scrollable: false,
      child: FadeUp(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(color: Color(0x732563EB), blurRadius: 50),
                  ],
                ),
                child: const Icon(LucideIcons.check,
                    color: Colors.white, size: 38),
              ),
              const SizedBox(height: 22),
              const Text(
                'Abonnement actief',
                style: TextStyle(
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
                  'Eerste maand gratis — daarna factureren we automatisch via $via.',
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
                  onPressed: onDone,
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

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.active,
    required this.onTap,
  });

  final _Plan plan;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: active ? AppGradients.soft : null,
          color: active ? null : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textP,
                        ),
                      ),
                      if (plan.highlight) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0x262563EB),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'POPULAIR',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '👥 ${plan.clients}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textS,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '€${plan.price}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: active ? AppColors.primary : AppColors.textP,
                  ),
                ),
                const Text(
                  'per maand',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textS,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          gradient: active ? AppGradients.soft : null,
          color: active ? null : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: active ? AppColors.primary : AppColors.textS, size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: active ? AppColors.primary : AppColors.textP,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BankCard extends StatelessWidget {
  const _BankCard({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          gradient: active ? AppGradients.soft : null,
          color: active ? null : AppColors.card,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active ? AppColors.primary : AppColors.textP,
            ),
          ),
        ),
      ),
    );
  }
}
