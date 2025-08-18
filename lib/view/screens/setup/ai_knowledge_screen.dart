import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minechat/controller/ai_knowledge_controller/ai_knowledge_controller.dart';
import 'package:minechat/controller/product_controller/product_controller.dart';
import 'package:minechat/controller/faq_controller/faq_controller.dart';
import 'package:minechat/core/utils/helpers/app_spacing/app_spacing.dart';
import 'package:minechat/model/data/product_model.dart';
import 'package:minechat/model/data/faq_model.dart';

import '../../../controller/ai_assistant_controller/ai_assistant_controller.dart';

class AIKnowledgeScreen extends StatelessWidget {
  final AIAssistantController controller;

  const AIKnowledgeScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final productController = Get.put(ProductController());
    final faqController = Get.put(FAQController());

    final controller = Get.put((AIKnowledgeController() ));
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 80,),

          Row(
            children: [

              _buildTab('Business Information', 0,controller),
              _buildTab('Products & Services', 1,controller),
              _buildTab('FAQs', 2,controller),
            ],
          ),
          const SizedBox(height: 20),
          // if (controller.selectedTabIndex.value == 0)
          //   BusinessInformationWidget()
          // else if (controller.selectedTabIndex.value == 1)
          //   ProductsServicesWidget(controller: productController)
          // else
          //   FAQWidget(controller: faqController),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index,controller) {
    final isSelected = controller.selectedTabIndex.value == index;
    return GestureDetector(
      onTap: () => controller.selectedTabIndex.value = index,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red[400] : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.red[400]! : Colors.grey[300]!,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}



  Widget _buildBreadcrumbs(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Text(
            'Setup',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.chevron_right, color: Colors.grey[600], size: 16),
        const SizedBox(width: 8),
        Text(
          'AI Assistant',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.chevron_right, color: Colors.grey[600], size: 16),
        const SizedBox(width: 8),
        Text(
          'AI Knowledge',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.chevron_right, color: Colors.grey[600], size: 16),
        const SizedBox(width: 8),
        Text(
          'Channels',
          style: TextStyle(
            color: Colors.red[400],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(AIKnowledgeController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => controller.selectedTabIndex.value = 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: controller.selectedTabIndex.value == 0
                    ? Colors.red[400]
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Business Information',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: controller.selectedTabIndex.value == 0
                      ? Colors.white
                      : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => controller.selectedTabIndex.value = 1,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: controller.selectedTabIndex.value == 1
                    ? Colors.red[400]
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Products & Services',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: controller.selectedTabIndex.value == 1
                      ? Colors.white
                      : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => controller.selectedTabIndex.value = 2,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: controller.selectedTabIndex.value == 2
                    ? Colors.red[400]
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'FAQs',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: controller.selectedTabIndex.value == 2
                      ? Colors.white
                      : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTabContent(
      AIKnowledgeController controller,
      ProductController productController,
      FAQController faqController,
      BuildContext context,
      ) {
    return Obx(() {
      switch (controller.selectedTabIndex.value) {
        case 0:
          return _buildBusinessInformationTab(controller, context);
        case 1:
          return _buildProductsServicesTab(productController, context);
        case 2:
          return _buildFAQsTab(faqController, context);
        default:
          return _buildBusinessInformationTab(controller, context);
      }
    });
  }

  Widget _buildBusinessInformationTab(AIKnowledgeController controller, BuildContext context) {
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
        _buildTextField('Business Name', 'Enter Company Name', controller.businessNameCtrl, controller.businessNameError),
        AppSpacing.vertical(context, 0.015),

        // Phone Number with flag
        _buildPhoneField(controller.phoneCtrl, controller.phoneError),
        AppSpacing.vertical(context, 0.015),

        // Address
        _buildTextField('Address', 'Enter address', controller.addressCtrl, controller.addressError),
        AppSpacing.vertical(context, 0.015),

        // Email
        _buildTextField('Email', 'Enter email', controller.emailCtrl, controller.emailError),
        AppSpacing.vertical(context, 0.015),

        // Company Story or Other information
        _buildMultiLineTextField('Company Story or Other information:', 'Enter Company Story or Other information:', controller.companyStoryCtrl, controller.companyStoryError),
        AppSpacing.vertical(context, 0.015),

        // Payment Details
        _buildMultiLineTextField('Payment Details:', 'Payment Details:', controller.paymentDetailsCtrl, controller.paymentDetailsError),
        AppSpacing.vertical(context, 0.015),

        // Discounts
        _buildMultiLineTextField('Discounts:', 'Enter FAQs', controller.discountsCtrl, controller.discountsError),
        AppSpacing.vertical(context, 0.015),

        // Policy
        _buildMultiLineTextField('Policy:', 'Enter Enter Policy', controller.policyCtrl, controller.policyError),
        AppSpacing.vertical(context, 0.015),

        // Additional Notes
        _buildMultiLineTextField('Additional Notes:', 'Enter Additional Notes', controller.additionalNotesCtrl, controller.additionalNotesError),
        AppSpacing.vertical(context, 0.015),

        // Thank you message
        _buildMultiLineTextField('Thank you message', 'Enter Thank you message', controller.thankYouMessageCtrl, controller.thankYouMessageError),
        AppSpacing.vertical(context, 0.02),

        // Action Buttons
        _buildActionButtons(controller, context),
      ],
    );
  }

  Widget _buildProductsServicesTab(ProductController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Products and Services',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        AppSpacing.vertical(context, 0.02),

        // Products List
        Obx(() => Column(
          children: controller.products.map((product) => _buildProductCard(product, controller, context)).toList(),
        )),

        // Add More Button
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red[400]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextButton.icon(
            onPressed: () => controller.addNewProduct(),
            icon: Icon(Icons.add, color: Colors.red[400], size: 20),
            label: Text(
              'Add More',
              style: TextStyle(
                color: Colors.red[400],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        AppSpacing.vertical(context, 0.02),

        // Action Buttons
        _buildActionButtons(controller, context),
      ],
    );
  }

  Widget _buildFAQsTab(FAQController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
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

        // Individual FAQ Entries Section
        Text(
          'Individual FAQ Entries',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        AppSpacing.vertical(context, 0.01),

        // Example FAQ Entry
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Q: Does this work on mobile or pc?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'A: Yes, it works on both!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        AppSpacing.vertical(context, 0.02),

        // FAQs List
        Obx(() => Column(
          children: controller.faqs.map((faq) => _buildFAQCard(faq, controller, context)).toList(),
        )),

        // Add More Button
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red[400]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextButton.icon(
            onPressed: () => controller.addNewFAQ(),
            icon: Icon(Icons.add, color: Colors.red[400], size: 20),
            label: Text(
              'Add More',
              style: TextStyle(
                color: Colors.red[400],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        AppSpacing.vertical(context, 0.02),

        // Action Buttons
        _buildActionButtons(controller, context),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product, ProductController controller, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Product ${controller.products.indexOf(product) + 1}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              IconButton(
                onPressed: () => controller.removeProduct(product),
                icon: Icon(Icons.delete, color: Colors.red[400], size: 20),
              ),
            ],
          ),
          AppSpacing.vertical(context, 0.01),

          // Product Name
          _buildTextField('Name', 'Enter Name', product.nameCtrl, product.nameError),
          AppSpacing.vertical(context, 0.015),

          // Product Description
          _buildTextField('Description', 'Enter Description', product.descriptionCtrl, product.descriptionError),
          AppSpacing.vertical(context, 0.015),

          // Product Price
          _buildTextField('Price', 'Enter Price', product.priceCtrl, product.priceError),
          AppSpacing.vertical(context, 0.015),

          // Image Upload Section
          _buildImageUploadSection(product, context),
        ],
      ),
    );
  }

  Widget _buildFAQCard(FAQModel faq, FAQController controller, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FAQ ${controller.faqs.indexOf(faq) + 1}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              IconButton(
                onPressed: () => controller.removeFAQ(faq),
                icon: Icon(Icons.delete, color: Colors.red[400], size: 20),
              ),
            ],
          ),
          AppSpacing.vertical(context, 0.01),

          // Question
          _buildTextField('Question', 'Enter question', faq.questionCtrl, faq.questionError),
          AppSpacing.vertical(context, 0.015),

          // Answer
          _buildTextField('Answer', 'Enter answer', faq.answerCtrl, faq.answerError),
        ],
      ),
    );
  }

  Widget _buildFileUploadSection(dynamic controller, BuildContext context) {
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
          AppSpacing.vertical(context, 0.01),
          GestureDetector(
            onTap: () => _showFileUploadOptions(context, controller),
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_file, color: Colors.grey[400], size: 40),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
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
            ),
          ),
          AppSpacing.vertical(context, 0.01),

          // Upload Progress (example)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard prototype FINAL.fig',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '4.2 MB',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: 0.8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red[400]!),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          AppSpacing.vertical(context, 0.01),

          // Upload Failed Message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              border: Border.all(color: Colors.red[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[400], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Upload failed, please try again',
                    style: TextStyle(
                      color: Colors.red[400],
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.refresh, color: Colors.red[400], size: 16),
                  label: Text(
                    'Upload again',
                    style: TextStyle(
                      color: Colors.red[400],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vertical(context, 0.01),

          // Previously Uploaded File
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard prototype FINAL.fig',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '4.2 MB',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.delete, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection(ProductModel product, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload picture',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showImageUploadOptions(product, context),
          child: Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, color: Colors.grey[400], size: 30),
                const SizedBox(height: 8),
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    product.selectedImage.value.isNotEmpty
                        ? product.selectedImage.value
                        : 'Choose photo',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showFileUploadOptions(BuildContext context, dynamic controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _selectFromGallery(controller);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _captureFromCamera(controller);
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Document'),
              onTap: () {
                Navigator.pop(context);
                _selectDocument(controller);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showImageUploadOptions(ProductModel product, BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _selectImageFromGallery(product);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _captureImageFromCamera(product);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFromGallery(dynamic controller) async {
    try {
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        String fileName = image.path.split('/').last;
        if (controller is AIKnowledgeController) {
          controller.selectedBusinessFile.value = fileName;
        } else if (controller is FAQController) {
          controller.selectedFAQFile.value = fileName;
        }
        _handleSelectedFile(image.path, 'image');
        Get.snackbar('Success', 'File selected: $fileName');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to select file from gallery');
    }
  }

  Future<void> _captureFromCamera(dynamic controller) async {
    try {
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image != null) {
        String fileName = image.path.split('/').last;
        if (controller is AIKnowledgeController) {
          controller.selectedBusinessFile.value = fileName;
        } else if (controller is FAQController) {
          controller.selectedFAQFile.value = fileName;
        }
        _handleSelectedFile(image.path, 'image');
        Get.snackbar('Success', 'File captured: $fileName');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture image from camera');
    }
  }

  Future<void> _selectDocument(dynamic controller) async {
    try {
      final XFile? document = await ImagePicker().pickMedia();
      if (document != null) {
        String fileName = document.path.split('/').last;
        if (controller is AIKnowledgeController) {
          controller.selectedBusinessFile.value = fileName;
        } else if (controller is FAQController) {
          controller.selectedFAQFile.value = fileName;
        }
        _handleSelectedFile(document.path, 'document');
        Get.snackbar('Success', 'Document selected: $fileName');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to select document');
    }
  }

  Future<void> _selectImageFromGallery(ProductModel product) async {
    try {
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        String fileName = image.path.split('/').last;
        product.selectedImage.value = fileName;
        _handleSelectedProductImage(image.path, product);
        Get.snackbar('Success', 'Image selected: $fileName');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to select image from gallery');
    }
  }

  Future<void> _captureImageFromCamera(ProductModel product) async {
    try {
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image != null) {
        String fileName = image.path.split('/').last;
        product.selectedImage.value = fileName;
        _handleSelectedProductImage(image.path, product);
        Get.snackbar('Success', 'Image captured: $fileName');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture image from camera');
    }
  }

  void _handleSelectedFile(String filePath, String fileType) {
    // TODO: Implement Firebase Storage upload logic
    print('Selected file: $filePath, Type: $fileType');
  }

  void _handleSelectedProductImage(String filePath, ProductModel product) {
    // TODO: Implement Firebase Storage upload logic
    print('Selected product image: $filePath for product: ${product.name}');
  }

  Widget _buildActionButtons(dynamic controller, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red[400]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.red[400],
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red[400],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton.icon(
                  onPressed: () {
                    // TODO: Implement Test AI functionality
                    Get.snackbar('Info', 'Test AI functionality coming soon!');
                  },
                  icon: Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    'Test AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _saveData(dynamic controller) {
    if (controller is AIKnowledgeController) {
      controller.saveAIKnowledge();
    } else if (controller is ProductController) {
      // TODO: Implement save products logic
      Get.snackbar('Success', 'Products saved successfully');
    } else if (controller is FAQController) {
      // TODO: Implement save FAQs logic
      Get.snackbar('Success', 'FAQs saved successfully');
    }
  }

  Widget _buildTextField(String label, String placeholder, TextEditingController controller, RxString errorText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red[400]!),
            ),
          ),
        ),
        if (errorText.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText.value,
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMultiLineTextField(String label, String placeholder, TextEditingController controller, RxString errorText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red[400]!),
            ),
          ),
        ),
        if (errorText.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText.value,
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPhoneField(TextEditingController controller, RxString errorText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🇵🇰', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    '+92',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey[600]),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: '0000000000',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.red[400]!),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (errorText.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText.value,
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

