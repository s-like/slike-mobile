import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core.dart';

class LoginView extends GetView<UserController> {
  LoginView({Key? key}) : super(key: key);
  final MainService mainService = Get.find();
  final AuthService authService = Get.find();
  final DashboardController dashboardController = Get.find();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Get.theme.primaryColor, statusBarIconBrightness: Brightness.dark),
    );

    return GetBuilder<UserController>(
      initState: (_) => controller.getLoginPageData(),
      builder: (logic) {
        return WillPopScope(
          onWillPop: () {
            dashboardController.getVideos();
            Get.offNamed('/home');
            return Future.value(false);
          },
          child: Scaffold(
            body: Stack(
              children: [
                Container(
                  width: Get.width,
                  height: Get.height,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/login-bg.png"),
                      fit: BoxFit.cover,
                      scale: 0.8
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
                      controller: controller.scrollController1,
                      child: Obx(
                        () => Form(
                          key: controller.loginFormKey,
                          autovalidateMode: AutovalidateMode.always,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Logo
                              Image.asset(
                                "assets/images/login-logo.png",
                                height: 120,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 32),
                              // Welcome text
                              const Text(
                                "Welcome back",
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
                                "Log in to your account",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              // Username field
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
                                    hintText: "User Email",
                                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                      color: Color(0xFFFFD700),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    errorStyle: TextStyle(color: Colors.red, fontSize: 12, height: 1),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Password field
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
                                  obscureText: controller.hidePassword.value,
                                  onChanged: (input) {
                                    controller.password = input;
                                  },
                                  validator: (input) {
                                    if (input!.isEmpty) {
                                      return "Please enter your password!".tr;
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: "**************",
                                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: Color(0xFFFFD700),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        !controller.hidePassword.value ? Icons.visibility : Icons.visibility_off,
                                        color: Color(0xFFFFD700),
                                      ),
                                      onPressed: () {
                                        controller.hidePassword.value = !controller.hidePassword.value;
                                        controller.hidePassword.refresh();
                                      },
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    errorStyle: TextStyle(color: Colors.red, fontSize: 12, height: 1.2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Remember me and password row
                              Row(
                                children: [
                                  Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      Get.offNamed('/forgot-password');
                                    },
                                    child: const Text(
                                      "Forgot password?",
                                      style: TextStyle(
                                        color: Color(0xFFFFD700),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              // Log in button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (controller.loginFormKey.currentState!.validate()) {
                                      controller.login();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFD700),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    "Log in",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Sign up row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have account?",
                                    style: TextStyle(fontSize: 14, color: Colors.white),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Get.offNamed('/register');
                                    },
                                    child: const Text(
                                      "Register",
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
                              // Google sign in button
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
                                        "Sign in with Google",
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
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MyDateTimePicker extends StatefulWidget {
  @override
  _MyDateTimePickerState createState() => _MyDateTimePickerState();
}

class _MyDateTimePickerState extends State<MyDateTimePicker> {
  DateTime _dateTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return CupertinoDatePicker(
      initialDateTime: _dateTime,
      onDateTimeChanged: (dateTime) {
        setState(() {
          _dateTime = dateTime;
        });
      },
    );
  }
}
