import 'package:get/get.dart';

class SetupNavigationController extends GetxController {
  var currentSetupStep = 0.obs;
  
  // Setup steps: 0 = AI Assistant, 1 = AI Knowledge, 2 = Channels
  final List<String> setupSteps = [
    'AI Assistant',
    'AI Knowledge', 
    'Channels'
  ];

  void goToStep(int step) {
    if (step >= 0 && step < setupSteps.length) {
      currentSetupStep.value = step;
    }
  }

  void nextStep() {
    if (currentSetupStep.value < setupSteps.length - 1) {
      currentSetupStep.value++;
    }
  }

  void previousStep() {
    if (currentSetupStep.value > 0) {
      currentSetupStep.value--;
    }
  }

  String get currentStepName => setupSteps[currentSetupStep.value];
  
  bool get isFirstStep => currentSetupStep.value == 0;
  bool get isLastStep => currentSetupStep.value == setupSteps.length - 1;
}
