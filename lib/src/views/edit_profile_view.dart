import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as datePick;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../core.dart';

class EditProfileView extends StatefulWidget {
  EditProfileView({Key? key}) : super(key: key);

  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  UserProfileController userProfileController = Get.find();
  MainService mainService = Get.find();
  UserService userService = Get.find();
  AuthService authService = Get.find();
  int page = 1;
  var minDate = new DateTime.now().subtract(Duration(days: 29200));
  var yearBefore = new DateTime.now().subtract(Duration(days: 4746));
  var formatter = new DateFormat('yyyy-MM-dd 00:00:00.000');
  var formatterYear = new DateFormat('yyyy');
  var formatterDate = new DateFormat('dd MMM yyyy');

  String minYear = "";
  String maxYear = "";
  String initDatetime = "";

  @override
  initState() {
    minYear = formatterYear.format(minDate);
    maxYear = formatterYear.format(yearBefore);
    initDatetime = formatter.format(yearBefore);

    userProfileController.genders.forEach((element) {
      print(element.value + " " + element.name);
    });
    print("EndForeach");

    super.initState();
  }

  InputDecoration customInputDecoration({String? hint, IconData? icon}) {
    return InputDecoration(
      prefixIcon: icon != null ? Icon(icon, color: Colors.yellow) : null,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.yellow.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.transparent,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.yellow, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.yellow, width: 2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.yellow, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      errorStyle: TextStyle(
        color: Colors.red,
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
        wordSpacing: 2.0,
      ),
    );
  }

  void _showGenderModal(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.black,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: Color(0xFFFFD700), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select Gender',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Gender options
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: userProfileController.genders.length,
                  itemBuilder: (context, index) {
                    final item = userProfileController.genders.elementAt(index);
                    final isSelected = userProfileController.selectedGender.value == item.value;
                    
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        title: Text(
                          item.name,
                          style: TextStyle(
                            color: isSelected ? Color(0xFFFFD700) : Colors.white,
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected 
                          ? Icon(
                              Icons.check_circle,
                              color: Color(0xFFFFD700),
                              size: 24,
                            )
                          : null,
                        onTap: () {
                          userService.userProfile.value.gender = item.value;
                          setState(() {
                            userProfileController.selectedGender = item;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      key: userProfileController.scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
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
                    const SizedBox(height: 16),
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
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: (authService.currentUser.value.userDP.toLowerCase().contains(".jpg") ||
                                      authService.currentUser.value.userDP.toLowerCase().contains(".jpeg") ||
                                      authService.currentUser.value.userDP.toLowerCase().contains(".png") ||
                                      authService.currentUser.value.userDP.toLowerCase().contains(".gif") ||
                                      authService.currentUser.value.userDP.toLowerCase().contains(".bmp") ||
                                      authService.currentUser.value.userDP.toLowerCase().contains("fbsbx.com") ||
                                      authService.currentUser.value.userDP.toLowerCase().contains("googleusercontent.com"))
                                  ? authService.currentUser.value.userDP
                                  : '$baseUrl' + "default/user-dummy-pic.png",
                              placeholder: (context, url) => CommonHelper.showLoaderSpinner(mainService.setting.value.iconColor!),
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                              errorWidget: (a, b, c) {
                                return Image.asset(
                                  "assets/images/default-user.png",
                                  fit: BoxFit.cover,
                                );
                              },
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
                                            userProfileController.getImageOption(true);
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
                                            userProfileController.getImageOption(false);
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
                                            // TODO: View Picture feature disabled due to imageProvider type error. Uncomment and fix if needed in the future.
                                            // Navigator.of(context).push(
                                            //   MaterialPageRoute(
                                            //     builder: (context) {
                                            //       return Scaffold(
                                            //         appBar: PreferredSize(
                                            //           preferredSize: Size.fromHeight(45.0),
                                            //           child: AppBar(
                                            //             iconTheme: IconThemeData(
                                            //               color: Color(0xFFFFD700),
                                            //             ),
                                            //             backgroundColor: Colors.black,
                                            //             title: const Text(
                                            //               "Profile Picture",
                                            //               style: TextStyle(fontSize: 18, color: Color(0xFFFFD700)),
                                            //             ),
                                            //             centerTitle: true,
                                            //           ),
                                            //         ),
                                            //         backgroundColor: Colors.black,
                                            //         body: Center(
                                            //           child: PhotoView(
                                            //             enableRotation: true,
                                            //             imageProvider: (authService.currentUser.value.largeProfilePic.toLowerCase().contains(".jpg") ||
                                            //                     authService.currentUser.value.largeProfilePic.toLowerCase().contains(".jpeg") ||
                                            //                     authService.currentUser.value.largeProfilePic.toLowerCase().contains(".png") ||
                                            //                     authService.currentUser.value.largeProfilePic.toLowerCase().contains(".gif") ||
                                            //                     authService.currentUser.value.largeProfilePic.toLowerCase().contains(".bmp") ||
                                            //                     authService.currentUser.value.largeProfilePic.toLowerCase().contains("fbsbx.com") ||
                                            //                     authService.currentUser.value.largeProfilePic.toLowerCase().contains("googleusercontent.com"))
                                            //                 ? CachedNetworkImageProvider(authService.currentUser.value.largeProfilePic)
                                            //                 : AssetImage("assets/images/default-user.png"),
                                            //           ),
                                            //         ),
                                            //       );
                                            //     },
                                            //   ),
                                            // );
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
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      key: userProfileController.formKey,
                      child: Column(
                        children: [
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
                              controller: userProfileController.usernameController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.text,
                              onChanged: (val) => userService.userProfile.value.username = val,
                              validator: (input) {
                                if (input!.isEmpty) {
                                  return "Username field is required!";
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                hintText: "Ex. joedoe",
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Color(0xFFFFD700),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Full name
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
                              controller: userProfileController.nameController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.text,
                              onChanged: (val) => userService.userProfile.value.name = val,
                              validator: (input) {
                                String patttern = r'^[a-z A-Z,.\-]+$';
                                RegExp regExp = new RegExp(patttern);
                                if (input!.isEmpty) {
                                  return "Name field is required!";
                                } else if (!regExp.hasMatch(input)) {
                                  return "Please enter valid full name";
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                hintText: "Ex. joedoe",
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
                            child: TextFormField(
                              controller: userProfileController.emailController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.emailAddress,
                              readOnly: true,
                              onChanged: (val) => userService.userProfile.value.email = val,
                              validator: (input) {
                                Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                RegExp regex = new RegExp(pattern.toString());
                                if (input!.isEmpty) {
                                  return "Email field is required!";
                                } else if (!regex.hasMatch(input)) {
                                  return "Please enter valid email";
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                hintText: "Ex. joedoe@email.com",
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                prefixIcon: Icon(
                                  Icons.email,
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
                              controller: TextEditingController(text: formatterDate.format(userService.userProfile.value.dob)),
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.text,
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
                                    DateTime result;
                                    if (date.year > 0) {
                                      result = DateTime(date.year, date.month, date.day, userService.userProfile.value.dob.hour, userService.userProfile.value.dob.minute);
                                      userService.userProfile.value.dob = result;
                                      userService.userProfile.refresh();
                                    } else {
                                      result = userService.userProfile.value.dob;
                                    }
                                    userProfileController.onChanged(result);
                                  },
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.en,
                                );
                              },
                              decoration: InputDecoration(
                                hintText: "YY / MM / DD",
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                prefixIcon: Icon(
                                  Icons.calendar_today_outlined,
                                  color: Color(0xFFFFD700),
                                ),
                                suffixIcon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xFFFFD700),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Gender
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
                              controller: TextEditingController(
                                text: userProfileController.selectedGender.name == 'Select' 
                                  ? 'Select Gender' 
                                  : userProfileController.selectedGender.name
                              ),
                              style: const TextStyle(color: Colors.white),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                _showGenderModal(context);
                              },
                              decoration: InputDecoration(
                                hintText: "Select Gender",
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: Color(0xFFFFD700),
                                ),
                                suffixIcon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xFFFFD700),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Mobile
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
                              controller: userProfileController.mobileController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [LengthLimitingTextInputFormatter(13)],
                              onChanged: (val) => userService.userProfile.value.mobile = val,
                              validator: (input) {
                                Pattern pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                                RegExp regex = new RegExp(pattern.toString());
                                if (input != "" && !regex.hasMatch(input!)) {
                                  return "Please enter valid mobile no";
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                hintText: "Enter Mobile No.",
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color: Color(0xFFFFD700),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Bio
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
                              controller: userProfileController.bioController,
                              style: const TextStyle(color: Colors.white),
                              maxLength: 80,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              onChanged: (val) => userService.userProfile.value.bio = val,
                              decoration: InputDecoration(
                                counterText: "",
                                hintText: "Enter Bio (80 chars)",
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                prefixIcon: Icon(
                                  Icons.info_outline,
                                  color: Color(0xFFFFD700),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Submit Button
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
                                "SUBMIT",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                if (userProfileController.formKey.currentState!.validate()) {
                                  userProfileController.updateProfile();
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ).paddingSymmetric(horizontal: 24),
              ),
            ),
          ),
          if (userProfileController.showLoader.value)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CommonHelper.showLoaderSpinner(
                  Color(0xFFFFD700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
