import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:minechat/controller/login_controller/login_controller.dart';
import 'package:minechat/model/data/accounts/manage_user_model.dart';
import 'package:minechat/model/data/user_model.dart';
import 'package:minechat/model/repositories/manage_user_repository.dart';

class ManageUserController extends GetxController {
  final repo = ManageUserRepository();

  /// All managed profiles for the owner (realtime)
  final profiles = <ManageUserModel>[].obs;

  /// Busy flag for add/edit/delete
  final isBusy = false.obs;

  /// Currently "switched" managed user; null = show owner/admin
  final activeProfile = Rx<ManageUserModel?>(null);

  /// Stream subscription for managing the Firestore listener
  StreamSubscription<List<ManageUserModel>>? _streamSubscription;

  String get ownerUid =>
      Get.find<LoginController>().currentUser.value?.uid ?? '';

  @override
  void onInit() {
    super.onInit();

    final login = Get.find<LoginController>();

    // If owner is already present, start stream now
    if (ownerUid.isNotEmpty) {
      _bindStream(ownerUid);
    }

    // Also bind when the login.currentUser arrives later
    ever<UserModel?>(login.currentUser, (u) {
      final uid = u?.uid ?? '';
      if (uid.isNotEmpty) {
        _bindStream(uid);
      } else {
        // User logged out, clear data and cancel stream
        _clearData();
      }
    });
  }

  void _bindStream(String uid) {
    // Cancel existing subscription if any
    _streamSubscription?.cancel();
    
    _streamSubscription = repo.streamByOwner(uid).listen(
      (list) {
        profiles.assignAll(list);
        // keep activeProfile in sync with latest snapshot (id match)
        final activeId = activeProfile.value?.id;
        if (activeId != null) {
          activeProfile.value = list.firstWhereOrNull((e) => e.id == activeId);
        }
      },
      onError: (error) {
        // Handle permission errors gracefully
        print('ManageUserController stream error: $error');
        _clearData();
      },
    );
  }

  void _clearData() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    profiles.clear();
    activeProfile.value = null;
  }

  /// Switch UI context to a managed user (affects AccountScreen tile)
  void switchToProfile(ManageUserModel m) {
    activeProfile.value = m;
    Get.snackbar('Switched', 'Now viewing ${m.name}');
  }

  /// Switch back to owner/admin (optional helper if you add a button somewhere)
  void clearSwitchedProfile() {
    activeProfile.value = null;
  }

  Future<void> addProfile({
    required String name,
    required String email,
    required String roleTitle,
    String? phone,
    File? imageFile,
  }) async {
    if (ownerUid.isEmpty) {
      Get.snackbar('Error', 'No logged-in user.');
      return;
    }

    isBusy.value = true;
    try {
      final dup = await repo.emailExistsForOwner(ownerUid, email);
      if (dup) {
        Get.snackbar('Duplicate', 'A profile with this email already exists.');
        isBusy.value = false; // ensure we reset before returning
        return;
      }

      await repo.create(
        ownerUid: ownerUid,
        name: name,
        email: email,
        roleTitle: roleTitle,
        phone: phone,
        imageFile: imageFile,
      );

      // ✅ Explicitly navigate to Manage screen after success
      Get.offNamed(
          '/manage-user-profiles'); // AppRoutes.manageUserProfiles if you prefer
      Get.snackbar('Saved', 'User profile added.');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> updateProfile(ManageUserModel m, {File? image}) async {
    isBusy.value = true;
    try {
      await repo.update(m, newImage: image);
      Get.back(); // close dialog
      Get.snackbar('Updated', 'User profile updated.');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> deleteProfile(ManageUserModel m) async {
    isBusy.value = true;
    try {
      await repo.delete(m);
      // If we deleted the active one, fall back to owner
      if (activeProfile.value?.id == m.id) {
        activeProfile.value = null;
      }
      Get.snackbar('Deleted', 'User profile deleted.');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isBusy.value = false;
    }
  }

  @override
  void onClose() {
    _streamSubscription?.cancel();
    super.onClose();
  }
}
