import 'package:cloud_functions/cloud_functions.dart';

class OtpService {
  OtpService._();

  static final OtpService _instance = OtpService._();

  factory OtpService() => _instance;

  static const int codeLength = 6;
  static const String _region = 'us-central1';

  FirebaseFunctions get _fx => FirebaseFunctions.instanceFor(region: _region);

  /// Send a 6-digit OTP to the given email via Cloud Function (and Trigger Email extension).
  Future<void> sendOtp({required String email}) async {
    final res = await _fx.httpsCallable('sendOtpEmail').call({'email': email});
    final data = (res.data as Map?) ?? {};
    if (data['ok'] != true) {
      throw data['error'] ?? 'Failed to send OTP';
    }
  }

  /// Verify OTP on the server and (for forgot-password) create a reset session.
  /// Returns a resetToken string (use it only in forgot-password flow).
  Future<String> verifyOtpAndIssueResetSession({
    required String email,
    required String code,
  }) async {
    final res = await _fx
        .httpsCallable('verifyOtpAndIssueResetSession')
        .call({'email': email, 'code': code});
    final data = (res.data as Map?) ?? {};
    if (data['ok'] == true && data['resetToken'] is String) {
      return data['resetToken'] as String;
    }
    throw data['error'] ?? 'Verification failed';
  }
}
