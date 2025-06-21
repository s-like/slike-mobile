import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core.dart';

class SettingUsers extends StatefulWidget {
  final int type;
  final int userId;
  SettingUsers({Key? key, this.type = 0, this.userId = 0}) : super(key: key);

  @override
  _SettingUsersState createState() => _SettingUsersState();
}

class _SettingUsersState extends State<SettingUsers> {
  bool cirAn = false;
  UserProfileController userProfileController = Get.find();
  MainService mainService = Get.find();
  UserController userController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Scaffold(
          backgroundColor: Get.theme.primaryColor,
          key: userProfileController.blockedUserScaffoldKey,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            foregroundColor: Get.theme.iconTheme.color,
            backgroundColor: Get.theme.primaryColor,
            automaticallyImplyLeading: true,
            leading: InkWell(
              onTap: () {
                Get.back();
              },
              child: Icon(
                Icons.arrow_back_ios,
                size: 15,
              ),
            ),
            centerTitle: true,
            title: Text(
              "Settings".tr,
              style: TextStyle(fontSize: 18, color: Get.theme.indicatorColor),
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              child: Column(
                children: <Widget>[
                  // Put list item start

                  // Account header //
                  Container(
                    padding: EdgeInsetsDirectional.only(
                      start: 20,
                      top: 20,
                      bottom: 20,
                    ),
                    child: Row(
                      children: [
                        Text("Account Settings".tr, style: TextStyle(fontSize: 16, color: Get.theme.highlightColor)),
                      ],
                    ),
                  ),
                  //Divider(color: Get.theme.indicatorColor),
                  // edit profile
                  InkWell(
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined, color: Get.theme.indicatorColor, size: 16),
                      //  trailing: Icon(Icons.arrow_forward_ios),
                      title: Text(
                        "Edit Profile".tr,
                        style: TextStyle(fontSize: 15, color: Get.theme.indicatorColor),
                      ),
                    ),
                    onTap: () {
                      Get.toNamed('/edit-profile');
                    },
                  ),
                  Divider(color: Get.theme.indicatorColor, thickness: 0.3),
                  // Change password
                  InkWell(
                    child: ListTile(
                      leading: Icon(Icons.password_rounded, color: Get.theme.indicatorColor, size: 16),
                      title: Text(
                        "Change Password".tr,
                        style: TextStyle(fontSize: 15, color: Get.theme.indicatorColor),
                      ),
                      //  trailing: Icon(Icons.arrow_forward_ios),
                    ),
                    onTap: () {
                      Get.toNamed('/change-password');
                    },
                  ),
                  // Divider(color: Get.theme.indicatorColor, thickness: 0.3),
                  // // profile Verification
                  // InkWell(
                  //   child: ListTile(
                  //     leading: Icon(Icons.verified_outlined, color: Get.theme.indicatorColor, size: 16),
                  //     title: Text(
                  //       "Profile Verification".tr,
                  //       style: TextStyle(fontSize: 15, color: Get.theme.indicatorColor),
                  //     ),
                  //     //   trailing: Icon(Icons.arrow_forward_ios),
                  //   ),
                  //   onTap: () {
                  //     Get.toNamed("/verify-badges-users");
                  //   },
                  // ),
                  // Divider(color: Get.theme.indicatorColor, thickness: 0.3),
                  // // Tools header
                  // Container(
                  //   padding: EdgeInsetsDirectional.only(
                  //     start: 20,
                  //     top: 20,
                  //     bottom: 20,
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Text("Application Tools".tr, style: TextStyle(fontSize: 16, color: Get.theme.highlightColor)),
                  //     ],
                  //   ),
                  // ),
                  /*InkWell(
                    child: Card(
                      color: Get.theme.indicatorColor!.withValues(alpha:0.5),
                      child: ListTile(
                        leading: Icon(Icons.chat_bubble_outline, color: mainService.setting.value.iconColor),
                        title: Text(
                          "Conversations".tr,
                          style: TextStyle(fontSize: 15, color: Get.theme.indicatorColor),
                        ),
                        // trailing: Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConversationsView(),
                        ),
                      );
                    },
                  ),*/
                  // blocked user
                  // InkWell(
                  //   child: ListTile(
                  //     leading: Icon(Icons.block_rounded, color: mainService.setting.value.iconColor, size: 16),
                  //     title: Text(
                  //       "Blocked Users".tr,
                  //       style: TextStyle(fontSize: 15, color: Get.theme.indicatorColor),
                  //     ),
                  //     //  trailing: Icon(Icons.arrow_forward_ios),
                  //   ),
                  //   onTap: () {
                  //     UserService userService = Get.find();
                  //     userService.blockedUsersData = BlockedModel().obs;
                  //     userService.blockedUsersData.refresh();
                  //     userProfileController.getBlockedUsers(1);
                  //     Get.toNamed("/blocked-users");
                  //   },
                  // ),
                  // Divider(color: Get.theme.indicatorColor, thickness: 0.3),
                  // // profile Info and Qrcode
                  // InkWell(
                  //   child: ListTile(
                  //     leading: Icon(Icons.qr_code_outlined, color: mainService.setting.value.iconColor, size: 16),
                  //     title: Text(
                  //       "My QR Code".tr,
                  //       style: TextStyle(fontSize: 15, color: Get.theme.indicatorColor),
                  //     ),
                  //     // trailing: Icon(Icons.arrow_forward_ios),
                  //   ),
                  //   onTap: () {
                  //     Get.toNamed("/my-profile-info");
                  //   },
                  // ),
                  // Divider(color: Get.theme.indicatorColor, thickness: 0.3),
                  // // explore people
                  // InkWell(
                  //   child: ListTile(
                  //     leading: Icon(Icons.search_outlined, size: 18, color: mainService.setting.value.iconColor),
                  //     title: Text(
                  //       "Discover People".tr,
                  //       style: TextStyle(fontSize: 15, color: Get.theme.indicatorColor),
                  //     ),
                  //     // trailing: Icon(Icons.arrow_forward_ios),
                  //   ),
                  //   onTap: () {
                  //     Get.toNamed("/users");
                  //   },
                  // ),
                  // Divider(color: Get.theme.indicatorColor, thickness: 0.3),
                  // InkWell(
                  //   child: ListTile(
                  //     leading: Icon(Icons.card_giftcard, color: mainService.setting.value.iconColor, size: 16),
                  //     title: Text(
                  //       "My Gifts".tr,
                  //       style: TextStyle(fontSize: 15, color: Get.theme.indicatorColor),
                  //     ),
                  //     //  trailing: Icon(Icons.arrow_forward_ios),
                  //   ),
                  //   onTap: () {
                  //     GiftController giftController = Get.find();
                  //     giftController.myGiftsPage = 1;
                  //     giftController.fetchMyGiftsList(showLoader: true);
                  //     Get.toNamed("/my-gifts");
                  //   },
                  // ),
                  // Divider(color: Get.theme.indicatorColor, thickness: 0.3),
                  // // Setting header
                  // Container(
                  //   padding: EdgeInsetsDirectional.only(
                  //     start: 20,
                  //     top: 20,
                  //     bottom: 20,
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Text("Application Settings".tr, style: TextStyle(fontSize: 16, color: Get.theme.highlightColor)),
                  //     ],
                  //   ),
                  // ),
                  // notification settings
                  // InkWell(
                  //   child: ListTile(
                  //     leading: Icon(Icons.notifications_none_outlined, color: mainService.setting.value.iconColor, size: 16),
                  //     title: Text(
                  //       "Notifications".tr,
                  //       style: TextStyle(fontSize: 15, color: Get.theme.indicatorColor),
                  //     ),
                  //     //  trailing: Icon(Icons.arrow_forward_ios),
                  //   ),
                  //   onTap: () {
                  //     Get.toNamed("/notification-settings");
                  //   },
                  // ),
                  // Divider(color: Get.theme.indicatorColor, thickness: 0.3),
                  // // chat settings
                  // InkWell(
                  //   child: ListTile(
                  //     leading: Icon(Icons.chat_outlined, color: mainService.setting.value.iconColor, size: 16),
                  //     title: Text(
                  //       "Chat Settings".tr,
                  //       style: TextStyle(fontSize: 15, color: Get.theme.indicatorColor),
                  //     ),
                  //     // trailing: Icon(Icons.arrow_forward_ios),
                  //   ),
                  //   onTap: () {
                  //     Get.toNamed("/chat-settings");
                  //   },
                  // ),
                  // Divider(color: Get.theme.indicatorColor, thickness: 0.3),
                  // // language settings
                  // InkWell(
                  //   child: ListTile(
                  //     leading: Icon(Icons.language_outlined, color: mainService.setting.value.iconColor, size: 16),
                  //     title: Text(
                  //       "App Language".tr,
                  //       style: TextStyle(fontSize: 15, color: Get.theme.indicatorColor),
                  //     ),
                  //     // trailing: Icon(Icons.arrow_forward_ios),
                  //   ),
                  //   onTap: () {
                  //     Get.toNamed("/languages");
                  //   },
                  // ),
                  // Divider(color: Get.theme.indicatorColor, thickness: 0.3),
                  // // update application
                  // InkWell(
                  //   child: ListTile(
                  //     leading: Icon(Icons.update_outlined, color: mainService.setting.value.iconColor, size: 16),
                  //     title: Text(
                  //       "Update Application".tr,
                  //       style: TextStyle(fontSize: 15, color: Get.theme.indicatorColor),
                  //     ),
                  //     //  trailing: Icon(Icons.arrow_forward_ios),
                  //   ),
                  //   onTap: () {
                  //     // Navigator.push(
                  //     //   context,
                  //     //   MaterialPageRoute(
                  //     //     builder: (context) => UpdateosUsers(),
                  //     //   ),
                  //     // );
                  //   },
                  // ),
                  Divider(color: Get.theme.indicatorColor, thickness: 0.3),
                  // Setting header
                  Container(
                    padding: EdgeInsetsDirectional.only(
                      start: 20,
                      top: 20,
                      bottom: 20,
                    ),
                    child: Row(
                      children: [
                        Text("Information".tr, style: TextStyle(fontSize: 16, color: Get.theme.highlightColor)),
                      ],
                    ),
                  ),
                  //  share
                  InkWell(
                    child: ListTile(
                      leading: Icon(Icons.people_outline, color: mainService.setting.value.iconColor, size: 16),
                      title: Text(
                        "Invite Your Friends".tr,
                        style: TextStyle(fontSize: 15, color: Get.theme.indicatorColor),
                      ),
                      // trailing: Icon(Icons.arrow_forward_ios),
                    ),
                    onTap: () async {
                      Share.share(
                          // '$baseUrl',
                          'https://slike.com/public/',
                          subject: "Hey, enjoy me on Slike...open this link and download the app".tr);
                    },
                  ),
                  // Divider(color: Get.theme.indicatorColor, thickness: 0.3),
                  // // Rate our app
                  // Platform.isAndroid
                  //     ? InkWell(
                  //         child: ListTile(
                  //           leading: Icon(Icons.label_important_outline_rounded, color: mainService.setting.value.iconColor, size: 16),
                  //           title: Text(
                  //             "Review Our App".tr,
                  //             style: TextStyle(fontSize: 15, color: Get.theme.indicatorColor),
                  //           ),
                  //           // trailing: Icon(Icons.arrow_forward_ios),
                  //         ),
                  //         onTap: () => launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.slike.apps')))
                  //     : Container(),
                  // /*InkWell(
                  //         child: ListTile(
                  //           leading: Icon(Icons.label_important_outline_rounded, color: mainService.setting.value.iconColor, size: 16),
                  //           title: Text(
                  //             "Review Our App".tr,
                  //             style: TextStyle(fontSize: 15, color: Get.theme.indicatorColor),
                  //           ),
                  //           // trailing: Icon(Icons.arrow_forward_ios),
                  //         ),
                  //         onTap: () => launchUrl(Uri.parse('https://apps.apple.com/us/app/')),
                  //       ),*/
                  Divider(color: Get.theme.indicatorColor, thickness: 0.3),
                  // Privacy policy
                  InkWell(
                    child: ListTile(
                      leading: Icon(Icons.privacy_tip_outlined, color: mainService.setting.value.iconColor, size: 16),
                      title: Text(
                        "Privacy Policy".tr,
                        style: TextStyle(fontSize: 15, color: Get.theme.indicatorColor),
                      ),
                      // trailing: Icon(Icons.arrow_forward_ios),
                    ),
                    onTap: () {
                      launchUrl(Uri.parse(baseUrl + "privacy-policy"));
                    },
                  ),
                  Divider(color: Get.theme.indicatorColor, thickness: 0.3),
                  // community guideline start
                  InkWell(
                    child: ListTile(
                      leading: Icon(Icons.info_outline_rounded, color: mainService.setting.value.iconColor, size: 16),
                      title: Text(
                        "Terms of use".tr,
                        style: TextStyle(fontSize: 15, color: Get.theme.indicatorColor),
                      ),
                      //   trailing: Icon(Icons.arrow_forward_ios),
                    ),
                    onTap: () {
                      launchUrl(Uri.parse((baseUrl + "terms")));
                    },
                  ),
                  // Divider(color: Get.theme.indicatorColor, thickness: 0.3),
                  // // community guideline end
                  // InkWell(
                  //   child: ListTile(
                  //     leading: Icon(Icons.delete_outline, color: mainService.setting.value.iconColor, size: 16),
                  //     title: Text(
                  //       "Data Deletion".tr,
                  //       style: TextStyle(fontSize: 15, color: Get.theme.indicatorColor),
                  //     ),
                  //     //    trailing: Icon(Icons.arrow_forward_ios),
                  //   ),
                  //   onTap: () {
                  //     Get.toNamed("/delete-user-profile");
                  //   },
                  // ),
                  Divider(color: Get.theme.indicatorColor, thickness: 0.3),
                  // Logout
                  InkWell(
                    child: ListTile(
                      leading: Icon(Icons.logout_outlined, color: mainService.setting.value.iconColor, size: 16),
                      iconColor: mainService.setting.value.buttonColor!,
                      textColor: mainService.setting.value.buttonColor!,
                      title: Text(
                        "Logout".tr,
                        style: TextStyle(fontSize: 15, color: Get.theme.indicatorColor),
                      ),
                      // trailing: Icon(Icons.arrow_forward_ios),
                    ),
                    onTap: () async {
                      userController.logoutConfirmation();
                    },
                  ),
                  Divider(color: Get.theme.indicatorColor, thickness: 0.3),
                  // info
                  InkWell(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.transparent),
                      ),
                      margin: EdgeInsets.all(0.0),
                      elevation: 0,
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, right: 10, bottom: 10),
                        child: ListTile(
                          title: Text(
                            "© Slike ${'All right reserved'.tr}",
                            style: TextStyle(fontSize: 14, color: Get.theme.indicatorColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      //
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
