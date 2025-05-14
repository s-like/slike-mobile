import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core.dart';

class ResetForgotPasswordView extends GetView<UserController> {
  ResetForgotPasswordView({Key? key}) : super(key: key);
  MainService mainService = Get.find();
  AuthService authService = Get.find();
  DashboardController dashboardController = Get.find();
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Get.theme.primaryColor, statusBarIconBrightness: Brightness.dark),
    );

    return WillPopScope(
      onWillPop: () {
        Get.offNamed('/forgot-password');
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
                            Get.offNamed('/forgot-password');
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
                      "Reset Password",
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
                      "Enter the OTP and your new password.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Form
                    Form(
                      autovalidateMode: AutovalidateMode.always,
                      key: controller.resetForgotPassword,
                      child: Column(
                        children: [
                          // OTP Field
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
                              keyboardType: TextInputType.number,
                              onChanged: (input) {
                                controller.otp = input;
                              },
                              onSaved: (input) {
                                controller.otp = input!;
                              },
                              validator: (value) {
                                return controller.validateField(value!, "OTP");
                              },
                              decoration: InputDecoration(
                                hintText: "Enter OTP",
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                prefixIcon: Icon(
                                  Icons.verified_user_outlined,
                                  color: Color(0xFFFFD700),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Password Field
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
                              keyboardType: TextInputType.text,
                              onChanged: (input) {
                                controller.password = input;
                              },
                              onSaved: (input) {
                                controller.password = input!;
                              },
                              validator: (input) {
                                return controller.validateField(input!, "Password");
                              },
                              obscureText: controller.hidePassword.value,
                              decoration: InputDecoration(
                                hintText: "Enter Password",
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFFFFD700),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    controller.hidePassword.value = !controller.hidePassword.value;
                                    controller.hidePassword.refresh();
                                  },
                                  color: Color(0xFFFFD700),
                                  icon: Icon(!controller.hidePassword.value ? Icons.visibility : Icons.visibility_off),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            )),
                          ),
                          const SizedBox(height: 24),
                          // Confirm Password Field
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
                              obscureText: true,
                              maxLines: 1,
                              keyboardType: TextInputType.text,
                              controller: controller.confirmPasswordController,
                              style: const TextStyle(color: Colors.white),
                              validator: (value) {
                                return controller.validateField(value!, "Confirm Password");
                              },
                              onSaved: (String? val) {
                                controller.confirmPassword = val!;
                              },
                              onChanged: (String val) {
                                controller.confirmPassword = val;
                              },
                              decoration: InputDecoration(
                                hintText: "Confirm Password",
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFFFFD700),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Reset Button
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
                                "Reset",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                if (controller.resetForgotPassword.currentState!.validate()) {
                                  controller.updateForgotPassword();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
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
