import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../data/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Save user data to Firestore
  Future<void> saveUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'name': user.name,
        'email': user.email,
        'photoURL': user.photoURL,
        'uid': user.uid,
        'phoneNumber': user.phoneNumber,
        'companyName': user.companyName,
        'position': user.position,
        'accountType': user.accountType,
        'isEmailVerified': user.isEmailVerified,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  // Upload profile image (common for both admin and business)
  Future<String> uploadProfileImage(
      File imageFile, String userId, String accountType) async {
    try {
      final path = 'profile_images/${accountType}_profile/$userId.jpg';
      final ref = _storage.ref().child(path);

      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Save business account data
  Future<void> saveBusinessAccount(UserModel user) async {
    try {
      await _firestore.collection('business_accounts').doc(user.uid).set({
        'uid': user.uid,
        'companyName': user.companyName,
        'email': user.email,
        'phoneNumber': user.phoneNumber,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save business account: $e');
    }
  }

  // Save admin user data
  Future<void> saveAdminUser(UserModel user) async {
    try {
      await _firestore.collection('admin_users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.name,
        'email': user.email,
        'position': user.position,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save admin user: $e');
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Get business account data
  Future<Map<String, dynamic>?> getBusinessAccount(String uid) async {
    try {
      final doc =
          await _firestore.collection('business_accounts').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get business account: $e');
    }
  }

  // Get admin user data
  Future<Map<String, dynamic>?> getAdminUser(String uid) async {
    try {
      final doc = await _firestore.collection('admin_users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get admin user: $e');
    }
  }

  // Update user's last login time
  Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update last login: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check email existence: $e');
    }
  }

  // Create user model from Firebase User
  UserModel createUserFromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      name: user.displayName ?? 'Unknown',
      email: user.email ?? '',
      photoURL: user.photoURL,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isEmailVerified: user.emailVerified,
    );
  }

  // Create business user model
  UserModel createBusinessUser({
    required String uid,
    required String email,
    required String companyName,
    required String phoneNumber,
    String? photoURL,
  }) {
    return UserModel(
      uid: uid,
      name: companyName,
      email: email,
      photoURL: photoURL,
      phoneNumber: phoneNumber,
      companyName: companyName,
      accountType: 'business',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  // Create admin user model
  UserModel createAdminUser({
    required String uid,
    required String email,
    required String name,
    required String position,
    String? photoURL,
  }) {
    return UserModel(
      uid: uid,
      name: name,
      email: email,
      photoURL: photoURL,
      position: position,
      accountType: 'admin',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  // Delete User Data when Deleting Account
  Future<void> deleteUserEverywhere(String uid) async {
    try {
      // Firestore docs (ignore if not found)
      await _firestore
          .collection('admin_users')
          .doc(uid)
          .delete()
          .catchError((_) {});
      await _firestore
          .collection('business_accounts')
          .doc(uid)
          .delete()
          .catchError((_) {});
      await _firestore.collection('users').doc(uid).delete().catchError((_) {});

      // Storage profile images (both possible locations)
      for (final path in [
        'profile_images/admin_profile/$uid.jpg',
        'profile_images/business_profile/$uid.jpg',
      ]) {
        try {
          await _storage.ref().child(path).delete();
        } catch (_) {}
      }
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }
}
