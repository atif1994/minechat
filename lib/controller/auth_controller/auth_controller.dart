import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  /// Initialize authentication state
  void _initializeAuth() {
    // Listen to authentication state changes
    _authService.authStateChanges.listen((User? user) {
      currentUser.value = user;
      isAuthenticated.value = user != null;
      
      if (user != null) {
        _handleAuthenticatedUser();
      } else {
        _handleUnauthenticatedUser();
      }
    });
  }

  /// Handle authenticated user flow
  void _handleAuthenticatedUser() {
    final hasCompletedOnboarding = _storage.read(_hasCompletedOnboardingKey) ?? false;
    final hasCompletedSetup = _storage.read(_hasCompletedSetupKey) ?? false;
    
    // Use Future.delayed to ensure GetMaterialApp is ready
    Future.delayed(const Duration(milliseconds: 100), () {
      if (hasCompletedOnboarding && hasCompletedSetup) {
        // User has completed onboarding and setup - go to main app
        Get.offAll(() => RootBottomNavScreen());
      } else if (hasCompletedOnboarding) {
        // User has completed onboarding but not setup - go to setup flow
        // You can navigate to your setup screen here
        Get.offAll(() => RootBottomNavScreen()); // For now, go to main app
      } else {
        // User is authenticated but hasn't completed onboarding - go to onboarding
        Get.offAll(() => OnboardingScreen());
      }
    });
  }

  /// Handle unauthenticated user flow
  void _handleUnauthenticatedUser() {
    // User is not authenticated - go to onboarding
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.offAll(() => OnboardingScreen());
    });
  }

  /// Check if user is already signed up and authenticated
  Future<void> checkAuthState() async {
    isLoading.value = true;
    
    try {
      final user = _authService.currentUser;
      
      if (user != null) {
        // User is already authenticated
        currentUser.value = user;
        isAuthenticated.value = true;
        _handleAuthenticatedUser();
      } else {
        // User is not authenticated
        isAuthenticated.value = false;
        _handleUnauthenticatedUser();
      }
    } catch (e) {
      print('Error checking auth state: $e');
      // On error, go to onboarding
      Get.offAll(() => OnboardingScreen());
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
  bool get hasCompletedOnboarding => _storage.read(_hasCompletedOnboardingKey) ?? false;

  /// Check if user has completed setup
  bool get hasCompletedSetup => _storage.read(_hasCompletedSetupKey) ?? false;

  /// Sign out user
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      // Clear stored data
      _storage.remove(_hasCompletedOnboardingKey);
      _storage.remove(_hasCompletedSetupKey);
      // Navigate to onboarding
      Get.offAll(() => OnboardingScreen());
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  /// Get current user ID
  String? get currentUserId => currentUser.value?.uid;

  /// Get current user email
  String? get currentUserEmail => currentUser.value?.email;
}
