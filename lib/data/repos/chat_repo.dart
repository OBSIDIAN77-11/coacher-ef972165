import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase.dart';
import '../models/message.dart';

final chatRepoProvider = Provider<ChatRepo>((ref) => ChatRepo());

class ChatSummary {
  const ChatSummary({this.lastMessage, this.lastMessageAt, this.unreadCount = 0});

  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
}

/// Data-laag voor de 1-op-1 chat tussen een coach en zijn gekoppelde klant.
class ChatRepo {
  String _orFilter(String meId, String otherId) =>
      'and(sender_id.eq.$meId,recipient_id.eq.$otherId),'
      'and(sender_id.eq.$otherId,recipient_id.eq.$meId)';

  Future<List<ChatMessage>> fetchConversation(String meId, String otherId) async {
    final rows = await supabase
        .from('messages')
        .select()
        .or(_orFilter(meId, otherId))
        .order('created_at');
    return [for (final r in rows) ChatMessage.fromRow(r)];
  }

  Future<ChatMessage> sendMessage({
    required String senderId,
    required String recipientId,
    required String content,
  }) async {
    final row = await supabase
        .from('messages')
        .insert({
          'sender_id': senderId,
          'recipient_id': recipientId,
          'content': content,
        })
        .select()
        .single();
    return ChatMessage.fromRow(row);
  }

  /// Live-stream van alles wat aan mij verstuurd wordt (van om het even wie).
  /// De aanroeper filtert client-side op de afzender die er op dat moment
  /// toe doet (open gesprek, of contactenlijst).
  Stream<List<ChatMessage>> incomingMessages(String meId) {
    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('recipient_id', meId)
        .map((rows) => [for (final r in rows) ChatMessage.fromRow(r)]);
  }

  Future<void> markConversationRead(String meId, String otherId) async {
    await supabase
        .from('messages')
        .update({'read_at': DateTime.now().toUtc().toIso8601String()})
        .eq('recipient_id', meId)
        .eq('sender_id', otherId)
        .isFilter('read_at', null);
  }

  Future<ChatSummary> fetchSummary(String meId, String otherId) async {
    final lastRows = await supabase
        .from('messages')
        .select('content, created_at')
        .or(_orFilter(meId, otherId))
        .order('created_at', ascending: false)
        .limit(1);
    final unreadRows = await supabase
        .from('messages')
        .select('id')
        .eq('recipient_id', meId)
        .eq('sender_id', otherId)
        .isFilter('read_at', null);
    return ChatSummary(
      lastMessage: lastRows.isNotEmpty ? lastRows.first['content'] as String : null,
      lastMessageAt: lastRows.isNotEmpty
          ? DateTime.parse(lastRows.first['created_at'] as String).toLocal()
          : null,
      unreadCount: unreadRows.length,
    );
  }
}
