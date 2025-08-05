import 'package:flutter/material.dart';
import 'business_account_form.dart';
import 'admin_user_form.dart';

class SignupScreen extends StatelessWidget {
  final bool isBusiness;

  const SignupScreen({super.key, required this.isBusiness});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isBusiness ? const BusinessAccountForm() : const AdminUserForm(),
      ),
    );
  }
}
