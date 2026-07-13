class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String recipientId;
  final String content;
  final DateTime createdAt;

  factory ChatMessage.fromRow(Map<String, dynamic> row) => ChatMessage(
        id: row['id'] as String,
        senderId: row['sender_id'] as String,
        recipientId: row['recipient_id'] as String,
        content: row['content'] as String,
        createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      );
}
