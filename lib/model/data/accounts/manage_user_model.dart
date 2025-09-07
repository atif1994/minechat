import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUserModel {
  final String id;
  final String ownerUid;
  final String name;
  final String email;
  final String roleTitle;
  final String? phone;
  final String? photoURL;
  final String status; // active|inactive
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ManageUserModel({
    required this.id,
    required this.ownerUid,
    required this.name,
    required this.email,
    required this.roleTitle,
    this.phone,
    this.photoURL,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  ManageUserModel copyWith({
    String? id,
    String? ownerUid,
    String? name,
    String? email,
    String? roleTitle,
    String? phone,
    String? photoURL,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ManageUserModel(
      id: id ?? this.id,
      ownerUid: ownerUid ?? this.ownerUid,
      name: name ?? this.name,
      email: email ?? this.email,
      roleTitle: roleTitle ?? this.roleTitle,
      phone: phone ?? this.phone,
      photoURL: photoURL ?? this.photoURL,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'ownerUid': ownerUid,
    'name': name,
    'email': email,
    'roleTitle': roleTitle,
    'phone': phone,
    'photoURL': photoURL,
    'status': status,
    'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
  };

  factory ManageUserModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return ManageUserModel(
      id: doc.id,
      ownerUid: d['ownerUid'] ?? '',
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      roleTitle: d['roleTitle'] ?? '',
      phone: d['phone'],
      photoURL: d['photoURL'],
      status: d['status'] ?? 'active',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
