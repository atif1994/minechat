import 'dart:math';

class OtpService {
  OtpService._();

  static final OtpService _instance = OtpService._();

  factory OtpService() => _instance;

  static const int codeLength = 6;

  /// Generate a random 6-digit OTP code
  String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Send a 6-digit OTP to the given email (simplified version)
  /// Note: This is a placeholder implementation. In production, you would
  /// integrate with an email service like SendGrid, AWS SES, or similar.
  Future<void> sendOtp({required String email}) async {
    // For now, just simulate sending OTP
    // In a real app, you would call an email service here
    print('OTP would be sent to: $email');
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Verify OTP code (simplified version)
  /// Note: This is a placeholder implementation. In production, you would
  /// verify against a stored OTP in your database.
  Future<String> verifyOtpAndIssueResetSession({
    required String email,
    required String code,
  }) async {
    // For now, just simulate verification
    // In a real app, you would verify against stored OTP
    if (code.length == 6 && code.contains(RegExp(r'^\d+$'))) {
      // Generate a mock reset token
      return 'mock_reset_token_${DateTime.now().millisecondsSinceEpoch}';
    }
    throw 'Invalid OTP code';
  }
}
