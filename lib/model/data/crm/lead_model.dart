import 'package:cloud_firestore/cloud_firestore.dart';

enum LeadStatus { hot, followUps, cold, opportunity }
enum LeadSource { website, social, referral, coldCall, other }

// Extension methods for display names
extension LeadStatusExtension on LeadStatus {
  String get displayName {
    switch (this) {
      case LeadStatus.hot:
        return 'Hot';
      case LeadStatus.followUps:
        return 'Follow-ups';
      case LeadStatus.cold:
        return 'Cold';
      case LeadStatus.opportunity:
        return 'Opportunity';
    }
  }
}

extension LeadSourceExtension on LeadSource {
  String get displayName {
    switch (this) {
      case LeadSource.website:
        return 'Website';
      case LeadSource.social:
        return 'Social Media';
      case LeadSource.referral:
        return 'Referral';
      case LeadSource.coldCall:
        return 'Cold Call';
      case LeadSource.other:
        return 'Other';
    }
  }
}

class LeadModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String description;
  final LeadStatus status;
  final LeadSource source;
  final String profileImageUrl;
  final DateTime createdAt;
  final DateTime? lastContacted;
  final String? assignedTo;
  final Map<String, dynamic>? customFields;
  final bool isSelected; // For UI selection state

  LeadModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.description,
    required this.status,
    required this.source,
    this.profileImageUrl = '',
    required this.createdAt,
    this.lastContacted,
    this.assignedTo,
    this.customFields,
    this.isSelected = false,
  });

  // Factory constructor to create from Firestore document
  factory LeadModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return LeadModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      description: data['description'] ?? '',
      status: LeadStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => LeadStatus.hot,
      ),
      source: LeadSource.values.firstWhere(
        (e) => e.toString().split('.').last == data['source'],
        orElse: () => LeadSource.other,
      ),
      profileImageUrl: data['profileImageUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastContacted: data['lastContacted'] != null 
          ? (data['lastContacted'] as Timestamp).toDate() 
          : null,
      assignedTo: data['assignedTo'],
      customFields: data['customFields'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'description': description,
      'status': status.toString().split('.').last,
      'source': source.toString().split('.').last,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastContacted': lastContacted != null ? Timestamp.fromDate(lastContacted!) : null,
      'assignedTo': assignedTo,
      'customFields': customFields,
    };
  }

  // Copy with method for updating fields
  LeadModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? description,
    LeadStatus? status,
    LeadSource? source,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastContacted,
    String? assignedTo,
    Map<String, dynamic>? customFields,
    bool? isSelected,
  }) {
    return LeadModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      description: description ?? this.description,
      status: status ?? this.status,
      source: source ?? this.source,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastContacted: lastContacted ?? this.lastContacted,
      assignedTo: assignedTo ?? this.assignedTo,
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
  String get statusDisplayName => status.displayName;

  // Get source display name
  String get sourceDisplayName => source.displayName;
}
