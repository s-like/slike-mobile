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
import 'package:badges/badges.dart' as badges;
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
  bool isNewsExpanded = false;
  bool isSportExpanded = false;
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

  reportLayout(context, Video videoObj) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Obx(
          () => Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: BoxDecoration(
              color: Color(0xff2a3a49),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: dashboardController.showReportMsg.value
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "REPORT SUBMITTED!".tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 20 + MediaQuery.of(context).padding.bottom),
                      ],
                    ),
                  )
                : StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(height: 12),
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(height: 20),
                          Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Report".tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: InkWell(
                                    onTap: () => Get.back(),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 10),
                          ...dashboardController.reportType.map((String val) {
                            return Theme(
                              data: ThemeData(
                                unselectedWidgetColor: Colors.grey,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                              ),
                              child: RadioListTile(
                                title: Text(
                                  val,
                                  style: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                                value: val,
                                groupValue: dashboardController.selectedType,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dashboardController.selectedType = newValue!;
                                  });
                                },
                                activeColor: Color(0xffFFC107),
                                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                              ),
                            );
                          }).toList(),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: Text('cancel'.tr, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[800],
                                      padding: EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (!dashboardController.showReportLoader.value) {
                                        dashboardController.submitReport(videoObj, context);
                                      }
                                    },
                                    child: Obx(() => dashboardController.showReportLoader.value
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                            ),
                                          )
                                        : Text(
                                            'Report'.tr,
                                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                          )),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xffFFC107),
                                      padding: EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20 + MediaQuery.of(context).padding.bottom),
                        ],
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  /// Eula agreement
  void eulaLayout(context) {
    // ... existing code ...
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
          dashboardController.resetToAllVideos();
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
        appBar: AppBar(
          leading: Image.asset("assets/images/video-logo.png"),
          leadingWidth: 189,
          toolbarHeight: 59,
          backgroundColor: Colors.black,
          actions: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Search Icon
                IconButton(
                  icon: SvgPicture.asset(
                    "assets/icons/search.svg",
                    width: 26,
                    height: 26,
                    color: Color(0xFFFFD700),
                  ),
                  onPressed: () {
                    // Your search action
                  },
                ),
                // Notification Badge
                badges.Badge(
                  badgeContent: Text(
                    '15',
                    style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  position: badges.BadgePosition.topEnd(top: 2, end: 2),
                  showBadge: true,
                  child: IconButton(
                    icon: SvgPicture.asset(
                      "assets/icons/notification.svg",
                      width: 26,
                      height: 26,
                      color: Color(0xFFFFD700),
                    ),
                    onPressed: () {
                      Get.toNamed("/notifications");
                    },
                  ),
                ),
                // Message Badge
                badges.Badge(
                  badgeContent: Text(
                    '12',
                    style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  position: badges.BadgePosition.topEnd(top: 2, end: 2),
                  showBadge: true,
                  child: IconButton(
                    icon: SvgPicture.asset(
                      "assets/icons/chat.svg",
                      width: 26,
                      height: 26,
                      color: Color(0xFFFFD700),
                    ),
                    onPressed: () {
                      Get.toNamed("/chat");
                    },
                  ),
                ),
                SizedBox(width: 8),
              ],
            ),
          ],
        ),
        body: Obx(
          () => Stack(
            children: [
              RefreshIndicator(
                onRefresh: () {
                  dashboardController
                      .stopController(dashboardService.pageIndex.value);
                  Get.offNamed('/home');
                  dashboardService.postIds = [];
                  dashboardController.resetToAllVideos();
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
              // right: CommonHelper.isRtl ? 20 : 0,
              right: 10),
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
                // right: CommonHelper.isRtl ? 0 : 15,
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
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (isMyTeamExpanded || isNewsExpanded || isSportExpanded) {
          setState(() {
            isMyTeamExpanded = false;
            isNewsExpanded = false;
            isSportExpanded = false;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.black87),
        // height: 120,
        // width: 38,
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
                    if (isMyTeamExpanded) {
                      isNewsExpanded = false;  // Collapse NEWS tab when MY TEAM is expanded
                      isSportExpanded = false;
                    }
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
                isExpanded: isNewsExpanded,
                onTabTap: () {
                  setState(() {
                    isNewsExpanded = !isNewsExpanded;
                    if (isNewsExpanded) {
                      isMyTeamExpanded = false;  // Collapse MY TEAM tab when NEWS is expanded
                      isSportExpanded = false;
                    }
                  });
                },
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: buildImageRow(
                label: 'SPORT',
                labelColor: Color.fromRGBO(255, 204, 0, 1),
                imagePaths: [
                  'assets/images/sample/fourth.jpg',
                  'assets/images/sample/first.jpg',
                  'assets/images/sample/third.jpg',
                  'assets/images/sample/fourth.jpg',
                ],
                isExpanded: isSportExpanded,
                onTabTap: () {
                  setState(() {
                    isSportExpanded = !isSportExpanded;
                    if (isSportExpanded) {
                      isMyTeamExpanded = false;
                      isNewsExpanded = false;
                    }
                  });
                },
              ),
            ),
          ],
        ),
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
    final expandedWidth = (label == 'NEWS') ? 380.0 : 220.0;
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
                  // TAB CONTAINER (top layer)
                  Positioned(
                    left: 0,
                    child: GestureDetector(
                      onTap: onTabTap,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: isExpanded ? expandedWidth : 36,
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
                          color: Colors.black.withOpacity(0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Container(
                                width: 32,
                                height: double.infinity,
                                child: RotatedBox(
                                  quarterTurns: -1,
                                  child: Container(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      isExpanded && label == 'MY TEAM' ? 'MY STORY' : label,
                                      style: TextStyle(
                                        fontFamily: 'ArimoHebrewSubsetItalic',
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 30,
                                        height: 1.0,
                                        letterSpacing: -0.3,
                                        color: labelColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (isExpanded && (expandedWidth == 220.0))
                              Expanded(
                                child: Align(
                                  alignment: Alignment(0, -0.2),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 160,
                                        child: Text(
                                          "No story, add new one",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFFCC00),
                                          shape: BoxShape.circle,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            if (dashboardService.isUploading.value) {
                                              Fluttertoast.showToast(
                                                msg: 'Video is being uploaded kindly wait for the process to complete'.tr,
                                                textColor: Get.theme.primaryColor,
                                              );
                                            } else {
                                              mainService.isOnHomePage.value = false;
                                              mainService.isOnHomePage.refresh();
                                              dashboardService.bottomPadding.value = 0.0;
                                              dashboardController.stopController(dashboardService.pageIndex.value);
                                              if (authService.currentUser.value.accessToken != '') {
                                                mainService.isOnRecordingPage.value = true;
                                                Get.put(VideoRecorderController(), permanent: true);
                                                Get.offNamed('/video-recorder');
                                              } else {
                                                Get.offNamed('/login');
                                              }
                                            }
                                          },
                                          child: Icon(Icons.add, size: 32, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        } else if (label == 'NEWS') {
          return Stack(
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
                            width: rowHeight * 0.75,
                            height: rowHeight,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Positioned(
                left: 0,
                child: GestureDetector(
                  onTap: onTabTap,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: isExpanded ? expandedWidth : 36,
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
                      color: Colors.black.withOpacity(0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Container(
                            width: 32,
                            height: double.infinity,
                            child: RotatedBox(
                              quarterTurns: -1,
                              child: Container(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontFamily: 'ArimoHebrewSubsetItalic',
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 30,
                                    height: 1.0,
                                    letterSpacing: -0.3,
                                    color: labelColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (isExpanded && (expandedWidth == 380.0))
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // COMING SOON banner
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/images/coming-soon.png',
                                        height: 100,  // Increased height for prominence
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  // SizedBox(height: 18),
                                  SizedBox(
                                    width: 220,
                                    child: Text(
                                      'Here you will find News\nand  sports updates',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
                  child: GestureDetector(
                    onTap: onTabTap,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: isExpanded && label == 'SPORT' ? 380.0 : isExpanded ? 380.0 : 36, // Increased collapsed width to prevent overflow
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
                        color: Colors.black.withOpacity(0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 10), // Match NEWS tab
                            child: Container(
                              width: 32, // Match NEWS tab
                              height: double.infinity,
                              child: RotatedBox(
                                quarterTurns: -1,
                                child: Container(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontFamily: 'ArimoHebrewSubsetItalic',
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 30,
                                      height: 1.0,
                                      letterSpacing: -0.3,
                                      color: labelColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (isExpanded && (label == 'SPORT'))
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // COMING SOON banner
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      child: Center(
                                        child: Image.asset(
                                          'assets/images/coming-soon.png',
                                          height: 100,  // Increased height for prominence
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    // SizedBox(height: 18),
                                    SizedBox(
                                      width: 220,
                                      child: Text(
                                        'Here you will find sports',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
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

}
