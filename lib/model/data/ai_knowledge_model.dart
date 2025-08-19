
class AIKnowledgeModel {
  final String id;
  final String businessName;
  final String phone;
  final String address;
  final String email;
  final String companyStory;
  final String paymentDetails;
  final String discounts;
  final String policy;
  final String additionalNotes;
  final String thankYouMessage;
  final String uploadedFileUrl; // Firebase Storage URL for uploaded file
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  AIKnowledgeModel({
    required this.id,
    required this.businessName,
    required this.phone,
    required this.address,
    required this.email,
    required this.companyStory,
    required this.paymentDetails,
    required this.discounts,
    required this.policy,
    required this.additionalNotes,
    required this.thankYouMessage,
    required this.uploadedFileUrl,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessName': businessName,
      'phone': phone,
      'address': address,
      'email': email,
      'companyStory': companyStory,
      'paymentDetails': paymentDetails,
      'discounts': discounts,
      'policy': policy,
      'additionalNotes': additionalNotes,
      'thankYouMessage': thankYouMessage,
      'uploadedFileUrl': uploadedFileUrl,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AIKnowledgeModel.fromMap(Map<String, dynamic> map) {
    return AIKnowledgeModel(
      id: map['id'] ?? '',
      businessName: map['businessName'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      email: map['email'] ?? '',
      companyStory: map['companyStory'] ?? '',
      paymentDetails: map['paymentDetails'] ?? '',
      discounts: map['discounts'] ?? '',
      policy: map['policy'] ?? '',
      additionalNotes: map['additionalNotes'] ?? '',
      thankYouMessage: map['thankYouMessage'] ?? '',
      uploadedFileUrl: map['uploadedFileUrl'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  AIKnowledgeModel copyWith({
    String? id,
    String? businessName,
    String? phone,
    String? address,
    String? email,
    String? companyStory,
    String? paymentDetails,
    String? discounts,
    String? policy,
    String? additionalNotes,
    String? thankYouMessage,
    String? uploadedFileUrl,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AIKnowledgeModel(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      email: email ?? this.email,
      companyStory: companyStory ?? this.companyStory,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      discounts: discounts ?? this.discounts,
      policy: policy ?? this.policy,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      thankYouMessage: thankYouMessage ?? this.thankYouMessage,
      uploadedFileUrl: uploadedFileUrl ?? this.uploadedFileUrl,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
