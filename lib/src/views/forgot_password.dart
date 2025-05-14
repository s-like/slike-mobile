import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core.dart';

class ForgotPasswordView extends GetView<UserController> {
  ForgotPasswordView({Key? key}) : super(key: key);
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
          // Background image
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
          // Dark overlay
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
                    // Back Arrow and Logo Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFFFD700)),
                          onPressed: () {
                            Get.offNamed('/login');
                          },
                        ),
                        SizedBox(width: 8),
                        Image.asset(
                          "assets/images/register-logo.png",
                          height: 55,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Title
                    const Text(
                      "Forgot Password",
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
                      "Please enter your email address to reset your password.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Email Field
                    Form(
                      autovalidateMode: AutovalidateMode.always,
                      key: controller.formKey,
                      child: Column(
                        children: [
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
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (input) {
                                controller.email.value = input;
                              },
                              validator: controller.validateEmail,
                              decoration: InputDecoration(
                                hintText: "Email",
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: Color(0xFFFFD700),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
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
                                if (controller.formKey.currentState!.validate()) {
                                  controller.sendPasswordResetOTP();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Info Text
                    const Text(
                      "We will email you a link to reset your password.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Terms and Privacy
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            controller.launchURL("${baseUrl}terms");
                          },
                          child: const Text(
                            "Terms of use",
                            style: TextStyle(fontSize: 14, color: Color(0xFFFFD700)),
                          ),
                        ),
                        SizedBox(width: 15),
                        Container(
                          width: 1,
                          height: 17,
                          color: Colors.white,
                        ),
                        SizedBox(width: 15),
                        GestureDetector(
                          onTap: () {
                            controller.launchURL(baseUrl + "privacy-policy");
                          },
                          child: const Text(
                            "Privacy Policy",
                            style: TextStyle(fontSize: 14, color: Color(0xFFFFD700)),
                          ),
                        ),
                      ],
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
