import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../core.dart';

class VerifyOTPView extends StatefulWidget {
  @override
  _VerifyOTPViewState createState() => _VerifyOTPViewState();
}

class _VerifyOTPViewState extends State<VerifyOTPView> {
  ScaffoldState scaffold = ScaffoldState();
  UserController userController = Get.find();
  MainService mainService = Get.find();

  TextEditingController textEditingController = TextEditingController();
  bool hasError = false;
  StreamController<ErrorAnimationType> errorController = StreamController<ErrorAnimationType>();
  @override
  void initState() {
    userController.startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userController.bHideTimer.value = true;
      userController.bHideTimer.refresh();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Get.theme.primaryColor, statusBarIconBrightness: Brightness.dark),
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
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
                            Get.back();
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
                      "Email Verification",
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
                      "Enter the 6-digit code sent to your registered email.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Pin Code Field
                    PinCodeTextField(
                      backgroundColor: Colors.transparent,
                      appContext: context,
                      pastedTextStyle: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                      length: 6,
                      obscureText: true,
                      obscuringCharacter: '*',
                      blinkWhenObscuring: true,
                      animationType: AnimationType.fade,
                      pinTheme: PinTheme(
                        inactiveColor: Color(0xFFFFD700).withOpacity(0.3),
                        disabledColor: Colors.transparent,
                        inactiveFillColor: Colors.transparent,
                        selectedFillColor: Colors.transparent,
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(8),
                        fieldHeight: Get.width * 0.13,
                        fieldWidth: Get.width * 0.13,
                        activeFillColor: Colors.transparent,
                        activeColor: Color(0xFFFFD700),
                        selectedColor: Color(0xFFFFD700),
                      ),
                      cursorColor: Color(0xFFFFD700),
                      animationDuration: Duration(milliseconds: 300),
                      enableActiveFill: true,
                      keyboardType: TextInputType.number,
                      boxShadows: [
                        BoxShadow(
                          offset: Offset(0, 1),
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                        )
                      ],
                      onCompleted: (v) {
                        userController.otp = v;
                        userController.verifyOtp();
                      },
                      onChanged: (value) {
                        userController.otp = value;
                      },
                      beforeTextPaste: (text) {
                        return true;
                      },
                      textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    // Timer or Resend
                    Obx(() => userController.bHideTimer.value
                        ? '${"Resend OTP in".tr} ${userController.countTimer.value} ${"seconds".tr}'
                            .text
                            .color(Colors.white)
                            .lineHeight(1.4)
                            .size(16)
                            .wide
                            .center
                            .make()
                            .centered()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              "Did not get OTP?".tr.text.color(Colors.white).size(16).wide.center.make(),
                              SizedBox(width: 10),
                              "Resend OTP".tr.text.color(Color(0xFFFFD700)).size(16).wide.center.make().onTap(() {
                                userController.resendOtp(verifyPage: true);
                              }),
                            ],
                          )),
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
