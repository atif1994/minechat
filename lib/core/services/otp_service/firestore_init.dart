import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreInitializer {
  static final _firestore = FirebaseFirestore.instance;
  static bool _isInitialized = false;

  static Future<void> initializeCollections() async {
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp();

      // Initialize mailTemplates collection
      await _initMailTemplates();

      // Initialize other collections if needed
      await _initOtpCodes();

      _isInitialized = true;
    } catch (e) {
      print('Firestore initialization error: $e');
      // Fail silently - the app should still work
    }
  }

  static Future<void> _initMailTemplates() async {
    const templateId = 'otp';
    final templateRef = _firestore.collection('mailTemplates').doc(templateId);

    // Check if exists first to prevent overwriting
    final exists = (await templateRef.get()).exists;
    if (!exists) {
      await templateRef.set({
        'subject': 'Your MineChat Verification Code: {{otp}}',
        'html': '''
          <p>Your verification code is: <strong>{{otp}}</strong></p>
          <p>Expires in 3 minutes.</p>
          <p>If you didn't request this, please ignore this email.</p>
        ''',
        'text': '''
          Your verification code: {{otp}}
          Expires in 3 minutes.
          
          If you didn't request this, please ignore this email.
        ''',
      }, SetOptions(merge: true));
    }
  }

  static Future<void> _initOtpCodes() async {
    // This collection doesn't need initial documents
    // Just ensures the collection reference is valid
    // Firestore creates collections automatically on first write
  }
}
