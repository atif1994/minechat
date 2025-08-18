import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:minechat/core/services/otp_service/otp_service.dart';

class OtpController extends GetxController {
  late final String email;
  late final String purpose; // 'signup' | 'forgot'
  late final bool skipInitialSend;

  final otp = List.filled(6, '').obs;
  final isButtonEnabled = false.obs;
  final timerSeconds = 180.obs;
  final isSending = false.obs;
  final isVerifying = false.obs;

  Timer? _timer;
  late List<TextEditingController> textControllers;
  late List<FocusNode> focusNodes;

  final _otpService = OtpService();

  @override
  void onInit() {
    super.onInit();
    email = (Get.arguments?['email'] as String?) ?? '';
    purpose = (Get.arguments?['purpose'] as String?) ?? 'signup';
    skipInitialSend = (Get.arguments?['skipInitialSend'] as bool?) ?? false;

    textControllers = List.generate(6, (_) => TextEditingController());
    focusNodes = List.generate(6, (_) => FocusNode());
    for (final node in focusNodes) {
      node.addListener(update);
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      focusNodes.first.requestFocus();
    });

    if (!skipInitialSend) _sendInitialOtp();
    startTimer();
  }

  Future<void> _sendInitialOtp() async {
    if (email.isEmpty) return;
    try {
      isSending.value = true;
      await _otpService.sendOtp(email: email);
      Get.snackbar('OTP Sent', 'A 6-digit code was sent to $email',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSending.value = false;
    }
  }

  void startTimer() {
    timerSeconds.value = 180;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
      } else {
        _timer?.cancel();
      }
    });
  }

  void onOtpChanged(int i, String v) {
    otp[i] = v;
    isButtonEnabled.value = otp.every((d) => d.isNotEmpty);
  }

  void handleBackspace(int i) {
    if (otp[i].isNotEmpty) {
      otp[i] = '';
      textControllers[i].clear();
    } else if (i > 0) {
      focusNodes[i - 1].requestFocus();
    }
    isButtonEnabled.value = otp.every((d) => d.isNotEmpty);
  }

  Future<void> pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null && data.text!.length == otp.length) {
      for (int i = 0; i < otp.length; i++) {
        otp[i] = data.text![i];
        textControllers[i].text = otp[i];
      }
      isButtonEnabled.value = true;
    }
  }

  String get formattedTime {
    final m = (timerSeconds.value ~/ 60).toString().padLeft(2, '0');
    final s = (timerSeconds.value % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> verifyOtp() async {
    final code = otp.join();
    if (code.length != OtpService.codeLength) return;

    try {
      isVerifying.value = true;

      // Server-side verification for BOTH flows
      final token = await _otpService.verifyOtpAndIssueResetSession(
        email: email,
        code: code,
      );

      if (purpose == 'forgot') {
        Get.offNamed('/new-password', arguments: {
          'email': email,
          'resetToken': token,
        });
      } else {
        // Signup flow: continue to your home/root
        Get.offAllNamed('/root-bottom-nav-bar');
      }
    } catch (e) {
      Get.snackbar('Verification Failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isVerifying.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (timerSeconds.value > 0) {
      Get.snackbar('Please wait', 'You can resend in ${timerSeconds.value}s.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    await _sendInitialOtp();
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (final n in focusNodes) {
      n.dispose();
    }
    for (final c in textControllers) {
      c.dispose();
    }
    super.onClose();
  }
}
