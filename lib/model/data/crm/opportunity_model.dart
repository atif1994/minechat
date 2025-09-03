import 'package:cloud_firestore/cloud_firestore.dart';

enum OpportunityStatus { open, qualified, proposal, negotiation, closedWon, closedLost }
enum OpportunityStage { initial, qualified, proposal, negotiation, closed }

class OpportunityModel {
  final String id;
  final String leadId;
  final String name;
  final String description;
  final double amount;
  final String currency;
  final OpportunityStatus status;
  final OpportunityStage stage;
  final DateTime expectedCloseDate;
  final DateTime createdAt;
  final DateTime? lastModified;
  final String? assignedTo;
  final double probability; // 0-100 percentage
  final String? notes;
  final Map<String, dynamic>? customFields;
  final bool isSelected; // For UI selection state

  OpportunityModel({
    required this.id,
    required this.leadId,
    required this.name,
    required this.description,
    required this.amount,
    this.currency = 'USD',
    required this.status,
    required this.stage,
    required this.expectedCloseDate,
    required this.createdAt,
    this.lastModified,
    this.assignedTo,
    this.probability = 0.0,
    this.notes,
    this.customFields,
    this.isSelected = false,
  });

  // Factory constructor to create from Firestore document
  factory OpportunityModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return OpportunityModel(
      id: doc.id,
      leadId: data['leadId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'USD',
      status: OpportunityStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => OpportunityStatus.open,
      ),
      stage: OpportunityStage.values.firstWhere(
        (e) => e.toString().split('.').last == data['stage'],
        orElse: () => OpportunityStage.initial,
      ),
      expectedCloseDate: (data['expectedCloseDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastModified: data['lastModified'] != null 
          ? (data['lastModified'] as Timestamp).toDate() 
          : null,
      assignedTo: data['assignedTo'],
      probability: (data['probability'] ?? 0.0).toDouble(),
      notes: data['notes'],
      customFields: data['customFields'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'leadId': leadId,
      'name': name,
      'description': description,
      'amount': amount,
      'currency': currency,
      'status': status.toString().split('.').last,
      'stage': stage.toString().split('.').last,
      'expectedCloseDate': Timestamp.fromDate(expectedCloseDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastModified': lastModified != null ? Timestamp.fromDate(lastModified!) : null,
      'assignedTo': assignedTo,
      'probability': probability,
      'notes': notes,
      'customFields': customFields,
    };
  }

  // Copy with method for updating fields
  OpportunityModel copyWith({
    String? id,
    String? leadId,
    String? name,
    String? description,
    double? amount,
    String? currency,
    OpportunityStatus? status,
    OpportunityStage? stage,
    DateTime? expectedCloseDate,
    DateTime? createdAt,
    DateTime? lastModified,
    String? assignedTo,
    double? probability,
    String? notes,
    Map<String, dynamic>? customFields,
    bool? isSelected,
  }) {
    return OpportunityModel(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      stage: stage ?? this.stage,
      expectedCloseDate: expectedCloseDate ?? this.expectedCloseDate,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      assignedTo: assignedTo ?? this.assignedTo,
      probability: probability ?? this.probability,
      notes: notes ?? this.notes,
      customFields: customFields ?? this.customFields,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  // Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Get status display name
  String get statusDisplayName {
    switch (status) {
      case OpportunityStatus.open:
        return 'Open';
      case OpportunityStatus.qualified:
        return 'Qualified';
      case OpportunityStatus.proposal:
        return 'Proposal';
      case OpportunityStatus.negotiation:
        return 'Negotiation';
      case OpportunityStatus.closedWon:
        return 'Closed Won';
      case OpportunityStatus.closedLost:
        return 'Closed Lost';
    }
  }

  // Get stage display name
  String get stageDisplayName {
    switch (stage) {
      case OpportunityStage.initial:
        return 'Initial';
      case OpportunityStage.qualified:
        return 'Qualified';
      case OpportunityStage.proposal:
        return 'Proposal';
      case OpportunityStage.negotiation:
        return 'Negotiation';
      case OpportunityStage.closed:
        return 'Closed';
    }
  }

  // Get formatted amount
  String get formattedAmount {
    return '\$${amount.toStringAsFixed(2)}';
  }

  // Get days until close
  int get daysUntilClose {
    final now = DateTime.now();
    return expectedCloseDate.difference(now).inDays;
  }

  // Check if opportunity is overdue
  bool get isOverdue {
    return daysUntilClose < 0;
  }

  // Get status color
  String get statusColor {
    switch (status) {
      case OpportunityStatus.open:
        return '#FF6B35'; // Orange
      case OpportunityStatus.qualified:
        return '#4ECDC4'; // Teal
      case OpportunityStatus.proposal:
        return '#45B7D1'; // Blue
      case OpportunityStatus.negotiation:
        return '#96CEB4'; // Green
      case OpportunityStatus.closedWon:
        return '#2ECC71'; // Green
      case OpportunityStatus.closedLost:
        return '#E74C3C'; // Red
    }
  }
}
