import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:minechat/core/constants/app_assets/app_assets.dart';
import 'package:minechat/core/constants/app_colors/app_colors.dart';

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
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16,right: 16),
          child: Column(
            children: [
              _buildBusinessInformationTab(controller, context)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessInformationTab(BusinessInfoController controller,
      BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Business Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        AppSpacing.vertical(context, 0.02),

        // File Upload Section
        _buildFileUploadSection(controller, context),
        AppSpacing.vertical(context, 0.02),

        // Business Name
        SignupTextField(
          labelText: 'Company Name',
          hintText: 'Enter Company Name',
          controller: controller.businessNameCtrl,
          errorText: controller.businessNameError,
        ),
        AppSpacing.vertical(context, 0.015),

        // Phone Number
        SignupTextField(
          labelText: 'Phone Number',
          hintText: 'Enter phone number',
                        prefixIcon: 'assets/images/icons/icon_phone.svg',
          // optional
          controller: controller.phoneCtrl,
          errorText: controller.phoneError,
          keyboardType: TextInputType.phone,
        ),
        AppSpacing.vertical(context, 0.015),

        // Address
        SignupTextField(
          labelText: 'Address',
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
          labelText: 'Company Story or Other information',
          hintText: 'Enter Company Story or Other information',
          controller: controller.companyStoryCtrl,
          errorText: controller.companyStoryError,
        ),
        AppSpacing.vertical(context, 0.015),

        // Payment Details
        SignupTextField(
          labelText: 'Payment Details',
          hintText: 'Enter Payment Details',
          controller: controller.paymentDetailsCtrl,
          errorText: controller.paymentDetailsError,
        ),
        AppSpacing.vertical(context, 0.015),

        // Discounts
        SignupTextField(
          labelText: 'Discounts',
          hintText: 'Enter Discounts',
          controller: controller.discountsCtrl,
          errorText: controller.discountsError,
        ),
        AppSpacing.vertical(context, 0.015),

        // Policy
        SignupTextField(
          labelText: 'Policy',
          hintText: 'Enter Policy',
          controller: controller.policyCtrl,
          errorText: controller.policyError,
        ),
        AppSpacing.vertical(context, 0.015),

        // Additional Notes
        SignupTextField(
          labelText: 'Additional Notes',
          hintText: 'Enter Additional Notes',
          controller: controller.additionalNotesCtrl,
          errorText: controller.additionalNotesError,
        ),
        AppSpacing.vertical(context, 0.015),

        // Thank you message
        SignupTextField(
          labelText: 'Thank You Message',
          hintText: 'Enter Thank You Message',
          controller: controller.thankYouMessageCtrl,
          errorText: controller.thankYouMessageError,
        ),
        AppSpacing.vertical(context, 0.02),

        // Action Buttons
        TwoButtonsRow(
          isSaving: controller.isSaving,          // your RxBool
          onSave: controller.saveBusinessInfo,     // your save function
          secondLabel: "Test AI",                 // text for second button
          secondIcon: Icons.smart_toy,            // icon for second button
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
      BusinessInfoController controller, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload file you want to import (see sample document)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: () => controller.pickFile(),
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(() {
                if (controller.selectedFileName.value.isNotEmpty) {
                  // Show uploaded file name
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.insert_drive_file,
                          size: 40, color: Colors.blueGrey),
                      const SizedBox(height: 8),
                      Text(
                        controller.selectedFileName.value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),

                    ],
                  );
                } else {
                  // Default design (no file picked yet)
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppAssets.uploadFile,
                        height: 40,
                        width: 40,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Upload file',
                          style: TextStyle(
                            color: AppColors.g3,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  );
                }
              }),
            ),
          ),
        ],
      ),
    );
  }




}
