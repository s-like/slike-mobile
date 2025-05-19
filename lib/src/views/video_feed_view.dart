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

  double _tempAdPadding = 0;

  @override
  void initState() {
    mainService.isOnHomePage.value = false;
    mainService.isOnHomePage.refresh();
    
    // Initialize video feed data
    dashboardController.getVideos();
    super.initState();
  }

  @override
  void dispose() {
    dashboardController.stopController(dashboardService.pageIndex.value);
    dashboardService.postIds = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();
        if (dashboardController.pc.isPanelOpen) {
          dashboardController.pc.close();
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
        backgroundColor: Colors.black,
        body: Obx(
          () => Stack(
            children: [
              RefreshIndicator(
                onRefresh: () {
                  if (dashboardService.randomString.value != "") {
                    dashboardService.randomString.value = CommonHelper.getRandomString(4, numeric: true);
                    dashboardService.randomString.refresh();
                  }
                  dashboardController.stopController(dashboardService.pageIndex.value);
                  dashboardService.postIds = [];
                  return dashboardController.getVideos();
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
                          SizedBox(height: 60.0),
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
                Text(
                  "No Videos yet".tr,
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
  }

  Widget _buildSidebar(int index) {
    return sidebar(index);
  }

  Widget sidebar(index) {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    dashboardController.encodedVideoId = stringToBase64.encode(dashboardController.encKey + dashboardController.videoObj.value.videoId.toString());
    return Obx(
      () => Container(
        width: 70.0,
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Column(
            children: [
              LikeButton(
                size: 25,
                circleColor: CircleColor(start: Colors.transparent, end: Colors.transparent),
                bubblesColor: BubblesColor(
                  dotPrimaryColor: dashboardController.videoObj.value.isLike ? Color(0xffee1d52) : Color(0xffffffff),
                  dotSecondaryColor: dashboardController.videoObj.value.isLike ? Color(0xffee1d52) : Color(0xffffffff),
                ),
                likeBuilder: (bool isLiked) {
                  return SvgPicture.asset(
                    'assets/icons/liked.svg',
                    width: 25.0,
                    colorFilter: ColorFilter.mode(dashboardController.videoObj.value.isLike ? Color(0xffee1d52) : Colors.white, BlendMode.srcIn),
                  );
                },
                onTap: dashboardController.onLikeButtonTapped,
              ),
              Text(
                CommonHelper.formatter(dashboardController.videoObj.value.totalLikes.toString()),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          SizedBox(height: 10),
          Bouncy(
            duration: Duration(milliseconds: 2000),
            lift: 10,
            ratio: 0.25,
            pause: 0.5,
            child: Obx(
              () => Column(
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
                  SizedBox(height: 10),
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
                      padding: EdgeInsets.only(top: 9, bottom: 6, left: 5.0, right: 5.0),
                      icon: SvgPicture.asset(
                        'assets/icons/comments.svg',
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
                  ),
                  Text(
                    CommonHelper.formatter(dashboardController.videoObj.value.totalComments.toString()),
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
          SizedBox(height: 10),
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
                      padding: EdgeInsets.only(top: 0, bottom: 0, left: 5.0, right: 5.0),
                      icon: SvgPicture.asset(
                        'assets/icons/views.svg',
                        width: 25.0,
                        colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                      onPressed: () {},
                    ),
                  ),
                  Text(
                    CommonHelper.formatter(dashboardController.videoObj.value.totalViews.toString()),
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
          SizedBox(height: 20),
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
              ),
            ],
          ),
          SizedBox(height: 10),
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
              ),
            ],
          ),
          SizedBox(height: 10),
          // Removing the music player action widget
          // (dashboardController.videoObj.value.soundId > 0)
          //     ? _getMusicPlayerAction(index)
          //     : SizedBox(height: 0),
          // (dashboardController.videoObj.value.soundId > 0)
          //     ? Divider(
          //         color: Colors.transparent,
          //         height: 5.0,
          //       )
          //     : SizedBox(height: 0),
        ]),
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