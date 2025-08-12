class AIAssistantModel {
  final String id;
  final String name;
  final String introMessage;
  final String shortDescription;
  final String aiGuidelines;
  final String responseLength; // 'Short', 'Normal', 'Long'
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  AIAssistantModel({
    required this.id,
    required this.name,
    required this.introMessage,
    required this.shortDescription,
    required this.aiGuidelines,
    required this.responseLength,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'introMessage': introMessage,
      'shortDescription': shortDescription,
      'aiGuidelines': aiGuidelines,
      'responseLength': responseLength,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AIAssistantModel.fromMap(Map<String, dynamic> map) {
    return AIAssistantModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      introMessage: map['introMessage'] ?? '',
      shortDescription: map['shortDescription'] ?? '',
      aiGuidelines: map['aiGuidelines'] ?? '',
      responseLength: map['responseLength'] ?? 'Normal',
      userId: map['userId'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  AIAssistantModel copyWith({
    String? id,
    String? name,
    String? introMessage,
    String? shortDescription,
    String? aiGuidelines,
    String? responseLength,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AIAssistantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      introMessage: introMessage ?? this.introMessage,
      shortDescription: shortDescription ?? this.shortDescription,
      aiGuidelines: aiGuidelines ?? this.aiGuidelines,
      responseLength: responseLength ?? this.responseLength,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
