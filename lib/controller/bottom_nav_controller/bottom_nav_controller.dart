import 'package:get/get.dart';

class BottomNavController extends GetxController {
  /// Current selected tab index
  final RxInt currentIndex = 0.obs;

  /// Change the active tab
  void changeTab(int index) {
    // Optional: handle reselect behaviour here (e.g., scroll-to-top event)
    currentIndex.value = index;
  }
}
