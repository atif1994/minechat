import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/accounts_controller/manage_user_controller.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/constants/app_texts/app_texts.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/core/widgets/app_button/app_large_button.dart';
import 'package:minechat/core/widgets/signUp/signUp_header.dart';
import 'package:minechat/core/widgets/signUp/signUp_profile_avatar_picker.dart';
import 'package:minechat/core/widgets/signUp/signUp_textfield.dart';

class AddUserProfileScreen extends StatefulWidget {
  const AddUserProfileScreen({super.key});

  @override
  State<AddUserProfileScreen> createState() => _AddUserProfileScreenState();
}

class _AddUserProfileScreenState extends State<AddUserProfileScreen> {
  final ManageUserController c = Get.isRegistered<ManageUserController>()
      ? Get.find<ManageUserController>()
      : Get.put(ManageUserController(), permanent: true);


  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final roleCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  final nameErr = ''.obs;
  final emailErr = ''.obs;
  final roleErr = ''.obs;

  File? imageFile;

  void _validateName(String v) =>
      nameErr.value = v.trim().isEmpty ? 'Name is required' : '';

  void _validateEmail(String v) {
    final t = v.trim();
    if (t.isEmpty) {
      emailErr.value = 'Email is required';
    } else if (!RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
        .hasMatch(t)) {
      emailErr.value = 'Enter a valid email';
    } else {
      emailErr.value = '';
    }
  }

  void _validateRole(String v) =>
      roleErr.value = v.trim().isEmpty ? 'Role/Title is required' : '';

  bool get _formOk =>
      nameErr.value.isEmpty &&
      emailErr.value.isEmpty &&
      roleErr.value.isEmpty &&
      nameCtrl.text.trim().isNotEmpty &&
      emailCtrl.text.trim().isNotEmpty &&
      roleCtrl.text.trim().isNotEmpty &&
      !c.isBusy.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent,),
      body: SingleChildScrollView(
        padding: AppSpacing.all(context, factor: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SignupHeader(
              title: 'Add User Profile',
              subtitle: 'Create a profile you can manage later.',
              avatar: SignupProfileAvatarPicker(
                onImageSelected: (f) => imageFile = f,
              ),
            ),
            AppSpacing.vertical(context, 0.02),
            SignupTextField(
              label: AppTexts.signupAdminNameLabel,
              hintText: AppTexts.signupAdminNameHintText,
              prefixIcon: AppAssets.signupIconAdmin,
              controller: nameCtrl,
              errorText: nameErr,
              onChanged: _validateName,
            ),
            AppSpacing.vertical(context, 0.01),
            SignupTextField(
              label: AppTexts.signupEmailLabel,
              hintText: AppTexts.dummyEmailText,
              prefixIcon: AppAssets.signupIconEmail,
              controller: emailCtrl,
              errorText: emailErr,
              onChanged: _validateEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            AppSpacing.vertical(context, 0.01),
            SignupTextField(
              label: AppTexts.signupAdminPositionLabel,
              hintText: AppTexts.signupAdminPositionHintText,
              prefixIcon: AppAssets.signupIconPosition,
              controller: roleCtrl,
              errorText: roleErr,
              onChanged: _validateRole,
            ),
            AppSpacing.vertical(context, 0.01),
            SignupTextField(
              label: AppTexts.signupBusinessPhoneNumberLabel,
              hintText: AppTexts.signupBusinessPhoneNumberHintText,
              prefixIcon: AppAssets.signupIconPhone,
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
            ),
            AppSpacing.vertical(context, 0.02),
            Obx(
              () => AppLargeButton(
                label: c.isBusy.value ? 'Saving...' : 'Save Profile',
                isLoading: c.isBusy.value,
                isEnabled: _formOk,
                onTap: () {
                  _validateName(nameCtrl.text);
                  _validateEmail(emailCtrl.text);
                  _validateRole(roleCtrl.text);
                  if (!_formOk) return;
                  c.addProfile(
                    name: nameCtrl.text,
                    email: emailCtrl.text,
                    roleTitle: roleCtrl.text,
                    phone:
                        phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text,
                    imageFile: imageFile,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
