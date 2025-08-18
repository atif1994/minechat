import 'package:cloud_functions/cloud_functions.dart';

class ResetPasswordService {
  // use same region you deployed: us-central1
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');

  Future<void> resetPasswordWithSession({
    required String email,
    required String newPassword,
    required String resetToken,
  }) async {
    final callable = _functions.httpsCallable('resetPasswordWithSession');
    final res = await callable.call({
      'email': email,
      'newPassword': newPassword,
      'resetToken': resetToken,
    });
    final data = (res.data as Map?) ?? {};
    if (data['ok'] != true) {
      throw data['error'] ?? 'Password reset failed';
    }
  }
}
