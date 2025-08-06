import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../constants/app_assets/app_assets.dart';
import '../../../controller/google_signin_controller/google_signin_controller.dart';
import '../../constants/app_colors/app_colors.dart';

class GoogleSignInButton extends StatelessWidget {
  final double? width;
  final double? height;
  final String? text;
  final VoidCallback? onPressed;

  const GoogleSignInButton({
    super.key,
    this.width,
    this.height = 35,
    this.text = 'Continue with Google',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GoogleSignInController>();

    return Obx(() {
      return Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: controller.isLoading.value ? null : (onPressed ?? controller.signInWithGoogle),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (controller.isLoading.value)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                    )
                  else
                    SvgPicture.asset(
                      AppAssets.googleIcon,
                      width: 24,
                      height: 24,
                    ),
                  const SizedBox(width: 12),
                  Text(
                    text!,
                    style:  TextStyle(
                      color:  AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
