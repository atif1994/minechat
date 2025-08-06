import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class OtpController extends GetxController {
  var otp = List.filled(6, '').obs;
  var isButtonEnabled = false.obs;
  var timerSeconds = 180.obs;
  Timer? _timer;

  late List<TextEditingController> textControllers;
  late List<FocusNode> focusNodes;

  @override
  void onInit() {
    super.onInit();

    textControllers = List.generate(6, (_) => TextEditingController());
    focusNodes = List.generate(6, (_) => FocusNode());

    // Add listener to trigger UI rebuild when focus changes
    for (final node in focusNodes) {
      node.addListener(update);
    }

    // Auto-focus first box
    Future.delayed(Duration(milliseconds: 300), () {
      focusNodes.first.requestFocus();
    });

    startTimer();
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
    isButtonEnabled.value = otp.every((digit) => digit.isNotEmpty);
  }

  void handleBackspace(int index) {
    if (otp[index].isNotEmpty) {
      otp[index] = '';
      textControllers[index].clear();
    } else if (index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    isButtonEnabled.value = otp.every((digit) => digit.isNotEmpty);
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
    final minutes = (timerSeconds.value ~/ 60).toString().padLeft(2, '0');
    final seconds = (timerSeconds.value % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (final node in focusNodes) {
      node.dispose();
    }
    for (final ctrl in textControllers) {
      ctrl.dispose();
    }
    super.onClose();
  }
}
