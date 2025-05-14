import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeleton_loader/skeleton_loader.dart';

import '../core.dart';

class LiveBroadcastAgora extends StatefulWidget {
  const LiveBroadcastAgora({key});

  @override
  State<LiveBroadcastAgora> createState() => _LiveBroadcastAgoraState();
}

class _LiveBroadcastAgoraState extends State<LiveBroadcastAgora> {
  AuthService authService = Get.find();
  MainService mainService = Get.find();
  LiveStreamingService liveStreamingService = Get.find();
  LiveStreamingController liveStreamingController = Get.find();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("WidgetsBinding");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          liveStreamingController.disposeAgoraLive();
          // Get.offNamed('/home');
          return Future.value(false);
        },
        child: Stack(
          children: [
            Scaffold(
              floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
              floatingActionButton: SizedBox(
                height: 120.0,
                child: Column(
                  mainAxisAlignment: liveStreamingService.isStreamSubscribe.value ? MainAxisAlignment.start : MainAxisAlignment.center,
                  children: <Widget>[
                    !liveStreamingService.isStreamSubscribe.value
                        ? FloatingActionButton(
                            heroTag: "btn1",
                            onPressed: () {
                              liveStreamingController.switchCameraFunc();
                            },
                            mini: true,
                            child: const Icon(Icons.switch_camera),
                          )
                        : const SizedBox(),
                    SizedBox(
                      height: 10,
                    ),
                    FloatingActionButton(
                      heroTag: "btn2",
                      onPressed: () async {
                        liveStreamingController.disposeAgoraLive();
                      },
                      tooltip: 'Hangup',
                      backgroundColor: Colors.pink,
                      mini: true,
                      child: Icon(
                        Icons.clear,
                        size: 20,
                        color: Get.theme.primaryColor,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              body: WillPopScope(
                onWillPop: () {
                  liveStreamingController.disposeAgoraLive();
                  return Future.value(true);
                },
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    return Obx(() {
                      return Stack(
                        children: <Widget>[
                          Positioned(
                            left: 0.0,
                            right: 0.0,
                            top: 0.0,
                            bottom: 0.0,
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                              width: Get.width,
                              height: Get.height,
                              decoration: BoxDecoration(
                                color: Get.theme.primaryColor,
                              ),
                              child: !liveStreamingService.isStreamSubscribe.value
                                  ? Center(
                                      child: liveStreamingController.localUserJoined.value
                                          ? AgoraVideoView(
                                              controller: VideoViewController(
                                                rtcEngine: liveStreamingController.engine!,
                                                canvas: const VideoCanvas(uid: 0),
                                              ),
                                              key: Key(liveStreamingService.currentLiveStreamName),
                                            )
                                          : const CircularProgressIndicator(),
                                    )
                                  : Center(
                                      child: AgoraVideoView(
                                        controller: VideoViewController.remote(
                                          rtcEngine: liveStreamingController.engine!,
                                          canvas: VideoCanvas(
                                            uid: int.parse(
                                              liveStreamingService.currentLiveStreamOwnerId.value,
                                            ),
                                          ),
                                          connection: RtcConnection(
                                            channelId: liveStreamingService.currentLiveStreamName,
                                          ),
                                          // useFlutterTexture: _isUseFlutterTexture,
                                          // useAndroidSurfaceView: _isUseAndroidSurfaceView,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            width: Get.width,
                            height: Get.height / 2,
                            child: Container(
                              width: Get.width,
                              height: Get.height / 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.35),
                                    Colors.black.withValues(alpha: 0.35),
                                    Colors.black.withValues(alpha: 0.35),
                                    Colors.black.withValues(alpha: 0.55),
                                    Colors.black.withValues(alpha: 0.85),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            width: Get.width,
                            height: Get.height / 2,
                            child: ShaderMask(
                              shaderCallback: (Rect rect) {
                                return const LinearGradient(
                                  end: Alignment.topCenter,
                                  begin: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black, Colors.black, Colors.black45, Colors.black26, Colors.transparent],
                                  stops: [0.0, 0.03, 0.7, 0.8, 0.9, 1.0],
                                ).createShader(rect);
                              },
                              blendMode: BlendMode.dstIn,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 55, bottom: 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Obx(
                                        () {
                                          return Stack(
                                            children: [
                                              SizedBox(
                                                width: Get.width,
                                                child: Padding(
                                                  padding: liveStreamingService.liveStreamComments.value.comments.length > 5
                                                      ? authService.currentUser.value.accessToken != ''
                                                          ? const EdgeInsets.only(bottom: 10)
                                                          : EdgeInsets.zero
                                                      : EdgeInsets.zero,
                                                  child: ListView.builder(
                                                    controller: liveStreamingController.liveStreamCommentsScrollController,
                                                    padding: const EdgeInsets.only(bottom: 15),
                                                    scrollDirection: Axis.vertical,
                                                    reverse: true,
                                                    itemCount: liveStreamingService.liveStreamComments.value.comments.length,
                                                    itemBuilder: (context, i) {
                                                      CommentData item = liveStreamingService.liveStreamComments.value.comments.elementAt(i);
                                                      return liveStreamingService.liveStreamComments.value.comments.elementAt(i).commentId > 0
                                                          ? InkWell(
                                                              onLongPress: () {
                                                                showModalBottomSheet<void>(
                                                                    isDismissible: true,
                                                                    isScrollControlled: true,
                                                                    barrierColor: Colors.black.withValues(alpha: 0.9),
                                                                    context: Get.context!,
                                                                    builder: (BuildContext context) {
                                                                      return StatefulBuilder(builder: (BuildContext context, StateSetter setState /*You can rename this!*/) {
                                                                        return Container(
                                                                          height: 60,
                                                                          width: Get.width,
                                                                          decoration: const BoxDecoration(
                                                                            color: Colors.white,
                                                                          ),
                                                                          child: Row(
                                                                            children: [
                                                                              Expanded(
                                                                                child: Text(
                                                                                  item.comment,
                                                                                  style: const TextStyle(
                                                                                    fontWeight: FontWeight.w400,
                                                                                    color: Colors.black,
                                                                                    fontSize: 14.0,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  liveStreamingController.deleteComment(item.commentId, liveStreamingService.currentLiveStreamId);
                                                                                  liveStreamingService.liveStreamComments.value.comments.removeAt(i);
                                                                                  liveStreamingService.liveStreamComments.refresh();
                                                                                  Get.back();
                                                                                },
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(
                                                                                    color: Get.theme.primaryColorDark,
                                                                                    borderRadius: BorderRadius.circular(3),
                                                                                  ),
                                                                                  child: "Delete".text.color(Get.theme.primaryColor).make().pSymmetric(h: 10, v: 7),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ).pSymmetric(h: 10),
                                                                        );
                                                                      });
                                                                    });
                                                              },
                                                              child: Container(
                                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                child: Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 50,
                                                                      child: InkWell(
                                                                        onTap: () {},
                                                                        child: Container(
                                                                          width: 35.0,
                                                                          height: 35.0,
                                                                          decoration: BoxDecoration(
                                                                            border: Border.all(color: Get.theme.primaryColor.withValues(alpha: 0.7), width: 1),
                                                                            shape: BoxShape.circle,
                                                                            image: DecorationImage(
                                                                              image: item.userDp.isNotEmpty
                                                                                  ? CachedNetworkImageProvider(
                                                                                      item.userDp,
                                                                                      maxWidth: 120,
                                                                                      maxHeight: 120,
                                                                                    )
                                                                                  : const AssetImage(
                                                                                      "assets/images/logo.png",
                                                                                    ) as ImageProvider,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: Column(
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              InkWell(
                                                                                onTap: () {},
                                                                                child: Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      item.username,
                                                                                      style: TextStyle(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        color: Get.theme.primaryColor,
                                                                                        fontSize: 14.0,
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      width: 5,
                                                                                    ),
                                                                                    item.isVerified == true
                                                                                        ? const Icon(
                                                                                            Icons.verified,
                                                                                            color: Colors.blue,
                                                                                            size: 16,
                                                                                          )
                                                                                        : Container().pOnly(right: 5),
                                                                                    authService.currentUser.value.id == item.userId
                                                                                        ? item.time.isNotEmpty
                                                                                            ? Container(
                                                                                                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                                                                child: Text(
                                                                                                  CommonHelper.timeAgoCustom(
                                                                                                    DateFormat("yyyy-MM-dd hh:mm:ss").parse(item.time),
                                                                                                  ),
                                                                                                  style: TextStyle(
                                                                                                    color: Get.theme.primaryColor,
                                                                                                    fontSize: 12.0,
                                                                                                  ),
                                                                                                ),
                                                                                              )
                                                                                            : Container()
                                                                                        : Container(
                                                                                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                                                            child: Text(
                                                                                              // liveStreamingService.liveStreamComments.value.comments!.elementAt(i).time,
                                                                                              CommonHelper.timeAgoSinceDate(
                                                                                                item.time,
                                                                                                dateFormat: item.time.contains(".") ? "yyyy-MM-dd HH:mm:ss.sss" : "yyyy-MM-dd HH:mm:ss",
                                                                                              ),
                                                                                              style: TextStyle(
                                                                                                color: Get.theme.primaryColor,
                                                                                                fontSize: 10.0,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Text(
                                                                            item.comment,
                                                                            style: TextStyle(
                                                                              color: Get.theme.primaryColor,
                                                                              fontSize: 14.0,
                                                                              fontWeight: FontWeight.w400,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ).pOnly(bottom: 15),
                                                            )
                                                          : Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 15),
                                                              child: item.type != "G"
                                                                  ? Text(
                                                                      item.comment,
                                                                      style: TextStyle(
                                                                        color: item.type != "G" ? Get.theme.primaryColor : Colors.pink,
                                                                        fontSize: 13.0,
                                                                      ),
                                                                    )
                                                                  : Row(
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      children: [
                                                                        Text(
                                                                          item.comment,
                                                                          style: TextStyle(
                                                                            color: item.type != "G" ? Get.theme.primaryColor : Colors.pink,
                                                                            fontSize: 13.0,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width: 3,
                                                                        ),
                                                                        if (item.commentGiftImage != "")
                                                                          Transform.translate(
                                                                            offset: const Offset(-2, -4),
                                                                            child: SizedBox(
                                                                              height: 25,
                                                                              child: CachedNetworkImage(
                                                                                imageUrl: item.commentGiftImage,
                                                                                progressIndicatorBuilder: (context, url, downloadProgress) {
                                                                                  return SizedBox(
                                                                                    height: 30,
                                                                                    width: 36,
                                                                                    child: SkeletonLoader(
                                                                                      builder: AspectRatio(
                                                                                        aspectRatio: 1,
                                                                                        child: Container(
                                                                                          color: Colors.black,
                                                                                        ),
                                                                                      ),
                                                                                      items: 1,
                                                                                    ),
                                                                                  );
                                                                                },
                                                                                // width: 80,
                                                                                height: 30,
                                                                                fit: BoxFit.fill,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                      ],
                                                                    ),
                                                            ).pOnly(bottom: 10);
                                                    },
                                                  ),
                                                ),
                                              ),
                                              liveStreamingController.commentsLoader.value
                                                  ? CommonHelper.showLoaderSpinner(Colors.white)
                                                  : const SizedBox(
                                                      height: 0,
                                                    )
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    Container(
                                      height: 0.1,
                                      color: Get.theme.primaryColor.withValues(alpha: 0.5),
                                    ),
                                    authService.currentUser.value.accessToken != ''
                                        ? Container(
                                            padding: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
                                            height: 50,
                                            width: Get.width,
                                            child: Obx(() {
                                              return SizedBox(
                                                width: Get.width,
                                                child: commentField(liveStreamingController.editedComment.value),
                                              );
                                            }),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    });
                  },
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 20,
              child: Row(
                children: [
                  Container(
                    height: 25,
                    color: Colors.pink,
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ).pOnly(right: 5),
                        "Live".text.uppercase.white.bold.size(13).make(),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  Container(
                    height: 25,
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                    color: Colors.black,
                    child: Obx(
                      () => Row(
                        children: [
                          const SizedBox(
                            width: 3,
                          ),
                          Transform.scale(
                            scale: 1.3,
                            child: const Icon(
                              Icons.remove_red_eye_outlined,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          "${liveStreamingService.liveStreamViewers.length}".text.white.bold.size(14).make(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: Get.width * 0.1,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () => (liveStreamingService.totalCurrentLiveStreamGifts.value > 0)
                        ? Container(
                            height: 25,
                            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
                            color: Colors.black26,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 3,
                                ),
                                Image.asset(
                                  "assets/icons/gift.png",
                                  width: 18.0,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                "${liveStreamingService.totalCurrentLiveStreamGifts.value}".text.white.bold.size(14).make(),
                              ],
                            ),
                          )
                        : Container(),
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  Obx(
                    () => (liveStreamingService.totalCurrentLiveStreamCoins.value > 0)
                        ? Container(
                            height: 25,
                            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                            color: Colors.black26,
                            child: Obx(
                              () => Row(
                                children: [
                                  const SizedBox(
                                    width: 3,
                                  ),
                                  Image.asset(
                                    "assets/icons/coin.png",
                                    width: 18.0,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  "${liveStreamingService.totalCurrentLiveStreamCoins.value}".text.white.bold.size(14).make(),
                                ],
                              ),
                            ),
                          )
                        : Container(),
                  ),
                ],
              ),
            ),
            if (liveStreamingService.isStreamSubscribe.value && mainService.enableGifts.value)
              Positioned(
                right: 15,
                bottom: 100,
                child: InkWell(
                  onTap: () async {
                    if (!liveStreamingService.isStreamSubscribe.value) {
                      LiveStreamingController liveStreamingController = Get.find();
                      liveStreamingController.offset.value = Offset(0.05, liveStreamingController.offset.value.dy);
                      liveStreamingController.liveConfettiControllerCenter.play();
                      Timer(const Duration(seconds: 4), () {
                        liveStreamingController.offset.value = Offset(-10, liveStreamingController.offset.value.dy);
                        liveStreamingController.liveConfettiControllerCenter.stop();
                      });
                    } else {
                      AuthService authService = Get.find();
                      if (authService.currentUser.value.id > 0) {
                        DashboardService homeService = Get.find();
                        homeService.firstLoad.value = false;
                        GiftController giftController = Get.find();
                        giftController.openGiftsWidget(id: liveStreamingService.currentLiveStreamId, isLivePage: true);
                      } else {
                        Fluttertoast.showToast(msg: "You must Login first to send gifts.");
                        Get.toNamed("/login");
                      }
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Get.theme.primaryColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Image.asset(
                      "assets/icons/gift.png",
                      width: 28.0,
                    ),
                  ),
                ),
              ),
            if (!liveStreamingService.isStreamSubscribe.value)
              Align(
                alignment: Alignment.center,
                child: ConfettiWidget(
                  confettiController: liveStreamingController.liveConfettiControllerCenter,
                  blastDirectionality: BlastDirectionality.explosive, // don't specify a direction, blast randomly
                  shouldLoop: true, // start again as soon as the animation is finished
                  colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple], // manually specify the colors to be used
                ),
              ),
            Positioned(
              top: Get.height * 0.35,
              height: 70,
              width: Get.width * 0.8,
              child: SizedBox(
                width: Get.width * 0.8,
                height: 70,
                child: Opacity(
                  opacity: !liveStreamingService.isStreamSubscribe.value ? 1.0 : 0.0,
                  child: Obx(
                    () => AnimatedSlide(
                      offset: liveStreamingController.offset.value,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      child: Container(
                        width: Get.width * 0.8,
                        height: 70,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          // color: activeGiftIndex.value != i ? Get.theme.colorScheme.secondary.withValues(alpha:0.05) : Get.theme.primaryColorDark.withValues(alpha:0.6),
                          // color: Get.theme.colorScheme.secondary.withValues(alpha:0.05),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.black.withValues(alpha: 0.55),
                              Colors.black.withValues(alpha: 0.55),
                              Colors.black.withValues(alpha: 0.35),
                              Colors.black.withValues(alpha: 0.35),
                              Colors.black.withValues(alpha: 0.25),
                              Colors.black.withValues(alpha: 0.15),
                            ],
                          ),
                        ),
                        child: FittedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              liveStreamingService.notificationMessage.value
                                  .replaceAll("on your live stream", "")
                                  .text
                                  .center
                                  .white
                                  .textStyle(Get.theme.textTheme.headlineSmall)
                                  .size(14)
                                  .make()
                                  .centered(),
                              const SizedBox(
                                width: 8,
                              ),
                              SizedBox(
                                height: 50,
                                child: CachedNetworkImage(
                                  imageUrl: liveStreamingService.notificationGiftIcon.value,
                                  progressIndicatorBuilder: (context, url, downloadProgress) {
                                    return SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: SkeletonLoader(
                                        builder: AspectRatio(
                                          aspectRatio: 1,
                                          child: Container(
                                            color: Colors.black,
                                          ),
                                        ),
                                        items: 1,
                                      ),
                                    );
                                  },
                                  // width: 80,
                                  height: 50,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ],
                          ).pSymmetric(v: 10),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget commentField(int editedCommentId) {
    return TextFormField(
      style: TextStyle(
        color: Get.theme.primaryColor,
        fontSize: 12.0,
      ),
      obscureText: false,
      focusNode: liveStreamingController.inputNode,
      keyboardType: TextInputType.text,
      controller: liveStreamingController.liveCommentController,
      onSaved: (String? val) {
        liveStreamingService.liveComment.value = val!;
      },
      onChanged: (String? val) {
        liveStreamingService.liveComment.value = val!;
      },
      onTap: () {},
      decoration: InputDecoration(
        fillColor: Colors.white.withValues(alpha: 0.2),
        filled: true,
        contentPadding: const EdgeInsets.only(left: 20, top: 0),
        errorStyle: const TextStyle(
          color: Color(0xFF210ed5),
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          wordSpacing: 2.0,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: const BorderSide(width: 0, color: Colors.transparent)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: const BorderSide(width: 0, color: Colors.transparent)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: const BorderSide(width: 0, color: Colors.transparent)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: const BorderSide(width: 0, color: Colors.transparent)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: const BorderSide(width: 0, color: Colors.transparent)),
        hintText: "Type here",
        hintStyle: TextStyle(color: Get.theme.primaryColor, fontSize: 13),
        prefixIcon: SizedBox(
          width: 30.0,
          height: 30.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: authService.currentUser.value.dp != ""
                ? CachedNetworkImage(
                    imageUrl: authService.currentUser.value.dp,
                    placeholder: (context, url) => Center(
                      child: CommonHelper.showLoaderSpinner(Colors.white),
                    ),
                    width: 30,
                    height: 30,
                    fit: BoxFit.fill,
                  )
                : Image.asset(
                    "assets/images/logo.png",
                    width: 30,
                    height: 30,
                  ),
          ).centered().pSymmetric(h: 10),
        ),
        suffixIcon: InkWell(
          onTap: () {
            setState(() {
              liveStreamingController.textFieldMoveToUp = false;
            });

            if (liveStreamingService.liveComment.value.trim() != '') {
              liveStreamingController.addLiveComment(liveStreamingService.currentLiveStreamId);
            }
          },
          child: Icon(
            Icons.send,
            color: Get.theme.primaryColor,
          ),
        ),
      ),
    );
  }
}
