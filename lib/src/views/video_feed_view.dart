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
  int? initialVideoId;
  int _retryCount = 0;
  Timer? _autoRetryTimer;

  @override
  void initState() {
    super.initState();
    // Get the videoId argument if present
    initialVideoId = Get.arguments != null ? Get.arguments['videoId'] : null;
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

  void _initializeVideoFeed() async {
    if (!mounted) return;
    setState(() {
      _isInitialized = true;
    });
    
    print("=== VIDEO FEED INITIALIZATION DEBUG ===");
    print("Before resetToAllVideos:");
    print("userVideoObj.userId: ${mainService.userVideoObj.value.userId}");
    print("userVideoObj.name: ${mainService.userVideoObj.value.name}");
    print("userVideoObj.videoId: ${mainService.userVideoObj.value.videoId}");
    print("userVideoObj.hashTag: ${mainService.userVideoObj.value.hashTag}");
    
    // Reset to show all videos (not just user's videos)
    dashboardController.resetToAllVideos();
    
    print("After resetToAllVideos:");
    print("userVideoObj.userId: ${mainService.userVideoObj.value.userId}");
    print("userVideoObj.name: ${mainService.userVideoObj.value.name}");
    print("userVideoObj.videoId: ${mainService.userVideoObj.value.videoId}");
    print("userVideoObj.hashTag: ${mainService.userVideoObj.value.hashTag}");
    print("=== END VIDEO FEED INITIALIZATION DEBUG ===");
    
    await dashboardController.getVideos();
    if (initialVideoId != null) {
      final videos = dashboardService.videosData.value.videos;
      final idx = videos.indexWhere((v) => v.videoId == initialVideoId);
      if (idx != -1) {
        dashboardController.pageViewController.value.jumpToPage(idx);
        dashboardService.pageIndex.value = idx;
      }
    }
  }

  void _retryVideoFetch() async {
    print("Retrying video fetch...");
    // Reset to show all videos
    dashboardController.resetToAllVideos();
    await dashboardController.getVideos();
  }

  void _startAutoRetry() {
    // Cancel any existing timer
    _autoRetryTimer?.cancel();
    
    // Auto retry every 5 seconds if no videos, max 10 attempts
    _autoRetryTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (dashboardService.videosData.value.videos.isNotEmpty || 
          dashboardController.isLoading.value) {
        timer.cancel();
        _retryCount = 0; // Reset counter on success
        return;
      }
      
      _retryCount++;
      print("Auto retrying video fetch... Attempt $_retryCount");
      
      if (_retryCount >= 10) {
        print("Max retry attempts reached, stopping auto-retry");
        timer.cancel();
        return;
      }
      
      _retryVideoFetch();
    });
  }

  @override
  void dispose() {
    _autoRetryTimer?.cancel();
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
                  _retryCount = 0; // Reset retry counter on manual refresh
                  _autoRetryTimer?.cancel(); // Cancel auto-retry
                  dashboardController.stopController(dashboardService.pageIndex.value);
                  dashboardService.postIds = [];
                  // Reset to show all videos
                  dashboardController.resetToAllVideos();
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
      ),
    );
  }

  Widget _buildVideoFeed() {
    return Obx(() {
      print("=== VIDEO FEED DEBUG ===");
      print("isLoading: ${dashboardController.isLoading.value}");
      print("isVideoInitialized: ${dashboardController.isVideoInitialized.value}");
      print("videos count: ${dashboardService.videosData.value.videos.length}");
      print("videos data: ${dashboardService.videosData.value.videos}");
      print("=== END VIDEO FEED DEBUG ===");
      
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
      
      if (!dashboardController.isVideoInitialized.value || dashboardService.videosData.value.videos.isEmpty) {
        // Start auto retry if not already started and under max attempts
        if (_retryCount < 10) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _startAutoRetry();
          });
        }
        
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
              if (_retryCount < 10) ...[
                Text(
                  "Retrying automatically... (Attempt $_retryCount/10)".tr,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ] else ...[
                Text(
                  "Unable to load videos after 10 attempts".tr,
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ],
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _retryCount = 0; // Reset counter
                      _retryVideoFetch();
                    },
                    icon: Icon(Icons.refresh, color: Colors.white),
                    label: Text(
                      "Retry Now".tr,
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFC107),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Reset and try with fresh data
                      _retryCount = 0; // Reset counter
                      dashboardService.postIds = [];
                      dashboardService.pageIndex.value = 0;
                      dashboardService.videosData.value.videos = [];
                      dashboardService.videosData.refresh();
                      // Reset to show all videos
                      dashboardController.resetToAllVideos();
                      _retryVideoFetch();
                    },
                    icon: Icon(Icons.restart_alt, color: Colors.white),
                    label: Text(
                      "Reset".tr,
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }

      return Obx(
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
} 