import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:minechat/controller/theme_controller/theme_controller.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';
import 'package:minechat/core/utils/extensions/app_gradient/app_gradient_extension.dart';
import 'package:minechat/core/utils/helpers/app_responsive/app_responsive.dart';
import 'package:minechat/core/utils/helpers/app_styles/app_text_styles.dart';

import '../../../controller/business_info_controller/business_info_controller.dart';
import '../../../core/utils/helpers/app_spacing/app_spacing.dart';
import '../../../core/widgets/app_button/app_save_ai_button.dart';
import '../../../core/widgets/signUp/signUp_textfield.dart';
import 'ai_business_information.dart';

class BusinessInformation extends StatelessWidget {
  final BusinessInfoController controller;

  const BusinessInformation({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    final radius = AppResponsive.radius(context);

    return Scaffold(
      backgroundColor: isDark ? Color(0XFF0A0A0A) : Color(0XFFF4F6FC),
      body: SingleChildScrollView(
        child: Column(
          children: [_buildBusinessInformationTab(controller, context)],
        ),
      ),
    );
  }

  Widget _buildBusinessInformationTab(
      BusinessInfoController controller, BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    final radius = AppResponsive.radius(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Business Information',
                style: AppTextStyles.bodyText(context).copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: '(watch tutorial video)',
                style: AppTextStyles.bodyText(context).copyWith(
                  fontSize: 10,
                  color: Color(0xFF1677FF),
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF1677FF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        AppSpacing.vertical(context, 0.02),

        // File Upload Section
        _buildFileUploadSection(controller, context),
        AppSpacing.vertical(context, 0.02),

        // Business Name
        SignupTextField(
          labelText: 'Business Name ',
          hintText: 'Enter Business Name',
          controller: controller.businessNameCtrl,
          errorText: controller.businessNameError,
        ),
        AppSpacing.vertical(context, 0.015),

        // Phone Number
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phone Number',
              style: AppTextStyles.bodyText(context).copyWith(
                fontSize: AppResponsive.scaleSize(context, 14),
                fontWeight: FontWeight.w500,
              ),
            ),
            AppSpacing.vertical(context, 0.005),

            IntlPhoneField(
              controller: controller.phoneCtrl,
              // keeps local part in the field
              initialCountryCode: 'PK',
              // default Pakistan
              disableLengthCheck: true,
              // show validation by length
              dropdownIconPosition: IconPosition.trailing,
              flagsButtonPadding: const EdgeInsets.only(left: 12),
              showDropdownIcon: false,

              // style to match your inputs
              decoration: InputDecoration(
                hintText: '0000000000',
                hintStyle: AppTextStyles.hintText(context),
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFBFD),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),

              // keep your controller in sync
              onChanged: (phone) {
                // local part already goes into controller.phoneCtrl.text
                controller.fullPhone.value =
                    phone.completeNumber; // +92xxxxxxxxxx
                controller.dialCode.value = phone.countryCode; // +92
                controller.isoCode.value = phone.countryISOCode; // PK
              },

              // you can also listen when country changes
              onCountryChanged: (country) {
                controller.dialCode.value = '+${country.dialCode}';
                controller.isoCode.value = country.code;
              },
            ),

            // your reactive error text (kept as-is)
            Obx(() => controller.phoneError.value.isNotEmpty
                ? Text(
                    controller.phoneError.value,
                    style: AppTextStyles.bodyText(context).copyWith(
                      fontSize: AppResponsive.scaleSize(context, 12),
                      color: AppColors.error,
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
        AppSpacing.vertical(context, 0.015),

        // Address
        SignupTextField(
          labelText: 'Address ',
          hintText: 'Enter address',
          controller: controller.addressCtrl,
          errorText: controller.addressError,
        ),
        AppSpacing.vertical(context, 0.015),

        // Email
        SignupTextField(
          labelText: 'Email',
          hintText: 'Enter email',
          controller: controller.emailCtrl,
          errorText: controller.emailError,
          keyboardType: TextInputType.emailAddress,
        ),
        AppSpacing.vertical(context, 0.015),

        // Company Story
        SignupTextField(
          labelText: 'Company Story ',
          hintText: 'Enter Company Story',
          controller: controller.companyStoryCtrl,
          errorText: controller.companyStoryError,
        ),
        AppSpacing.vertical(context, 0.015),

        // Payment Details
        SignupTextField(
          labelText: 'Payment Details ',
          hintText: 'Enter Payment Details',
          controller: controller.paymentDetailsCtrl,
          errorText: controller.paymentDetailsError,
        ),
        AppSpacing.vertical(context, 0.015),

        // Discounts
        SignupTextField(
          labelText: 'Discounts ',
          hintText: 'Enter Discounts',
          controller: controller.discountsCtrl,
          errorText: controller.discountsError,
        ),
        AppSpacing.vertical(context, 0.015),

        // Policy
        SignupTextField(
          labelText: 'Policy ',
          hintText: 'Enter Policy',
          controller: controller.policyCtrl,
          errorText: controller.policyError,
        ),
        AppSpacing.vertical(context, 0.015),

        // Additional Notes
        SignupTextField(
          labelText: 'Additional Notes ',
          hintText: 'Enter Additional Notes',
          controller: controller.additionalNotesCtrl,
          errorText: controller.additionalNotesError,
        ),
        AppSpacing.vertical(context, 0.015),

        // Thank you message
        SignupTextField(
          labelText: 'Thank You Message ',
          hintText: 'Enter Thank You Message',
          controller: controller.thankYouMessageCtrl,
          errorText: controller.thankYouMessageError,
        ),
        AppSpacing.vertical(context, 0.02),

        // Action Buttons
        TwoButtonsRow(
          isSaving: controller.isSaving,
          // your RxBool
          onSave: controller.saveBusinessInfo,
          // your save function
          secondLabel: "Test AI",
          // text for second button
          secondIcon: "assets/images/icons/icon_setup_test_ai_button.svg",
          // icon for second button
          onSecondTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AIBusinessInformation(),
              ),
            );
          },
        ),

        // Temporary Test Button
        AppSpacing.vertical(context, 0.02),
      ],
    );
  }

  Widget _buildFileUploadSection(
    BusinessInfoController controller,
    BuildContext context,
  ) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;
    final linkStyle = AppTextStyles.bodyText(context).copyWith(
      fontSize: 10,
      color: Color(0xFF1677FF),
      decoration: TextDecoration.underline,
      decorationColor: Color(0xFF1677FF),
      fontWeight: FontWeight.w500,
    );

    final subStyle = AppTextStyles.bodyText(context).copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w400,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Upload file you want to import ',
                style: subStyle,
              ),
              TextSpan(
                text: '(see sample document)',
                style: linkStyle,
              ),
            ],
          ),
        ),
        AppSpacing.vertical(context, 0.01),
        GestureDetector(
          onTap: () => controller.pickFile(),
          child: DottedBorder(
            color: isDark
                ? Color(0XFFFFFFFF).withValues(alpha: .12)
                : Color(0XFFEBEDF0),
            strokeWidth: 1.6,
            dashPattern: const [6, 6],
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(() {
                // If a file is already selected, show its name (keep original behavior)
                if (controller.selectedFileName.value.isNotEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.insert_drive_file,
                        size: 40,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          controller.selectedFileName.value,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  );
                }

                // Default “no file picked” design
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Upload icon in a light circle
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? Color(0XFFF0F1F5).withValues(alpha: .12)
                                  : Color(0XFFF0F1F5)),
                          child: Center(
                            child: SvgPicture.asset(
                              "assets/images/icons/icon_setup_file_upload.svg",
                              color: isDark
                                  ? Color(0XFFFFFFFF)
                                  : Color(0XFF15181F),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Gradient pill "Upload file" button (visual only; whole box is tappable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                          ).withAppGradient,
                          child: const Text(
                            'Upload file',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
