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
    const Color yellowColor = Color(0xFFFFD600);
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/login-bg.png"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.7),
            BlendMode.darken,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        key: userProfileController.blockedUserScaffoldKey,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          foregroundColor: yellowColor,
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: true,
          leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: yellowColor,
            ),
          ),
          centerTitle: false,
          title: Text(
            "Setting".tr,
            style: TextStyle(
                fontSize: 18,
                color: yellowColor,
                fontWeight: FontWeight.bold),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Icon(
                Icons.nightlight_round,
                color: Colors.white,
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 20),
                // Search TextField
                TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: yellowColor),
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Change Password
                _buildSettingItem(
                  icon: Icons.more_horiz,
                  text: 'Change password',
                  onTap: () {
                    Get.toNamed('/change-password');
                  },
                ),
                SizedBox(height: 20),

                // Account Status
                _buildSettingItem(
                  icon: Icons.person_search_outlined,
                  text: 'Account status',
                  onTap: () {
                    // TODO: Navigate to account status page
                  },
                ),
                SizedBox(height: 20),

                // Delete Account
                _buildSettingItem(
                  icon: Icons.delete_outline,
                  text: 'Delete account',
                  onTap: () {
                    // Get.toNamed("/delete-user-profile");
                  },
                ),
                SizedBox(height: 50),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      userController.logoutConfirmation();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      'LOG OUT',
                      style: TextStyle(
                        color: Color(0xFFE53935), // A reddish color
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({required IconData icon, required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.8)),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            SizedBox(width: 20),
            Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
