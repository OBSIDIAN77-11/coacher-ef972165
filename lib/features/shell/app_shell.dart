import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demo_mode.dart';
import '../../app/theme/tokens.dart';
import '../../core/supabase.dart';
import '../../data/models/role.dart';
import '../../widgets/anim/soft_pulse.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/coacher_button.dart';
import '../chat/chat_screen.dart';
import '../coach/coach_alerts.dart';
import '../coach/coach_clients.dart';
import '../coach/coach_home.dart';
import '../klant/klant_coaching.dart';
import '../klant/klant_home.dart';
import '../klant/klant_voortgang.dart';
import '../settings/settings_screen.dart';

class _TabDef {
  const _TabDef(this.key, this.label, this.icon, {this.dot = false});

  final String key;
  final String label;
  final IconData icon;
  final bool dot;
}

const _coachTabs = [
  _TabDef('home', 'Home', LucideIcons.house),
  _TabDef('clients', 'Cliënten', LucideIcons.users),
  _TabDef('messages', 'Berichten', LucideIcons.messageSquare),
  _TabDef('alerts', 'Meldingen', LucideIcons.triangleAlert, dot: true),
  _TabDef('settings', 'Instellingen', LucideIcons.settings),
];

const _klantTabs = [
  _TabDef('home', 'Home', LucideIcons.house),
  _TabDef('coaching', 'Coaching', LucideIcons.dumbbell),
  _TabDef('messages', 'Berichten', LucideIcons.messageSquare),
  _TabDef('voortgang', 'Voortgang', LucideIcons.trendingUp),
  _TabDef('settings', 'Instellingen', LucideIcons.settings),
];

class _Notif {
  const _Notif(this.title, this.time, this.unread);

  final String title;
  final String time;
  final bool unread;
}

const _coachNotifs = [
  _Notif('Sophie heeft check-in ingevuld', '5 min', true),
  _Notif('Tim gaf je 5 sterren', '1 u', true),
  _Notif('Nieuwe boeking — vr 09:00', '3 u', false),
  _Notif('Betaling ontvangen — €110', 'gisteren', false),
];

const _klantNotifs = [
  _Notif('Yasmine heeft je schema bijgewerkt', '10 min', true),
  _Notif('Sessie bevestigd — di 10:00', '2 u', true),
  _Notif('Vergeet je check-in niet', 'gisteren', false),
];

/// Port van AppShell.tsx — glass topbar met rol-toggle, tab-inhoud en
/// glass bottom-nav met 5 tabs per rol.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    super.key,
    required this.initialMode,
    required this.onLogout,
  });

  final Role initialMode;
  final VoidCallback onLogout;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  late Role _mode = widget.initialMode;
  String _tab = 'home';
  String _profileName = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    try {
      final data = await supabase
          .from('profiles')
          .select('name')
          .eq('id', user.id)
          .maybeSingle();
      final name = data?['name'] as String?;
      if (mounted && name != null && name.isNotEmpty) {
        setState(() => _profileName = name);
      }
    } catch (_) {
      // Demo-modus zonder sessie: naam-fallback volstaat.
    }
  }

  List<_TabDef> get _tabs => _mode == Role.coach ? _coachTabs : _klantTabs;

  String get _name =>
      _profileName.isNotEmpty ? _profileName : (_mode == Role.coach ? 'Coach' : 'Jij');

  String get _initials {
    final parts = _name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).take(2);
    final joined = parts.map((p) => p[0].toUpperCase()).join();
    return joined.isEmpty ? '·' : joined;
  }

  void _switchMode(Role m) => setState(() {
        _mode = m;
        _tab = 'home';
      });

  void _openNotifs() {
    final demo = ref.read(demoModeProvider);
    final notifs = demo
        ? (_mode == Role.coach ? _coachNotifs : _klantNotifs)
        : const <_Notif>[];
    showAppBottomSheet(
      context: context,
      title: 'Meldingen',
      builder: (context) => Column(
        children: [
          if (notifs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'Geen nieuwe meldingen.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textS,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          for (final n in notifs)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: n.unread ? const Color(0x142563EB) : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                      n.unread ? const Color(0x402563EB) : AppColors.border,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (n.unread)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, right: 12),
                      child: SoftPulse(
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textP,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          n.time,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textS,
                            fontWeight: FontWeight.w600,
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

  void _openLogout() {
    showAppBottomSheet(
      context: context,
      title: 'Uitloggen?',
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Je wordt uitgelogd en teruggebracht naar het welkomstscherm.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textS,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CoacherButton(
                  variant: ButtonVariant.muted,
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Annuleren'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CoacherButton(
                  variant: ButtonVariant.danger,
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    widget.onLogout();
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.logOut, size: 14),
                      SizedBox(width: 8),
                      Text('Uitloggen'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabContent() {
    if (_mode == Role.coach && _tab == 'home') {
      return CoachHome(onOpenClient: () => setState(() => _tab = 'clients'));
    }
    if (_mode == Role.coach && _tab == 'clients') return const CoachClients();
    if (_mode == Role.coach && _tab == 'alerts') return const CoachAlerts();
    if (_tab == 'messages') return ChatScreen(mode: _mode);
    if (_mode == Role.klant && _tab == 'home') return const KlantHome();
    if (_mode == Role.klant && _tab == 'coaching') return const KlantCoaching();
    if (_mode == Role.klant && _tab == 'voortgang') {
      return const KlantVoortgang(standalone: true);
    }
    if (_tab == 'settings') {
      return SettingsScreen(
        mode: _mode,
        name: _name,
        initials: _initials,
        onLogout: _openLogout,
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    if (!_tabs.any((t) => t.key == _tab)) _tab = 'home';

    // Berichten en (klant-)Voortgang beheren hun eigen scroll: de chat
    // heeft een vaste composer onderin, Voortgang een sticky header met
    // tabs (parity met position:sticky in de bron).
    final selfScrolling = _tab == 'messages' ||
        (_mode == Role.klant && _tab == 'voortgang');

    // De coach/klant-toggle is alleen zinvol in demo-modus (om beide
    // ervaringen te laten zien zonder twee accounts). Een echt account
    // heeft een vaste rol in de database — coach ziet coach-schermen,
    // klant ziet klant-schermen, zonder wisselknop.
    final isDemo = ref.watch(demoModeProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _TopBar(
                  mode: _mode,
                  initials: _initials,
                  showModeToggle: isDemo,
                  onSwitchMode: _switchMode,
                  onBell: _openNotifs,
                ),
                Expanded(
                  child: selfScrolling
                      ? _tabContent()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 110),
                          child: _tabContent(),
                        ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _BottomNav(
                tabs: _tabs,
                current: _tab,
                onTab: (t) => setState(() => _tab = t),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.mode,
    required this.initials,
    required this.showModeToggle,
    required this.onSwitchMode,
    required this.onBell,
  });

  final Role mode;
  final String initials;
  final bool showModeToggle;
  final ValueChanged<Role> onSwitchMode;
  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xED0F1525),
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppGradients.primary.createShader(bounds),
                child: const Text(
                  'Coacher',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
              ),
              Row(
                children: [
                  // Coach/klant-toggle: alleen in demo-modus. Een echt
                  // account heeft een vaste rol, dus geen wisselknop.
                  if (showModeToggle) ...[
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          for (final m in Role.values)
                            GestureDetector(
                              onTap: () => onSwitchMode(m),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: mode == m
                                      ? AppGradients.primary
                                      : null,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  m == Role.coach ? 'Coach' : 'Klant',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: mode == m
                                        ? Colors.white
                                        : AppColors.textS,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Bell
                  GestureDetector(
                    onTap: onBell,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(LucideIcons.bell,
                              color: Colors.white, size: 16),
                          Positioned(
                            top: 7,
                            right: 8,
                            child: SoftPulse(
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.card, width: 2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Avatar
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      gradient: AppGradients.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.tabs,
    required this.current,
    required this.onTab,
  });

  final List<_TabDef> tabs;
  final String current;
  final ValueChanged<String> onTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: [0.6, 1.0],
          colors: [AppColors.bg, Color(0x00000000)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x141E3A8A),
                  offset: Offset(0, 8),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Row(
              children: [
                for (final t in tabs)
                  Expanded(
                    child: _NavItem(
                      def: t,
                      active: t.key == current,
                      onTap: () => onTab(t.key),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.def,
    required this.active,
    required this.onTap,
  });

  final _TabDef def;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: active ? 10 : 12,
            ),
            decoration: BoxDecoration(
              gradient: active ? AppGradients.primary : null,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  def.icon,
                  size: 20,
                  color: active ? Colors.white : AppColors.textS,
                ),
                if (active) ...[
                  const SizedBox(height: 2),
                  Text(
                    def.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (def.dot && !active)
            Positioned(
              top: 8,
              right: 14,
              child: SoftPulse(
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
