import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../core.dart';

class MyProfileInfoView extends StatefulWidget {
  MyProfileInfoView({Key? key}) : super(key: key);
  @override
  _MyProfileInfoViewState createState() => _MyProfileInfoViewState();
}

class _MyProfileInfoViewState extends State<MyProfileInfoView> {
  UserController userController = Get.find();
  DashboardController dashboardController = Get.find();
  MainService mainService = Get.find();
  AuthService authService = Get.find();

  @override
  void initState() {
    // userController.getMyProfile(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final yellowColor = Color(0xFFFFC800);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text('Share QR code', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_2_sharp, color: Colors.white, size: 25),
            onPressed: () => Get.toNamed('/scan-qr'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 280,
                  padding: EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
                  decoration: BoxDecoration(
                    color: yellowColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        "${authService.currentUser.value.name}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 18),
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(8),
                        child: QrImageView(
                          data: "${authService.currentUser.value.id}",
                          version: QrVersions.auto,
                          size: 170.0,
                          eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                          gapless: false,
                        ),
                      ),
                      SizedBox(height: 18),
                      Image.asset('assets/images/video-logo.png', width: 70),
                    ],
                  ),
                ),
                Positioned(
                  top: -45,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child: authService.currentUser.value.smallProfilePic != ""
                            ? CachedNetworkImage(
                                imageUrl: authService.currentUser.value.smallProfilePic,
                                fit: BoxFit.cover,
                                width: 90,
                                height: 90,
                                errorWidget: (context, url, error) => Image.asset('assets/images/default-user.png'),
                              )
                            : Image.asset('assets/images/default-user.png'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: (280 / 2) - 12,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellowColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: baseUrl + 'profile/${authService.currentUser.value.id}'));
                      Fluttertoast.showToast(msg: "Link is copied.".tr);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.link, color: Colors.black, size: 24),
                        // SizedBox(height: 4),
                        Text("Copy link", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                SizedBox(
                  width: (280 / 2) - 12,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellowColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Share.share(baseUrl + 'profile/${authService.currentUser.value.id}');
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.share, color: Colors.black, size: 24),
                        // SizedBox(height: 4),
                        Text("Share link", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
