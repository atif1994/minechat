import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/core/services/otp_service.dart';

class OtpController extends GetxController {
  // from arguments
  late final String email;

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

    textControllers = List.generate(6, (_) => TextEditingController());
    focusNodes = List.generate(6, (_) => FocusNode());
    for (final node in focusNodes) {
      node.addListener(update);
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      focusNodes.first.requestFocus();
    });

    // Send OTP immediately
    _sendInitialOtp();
    startTimer();
  }

  Future<void> _sendInitialOtp() async {
    if (email.isEmpty) return;
    await _safeSendOtp();
  }

  Future<void> _safeSendOtp() async {
    try {
      isSending.value = true;
      await _otpService.sendOtp(email);
      Get.snackbar('OTP Sent', 'A 6-digit code was sent to $email',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
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

  void onOtpChanged(int index, String value) {
    otp[index] = value;
    isButtonEnabled.value = otp.every((d) => d.isNotEmpty);
  }

  void handleBackspace(int index) {
    if (otp[index].isNotEmpty) {
      otp[index] = '';
      textControllers[index].clear();
    } else if (index > 0) {
      focusNodes[index - 1].requestFocus();
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
    return "$m:$s";
  }

  Future<void> verifyOtp() async {
    final code = otp.join();
    if (code.length != OtpService.codeLength) return;

    try {
      isVerifying.value = true;
      final ok = await _otpService.verifyOtp(email: email, code: code);
      if (!ok) {
        Get.snackbar('Invalid Code', 'Please check the code and try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }
      Get.offAllNamed('/dashboard');
    } catch (e) {
      Get.snackbar('Verification Failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
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
    await _safeSendOtp();
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
