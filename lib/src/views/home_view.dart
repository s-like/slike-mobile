import 'dart:async';
import 'dart:convert';

import 'package:bouncy_widget/bouncy_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:skeleton_loader/skeleton_loader.dart';
// import 'package:sliding_up_panel2/sliding_up_panel2.dart';
// import 'package:badges/badges.dart' as badges;
import '../core.dart';

class HomeView extends StatefulWidget {
  HomeView({Key? key}) : super(key: key);
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin, RouteAware {
  DashboardController dashboardController = Get.find();
  MainService mainService = Get.find();
  AuthService authService = Get.find();
  DashboardService dashboardService = Get.find();

  PostService postService = Get.find();
  // double hgt = 0;
  late AnimationController musicAnimationController;
  DateTime currentBackPressTime = DateTime.now();

  double _tempAdPadding = 0;
  bool isMyTeamExpanded = false;
  @override
  Future<void> didChangeDependencies() async {
    print("|didChangeDependencies|");
    // final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    Timer(
        Duration(milliseconds: 800),
        () => setState(() {
              final bottomInset = Get.mediaQuery.viewInsets.bottom;
              final newValue = bottomInset > 0.0;
              setState(() {
                dashboardController.textFieldMoveToUp = newValue;
              });
            }));
    super.didChangeDependencies();
  }

  @override
  void initState() {
    mainService.isOnHomePage.value = true;
    mainService.isOnHomePage.refresh();

    musicAnimationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 10),
    );
    musicAnimationController.repeat();
    if (authService.currentUser.value.email != '') {
      Timer(Duration(milliseconds: 300), () {
        dashboardController.checkEulaAgreement();
      });
    }
    dashboardController.getAds();
    super.initState();
  }

  waitForSometime() {
    Future.delayed(Duration(seconds: 2));
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state.toString() == "AppLifecycleState.paused" ||
        state.toString() == "AppLifecycleState.inactive" ||
        state.toString() == "AppLifecycleState.detached" ||
        state.toString() == "AppLifecycleState.suspending ") {
      dashboardController.onTap.value = false;
      dashboardController.onTap.refresh();
      dashboardController.stopController(dashboardService.pageIndex.value);
    } else {
      dashboardController.onTap.value = true;
      dashboardController.onTap.refresh();
      dashboardController.playController(dashboardService.pageIndex.value);
    }
  }

  @override
  dispose() async {
    print("HomePage dispose");
    musicAnimationController.dispose();
    dashboardController.stopController(dashboardService.pageIndex.value);
    dashboardService.postIds = [];
    super.dispose();
  }

  validateForm(Video videoObj, context) {
    if (dashboardController.formKey.currentState!.validate()) {
      dashboardController.formKey.currentState!.save();
      dashboardController.submitReport(videoObj, context);
    }
  }

  reportLayout(context, Video videoObj) {
    print(
        "dashboardController.selectedType ${dashboardController.selectedType}");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: mainService.setting.value.bgShade,
          title: dashboardController.showReportMsg.value
              ? Text("REPORT SUBMITTED!".tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ))
              : Text("REPORT".tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  )),
          insetPadding: EdgeInsets.zero,
          content: Obx(
            () => Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: dashboardController.formKey,
              child: !dashboardController.showReportMsg.value
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: Get.theme.highlightColor,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField(
                                isExpanded: true,
                                hint: new Text(
                                  "Select Type".tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.7)),
                                ),
                                iconEnabledColor: Get.theme.iconTheme.color,
                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                ),
                                value: dashboardController.selectedType,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dashboardController.selectedType =
                                        newValue!;
                                  });
                                },
                                validator: (value) => value == null
                                    ? 'This field is required!'.tr
                                    : null,
                                items: dashboardController.reportType
                                    .map((String val) {
                                  print("val $val");
                                  return new DropdownMenuItem(
                                    value: val,
                                    child: new Text(
                                      val,
                                      style: new TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          maxLines: 4,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Description'.tr,
                            labelStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 15.0,
                            ),
                          ),
                          onChanged: (String val) {
                            setState(() {
                              dashboardService.videoReportDescription = val;
                            });
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: Get.width - 100,
                          height: 30,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Row(
                                  children: [
                                    "Block"
                                        .tr
                                        .text
                                        .color(Colors.white)
                                        .size(16)
                                        .make(),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Transform.scale(
                                  scale: 0.6,
                                  child: CupertinoSwitch(
                                    activeTrackColor: Get.theme.highlightColor,
                                    value: dashboardService
                                        .videoReportBlocked.value,
                                    onChanged: (value) {
                                      dashboardService
                                              .videoReportBlocked.value =
                                          !dashboardService
                                              .videoReportBlocked.value;
                                      dashboardService.videoReportBlocked
                                          .refresh();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) async {
                                  setState(() {
                                    if (!dashboardController
                                        .showReportLoader.value) {
                                      validateForm(videoObj, context);
                                    }
                                  });
                                });
                              },
                              child: Container(
                                height: 30,
                                width: 60,
                                decoration: BoxDecoration(
                                    color: Get.theme.highlightColor),
                                child: Obx(
                                  () => Center(
                                    child: (!dashboardController
                                            .showReportLoader.value)
                                        ? Text(
                                            "Submit".tr,
                                            style: TextStyle(
                                              color: mainService.setting.value
                                                  .buttonTextColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                              fontFamily: 'RockWellStd',
                                            ),
                                          )
                                        : CommonHelper.showLoaderSpinner(
                                            Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                dashboardController.playController(
                                    dashboardService.pageIndex.value);

                                Get.back();
                              },
                              child: Container(
                                height: 30,
                                width: 60,
                                decoration: BoxDecoration(
                                    color: Get.theme.highlightColor),
                                child: Center(
                                  child: Text(
                                    "Cancel".tr,
                                    style: TextStyle(
                                      color: mainService
                                          .setting.value.buttonTextColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      fontFamily: 'RockWellStd',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: Get.width - 100,
                          child: Center(
                            child: Text(
                              "Thanks for reporting. If we find this content to be in violation of our Guidelines, we will remove it"
                                  .tr,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();
        if (dashboardController.pc.isPanelOpen) {
          dashboardController.pc.close();
          return Future.value(false);
        }
        if (mainService.userVideoObj.value.videoId > 0 ||
            mainService.userVideoObj.value.userId > 0 ||
            mainService.userVideoObj.value.hashTag != "" ||
            mainService.userVideoObj.value.name != "") {
          mainService.userVideoObj.value.videoId = 0;
          mainService.userVideoObj.value.userId = 0;
          mainService.userVideoObj.value.name = "";
          mainService.userVideoObj.value.hashTag = "";
          dashboardController.stopController(dashboardService.pageIndex.value);

          dashboardService.postIds = [];
          Get.offNamed('/home');
          dashboardController.getVideos();
          return Future.value(false);
        }

        if (now.difference(currentBackPressTime) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          Fluttertoast.showToast(msg: "Tap again to exit an app".tr);
          return Future.value(false);
        }
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return Future.value(false);
      },
      child: Scaffold(
        // key: dashboardController.scaffoldKey,
        backgroundColor: Colors.black,

        body: Obx(
          () => Stack(
            children: [
              RefreshIndicator(
                onRefresh: () {
                  if (dashboardService.randomString.value != "") {
                    dashboardService.randomString.value =
                        CommonHelper.getRandomString(4, numeric: true);
                    dashboardService.randomString.refresh();
                  }
                  dashboardController
                      .stopController(dashboardService.pageIndex.value);
                  Get.offNamed('/home');
                  dashboardService.postIds = [];
                  return dashboardController.getVideos();
                },
                child: homeWidget(),
              ),
              !dashboardController.isVideoInitialized.value
                  ? Container(
                      width: Get.width,
                      height: Get.height,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  bool _keyboardVisible = false;
  Widget commentField() {
    // Video videoObj = dashboardService.videosData.value.videos.elementAt(dashboardService.pageIndex.value);
    return Obx(
      () => TextFormField(
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
        obscureText: false,
        focusNode: dashboardController.inputNode,
        keyboardType: TextInputType.text,
        controller: dashboardController.commentController.value,
        onSaved: (String? val) {
          dashboardController.commentValue = val!;
        },
        onChanged: (String? val) {
          dashboardController.commentValue = val!;
        },
        onTap: () {
          setState(() {
            if (dashboardController.bannerShowOn.indexOf("1") > -1) {
              dashboardService.bottomPadding.value = 0;
            }
            dashboardController.textFieldMoveToUp = true;
            dashboardController.loadMoreUpdateView.value = true;
            dashboardController.loadMoreUpdateView.refresh();
            Timer(Duration(milliseconds: 200), () => setState(() {}));
          });
        },
        decoration: new InputDecoration(
          fillColor: Get.theme.shadowColor,
          filled: true,
          contentPadding: EdgeInsets.only(
              left: CommonHelper.isRtl ? 0 : 20,
              right: CommonHelper.isRtl ? 20 : 0,
              top: 0),
          errorStyle: TextStyle(
            color: Color(0xFF210ed5),
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            wordSpacing: 2.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          hintText: "Add a comment".tr,
          hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
          suffixIcon: InkWell(
            onTap: () {
              setState(() {
                dashboardController.textFieldMoveToUp = false;
              });
              if (dashboardController.commentValue.trim() != '' &&
                  dashboardController.commentValue != "") {
                print(
                    "dashboardController.editedComment.value ${dashboardController.editedComment.value} videoObj!.videoId ${dashboardController.videoObj.value.videoId}");
                dashboardController.editedComment.value != ""
                    ? dashboardController.editComment(
                        dashboardController.editedComment.value,
                        dashboardController.videoObj.value.videoId)
                    : dashboardController
                        .addComment(dashboardController.videoObj.value.videoId);
              }
            },
            child: Padding(
              padding: EdgeInsets.only(
                left: CommonHelper.isRtl ? 15 : 0,
                top: 10,
                bottom: 10,
                right: CommonHelper.isRtl ? 0 : 15,
              ),
              child: SvgPicture.asset(
                'assets/icons/send.svg',
                width: 15,
                height: 15,
                fit: BoxFit.fill,
                colorFilter:
                    ColorFilter.mode(Get.theme.highlightColor, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget homeWidget() {
    _keyboardVisible = View.of(context).viewInsets.bottom != 0;
    return Container(
      decoration: BoxDecoration(color: Colors.black87),
      height: Get.height,
      width: Get.width,
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Expanded(
            child: buildImageRow(
              label: 'MY TEAM',
              labelColor: Colors.white,
              imagePaths: [
                'assets/images/sample/first.jpg',
                'assets/images/sample/third.jpg',
                'assets/images/sample/fourth.jpg',
                'assets/images/sample/first.jpg',
              ],
              isExpanded: isMyTeamExpanded,
              onTabTap: () {
                setState(() {
                  isMyTeamExpanded = !isMyTeamExpanded;
                });
              },
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: buildImageRow(
              label: 'NEWS',
              labelColor: Color.fromRGBO(255, 204, 0, 1),
              imagePaths: [
                'assets/images/sample/third.jpg',
                'assets/images/sample/fourth.jpg',
                'assets/images/sample/first.jpg',
                'assets/images/sample/third.jpg',
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: buildImageRow(
              label: '#SPORT',
              labelColor: Color.fromRGBO(255, 204, 0, 1),
              imagePaths: [
                'assets/images/sample/fourth.jpg',
                'assets/images/sample/first.jpg',
                'assets/images/sample/third.jpg',
                'assets/images/sample/fourth.jpg',
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImageRow({
    required String label,
    required Color labelColor,
    required List<String> imagePaths,
    bool isExpanded = false,
    VoidCallback? onTabTap,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rowHeight = constraints.maxHeight;
        if (label == 'MY TEAM') {
          return LayoutBuilder(
            builder: (context, constraints) {
              final rowHeight = constraints.maxHeight;
              return Stack(
                children: [
                  // IMAGES (bottom layer)
                  ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: imagePaths.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                imagePaths[index],
                                width: rowHeight * 0.75,
                                height: rowHeight,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '10,3K',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  // OUTSIDE CONTAINER (top layer, overlays images)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: isExpanded ? 140 : 60,
                    height: rowHeight,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide.none,
                        right: BorderSide(color: labelColor, width: 2),
                        top: BorderSide(color: labelColor, width: 2),
                        bottom: BorderSide(color: labelColor, width: 2),
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      color: Colors.black.withOpacity(0.4), // semi-transparent
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: onTabTap,
                          child: Container(
                            width: 38,
                            height: rowHeight,
                            child: RotatedBox(
                              quarterTurns: -1,
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontFamily: 'ArimoHebrewSubsetItalic',
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 34,
                                    height: 1.0,
                                    letterSpacing: -0.3,
                                    color: labelColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (isExpanded)
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFCC00),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.add, size: 40, color: Colors.white),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "No story, add new one",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          return SizedBox(
            height: rowHeight,
            child: Stack(
              children: [
                ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imagePaths.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              imagePaths[index],
                              width: rowHeight * 0.75, // keep aspect ratio
                              height: rowHeight,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '10,3K',
                                style:
                                    TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 38,
                    height: rowHeight,
                    padding: EdgeInsets.only(
                      top: 8,                    
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide.none,
                        right: BorderSide(color: labelColor, width: 2),
                        top: BorderSide(color: labelColor, width: 2),
                        bottom: BorderSide(color: labelColor, width: 2),
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      color: Color.fromRGBO(0, 0, 0, 0.6)
                    ),
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          label,
                          style: TextStyle(
                            fontFamily:
                                'ArimoHebrewSubsetItalic', // ensure it's defined in pubspec.yaml
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                            fontSize: 34,
                            height: 1.0, // line-height: 100%
                            letterSpacing: -0.3,
                            color: labelColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget topSection() {
    return SafeArea(
      top: true,
      maintainBottomViewPadding: false,
      bottom: false,
      child: Container(
        color: Colors.black12,
        height: 60,
        child: Padding(
          padding: const EdgeInsets.only(top: 25.0, bottom: 0),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    child: Obx(() {
                      return Text("Following".tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: dashboardService.showFollowingPage.value
                                ? FontWeight.bold
                                : FontWeight.w400,
                            fontSize: 13.0,
                          ));
                    }),
                    onTap: () async {
                      dashboardController
                          .stopController(dashboardService.pageIndex.value);
                      dashboardService.showFollowingPage.value = true;
                      dashboardService.showFollowingPage.refresh();
                      dashboardService.postIds = [];
                      Get.offNamed('/home');
                      dashboardController.getVideos();
                    },
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    height: 13,
                    width: 1,
                    color: Get.theme.primaryColor.withValues(alpha: 0.5),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    child: Obx(() {
                      return Text(
                        "Featured".tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: dashboardService.showFollowingPage.value
                              ? FontWeight.w400
                              : FontWeight.bold,
                          fontSize: 13.0,
                        ),
                      );
                    }),
                    onTap: () async {
                      dashboardController
                          .stopController(dashboardService.pageIndex.value);
                      dashboardService.showFollowingPage.value = false;
                      dashboardService.showFollowingPage.refresh();
                      dashboardService.postIds = [];
                      Get.offNamed('/home');
                      dashboardController.getVideos();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getMusicPlayerAction(index) {
    return GestureDetector(
      onTap: () async {
        if (authService.currentUser.value.accessToken != '') {
          if (!dashboardService.showFollowingPage.value) {
            dashboardController
                .stopController(dashboardService.pageIndex.value);
          } else {}
          dashboardController.soundShowLoader.value = true;
          dashboardController.soundShowLoader.refresh();
          SoundController soundController = Get.find();
          SoundData sound = await soundController
              .getSound(dashboardController.videoObj.value.soundId);
          await soundController.selectSound(sound);
          dashboardController.soundShowLoader.value = false;
          dashboardController.soundShowLoader.refresh();

          dashboardService.postIds = [];
        } else {
          dashboardController.stopController(dashboardService.pageIndex.value);
          Get.offNamed("/login");
        }
      },
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(musicAnimationController),
        child: Container(
          margin: EdgeInsets.only(top: 10.0),
          width: 50,
          height: 50,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(2),
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50 / 2),
                ),
                child: Obx(() {
                  return (!dashboardController.soundShowLoader.value)
                      ? Container(
                          height: 45.0,
                          width: 45.0,
                          decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: dashboardController
                                        .videoObj.value.soundImageUrl !=
                                    ""
                                ? CachedNetworkImage(
                                    imageUrl: dashboardController
                                        .videoObj.value.soundImageUrl,
                                    memCacheHeight: 50,
                                    memCacheWidth: 50,
                                    errorWidget: (a, b, c) {
                                      return Image.asset(
                                        "assets/images/splash.png",
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    "assets/images/splash.png",
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        )
                      : CommonHelper.showLoaderSpinner(Colors.white);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sidebar(index) {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    dashboardController.encodedVideoId = stringToBase64.encode(
        dashboardController.encKey +
            dashboardController.videoObj.value.videoId.toString());
    return Obx(
      () => Container(
        // padding: new EdgeInsets.only(bottom: dashboardService.paddingBottom.value - 30 > 0 ? dashboardService.paddingBottom.value - 30 : 0),
        width: 70.0,
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Column(
            children: [
              LikeButton(
                size: 25,
                circleColor: CircleColor(
                    start: Colors.transparent, end: Colors.transparent),
                bubblesColor: BubblesColor(
                  dotPrimaryColor: dashboardController.videoObj.value.isLike
                      ? Color(0xffee1d52)
                      : Color(0xffffffff),
                  dotSecondaryColor: dashboardController.videoObj.value.isLike
                      ? Color(0xffee1d52)
                      : Color(0xffffffff),
                ),
                likeBuilder: (bool isLiked) {
                  return SvgPicture.asset(
                    'assets/icons/liked.svg',
                    width: 25.0,
                    colorFilter: ColorFilter.mode(
                        dashboardController.videoObj.value.isLike
                            ? Color(0xffee1d52)
                            : Colors.white,
                        BlendMode.srcIn),
                  );
                },
                onTap: dashboardController.onLikeButtonTapped,
              ),
              Text(
                CommonHelper.formatter(
                    dashboardController.videoObj.value.totalLikes.toString()),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Bouncy(
            duration: Duration(milliseconds: 2000),
            lift: 10,
            ratio: 0.25,
            pause: 0.5,
            child: Obx(
              () => Column(
                children: [
                  if (mainService.enableGifts.value)
                    (authService.currentUser.value.id !=
                            dashboardController.videoObj.value.userId)
                        ? InkWell(
                            child: Image.asset(
                              "assets/icons/gift.png",
                              width: 25.0,
                            ),
                            onTap: () async {
                              AuthService authService = Get.find();
                              print(33333);
                              if (authService.currentUser.value.id > 0) {
                                DashboardService dashboardService = Get.find();
                                dashboardService.firstLoad.value = false;
                                GiftController giftController = Get.find();
                                giftController.openGiftsWidget(
                                    id: dashboardController
                                        .videoObj.value.videoId);
                              } else {
                                Fluttertoast.showToast(
                                    msg: "You must Login first to send gifts.");
                                Get.toNamed("/login");
                              }
                            },
                          )
                        : Container(),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    height: 50.0,
                    width: 50.0,
                    child: IconButton(
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.only(
                          top: 9, bottom: 6, left: 5.0, right: 5.0),
                      icon: SvgPicture.asset(
                        'assets/icons/comments.svg',
                        width: 25.0,
                        colorFilter:
                            ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                      onPressed: () {
                        if (dashboardController.bannerShowOn.indexOf("1") >
                            -1) {
                          setState(() {
                            dashboardService.bottomPadding.value = 0;
                          });
                        }
                        dashboardController.hideBottomBar.value = true;
                        dashboardController.hideBottomBar.refresh();
                        dashboardController.videoIndex = index;
                        dashboardController.showBannerAd.value = false;
                        dashboardController.showBannerAd.refresh();
                        dashboardController.pc.open();
                        if (dashboardController.videoObj.value.totalComments >
                            0) {
                          dashboardController
                              .getComments(dashboardController.videoObj.value)
                              .whenComplete(
                            () {
                              Timer(
                                  Duration(seconds: 1), () => setState(() {}));
                            },
                          );
                        }
                      },
                    ),
                  ),
                  Text(
                    CommonHelper.formatter(dashboardController
                        .videoObj.value.totalComments
                        .toString()),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    height: 35.0,
                    width: 50.0,
                    child: IconButton(
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.only(
                          top: 0, bottom: 0, left: 5.0, right: 5.0),
                      icon: SvgPicture.asset(
                        'assets/icons/views.svg',
                        width: 25.0,
                        colorFilter:
                            ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                      onPressed: () {},
                    ),
                  ),
                  Text(
                    CommonHelper.formatter(dashboardController
                        .videoObj.value.totalViews
                        .toString()),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 50.0,
                width: 50.0,
                child: Obx(() {
                  return (!dashboardController.shareShowLoader.value)
                      ? IconButton(
                          alignment: Alignment.topCenter,
                          icon: SvgPicture.asset(
                            'assets/icons/share.svg',
                            width: 25.0,
                            colorFilter:
                                ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          ),
                          onPressed: () async {
                            Codec<String, String> stringToBase64 =
                                utf8.fuse(base64);
                            String vId = stringToBase64.encode(
                                dashboardController.videoObj.value.videoId
                                    .toString());
                            Share.share('$baseUrl$vId');
                          },
                        )
                      : CommonHelper.showLoaderSpinner(Colors.white);
                }),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 50.0,
                width: 50.0,
                child: IconButton(
                  alignment: Alignment.topCenter,
                  icon: SvgPicture.asset(
                    'assets/icons/report.svg',
                    width: 25.0,
                    colorFilter:
                        ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                  onPressed: () async {
                    if (authService.currentUser.value.accessToken != '') {
                      dashboardController.showReportMsg.value = false;
                      dashboardController.showReportMsg.refresh();
                      reportLayout(context, dashboardController.videoObj.value);
                    } else {
                      dashboardController
                          .stopController(dashboardService.pageIndex.value);
                      Get.offNamed("/login");
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          (dashboardController.videoObj.value.soundId > 0)
              ? _getMusicPlayerAction(index)
              : SizedBox(
                  height: 0,
                ),
          (dashboardController.videoObj.value.soundId > 0)
              ? Divider(
                  color: Colors.transparent,
                  height: 5.0,
                )
              : SizedBox(
                  height: 0,
                ),
        ]),
      ),
    );
  }
}
