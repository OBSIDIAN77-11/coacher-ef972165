import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demo_mode.dart';
import '../../app/theme/tokens.dart';
import '../../core/supabase.dart';
import '../../data/models/message.dart';
import '../../data/models/role.dart';
import '../../data/repos/chat_repo.dart';
import '../../widgets/anim/fade_up.dart';

/// Port van ChatScreen.tsx. Demo-modus: de mock-contacten en -berichten
/// uit het origineel, ongewijzigd. Echte sessie: contacten uit de
/// database (coach ↔ gekoppelde cliënten) met persistente, realtime
/// berichten via de messages-tabel.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.mode});

  final Role mode;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
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

  _Contact copyWith({String? last, String? time, int? unread}) => _Contact(
        id: id,
        name: name,
        last: last ?? this.last,
        time: time ?? this.time,
        unread: unread ?? this.unread,
        online: online,
        gradient: gradient,
      );

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

String _clockTime(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

const _weekdayAbbr = ['ma', 'di', 'wo', 'do', 'vr', 'za', 'zo'];

String _listTime(DateTime dt) {
  final now = DateTime.now();
  final that = DateTime(dt.year, dt.month, dt.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(that).inDays;
  if (diff == 0) return _clockTime(dt);
  if (diff == 1) return 'gisteren';
  if (diff < 7) return _weekdayAbbr[dt.weekday - 1];
  return '${dt.day}-${dt.month}-${dt.year.toString().substring(2)}';
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  _Contact? _active;
  List<_Contact> _realContacts = [];
  String? _meId;
  StreamSubscription<List<ChatMessage>>? _sub;

  @override
  void initState() {
    super.initState();
    _loadRealContacts();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _loadRealContacts() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    _meId = user.id;
    final repo = ref.read(chatRepoProvider);
    try {
      final rows = widget.mode == Role.coach
          ? await supabase
              .from('profiles')
              .select('id, name')
              .eq('coach_id', user.id)
              .order('name')
          : await _coachRow(user.id);

      final contacts = <_Contact>[];
      for (final r in rows) {
        final id = r['id'] as String;
        final name = (r['name'] as String?)?.isNotEmpty == true
            ? r['name'] as String
            : 'Naamloos';
        var summary = const ChatSummary();
        try {
          summary = await repo.fetchSummary(user.id, id);
        } catch (_) {
          // Nieuw contact zonder berichten, of netwerkfout — lege staat.
        }
        contacts.add(_Contact(
          id: id,
          name: name,
          last: summary.lastMessage ?? 'Nog geen berichten',
          time:
              summary.lastMessageAt != null ? _listTime(summary.lastMessageAt!) : '',
          unread: summary.unreadCount,
          online: false,
          gradient: _gradBlue,
        ));
      }
      if (!mounted) return;
      setState(() => _realContacts = contacts);
      _listenForIncoming(user.id, repo);
    } catch (_) {
      // Geen sessie of netwerkfout.
    }
  }

  void _listenForIncoming(String meId, ChatRepo repo) {
    _sub = repo.incomingMessages(meId).listen((rows) {
      if (!mounted || _realContacts.isEmpty) return;
      final bySender = <String, List<ChatMessage>>{};
      for (final m in rows) {
        (bySender[m.senderId] ??= []).add(m);
      }
      setState(() {
        _realContacts = [
          for (final c in _realContacts)
            if (bySender[c.id] case final msgs?)
              c.copyWith(
                last: msgs.last.content,
                time: _listTime(msgs.last.createdAt),
                unread: msgs.length,
              )
            else
              c,
        ];
      });
    });
  }

  Future<void> _refreshContactSummary(String contactId) async {
    final meId = _meId;
    if (meId == null) return;
    try {
      final summary =
          await ref.read(chatRepoProvider).fetchSummary(meId, contactId);
      if (!mounted) return;
      setState(() {
        _realContacts = [
          for (final c in _realContacts)
            if (c.id == contactId)
              c.copyWith(
                last: summary.lastMessage ?? 'Nog geen berichten',
                time: summary.lastMessageAt != null
                    ? _listTime(summary.lastMessageAt!)
                    : '',
                unread: summary.unreadCount,
              )
            else
              c,
        ];
      });
    } catch (_) {
      // Netwerkfout: lijst blijft op de vorige (mogelijk verouderde) stand.
    }
  }

  Future<List<Map<String, dynamic>>> _coachRow(String userId) async {
    final me = await supabase
        .from('profiles')
        .select('coach_id')
        .eq('id', userId)
        .maybeSingle();
    final coachId = me?['coach_id'] as String?;
    if (coachId == null) return [];
    final coach = await supabase
        .from('profiles')
        .select('id, name')
        .eq('id', coachId)
        .maybeSingle();
    return coach == null ? [] : [coach];
  }

  @override
  Widget build(BuildContext context) {
    final demo = ref.watch(demoModeProvider);
    final contacts = demo
        ? (widget.mode == Role.coach ? _coachContacts : _klantContacts)
        : _realContacts;
    final active = _active;

    if (active != null) {
      return _ChatThread(
        contact: active,
        isDemo: demo,
        meId: _meId,
        onBack: () {
          setState(() => _active = null);
          if (!demo) _refreshContactSummary(active.id);
        },
      );
    }

    return FadeUp(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
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
            if (contacts.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.messageSquare,
                        size: 18, color: AppColors.textM),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.mode == Role.coach
                            ? 'Nog geen gesprekken. Nodig een cliënt uit om te kunnen chatten.'
                            : 'Nog geen gesprekken. Zodra je aan een coach gekoppeld bent kun je chatten.',
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
              ),
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

class _ChatThread extends ConsumerStatefulWidget {
  const _ChatThread({
    required this.contact,
    required this.onBack,
    required this.isDemo,
    required this.meId,
  });

  final _Contact contact;
  final VoidCallback onBack;
  final bool isDemo;
  final String? meId;

  @override
  ConsumerState<_ChatThread> createState() => _ChatThreadState();
}

class _ChatThreadState extends ConsumerState<_ChatThread> {
  late final List<_Msg> _mockMsgs =
      widget.isDemo ? [...(_seed[widget.contact.id] ?? [])] : [];
  List<ChatMessage> _realMsgs = [];
  bool _loading = false;
  StreamSubscription<List<ChatMessage>>? _sub;

  final _text = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    if (!widget.isDemo) _loadReal();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadReal() async {
    final meId = widget.meId;
    if (meId == null) return;
    setState(() => _loading = true);
    final repo = ref.read(chatRepoProvider);
    try {
      final msgs = await repo.fetchConversation(meId, widget.contact.id);
      if (mounted) setState(() => _realMsgs = msgs);
      await repo.markConversationRead(meId, widget.contact.id);
    } catch (_) {
      // Netwerkfout: leeg gesprek tonen, versturen blijft mogelijk.
    } finally {
      if (mounted) setState(() => _loading = false);
      _scrollToBottom();
    }

    _sub = repo.incomingMessages(meId).listen((rows) {
      if (!mounted) return;
      final fromContact =
          rows.where((m) => m.senderId == widget.contact.id).toList();
      if (fromContact.isEmpty) return;
      final existingIds = _realMsgs.map((m) => m.id).toSet();
      final fresh = fromContact.where((m) => !existingIds.contains(m.id));
      if (fresh.isEmpty) return;
      setState(() {
        _realMsgs = [..._realMsgs, ...fresh]
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      });
      repo.markConversationRead(meId, widget.contact.id);
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
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

  Future<void> _send() async {
    final t = _text.text.trim();
    if (t.isEmpty) return;
    _text.clear();

    if (widget.isDemo) {
      setState(() => _mockMsgs.add(_Msg(true, t, _clockTime(DateTime.now()))));
      _scrollToBottom();
      return;
    }

    final meId = widget.meId;
    if (meId == null) return;
    try {
      final sent = await ref.read(chatRepoProvider).sendMessage(
            senderId: meId,
            recipientId: widget.contact.id,
            content: t,
          );
      if (mounted) setState(() => _realMsgs.add(sent));
      _scrollToBottom();
    } catch (_) {
      // Versturen mislukt: tekst terugzetten zodat niets verloren gaat.
      if (mounted) _text.text = t;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.contact;
    final itemCount = widget.isDemo ? _mockMsgs.length : _realMsgs.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 92),
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
            child: !widget.isDemo && _loading && _realMsgs.isEmpty
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                    itemCount: itemCount,
                    itemBuilder: (context, i) {
                      final bool mine;
                      final String text;
                      final String time;
                      if (widget.isDemo) {
                        final m = _mockMsgs[i];
                        mine = m.mine;
                        text = m.text;
                        time = m.time;
                      } else {
                        final m = _realMsgs[i];
                        mine = m.senderId == widget.meId;
                        text = m.content;
                        time = _clockTime(m.createdAt);
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: mine
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!mine) ...[
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
                                crossAxisAlignment: mine
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      gradient:
                                          mine ? AppGradients.primary : null,
                                      color: mine ? null : AppColors.card,
                                      border: mine
                                          ? null
                                          : Border.all(
                                              color: AppColors.border),
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(18),
                                        topRight: const Radius.circular(18),
                                        bottomLeft:
                                            Radius.circular(mine ? 18 : 6),
                                        bottomRight:
                                            Radius.circular(mine ? 6 : 18),
                                      ),
                                    ),
                                    child: Text(
                                      text,
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
                                    time,
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
