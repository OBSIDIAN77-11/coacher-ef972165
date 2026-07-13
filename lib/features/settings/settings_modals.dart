import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, UserAttributes;

import '../../app/theme/tokens.dart';
import '../../core/supabase.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/coacher_button.dart';

/// Port van de modals uit Settings.tsx (Payment/Notifications/Payout/
/// Password/Privacy/Terms/Help). Teksten letterlijk overgenomen.

class _SuccessState extends StatelessWidget {
  const _SuccessState({required this.title, required this.sub});

  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: const BoxDecoration(
              gradient: AppGradients.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x662563EB),
                  offset: Offset(0, 8),
                  blurRadius: 30,
                ),
              ],
            ),
            child: const Icon(LucideIcons.check, size: 38, color: Colors.white),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textP,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 280,
            child: Text(
              sub,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textS,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textS,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

InputDecoration _sheetInputDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textS),
      filled: true,
      fillColor: AppColors.card,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );

/* ─────────────────────── Betaling ─────────────────────── */

void showPaymentModal(BuildContext context) {
  showAppBottomSheet(
    context: context,
    title: 'Betaling instellen',
    builder: (context) => const _PaymentModalBody(),
  );
}

class _PaymentModalBody extends StatefulWidget {
  const _PaymentModalBody();

  @override
  State<_PaymentModalBody> createState() => _PaymentModalBodyState();
}

class _PaymentModalBodyState extends State<_PaymentModalBody> {
  static const _methods = ['iDEAL', 'Creditcard', 'Incasso'];
  static const _banks = ['ABN AMRO', 'ING', 'Rabobank', 'SNS', 'Bunq', 'Revolut'];

  String _method = 'iDEAL';
  String _bank = 'ING';
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SuccessState(
            title: 'Geactiveerd!',
            sub:
                '$_method${_method == 'iDEAL' ? ' · $_bank' : ''} is succesvol ingesteld.',
          ),
          CoacherButton(
            size: ButtonSize.lg,
            fullWidth: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Klaar'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SheetLabel('Methode'),
        Row(
          children: [
            for (final (i, m) in _methods.indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _method = m),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 12),
                    decoration: BoxDecoration(
                      gradient:
                          _method == m ? AppGradients.primary : null,
                      color: _method == m ? null : AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: _method == m
                          ? null
                          : Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        m,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _method == m
                              ? Colors.white
                              : AppColors.textS,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        if (_method == 'iDEAL') ...[
          const _SheetLabel('Kies je bank'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 4.1,
            children: [
              for (final b in _banks)
                GestureDetector(
                  onTap: () => setState(() => _bank = b),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 14),
                    decoration: BoxDecoration(
                      color: _bank == b
                          ? AppColors.primarySoft
                          : AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _bank == b
                            ? AppColors.primary
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        b,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _bank == b
                              ? AppColors.textP
                              : AppColors.textS,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
        ],
        CoacherButton(
          size: ButtonSize.lg,
          fullWidth: true,
          onPressed: () => setState(() => _done = true),
          child: const Text('Activeren'),
        ),
      ],
    );
  }
}

/* ─────────────────────── Notificaties ─────────────────────── */

void showNotificationsModal(BuildContext context) {
  showAppBottomSheet(
    context: context,
    title: 'Notificaties',
    builder: (context) => const _NotificationsModalBody(),
  );
}

class _NotificationsModalBody extends StatefulWidget {
  const _NotificationsModalBody();

  @override
  State<_NotificationsModalBody> createState() =>
      _NotificationsModalBodyState();
}

/// Kolomnamen in notification_preferences per weergavelabel.
const _notifDbKeys = {
  'Push': 'push',
  'E-mail': 'email',
  'SMS': 'sms',
  'Check-in': 'checkin',
  'Sessie': 'sessie',
  'Betaling': 'betaling',
  'Nieuws': 'nieuws',
};

class _NotificationsModalBodyState extends State<_NotificationsModalBody> {
  final _state = <String, bool>{
    'Push': true,
    'E-mail': true,
    'SMS': false,
    'Check-in': true,
    'Sessie': true,
    'Betaling': true,
    'Nieuws': false,
  };
  bool _loading = true;
  bool _saving = false;
  bool _saved = false;
  String _err = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final row = await supabase
          .from('notification_preferences')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();
      if (mounted && row != null) {
        setState(() {
          for (final entry in _notifDbKeys.entries) {
            final value = row[entry.value];
            if (value is bool) _state[entry.key] = value;
          }
        });
      }
    } catch (_) {
      // Netwerkfout: standaardwaarden blijven staan.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      // Demo-modus zonder sessie: niets om op te slaan, toon toch succes.
      setState(() => _saved = true);
      return;
    }
    setState(() {
      _err = '';
      _saving = true;
    });
    try {
      await supabase.from('notification_preferences').upsert({
        'user_id': user.id,
        for (final entry in _notifDbKeys.entries) entry.value: _state[entry.key],
      });
      if (mounted) setState(() => _saved = true);
    } catch (_) {
      if (mounted) setState(() => _err = 'Opslaan mislukt. Probeer opnieuw.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_saved) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SuccessState(
              title: 'Opgeslagen!', sub: 'Je voorkeuren zijn bijgewerkt.'),
          CoacherButton(
            size: ButtonSize.lg,
            fullWidth: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Klaar'),
          ),
        ],
      );
    }

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in _state.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () =>
                  setState(() => _state[entry.key] = !entry.value),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textP,
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 42,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient:
                            entry.value ? AppGradients.primary : null,
                        color: entry.value ? null : AppColors.borderHover,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 200),
                        alignment: entry.value
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          width: 18,
                          height: 18,
                          margin:
                              const EdgeInsets.symmetric(horizontal: 3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x4D000000),
                                offset: Offset(0, 2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_err.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _err,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(height: 4),
        CoacherButton(
          size: ButtonSize.lg,
          fullWidth: true,
          loading: _saving,
          onPressed: _save,
          child: const Text('Opslaan'),
        ),
      ],
    );
  }
}

/* ─────────────────────── Uitbetaling ─────────────────────── */

void showPayoutModal(BuildContext context) {
  showAppBottomSheet(
    context: context,
    title: 'Uitbetaling instellen',
    builder: (context) => const _PayoutModalBody(),
  );
}

class _PayoutModalBody extends StatefulWidget {
  const _PayoutModalBody();

  @override
  State<_PayoutModalBody> createState() => _PayoutModalBodyState();
}

class _PayoutModalBodyState extends State<_PayoutModalBody> {
  static const _saldo = 1840;
  static const _schedules = [
    ('Direct', 'Binnen 1 dag'),
    ('Vrijdag', 'Wekelijks'),
    ('1e vd maand', 'Maandelijks'),
  ];
  static const _history = [
    ('23 mei 2025', 980),
    ('16 mei 2025', 1140),
    ('9 mei 2025', 760),
  ];

  double _amount = _saldo.toDouble();
  String _schedule = 'Direct';
  bool _done = false;

  String _fmt(num n) => n
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SuccessState(
            title: 'Aangevraagd!',
            sub:
                '€${_fmt(_amount)} wordt ${_schedule == 'Direct' ? 'binnen 1 werkdag' : 'op ${_schedule.toLowerCase()}'} op je rekening gestort.',
          ),
          CoacherButton(
            size: ButtonSize.lg,
            fullWidth: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Klaar'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Saldo card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x402563EB),
                offset: Offset(0, 8),
                blurRadius: 30,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    color: Color(0x1AFFFFFF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BESCHIKBAAR SALDO',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xD9FFFFFF),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '€${_fmt(_saldo)}',
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Verdiend deze maand · 23 sessies',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xD9FFFFFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Bedrag-slider
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bedrag opnemen',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textS,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '€${_fmt(_amount)}',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.border,
            thumbColor: AppColors.primary,
            overlayColor: const Color(0x1F2563EB),
            trackHeight: 4,
          ),
          child: Slider(
            min: 0,
            max: _saldo.toDouble(),
            divisions: _saldo ~/ 10,
            value: _amount,
            onChanged: (v) => setState(() => _amount = v),
          ),
        ),
        const SizedBox(height: 12),

        const _SheetLabel('Uitbetalingsfrequentie'),
        for (final (key, sub) in _schedules)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => setState(() => _schedule = key),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient:
                      _schedule == key ? AppGradients.soft : null,
                  color: _schedule == key ? null : AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _schedule == key
                        ? AppColors.primary
                        : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            key,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textP,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            sub,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textS,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_schedule == key)
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          gradient: AppGradients.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.check,
                            size: 13, color: Colors.white),
                      ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),

        const _SheetLabel('Uitbetalingsgeschiedenis'),
        for (final (date, amount) in _history)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textP,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '€${_fmt(amount)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),

        CoacherButton(
          size: ButtonSize.lg,
          fullWidth: true,
          onPressed: _amount == 0 ? null : () => setState(() => _done = true),
          child: Text('€${_fmt(_amount)} uitbetalen →'),
        ),
      ],
    );
  }
}

/* ─────────────────────── Wachtwoord ─────────────────────── */

void showPasswordModal(BuildContext context) {
  showAppBottomSheet(
    context: context,
    title: 'Wachtwoord wijzigen',
    builder: (context) => const _PasswordModalBody(),
  );
}

class _PasswordModalBody extends StatefulWidget {
  const _PasswordModalBody();

  @override
  State<_PasswordModalBody> createState() => _PasswordModalBodyState();
}

class _PasswordModalBodyState extends State<_PasswordModalBody> {
  final _cur = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  bool _done = false;
  bool _loading = false;
  String _err = '';

  @override
  void dispose() {
    _cur.dispose();
    _pw.dispose();
    _pw2.dispose();
    super.dispose();
  }

  bool get _tooShort => _pw.text.isNotEmpty && _pw.text.length < 8;
  bool get _mismatch => _pw2.text.isNotEmpty && _pw.text != _pw2.text;
  bool get _valid =>
      _cur.text.isNotEmpty && _pw.text.length >= 8 && _pw.text == _pw2.text;

  Future<void> _submit() async {
    if (!_valid || _loading) return;
    setState(() {
      _err = '';
      _loading = true;
    });
    try {
      final email = supabase.auth.currentUser?.email;
      if (email == null) throw Exception('Geen sessie');
      // Huidig wachtwoord verifiëren door opnieuw in te loggen — Supabase
      // heeft geen aparte "verify password"-call zonder dit te doen.
      await supabase.auth
          .signInWithPassword(email: email, password: _cur.text);
      await supabase.auth.updateUser(UserAttributes(password: _pw.text));
      if (mounted) setState(() => _done = true);
    } on AuthException catch (e) {
      final msg = e.message.contains('Invalid login credentials')
          ? 'Huidig wachtwoord is onjuist'
          : e.message;
      if (mounted) setState(() => _err = msg);
    } catch (_) {
      if (mounted) setState(() => _err = 'Wijzigen mislukt. Probeer opnieuw.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SuccessState(
            title: 'Wachtwoord gewijzigd!',
            sub: 'Je account is opnieuw beveiligd.',
          ),
          CoacherButton(
            size: ButtonSize.lg,
            fullWidth: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Klaar'),
          ),
        ],
      );
    }

    const errStyle = TextStyle(
      fontSize: 11,
      color: AppColors.red,
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _cur,
          obscureText: true,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: AppColors.textP, fontSize: 14),
          decoration: _sheetInputDecoration('Huidig wachtwoord'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _pw,
          obscureText: true,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: AppColors.textP, fontSize: 14),
          decoration: _sheetInputDecoration('Nieuw wachtwoord'),
        ),
        if (_tooShort)
          const Padding(
            padding: EdgeInsets.only(top: 6, left: 4),
            child: Text('Minimaal 8 tekens', style: errStyle),
          ),
        const SizedBox(height: 12),
        TextField(
          controller: _pw2,
          obscureText: true,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: AppColors.textP, fontSize: 14),
          decoration: _sheetInputDecoration('Bevestig nieuw wachtwoord'),
        ),
        if (_mismatch)
          const Padding(
            padding: EdgeInsets.only(top: 6, left: 4),
            child: Text('Wachtwoorden komen niet overeen', style: errStyle),
          ),
        if (_err.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(_err, style: errStyle),
          ),
        const SizedBox(height: 20),
        CoacherButton(
          size: ButtonSize.lg,
          fullWidth: true,
          loading: _loading,
          onPressed: _valid ? _submit : null,
          child: const Text('Wachtwoord opslaan'),
        ),
      ],
    );
  }
}

/* ─────────────────────── Privacy & AVG ─────────────────────── */

void showPrivacyModal(BuildContext context) {
  const cards = [
    (
      'Jouw gegevens',
      "Wij verwerken je naam, e-mail, foto's en sessiedata om de app te leveren."
    ),
    (
      'Inzage en correctie',
      'Je kunt altijd je gegevens opvragen of laten corrigeren.'
    ),
    (
      'Bewaartermijn',
      'Accountdata wordt 7 jaar bewaard, daarna automatisch verwijderd.'
    ),
    (
      'Delen met derden',
      'Wij delen geen data zonder jouw expliciete toestemming.'
    ),
    (
      'Cookies & tracking',
      'Alleen essentiële cookies. Geen advertentie tracking.'
    ),
  ];

  showAppBottomSheet(
    context: context,
    title: 'Privacy & AVG',
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (title, body) in cards)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textP,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textS,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: const Color(0x1AFF4D6A),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: const Color(0x40FF4D6A)),
          ),
          child: const Center(
            child: Text(
              'Gegevens verwijderen',
              style: TextStyle(
                color: AppColors.red,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/* ─────────────────────── Voorwaarden ─────────────────────── */

void showTermsModal(BuildContext context) {
  const articles = [
    (
      'Toepasselijkheid',
      'Deze voorwaarden gelden voor alle gebruikers van Coacher.'
    ),
    (
      'Account & registratie',
      'Je bent verantwoordelijk voor de juistheid van je gegevens.'
    ),
    (
      'Betalingen',
      'Sessies worden vooraf afgerekend via iDEAL of incasso.'
    ),
    (
      'Annulering',
      'Sessies kunnen tot 24 uur van tevoren kosteloos worden geannuleerd.'
    ),
    (
      'Aansprakelijkheid',
      'Coacher is niet aansprakelijk voor blessures opgelopen tijdens trainingen.'
    ),
    (
      'Beëindiging',
      'Je kunt je account op elk moment opzeggen via Instellingen.'
    ),
  ];

  showAppBottomSheet(
    context: context,
    title: 'Algemene voorwaarden',
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, article) in articles.indexed)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.$1,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textP,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        article.$2,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textS,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

/* ─────────────────────── Help & support ─────────────────────── */

void showHelpModal(BuildContext context) {
  showAppBottomSheet(
    context: context,
    title: 'Help & support',
    builder: (context) => const _HelpModalBody(),
  );
}

class _HelpModalBody extends StatefulWidget {
  const _HelpModalBody();

  @override
  State<_HelpModalBody> createState() => _HelpModalBodyState();
}

class _HelpModalBodyState extends State<_HelpModalBody> {
  static const _contacts = [
    ('WhatsApp', 'Binnen 1 uur reactie', LucideIcons.messageSquare),
    ('E-mail', 'support@coacher.nl', LucideIcons.mail),
    ('Bellen', 'Ma-vr 9:00 - 17:00', LucideIcons.phone),
  ];

  static const _faqs = [
    (
      'Hoe boek ik mijn eerste sessie?',
      'Ga naar Coaches, kies een coach en selecteer een tijdslot.'
    ),
    (
      'Hoe annuleer ik een sessie?',
      'Open de chat met je coach en stuur een annuleringsverzoek tot 24 uur van tevoren.'
    ),
    (
      'Wanneer krijg ik mijn geld terug?',
      'Bij tijdige annulering binnen 3 werkdagen op je rekening.'
    ),
    (
      'Mijn coach reageert niet, wat nu?',
      'Neem contact op met support, wij bemiddelen graag.'
    ),
    (
      'Kan ik van coach wisselen?',
      'Ja, je kunt op elk moment een nieuwe coach kiezen via Coaches.'
    ),
  ];

  int? _open = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SheetLabel('Contact'),
        Row(
          children: [
            for (final (i, c) in _contacts.indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          gradient: AppGradients.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                            Icon(c.$3, size: 16, color: Colors.white),
                      ),
                      Text(
                        c.$1,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textP,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        c.$2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textS,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        const _SheetLabel('Veelgestelde vragen'),
        for (final (i, f) in _faqs.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => setState(() => _open = _open == i ? null : i),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _open == i
                        ? const Color(0x4D2563EB)
                        : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            f.$1,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textP,
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: _open == i ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(LucideIcons.chevronDown,
                              size: 16, color: AppColors.textS),
                        ),
                      ],
                    ),
                    if (_open == i)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          f.$2,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textS,
                            fontWeight: FontWeight.w500,
                            height: 1.55,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
