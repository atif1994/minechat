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
  final String? attachedFilePath;
  final String? attachedFileName;
  final String? attachedFileType; // 'image', 'document', etc.

  ChatMessageModel({
    required this.id,
    required this.message,
    required this.type,
    required this.timestamp,
    this.aiAssistantId,
    this.attachedFilePath,
    this.attachedFileName,
    this.attachedFileType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'aiAssistantId': aiAssistantId,
      'attachedFilePath': attachedFilePath,
      'attachedFileName': attachedFileName,
      'attachedFileType': attachedFileType,
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
      attachedFilePath: map['attachedFilePath'],
      attachedFileName: map['attachedFileName'],
      attachedFileType: map['attachedFileType'],
    );
  }

  ChatMessageModel copyWith({
    String? id,
    String? message,
    MessageType? type,
    DateTime? timestamp,
    String? aiAssistantId,
    String? attachedFilePath,
    String? attachedFileName,
    String? attachedFileType,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      aiAssistantId: aiAssistantId ?? this.aiAssistantId,
      attachedFilePath: attachedFilePath ?? this.attachedFilePath,
      attachedFileName: attachedFileName ?? this.attachedFileName,
      attachedFileType: attachedFileType ?? this.attachedFileType,
    );
  }
}
