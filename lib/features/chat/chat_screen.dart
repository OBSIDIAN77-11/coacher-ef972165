import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/tokens.dart';
import '../../data/models/role.dart';
import '../../widgets/anim/fade_up.dart';

/// Port van ChatScreen.tsx — contactenlijst + chatgesprek (mock-data,
/// geen realtime; pariteit met de bron).
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.mode});

  final Role mode;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _Contact {
  const _Contact({
    required this.id,
    required this.name,
    required this.last,
    required this.time,
    required this.unread,
    required this.online,
    required this.gradient,
  });

  final String id;
  final String name;
  final String last;
  final String time;
  final int unread;
  final bool online;
  final Gradient gradient;

  String get initials => name
      .split(' ')
      .where((p) => p.isNotEmpty)
      .map((p) => p[0])
      .join()
      .substring(0, 2.clamp(0, name.split(' ').length));
}

const _gradBlue = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.primary, AppColors.accent],
);

const _coachContacts = [
  _Contact(
    id: 'sophie',
    name: 'Sophie B.',
    last: 'Top, gisteren ging het super!',
    time: '14:02',
    unread: 2,
    online: true,
    gradient: _gradBlue,
  ),
  _Contact(
    id: 'tim',
    name: 'Tim R.',
    last: 'Kunnen we vrijdag schuiven?',
    time: '11:48',
    unread: 0,
    online: false,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.accent, AppColors.purple],
    ),
  ),
  _Contact(
    id: 'nora',
    name: 'Nora K.',
    last: 'Dankjewel voor het schema 🙌',
    time: 'gisteren',
    unread: 1,
    online: true,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.red, AppColors.cyan],
    ),
  ),
  _Contact(
    id: 'bas',
    name: 'Bas H.',
    last: 'Geen probleem, tot maandag.',
    time: 'ma',
    unread: 0,
    online: false,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.accent, AppColors.primary],
    ),
  ),
];

const _klantContacts = [
  _Contact(
    id: 'yasmine',
    name: 'Yasmine El Karimi',
    last: 'Goed bezig deze week!',
    time: '10:21',
    unread: 1,
    online: true,
    gradient: _gradBlue,
  ),
];

class _Msg {
  const _Msg(this.mine, this.text, this.time);

  final bool mine;
  final String text;
  final String time;
}

const _seed = <String, List<_Msg>>{
  'sophie': [
    _Msg(false, 'Hé Yasmine! Net klaar met de hip thrusts.', '13:55'),
    _Msg(true, 'Goed bezig! Hoe voelden ze?', '13:58'),
    _Msg(false, 'Zwaar maar prima. Reps haalbaar.', '14:01'),
    _Msg(false, 'Top, gisteren ging het super!', '14:02'),
  ],
  'yasmine': [
    _Msg(false, 'Hé Sophie, hoe is het herstel vandaag?', '10:14'),
    _Msg(true, 'Voelt goed, HRV is hoger dan gisteren.', '10:18'),
    _Msg(false, 'Goed bezig deze week!', '10:21'),
  ],
};

class _ChatScreenState extends State<ChatScreen> {
  _Contact? _active;

  @override
  Widget build(BuildContext context) {
    final contacts =
        widget.mode == Role.coach ? _coachContacts : _klantContacts;
    final active = _active;

    if (active != null) {
      return _ChatThread(
        contact: active,
        onBack: () => setState(() => _active = null),
      );
    }

    return FadeUp(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Berichten',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textP,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${contacts.length} ${contacts.length == 1 ? 'gesprek' : 'gesprekken'}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textS,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            for (final c in contacts)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _active = c),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        _Avatar(contact: c, size: 48, dotSize: 12),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    c.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textP,
                                    ),
                                  ),
                                  Text(
                                    c.time,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textS,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      c.last,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: c.unread > 0
                                            ? AppColors.textP
                                            : AppColors.textS,
                                        fontWeight: c.unread > 0
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (c.unread > 0)
                                    Container(
                                      constraints: const BoxConstraints(
                                          minWidth: 20),
                                      height: 20,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6),
                                      decoration: BoxDecoration(
                                        gradient: AppGradients.primary,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${c.unread}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
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
                      ],
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

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.contact,
    required this.size,
    required this.dotSize,
  });

  final _Contact contact;
  final double size;
  final double dotSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: contact.gradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                contact.initials,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.29,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          if (contact.online)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bg, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChatThread extends StatefulWidget {
  const _ChatThread({required this.contact, required this.onBack});

  final _Contact contact;
  final VoidCallback onBack;

  @override
  State<_ChatThread> createState() => _ChatThreadState();
}

class _ChatThreadState extends State<_ChatThread> {
  late final List<_Msg> _msgs = [...(_seed[widget.contact.id] ?? [])];
  final _text = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final t = _text.text.trim();
    if (t.isEmpty) return;
    final now = TimeOfDay.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    setState(() {
      _msgs.add(_Msg(true, t, time));
      _text.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.contact;
    // Het gesprek vult de hele tab (de AppShell scrollt normaal zelf; dit
    // scherm heeft een eigen scroller + composer onderin, zoals de bron).
    return SizedBox(
      height: MediaQuery.of(context).size.height - 170,
      child: Column(
        children: [
          // Header
          ClipRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xED0F1525),
                  border:
                      Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onBack,
                      child: const SizedBox(
                        width: 32,
                        height: 32,
                        child: Icon(LucideIcons.chevronLeft,
                            size: 20, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 4),
                    _Avatar(contact: c, size: 36, dotSize: 10),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textP,
                            ),
                          ),
                          Text(
                            c.online ? 'online' : 'offline',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: c.online
                                  ? AppColors.primary
                                  : AppColors.textS,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0x1AFF4D6A),
                        borderRadius: BorderRadius.circular(999),
                        border:
                            Border.all(color: const Color(0x40FF4D6A)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.flag,
                              size: 11, color: AppColors.red),
                          SizedBox(width: 4),
                          Text(
                            'Melden',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Berichten
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              itemCount: _msgs.length,
              itemBuilder: (context, i) {
                final m = _msgs[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: m.mine
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!m.mine) ...[
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: c.gradient,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              c.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: Column(
                          crossAxisAlignment: m.mine
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                gradient:
                                    m.mine ? AppGradients.primary : null,
                                color: m.mine ? null : AppColors.card,
                                border: m.mine
                                    ? null
                                    : Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft:
                                      Radius.circular(m.mine ? 18 : 6),
                                  bottomRight:
                                      Radius.circular(m.mine ? 6 : 18),
                                ),
                              ),
                              child: Text(
                                m.text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              m.time,
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.textM,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Composer
          ClipRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                decoration: const BoxDecoration(
                  color: Color(0xED0F1525),
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _text,
                          onSubmitted: (_) => _send(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textP,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Typ een bericht…',
                            hintStyle: TextStyle(color: AppColors.textS),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _send,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            gradient: AppGradients.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x4D2563EB),
                                offset: Offset(0, 4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: const Icon(LucideIcons.send,
                              size: 15, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
