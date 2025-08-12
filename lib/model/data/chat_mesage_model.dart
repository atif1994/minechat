enum MessageType {
  user,
  ai,
}

class ChatMessageModel {
  final String id;
  final String message;
  final MessageType type;
  final DateTime timestamp;
  final String? aiAssistantId;

  ChatMessageModel({
    required this.id,
    required this.message,
    required this.type,
    required this.timestamp,
    this.aiAssistantId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'aiAssistantId': aiAssistantId,
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] ?? '',
      message: map['message'] ?? '',
      type: MessageType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => MessageType.user,
      ),
      timestamp: DateTime.parse(map['timestamp']),
      aiAssistantId: map['aiAssistantId'],
    );
  }
}
