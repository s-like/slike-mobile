import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as datePick;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import '../core.dart';

class CompleteProfileView extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey = GlobalKey<ScaffoldState>();

  CompleteProfileView({
    Key? key,
  }) : super(key: key);

  @override
  _CompleteProfileViewState createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> with SingleTickerProviderStateMixin {
  UserController userController = Get.find();
  AuthService authService = Get.find();
  MainService mainService = Get.find();

  late AnimationController animationController;
  var minDate = new DateTime.now().subtract(Duration(days: 29200));
  var yearBefore = new DateTime.now().subtract(Duration(days: 4746));
  var formatter = new DateFormat('yyyy-MM-dd 00:00:00.000');
  var formatterYear = new DateFormat('yyyy');
  var formatterDate = new DateFormat('dd MMM yyyy');

  String minYear = "";
  String maxYear = "";
  String initDatetime = "";

  @override
  void initState() {
    minYear = formatterYear.format(minDate);
    maxYear = formatterYear.format(yearBefore);
    initDatetime = formatterDate.format(yearBefore);
    // TODO: implement initState
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    // if (authService.socialUserProfile.value.name != "") {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print("widget.email ${userController.email.value} widget.fullName ${userController.fullName.value}");
      // setState(() {
      userController.showLoader.value = false;
      userController.showLoader.refresh();
      userController.completeProfile = authService.socialUserProfile.value;
      userController.fullName = userController.fullName;
      userController.fullNameController.value = TextEditingController(text: userController.fullName.value);
      userController.email = userController.email;
      userController.profileEmailController.value = TextEditingController(text: userController.email.value);
      userController.loginType = userController.loginType;
      if (authService.socialUserProfile.value.email == "") {
      } else {
        userController.profileEmailController.value = TextEditingController(text: authService.socialUserProfile.value.email);
      }
      setState(() {});
      // });
    });
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Get.theme.primaryColor, statusBarIconBrightness: Brightness.dark),
    );
    return WillPopScope(
      onWillPop: () {
        if (EasyLoading.isShow || userController.showLoader.value) {
          EasyLoading.dismiss();
          userController.showLoader.value = false;
          userController.showLoader.refresh();
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Obx(
        () => Scaffold(
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
                        // const SizedBox(height: 32),
                        // Title
                        // const Text(
                        //   "Complete Profile",
                        //   style: TextStyle(
                        //     fontSize: 24,
                        //     fontWeight: FontWeight.bold,
                        //     color: Color(0xFFFFD700),
                        //   ),
                        //   textAlign: TextAlign.center,
                        // ),
                        // const SizedBox(height: 8),
                        // // Subtitle
                        // const Text(
                        //   "Fill in your details to continue",
                        //   style: TextStyle(
                        //     fontSize: 16,
                        //     color: Colors.white,
                        //   ),
                        //   textAlign: TextAlign.center,
                        // ),
                        const SizedBox(height: 32),
                        // Profile Photo
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Color(0xFFFFD700), width: 3),
                                image: DecorationImage(
                                  image: userController.selectedDp.value.path != ''
                                      ? FileImage(userController.selectedDp.value)
                                      : authService.socialUserProfile.value.userDP != ''
                                          ? CachedNetworkImageProvider(authService.socialUserProfile.value.userDP)
                                          : AssetImage("assets/images/default-user.png") as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  showModalBottomSheet<void>(
                                    backgroundColor: Colors.black,
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return Container(
                                        height: 75,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                              width: 0.5,
                                              color: Get.theme.dividerColor,
                                            ),
                                          ),
                                          color: Colors.black,
                                        ),
                                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () {
                                                Get.back();
                                                userController.getImageOption(true);
                                              },
                                              child: SvgPicture.asset(
                                                'assets/icons/camera.svg',
                                                width: 40.0,
                                                colorFilter: ColorFilter.mode(Color(0xFFFFD700), BlendMode.srcIn),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Get.back();
                                                userController.getImageOption(false);
                                              },
                                              child: SvgPicture.asset(
                                                'assets/icons/image-gallery.svg',
                                                width: 40.0,
                                                colorFilter: ColorFilter.mode(Color(0xFFFFD700), BlendMode.srcIn),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Get.back();
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return Scaffold(
                                                        appBar: PreferredSize(
                                                          preferredSize: Size.fromHeight(45.0),
                                                          child: AppBar(
                                                            iconTheme: IconThemeData(
                                                              color: Color(0xFFFFD700),
                                                            ),
                                                            backgroundColor: Colors.black,
                                                            title: const Text(
                                                              "Profile Picture",
                                                              style: TextStyle(fontSize: 18, color: Color(0xFFFFD700)),
                                                            ),
                                                            centerTitle: true,
                                                          ),
                                                        ),
                                                        backgroundColor: Colors.black,
                                                        body: Center(
                                                          child: PhotoView(
                                                            enableRotation: true,
                                                            imageProvider: authService.socialUserProfile.value.userDP != ''
                                                                ? CachedNetworkImageProvider(authService.socialUserProfile.value.userDP)
                                                                : AssetImage("assets/images/default-user.png") as ImageProvider,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                              child: SvgPicture.asset(
                                                'assets/icons/views.svg',
                                                width: 40.0,
                                                colorFilter: ColorFilter.mode(Color(0xFFFFD700), BlendMode.srcIn),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Color(0xFFFFD700), width: 2),
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/icons/camera.svg',
                                    width: 28.0,
                                    colorFilter: ColorFilter.mode(Color(0xFFFFD700), BlendMode.srcIn),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Form
                        Form(
                          key: userController.completeProfileFormKey,
                          child: Column(
                            children: [
                              // Full Name
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
                                  controller: userController.fullNameController.value,
                                  style: const TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.text,
                                  onChanged: (val) {
                                    userController.fullName.value = val;
                                  },
                                  validator: (value) {
                                    return userController.validateField(value!, "Full Name");
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Full Name",
                                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                      color: Color(0xFFFFD700),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Username
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
                                  controller: userController.profileUsernameController,
                                  style: const TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.text,
                                  onChanged: (val) {
                                    userController.username = val;
                                  },
                                  validator: (value) {
                                    return userController.validateField(value!, "Username");
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Username",
                                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                    prefixIcon: Icon(
                                      Icons.alternate_email,
                                      color: Color(0xFFFFD700),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Date of Birth
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
                                  readOnly: true,
                                  controller: userController.conDob..text,
                                  style: const TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.text,
                                  validator: (input) {
                                    if (userController.profileDOBString == '') {
                                      return "Date of birth is required!";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    DatePicker.showDatePicker(
                                      context,
                                      theme: datePick.DatePickerTheme(
                                        headerColor: Colors.black,
                                        backgroundColor: Colors.black,
                                        itemStyle: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w400, fontSize: 18),
                                        doneStyle: TextStyle(
                                          color: Color(0xFFFFD700),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        cancelStyle: TextStyle(
                                          color: Color(0xFFFFD700),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      showTitleActions: true,
                                      minTime: minDate,
                                      maxTime: yearBefore,
                                      onConfirm: (date) {
                                        userController.conDob..text = userController.validDob(date.year.toString(), date.month.toString(), date.day.toString());
                                        userController.profileDOBString = userController.validDob(date.year.toString(), date.month.toString(), date.day.toString());
                                      },
                                      currentTime: DateTime.now(),
                                      locale: LocaleType.en,
                                    );
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Date of Birth",
                                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                    prefixIcon: Icon(
                                      Icons.calendar_today_outlined,
                                      color: Color(0xFFFFD700),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Email
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
                                  controller: userController.profileEmailController.value,
                                  enabled: userController.email == "" ? true : false,
                                  style: const TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (val) {
                                    userController.email.value = val;
                                  },
                                  validator: (value) {
                                    return userController.validateEmail(value!);
                                  },
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
                                )),
                              ),
                              const SizedBox(height: 16),
                              // Password
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
                                  controller: userController.passwordController,
                                  style: const TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.text,
                                  obscureText: true,
                                  onChanged: (val) {
                                    userController.password = val;
                                  },
                                  validator: (value) {
                                    return userController.validateField(value!, "Password");
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Password",
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
                              // Validate Button
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
                                    "VALIDATE",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () async {
                                    FocusManager.instance.primaryFocus?.unfocus();
                                    if (userController.completeProfileFormKey.currentState!.validate()) {
                                      if (userController.loginType == 'O') {
                                        await userController.register();
                                      } else {
                                        userController.registerSocial();
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ).paddingSymmetric(horizontal: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
