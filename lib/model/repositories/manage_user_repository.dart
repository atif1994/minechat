import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:minechat/model/data/accounts/manage_user_model.dart';

class ManageUserRepository {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('manage_users');

  Stream<List<ManageUserModel>> streamByOwner(String ownerUid) {
    return _col
        .where('ownerUid', isEqualTo: ownerUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((q) => q.docs
            .map((d) => ManageUserModel.fromDoc(
                d as DocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }

  Future<String> create({
    required String ownerUid,
    required String name,
    required String email,
    required String roleTitle,
    String? phone,
    File? imageFile,
  }) async {
    final doc = _col.doc();

    String? photoURL;
    if (imageFile != null) {
      final path = 'profile_images/manage_users/$ownerUid/${doc.id}.jpg';
      final ref = _storage.ref().child(path);
      await ref.putFile(imageFile);
      photoURL = await ref.getDownloadURL();
    }

    await doc.set({
      'ownerUid': ownerUid,
      'name': name.trim(),
      'email': email.trim(),
      'roleTitle': roleTitle.trim(),
      'phone': (phone ?? '').trim().isEmpty ? null : phone!.trim(),
      'photoURL': photoURL,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<void> update(ManageUserModel m, {File? newImage}) async {
    String? photoURL = m.photoURL;
    if (newImage != null) {
      final path = 'profile_images/manage_users/${m.ownerUid}/${m.id}.jpg';
      final ref = _storage.ref().child(path);
      await ref.putFile(newImage);
      photoURL = await ref.getDownloadURL();
    }

    await _col.doc(m.id).update({
      'name': m.name.trim(),
      'email': m.email.trim(),
      'roleTitle': m.roleTitle.trim(),
      'phone': (m.phone ?? '').trim().isEmpty ? null : m.phone!.trim(),
      'photoURL': photoURL,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(ManageUserModel m) async {
    await _col.doc(m.id).delete();
    final path = 'profile_images/manage_users/${m.ownerUid}/${m.id}.jpg';
    try {
      await _storage.ref().child(path).delete();
    } catch (_) {}
  }

  Future<bool> emailExistsForOwner(String ownerUid, String email) async {
    final q = await _col
        .where('ownerUid', isEqualTo: ownerUid)
        .where('email', isEqualTo: email.trim())
        .limit(1)
        .get();
    return q.docs.isNotEmpty;
  }
}
