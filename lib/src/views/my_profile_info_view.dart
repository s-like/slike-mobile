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
    return Scaffold(
      backgroundColor: Get.theme.primaryColor,
      key: userController.myProfileScaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Get.theme.colorScheme.primary,
        foregroundColor: Get.theme.indicatorColor,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.arrow_back_ios, //  arrow back
            color: Get.theme.primaryColor,
            size: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () async {
              Get.toNamed('/scan-qr');
            },
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 15),
              child: Icon(
                Icons.qr_code_2_sharp,
                color: Get.theme.primaryColor,
                size: 25,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Get.theme.highlightColor.withValues(alpha:0.5),
                      Get.theme.highlightColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomLeft,
                  ),
                  // / color: Get.theme.highlightColor,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 55),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "${authService.currentUser.value.name}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            color: Get.theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        authService.currentUser.value.isVerified == true
                            ? Container(
                                padding: EdgeInsets.only(left: 3),
                                child: SvgPicture.asset(
                                  'assets/icons/newverified.svg',
                                  colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn),
                                  width: 14,
                                  height: 14,
                                ))
                            : Container(),
                      ],
                    ),
                    SizedBox(height: 15),
                    QrImageView(
                      data: "${authService.currentUser.value.id}",
                      version: QrVersions.auto,
                      size: 170.0,
                      eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: Get.theme.colorScheme.primary),
                      gapless: false,
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Text(
                        "Let someone to scan your QR code to quickly add you as a friend".tr,
                        style: TextStyle(
                          fontSize: 13,
                          color: Get.theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ).pSymmetric(h: 20),
                    SizedBox(height: 20),
                    Image.asset('assets/images/login-logo.png', width: 100),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Transform.translate(
                  offset: Offset(0, -45),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                        return Scaffold(
                            appBar: PreferredSize(
                              preferredSize: Size.fromHeight(45.0),
                              child: AppBar(
                                leading: InkWell(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    size: 20,
                                    color: mainService.setting.value.iconColor,
                                  ),
                                ),
                                title: Text(
                                  "Profile Picture".tr,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: mainService.setting.value.textColor,
                                  ),
                                ),
                                centerTitle: true,
                              ),
                            ),
                            body: Center(
                              child: PhotoView(
                                enableRotation: true,
                                imageProvider: CachedNetworkImageProvider((authService.currentUser.value.largeProfilePic.toLowerCase().contains(".jpg") ||
                                        authService.currentUser.value.largeProfilePic.toLowerCase().contains(".jpeg") ||
                                        authService.currentUser.value.largeProfilePic.toLowerCase().contains(".png") ||
                                        authService.currentUser.value.largeProfilePic.toLowerCase().contains(".gif") ||
                                        authService.currentUser.value.largeProfilePic.toLowerCase().contains(".bmp") ||
                                        authService.currentUser.value.largeProfilePic.toLowerCase().contains("fbsbx.com") ||
                                        authService.currentUser.value.largeProfilePic.toLowerCase().contains("googleusercontent.com"))
                                    ? authService.currentUser.value.largeProfilePic
                                    : '$baseUrl' + "default/user-dummy-pic.png"),
                              ),
                            ));
                      }));
                    },
                    child: Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: authService.currentUser.value.smallProfilePic != ""
                            ? CachedNetworkImage(
                                imageUrl: authService.currentUser.value.smallProfilePic,
                                placeholder: (context, url) => CommonHelper.showLoaderSpinner(Colors.white),
                                fit: BoxFit.fill,
                                width: 100,
                                height: 100,
                                errorWidget: (context, url, error) {
                                  return Image.asset('assets/images/default-user.png');
                                },
                              )
                            : Image.asset('assets/images/default-user.png'),
                      ).pLTRB(2, 2, 2, 2),
                    ),
                  ).centered(),
                ),
              ),
            ],
          ).centered(),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Share.share(baseUrl + 'profile/${authService.currentUser.value.id}');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Get.theme.colorScheme.primary.withValues(alpha:0.5), Get.theme.colorScheme.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/share.png',
                          color: Get.theme.primaryColor,
                          width: 20,
                        ).pOnly(bottom: 5),
                        "Share Profile".tr.text.size(14).color(Get.theme.primaryColor).make(),
                      ],
                    ).pSymmetric(v: 15),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: baseUrl + 'profile/${authService.currentUser.value.id}'));
                    Fluttertoast.showToast(msg: "Link is copied.".tr);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Get.theme.colorScheme.primary.withValues(alpha:0.5), Get.theme.colorScheme.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.link, color: Get.theme.primaryColor, size: 23).pOnly(bottom: 2),
                        "Copy Link".tr.text.size(14).color(Get.theme.primaryColor).make(),
                      ],
                    ).pSymmetric(v: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
      ).centered().pSymmetric(h: 25),
    );
  }
}
