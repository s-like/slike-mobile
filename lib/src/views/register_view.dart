import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core.dart';

class RegisterView extends GetView<UserController> {
  RegisterView({Key? key}) : super(key: key);
  final MainService mainService = Get.find();
  final AuthService authService = Get.find();
  final DashboardController dashboardController = Get.find();

  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Get.theme.primaryColor, statusBarIconBrightness: Brightness.dark),
    );

    return WillPopScope(
      onWillPop: () {
        Get.offNamed('/login');
        return Future.value(false);
      },
      child: Stack(
        children: [
          Container(
            width: Get.width,
            height: Get.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/login-bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: Get.width,
            height: Get.height,
            color: Colors.black.withOpacity(0.8),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      "assets/images/register-logo.png",
                      height: 55,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 32),
                    // Title
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFD700),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    const Text(
                      "Sign up to get started",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Full Name field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFFFFD700),
                          width: 2,
                        ),
                      ),
                      child: TextFormField(
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.text,
                        onChanged: (input) {
                          controller.fullName.value = input;
                        },
                        validator: (value) {
                          return controller.validateField(value!, "Full Name");
                        },
                        decoration: InputDecoration(
                          hintText: "Full Name",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Color(0xFFFFD700),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Email field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFFFFD700),
                          width: 2,
                        ),
                      ),
                      child: Obx(() => TextFormField(
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (input) {
                          controller.email.value = input;
                        },
                        validator: (input) {
                          if (input == null || input.isEmpty) {
                            return "Email is required";
                          }
                          return controller.validateEmail(input);
                        },
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Color(0xFFFFD700),
                          ),
                          suffixIcon: controller.isValidEmail.value
                              ? Icon(
                                  Icons.check,
                                  color: glSuccessColor,
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          errorStyle: TextStyle(color: Colors.red, fontSize: 12, height: 1.2),
                        ),
                      )),
                    ),
                    const SizedBox(height: 24),
                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Form(
                        autovalidateMode: AutovalidateMode.always,
                        key: controller.registerFormKey,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            if (controller.registerFormKey.currentState!.validate()) {
                              controller.ifEmailExists(controller.email.value);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Already have an account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.offNamed('/login');
                          },
                          child: const Text(
                            "Sign in",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Divider with Or
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.white,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Or",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.white,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Google sign up button
                    if (mainService.loginPageData.value.googleLogin == true)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            controller.loginWithGoogle();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/small-google.png',
                                width: 20,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Sign up with Google",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (Platform.isIOS && mainService.loginPageData.value.appleLogin == true)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            controller.signInWithApple();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/apple.svg',
                                width: 25.0,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Sign up with Apple",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ).paddingSymmetric(horizontal: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
