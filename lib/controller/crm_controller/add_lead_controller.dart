import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minechat/controller/crm_controller/crm_controller.dart';
import 'package:minechat/model/data/crm/lead_model.dart';

class AddLeadController extends GetxController {
  final CrmController crmController = Get.find<CrmController>();
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  // Text controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final descriptionController = TextEditingController();
  
  // Observable variables
  final selectedStatus = LeadStatus.hot.obs;
  final selectedSource = LeadSource.website.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    // Dispose text controllers
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // Save lead method
  void saveLead(LeadModel lead) {
    isLoading.value = true;
    crmController.addLead(lead);
    isLoading.value = false;
    Get.back(); // Navigate back after successful save
  }

  // Reset form
  void resetForm() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    descriptionController.clear();
    selectedStatus.value = LeadStatus.hot;
    selectedSource.value = LeadSource.website;
  }

  // Validate form
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }
}
