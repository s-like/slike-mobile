import 'dart:async';
import 'dart:convert';

import 'package:bouncy_widget/bouncy_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../core.dart';
import 'dashboard_view.dart';  // Add this import for CustomBottomNavBar

class VideoFeedView extends StatefulWidget {
  VideoFeedView({Key? key}) : super(key: key);
  @override
  _VideoFeedViewState createState() => _VideoFeedViewState();
}

class _VideoFeedViewState extends State<VideoFeedView> with SingleTickerProviderStateMixin, RouteAware {
  DashboardController dashboardController = Get.find();
  MainService mainService = Get.find();
  AuthService authService = Get.find();
  DashboardService dashboardService = Get.find();
  VideoRecorderService videoRecorderService = Get.find();
  PostService postService = Get.find();
  DateTime currentBackPressTime = DateTime.now();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize state
    mainService.isOnHomePage.value = false;
    mainService.isOnHomePage.refresh();
    
    // Reset video feed state
    dashboardService.pageIndex.value = 0;
    dashboardService.videosData.value.videos = [];
    dashboardService.videosData.refresh();
    
    // Schedule video initialization for after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _initializeVideoFeed();
      }
    });
  }

  void _initializeVideoFeed() {
    if (!mounted) return;
    setState(() {
      _isInitialized = true;
    });
    dashboardController.getVideos();
  }

  @override
  void dispose() {
    dashboardController.stopController(dashboardService.pageIndex.value);
    dashboardService.postIds = [];
    // Reset video feed state when leaving
    dashboardService.pageIndex.value = 0;
    dashboardService.videosData.value.videos = [];
    dashboardService.videosData.refresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (dashboardController.pc.isPanelOpen) {
          dashboardController.pc.close();
          return Future.value(false);
        }
        
        // Navigate to home view with home icon active
        dashboardService.currentPage.value = 0;
        dashboardService.currentPage.refresh();
        mainService.isOnHomePage.value = true;
        mainService.isOnHomePage.refresh();
        
        // Reset video feed state
        dashboardService.pageIndex.value = 0;
        dashboardService.videosData.value.videos = [];
        dashboardService.videosData.refresh();
        
        // Navigate to home
        Get.offNamed('/home');
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,  // Add this to prevent keyboard from pushing up nav bar
        body: Obx(
          () => Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  if (dashboardService.randomString.value != "") {
                    dashboardService.randomString.value = CommonHelper.getRandomString(4, numeric: true);
                    dashboardService.randomString.refresh();
                  }
                  dashboardController.stopController(dashboardService.pageIndex.value);
                  dashboardService.postIds = [];
                  await dashboardController.getVideos();
                },
                child: _buildVideoFeed(),
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
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: CustomBottomNavBar(
            currentIndex: 1, // Set to 1 for video feed
            onTap: (newIndex) {
              if (newIndex == 1) return; // Ignore if clicking video icon
              
              if (newIndex == 2) { // If clicking create video button
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
                    // Reset navigation state before going to login
                    dashboardService.currentPage.value = 1; // Keep video feed as current page
                    dashboardService.currentPage.refresh();
                    Get.offNamed('/login');
                  }
                }
              } else {
                // Handle other navigation items (home, conversations, profile)
                dashboardService.currentPage.value = newIndex;
                dashboardService.currentPage.refresh();
                switch (newIndex) {
                  case 0:
                    Get.offNamed('/home');
                    break;
                  case 2:
                    Get.offNamed('/conversations');
                    break;
                  case 4:
                    Get.offNamed('/my-profile');
                    break;
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVideoFeed() {
    return Obx(() {
      if (dashboardController.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                "Loading videos...".tr,
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }
      
      if (!dashboardController.isVideoInitialized.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.videocam_off,
                size: 48,
                color: Colors.white.withOpacity(0.7),
              ),
              SizedBox(height: 16),
              Text(
                "No Videos yet".tr,
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  dashboardController.getVideos();
                },
                child: Text(
                  "Try Again".tr,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        );
      }

      return (dashboardService.videosData.value.videos.isNotEmpty)
          ? Obx(
              () => PageView.builder(
                allowImplicitScrolling: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                controller: dashboardController.pageViewController.value,
                onPageChanged: (index) {
                  dashboardController.videoObj.value = dashboardService.videosData.value.videos.elementAt(index);
                  dashboardService.pageIndex.value = index;
                  dashboardController.videoObj.refresh();
                  dashboardController.showProgress.value = false;
                  dashboardController.showProgress.refresh();
                  if (dashboardService.videosData.value.videos.length - index == 3) {
                    dashboardController.listenForMoreVideos();
                  }
                },
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      dashboardController.onTap.value = true;
                      dashboardController.onTap.refresh();
                      dashboardController.playOrPauseVideo();
                    },
                    child: Stack(
                      fit: StackFit.passthrough,
                      children: <Widget>[
                        Container(
                          height: Get.height,
                          width: Get.width,
                          child: Center(
                            child: Container(
                              color: Colors.black,
                              child: VideoPlayerWidgetV2(videoObj: dashboardService.videosData.value.videos.elementAt(index)),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Obx(
                              () => Container(
                                padding: new EdgeInsets.only(
                                  bottom: dashboardService.bottomPadding.value + Get.mediaQuery.viewPadding.bottom,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    VideoDescription(
                                      dashboardService.videosData.value.videos.elementAt(index),
                                      dashboardController.pc3,
                                    ),
                                    _buildSidebar(index)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                itemCount: dashboardService.videosData.value.videos.length,
                scrollDirection: Axis.vertical,
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.videocam_off,
                    size: 48,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No Videos yet".tr,
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      dashboardController.getVideos();
                    },
                    child: Text(
                      "Try Again".tr,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            );
    });
  }

  Widget _buildSidebar(int index) {
    return sidebar(index);
  }

  Widget sidebar(index) {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    dashboardController.encodedVideoId = stringToBase64.encode(dashboardController.encKey + dashboardController.videoObj.value.videoId.toString());
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(5),
        ),
        margin: EdgeInsets.only(right: 20, bottom: 20),
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Container(
          width: 50.0,
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            // Gift icon
            Column(
              children: [
                if (mainService.enableGifts.value)
                  (authService.currentUser.value.id != dashboardController.videoObj.value.userId)
                      ? InkWell(
                          child: Image.asset(
                            "assets/icons/gift.png",
                            width: 25.0,
                          ),
                          onTap: () async {
                            if (authService.currentUser.value.id > 0) {
                              dashboardService.firstLoad.value = false;
                              GiftController giftController = Get.find();
                              giftController.openGiftsWidget(id: dashboardController.videoObj.value.videoId);
                            } else {
                              Fluttertoast.showToast(msg: "You must Login first to send gifts.");
                              Get.toNamed("/login");
                            }
                          },
                        )
                      : Container(),
                SizedBox(height: 5),
              ],
            ),
            // Muscle (like) icon
            Column(
              children: [
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/muscle.svg',
                    width: 25.0,
                    colorFilter: ColorFilter.mode(
                      dashboardController.videoObj.value.isLike ? Color(0xffee1d52) : Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () => dashboardController.onLikeButtonTapped(!dashboardController.videoObj.value.isLike),
                ),
                Text(
                  CommonHelper.formatter(dashboardController.videoObj.value.totalLikes.toString()),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // SizedBox(height: 5),
              ],
            ),
            // Chat icon
            Column(
              children: [
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/comment.svg',
                    width: 25.0,
                    colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                  onPressed: () {
                    if (dashboardController.bannerShowOn.indexOf("1") > -1) {
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
                    if (dashboardController.videoObj.value.totalComments > 0) {
                      dashboardController.getComments(dashboardController.videoObj.value).whenComplete(
                        () {
                          Timer(Duration(seconds: 1), () => setState(() {}));
                        },
                      );
                    }
                  },
                ),
                Text(
                  CommonHelper.formatter(dashboardController.videoObj.value.totalComments.toString()),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // SizedBox(height: 5),
              ],
            ),
            // Share icon
            Column(
              children: [
                Obx(() {
                  return (!dashboardController.shareShowLoader.value)
                      ? IconButton(
                          icon: SvgPicture.asset(
                            'assets/icons/share.svg',
                            width: 25.0,
                            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          ),
                          onPressed: () async {
                            Codec<String, String> stringToBase64 = utf8.fuse(base64);
                            String vId = stringToBase64.encode(dashboardController.videoObj.value.videoId.toString());
                            Share.share('$baseUrl$vId');
                          },
                        )
                      : CommonHelper.showLoaderSpinner(Colors.white);
                }),
                // SizedBox(height: 5),
              ],
            ),
            // Report icon
            Column(
              children: [
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/report.svg',
                    width: 25.0,
                    colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                  onPressed: () async {
                    if (authService.currentUser.value.accessToken != '') {
                      dashboardController.showReportMsg.value = false;
                      dashboardController.showReportMsg.refresh();
                      reportLayout(context, dashboardController.videoObj.value);
                    } else {
                      dashboardController.stopController(dashboardService.pageIndex.value);
                      Get.offNamed("/login");
                    }
                  },
                ),
                // SizedBox(height: 10),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  void reportLayout(context, Video videoObj) {
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
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                                ),
                                iconEnabledColor: Get.theme.iconTheme.color,
                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                ),
                                value: dashboardController.selectedType,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dashboardController.selectedType = newValue!;
                                  });
                                },
                                validator: (value) => value == null ? 'This field is required!'.tr : null,
                                items: dashboardController.reportType.map((String val) {
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
                        SizedBox(height: 20),
                        SizedBox(
                          width: Get.width - 100,
                          height: 30,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Row(
                                  children: [
                                    "Block".tr.text.color(Colors.white).size(16).make(),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Transform.scale(
                                  scale: 0.6,
                                  child: CupertinoSwitch(
                                    activeTrackColor: Get.theme.highlightColor,
                                    value: dashboardService.videoReportBlocked.value,
                                    onChanged: (value) {
                                      dashboardService.videoReportBlocked.value = !dashboardService.videoReportBlocked.value;
                                      dashboardService.videoReportBlocked.refresh();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                WidgetsBinding.instance.addPostFrameCallback((_) async {
                                  setState(() {
                                    if (!dashboardController.showReportLoader.value) {
                                      validateForm(videoObj, context);
                                    }
                                  });
                                });
                              },
                              child: Container(
                                height: 30,
                                width: 60,
                                decoration: BoxDecoration(color: Get.theme.highlightColor),
                                child: Obx(
                                  () => Center(
                                    child: (!dashboardController.showReportLoader.value)
                                        ? Text(
                                            "Submit".tr,
                                            style: TextStyle(
                                              color: mainService.setting.value.buttonTextColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                              fontFamily: 'RockWellStd',
                                            ),
                                          )
                                        : CommonHelper.showLoaderSpinner(Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                dashboardController.playController(dashboardService.pageIndex.value);
                                Get.back();
                              },
                              child: Container(
                                height: 30,
                                width: 60,
                                decoration: BoxDecoration(color: Get.theme.highlightColor),
                                child: Center(
                                  child: Text(
                                    "Cancel".tr,
                                    style: TextStyle(
                                      color: mainService.setting.value.buttonTextColor,
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
                              "Thanks for reporting. If we find this content to be in violation of our Guidelines, we will remove it".tr,
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

  validateForm(Video videoObj, context) {
    if (dashboardController.formKey.currentState!.validate()) {
      dashboardController.formKey.currentState!.save();
      dashboardController.submitReport(videoObj, context);
    }
  }
} 