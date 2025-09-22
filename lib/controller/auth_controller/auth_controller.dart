import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:minechat/controller/login_controller/login_controller.dart';
import 'package:minechat/controller/accounts_controller/manage_user_controller.dart';
import 'package:minechat/core/services/firebase_auth_service.dart';
import 'package:minechat/view/screens/onboarding/onboarding_screen.dart';
import 'package:minechat/view/screens/root_bottom_navigation/root_bottom_nav_scree.dart';

class AuthController extends GetxController {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final GetStorage _storage = GetStorage();

  // Observable variables
  var isLoading = false.obs;
  var isAuthenticated = false.obs;
  var currentUser = Rx<User?>(null);

  // Storage keys
  static const String _hasCompletedOnboardingKey = 'hasCompletedOnboarding';
  static const String _hasCompletedSetupKey = 'hasCompletedSetup';

  static final RxBool suppressGlobalRouting = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Only keep auth state in sync; do NOT navigate here
    _authService.authStateChanges.listen((User? user) {
      currentUser.value = user;
      isAuthenticated.value = user != null;

      // ❌ DO NOT navigate here if we are in a special flow (e.g., OTP)
      if (suppressGlobalRouting.value) return;

      // hydrate LoginController's currentUser whenever auth changes
      final login = Get.find<LoginController>();
      if (user != null) {
        login.hydrateFromAuthIfNeeded();
      } else {
        login.currentUser.value = null;
      }
    });
  }

  /// Called by SplashScreen when the animation ends
  Future<void> resolveStartupRoute() async {
    try {
      isLoading.value = true;
      final user = _authService.currentUser;
      if (user != null) {
        // Logged in → straight to app
        Get.offAll(() => RootBottomNavScreen());
      } else {
        // Not logged in → onboarding
        Get.offAll(() => const OnboardingScreen());
      }
    } catch (e) {
      // On error, be safe and go to onboarding
      Get.offAll(() => const OnboardingScreen());
    } finally {
      isLoading.value = false;
    }
  }

  /// Mark onboarding as completed
  void markOnboardingCompleted() {
    _storage.write(_hasCompletedOnboardingKey, true);
  }

  /// Mark setup as completed
  void markSetupCompleted() {
    _storage.write(_hasCompletedSetupKey, true);
  }

  /// Check if user has completed onboarding
  bool get hasCompletedOnboarding =>
      _storage.read(_hasCompletedOnboardingKey) ?? false;

  /// Check if user has completed setup
  bool get hasCompletedSetup => _storage.read(_hasCompletedSetupKey) ?? false;

  /// Sign out user
  Future<void> signOut() async {
    try {
      // Dispose of controllers that have active streams
      if (Get.isRegistered<ManageUserController>()) {
        Get.delete<ManageUserController>();
      }

      await _authService.signOut();
      _storage.remove(_hasCompletedOnboardingKey);
      _storage.remove(_hasCompletedSetupKey);
      Get.offAll(() => const OnboardingScreen());
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  /// Get current user ID
  String? get currentUserId => currentUser.value?.uid;

  /// Get current user email
  String? get currentUserEmail => currentUser.value?.email;
}