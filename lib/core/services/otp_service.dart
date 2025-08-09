import 'dart:math';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OtpService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Settings
  static const int codeLength = 6;
  static const Duration ttl = Duration(minutes: 3);
  static const Duration resendCooldown = Duration(seconds: 60);

  String _generateCode() {
    final rand = Random.secure();
    final code = List.generate(codeLength, (_) => rand.nextInt(10)).join();
    return code;
  }

  String _hash(String code) {
    return sha256.convert(utf8.encode(code)).toString();
  }

  Future<void> _saveOtp({
    required String email,
    required String codeHash,
    required DateTime expiresAt,
  }) async {
    await _firestore.collection('email_otps').doc(email).set({
      'email': email,
      'codeHash': codeHash,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'attempts': 0,
      'lastSentAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _sendEmailViaExtension({
    required String toEmail,
    required String code,
  }) async {
    // Requires Firebase Extension: "Email: Trigger Email" (writes to /mail)
    // https://firebase.google.com/products/extensions/mailchimp
    await _firestore.collection('mail').add({
      'to': toEmail,
      'message': {
        'subject': 'Your MineChat verification code',
        'text':
            'Your verification code is $code. It will expire in ${ttl.inMinutes} minutes.',
        'html':
            '<p>Your verification code is <b>$code</b>. It will expire in ${ttl.inMinutes} minutes.</p>',
      }
    });
  }

  Future<void> sendOtp(String email) async {
    final now = DateTime.now();

    // Cooldown check
    final snap = await _firestore.collection('email_otps').doc(email).get();
    if (snap.exists && snap.data()?['lastSentAt'] != null) {
      final lastSent = (snap.data()!['lastSentAt'] as Timestamp).toDate();
      if (now.difference(lastSent) < resendCooldown) {
        final remaining =
            resendCooldown.inSeconds - now.difference(lastSent).inSeconds;
        throw 'Please wait ${remaining}s before requesting a new code.';
      }
    }

    final code = _generateCode();
    final hash = _hash(code);
    final expiresAt = now.add(ttl);

    // Save OTP doc
    await _saveOtp(email: email, codeHash: hash, expiresAt: expiresAt);

    // Send email
    await _sendEmailViaExtension(toEmail: email, code: code);
  }

  Future<bool> verifyOtp({required String email, required String code}) async {
    final doc = await _firestore.collection('email_otps').doc(email).get();
    if (!doc.exists) throw 'No OTP request found. Please resend the code.';

    final data = doc.data()!;
    final expiresAt = (data['expiresAt'] as Timestamp).toDate();
    if (DateTime.now().isAfter(expiresAt)) {
      throw 'This code has expired. Please request a new one.';
    }

    final savedHash = data['codeHash'] as String;
    final matches = _hash(code) == savedHash;
    if (!matches) {
      // bump attempts (optional guardrail)
      await doc.reference.update({'attempts': FieldValue.increment(1)});
      return false;
    }

    // Mark verified (app-level flag)
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'isEmailVerified': true,
      }, SetOptions(merge: true));
    }

    // Clean up OTP doc
    await doc.reference.delete();
    return true;
  }
}
