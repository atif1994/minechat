class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoURL;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final String? phoneNumber;
  final String? companyName;
  final String? position;
  final String accountType; // 'business', 'admin', 'regular'
  final bool isEmailVerified;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoURL,
    this.createdAt,
    this.lastLoginAt,
    this.phoneNumber,
    this.companyName,
    this.position,
    this.accountType = 'regular',
    this.isEmailVerified = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoURL: map['photoURL'],
      createdAt: map['createdAt']?.toDate(),
      lastLoginAt: map['lastLoginAt']?.toDate(),
      phoneNumber: map['phoneNumber'],
      companyName: map['companyName'],
      position: map['position'],
      accountType: map['accountType'] ?? 'regular',
      isEmailVerified: map['isEmailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoURL': photoURL,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
      'phoneNumber': phoneNumber,
      'companyName': companyName,
      'position': position,
      'accountType': accountType,
      'isEmailVerified': isEmailVerified,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? phoneNumber,
    String? companyName,
    String? position,
    String? accountType,
    bool? isEmailVerified,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      companyName: companyName ?? this.companyName,
      position: position ?? this.position,
      accountType: accountType ?? this.accountType,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  // Helper methods
  bool get isBusinessAccount => accountType == 'business';
  bool get isAdminAccount => accountType == 'admin';
  bool get isRegularAccount => accountType == 'regular';
}
