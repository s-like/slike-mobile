import 'dart:async';
import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_token_service/agora_token_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as HTTP;
import 'package:permission_handler/permission_handler.dart';

import '../core.dart';

class LiveStreamingController extends GetxController {
  LiveStreamingService liveStreamingService = Get.find();
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final msgController = TextEditingController();
  DateTime now = DateTime.now();
  ScrollController scrollController = ScrollController();
  var loadMoreUpdateView = false.obs;
  var showLoader = false.obs;
  bool showLoading = false;
  bool loadMoreConversations = true;
  bool showLoad = false;
  int page = 1;
  var searchController = TextEditingController();
  String searchKeyword = '';
  ChatService chatService = Get.find();
  MainService mainService = Get.find();
  AuthService authService = Get.find();
  var emojiShowing = false.obs;
  var countTimer = 5.obs;
  var bHideTimer = false.obs;
  String amPm = "";
  bool showChatLoader = true;
  int conversationPage = 1;
  int userId = 0;
  String msg = "";
  String message = "";
  VoidCallback listener = () {};
  double scrollPos = 0.0;
  OnlineUsersModel userObj = OnlineUsersModel();
  ScrollController chatScrollController = ScrollController();
  var showFloatingScrollToBottom = false.obs;
  var min = 0.obs;
  var max = 0.obs;
  var newMessageCount = 0.obs;
  ScrollController liveStreamCommentsScrollController = ScrollController();
  TextEditingController liveCommentController = TextEditingController();
  CommentData commentObj = CommentData();
  // agora vars
  RtcEngine? engine;
  RtcEngineEventHandler? engineEventHandler;
  bool showLoadMore = true;
  bool isJoined = false, switchCamera = true, switchRender = true;
  Set<int> remoteUid = {};
  var editedComment = 0.obs;
  var commentsLoader = false.obs;
  FocusNode inputNode = FocusNode();
  bool textFieldMoveToUp = false;
  late VoidCallback scrollListener;
  Timer? _debounce;
  var localUserJoined = false.obs;
  Timer? timer;

  var offset = const Offset(-10, 0).obs;
  late ConfettiController liveConfettiControllerCenter;
  @override
  void onInit() {
    scaffoldKey = GlobalKey<ScaffoldState>();
    liveConfettiControllerCenter = ConfettiController(
      duration: const Duration(
        seconds: 2,
      ),
    );
    // TODO: implement onInit
    super.onInit();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();
    print("mainService.setting.value.agoraAppId ${mainService.setting.value.agoraAppId}");
    //create the engine
    engine = createAgoraRtcEngine();
    await engine!.initialize(
      RtcEngineContext(
        appId: mainService.setting.value.agoraAppId,
        // channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );
    await engine!.enableVideo();
    // await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    engineEventHandler = RtcEngineEventHandler(
      onUserEnableVideo: (RtcConnection connection, int elapsed, bool yes) {
        debugPrint("On enable video user ${connection.channelId} joined");
      },
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        debugPrint("local user ${connection.localUid} joined");
        localUserJoined.value = true;
        localUserJoined.refresh();
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        debugPrint("remote user $remoteUid joined");
        remoteUid = remoteUid;
      },
      onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        debugPrint("remote user $remoteUid left channel");
        remoteUid = 0;
      },
      onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
        debugPrint('[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
      },
      onError: (error, string) {
        print("AgoraonError ${error.name} $string");
      },
    );
    await engine!.startPreview();
    await engine!.joinChannel(
      token: mainService.setting.value.agoraToken,
      channelId: liveStreamingService.currentLiveStreamName,
      // uid:authService.currentUser.value.userId,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );
    // Register the event handler
    if (engineEventHandler != null) {
      engine!.registerEventHandler(engineEventHandler!);
    }
  }

  Future<void> switchCameraFunc() async {
    await engine!.switchCamera();
  }

  Future<void> joinChannel() async {
    print("liveStreamingService.agoraToken ${liveStreamingService.agoraToken}");
    await engine!.joinChannel(
      token: mainService.setting.value.agoraToken,
      channelId: liveStreamingService.currentLiveStreamName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> leaveChannel() async {
    await engine!.leaveChannel();
  }

  Future<void> initEngine() async {
    engine = createAgoraRtcEngine();
    await engine!.initialize(
      RtcEngineContext(
        appId: mainService.setting.value.agoraAppId,
      ),
    );

    await engine!.setClientRole(role: ClientRoleType.clientRoleAudience);
    await engine!.enableVideo();
    await engine!.startPreview();
    print("ABCDDD");
    print(mainService.setting.value.agoraAppId);
    engineEventHandler = RtcEngineEventHandler(
      onError: (ErrorCodeType err, String msg) {
        print('[onError] err: $err, msg: $msg');
      },
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        print('[onJoinChannelSuccess] connection: ${connection.toJson()} elapsed: $elapsed');
        isJoined = true;
      },
      onUserJoined: (RtcConnection connection, int rUid, int elapsed) {
        print('[onUserJoined] connection: ${connection.toJson()} remoteUid: $rUid elapsed: $elapsed');

        remoteUid.add(rUid);
        liveStreamingService.currentLiveStreamOwnerId.value = rUid.toString();
        liveStreamingService.currentLiveStreamOwnerId.refresh();
      },
      onUserOffline: (RtcConnection connection, int rUid, UserOfflineReasonType reason) async {
        print('[onUserOffline] connection: ${connection.toJson()}  rUid: $rUid reason: $reason');
        remoteUid.removeWhere((element) => element == rUid);
        if (rUid.toString() == liveStreamingService.currentLiveStreamOwnerId.toString()) {
          liveStreamingService.gotoLive.value = false;
          liveStreamingService.gotoLive.refresh();
          await exitLiveStream();
          await engine!.leaveChannel();
          await engine!.release();

          engineEventHandler = null;
          localUserJoined.value = false;
          localUserJoined.refresh();
          Get.offNamed("/live-landing");
        }
      },
      onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        print('[onLeaveChannel] connection: ${connection.toJson()} stats: ${stats.toJson()}');
        isJoined = false;
        remoteUid.clear();
      },
    );

    await joinChannel();
    if (engineEventHandler != null) {
      engine!.registerEventHandler(engineEventHandler!);
    }
  }

  deleteComment(commentId, videoId) async {
    showLoader.value = true;
    showLoader.refresh();
    LiveStreamingService liveStreamingService = Get.find();
    try {
      HTTP.Response response = await CommonHelper.sendRequestToServer(
          endPoint: 'delete-comment',
          requestData: {
            "comment_id": commentId,
            "video_id": videoId,
          },
          method: "post");

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          liveStreamingService.liveStreamComments.value.comments.removeWhere((item) => item.commentId == commentId);
        } else {
          // String msg = jsonData['msg'];
          Fluttertoast.showToast(msg: "Comment deleted Successfully".tr);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  showDeleteAlert(parentContext, errorTitle, errorString, commentId, videoId) {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return Container(
          color: Colors.transparent,
          height: 200,
          padding: const EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: AlertDialog(
            title: Center(
              child: Text(
                errorTitle.tr,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontFamily: 'RockWellStd',
                ),
              ),
            ),
            insetPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/icons/warning.jpg",
                  width: 150,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                  ),
                  child: Text(
                    errorString,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    decoration: const BoxDecoration(
                      //color: Color(0xff2e2f34),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                            onTap: () async {
                              deleteComment(commentId, videoId);
                              Get.back();
                            },
                            child: Container(
                              width: 100,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Get.theme.highlightColor,
                                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                              ),
                              child: Center(
                                child: Text(
                                  "Yes".tr,
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'RockWellStd'),
                                ),
                              ),
                            )),
                        GestureDetector(
                          onTap: () {
                            Get.back();
                            // Get.back();
                          },
                          child: Container(
                            width: 100,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Get.theme.highlightColor,
                              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                            ),
                            child: Center(
                              child: Text(
                                "No".tr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'RockWellStd',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> disposeAgoraLive() async {
    if (!liveStreamingService.isAlreadyBroadcasting.value) {
      AwesomeDialog(
        dialogBackgroundColor: Get.theme.primaryColor,
        context: Get.context!,
        animType: AnimType.scale,
        dialogType: DialogType.question,
        body: Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              "Close Live".tr.text.center.textStyle(Get.textTheme.headlineLarge!.copyWith(color: Get.theme.indicatorColor, fontSize: 22)).make().centered().pOnly(bottom: 10),
              "Do you want to close the live stream?".tr.text.center.textStyle(Get.textTheme.bodyLarge!.copyWith(color: Get.theme.indicatorColor)).make().centered().pOnly(bottom: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.back(),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.black,
                        ),
                        child: "No".tr.text.size(18).center.color(Get.theme.primaryColor).make().centered().pSymmetric(h: 10, v: 15),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        await engine!.leaveChannel();
                        await engine!.release();

                        closeLiveStream();
                        engineEventHandler = null;
                        localUserJoined.value = false;
                        localUserJoined.refresh();
                        liveStreamingService.liveStreamComments.value.comments = [];
                        liveStreamingService.liveStreamComments.refresh();
                        Get.toNamed('/home');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Get.theme.primaryColorDark,
                        ),
                        child: "Yes".tr.text.size(18).center.color(Get.theme.primaryColor).make().centered().pSymmetric(h: 10, v: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).show();
    } else {
      await exitLiveStream();
      await engine!.leaveChannel();
      await engine!.release();
      engineEventHandler = null;
      localUserJoined.value = false;
      localUserJoined.refresh();
      Get.toNamed('/home');
    }
  }

  Future<String> joinLive(streamId) async {
    print("joinLive $streamId");

    final response = await CommonHelper.sendRequestToServer(
      endPoint: 'join-stream',
      method: "post",
      requestData: {
        "stream_id": streamId,
      },
    );

    if (response.statusCode == 200) {
      liveStreamingService.currentLiveStreamId = int.parse(json.decode(response.body)['stream_id'].toString());
      liveStreamingService.liveStreamViewers.value = json.decode(response.body)['viewers'];
      liveStreamingService.liveStreamComments.value = CommentModel.fromJSON(json.decode(response.body)['comments']);
      liveStreamingService.totalCurrentLiveStreamCoins.value = json.decode(response.body)['total_coins'] ?? 0;
      liveStreamingService.totalCurrentLiveStreamGifts.value = json.decode(response.body)['total_gifts'] ?? 0;
      return json.encode(json.decode(response.body));
    } else {
      throw Exception(response.body);
    }
  }

  Future<String> closeLiveStream() async {
    final response = await CommonHelper.sendRequestToServer(endPoint: 'stop-stream', method: "post", requestData: {
      "stream_id": liveStreamingService.currentLiveStreamId,
    });
    liveStreamingService.currentLiveStreamId = 0;
    liveStreamingService.totalCurrentLiveStreamCoins.value = 0;
    liveStreamingService.totalCurrentLiveStreamGifts.value = 0;
    if (response.statusCode == 200) {
      return json.encode(json.decode(response.body));
    } else {
      throw Exception(response.body);
    }
  }

  Future<String> exitLiveStream() async {
    final response = await CommonHelper.sendRequestToServer(endPoint: 'exit-stream', method: "post", requestData: {
      "stream_id": liveStreamingService.currentLiveStreamId.toString(),
    });
    liveStreamingService.currentLiveStreamId = 0;
    if (response.statusCode == 200) {
      return json.encode(json.decode(response.body));
    } else {
      throw Exception(response.body);
    }
  }

  getLiveUsers() async {
    try {
      final response = await CommonHelper.sendRequestToServer(endPoint: 'live-stream-list', method: "post", requestData: {});

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          if (page > 1) {
            liveStreamingService.liveUsersData.value.users.addAll(FollowingModel.fromJSON(json.decode(response.body)).users);
          } else {
            liveStreamingService.liveUsersData.value = FollowingModel.fromJSON(json.decode(response.body));
          }
          liveStreamingService.liveUsersData.refresh();
          return liveStreamingService.liveUsersData.value;
        } else {
          return FollowingModel.fromJSON({});
        }
      } else {
        return FollowingModel.fromJSON({});
      }
    } catch (e, s) {
      print("fromJSON error");
      print(e.toString());
      print(s);
      return FollowingModel.fromJSON({});
    }
  }

  void redirectToLive({isPlay = false, String liveStreamName = "", int liveStreamId = 0, int streamUserId = 0}) async {
    Get.back();
    if (authService.currentUser.value.accessToken != '') {
      LiveStreamingService liveStreamingService = Get.find();
      liveStreamingService.gotoLive.value = true;
      liveStreamingService.gotoLive.refresh();
      String streamName = "";

      const expirationInSeconds = 3600;
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final expireTimestamp = currentTimestamp + expirationInSeconds;
      String userId = "";
      if (isPlay) {
        liveStreamingService.isAlreadyBroadcasting.value = true;
        liveStreamingService.isAlreadyBroadcasting.refresh();
        userId = streamUserId.toString();
        streamName = liveStreamName;
        liveStreamingService.currentLiveStreamOwnerId.value = userId.toString();
        liveStreamingService.currentLiveStreamOwnerId.refresh();
      } else {
        liveStreamingService.isAlreadyBroadcasting.value = false;
        liveStreamingService.isAlreadyBroadcasting.refresh();
        userId = authService.currentUser.value.id.toString();
        streamName = "${authService.currentUser.value.id}_${authService.currentUser.value.email}_${DateTime.now().millisecondsSinceEpoch}";
      }
      liveStreamingService.currentLiveStreamName = streamName;
      String token = RtcTokenBuilder.build(
        appId: mainService.setting.value.agoraAppId,
        appCertificate: mainService.setting.value.agoraAppCertificate,
        channelName: streamName,
        uid: "0",
        role: isPlay ? RtcRole.subscriber : RtcRole.publisher,
        expireTimestamp: expireTimestamp,
      );
      print("agoraToken $token $isPlay $expireTimestamp $streamName");
      mainService.setting.value.agoraToken = token;
      Get.offNamed("/live-landing");
      EasyLoading.show(
        status: "${'Loading'.tr}..",
        maskType: EasyLoadingMaskType.black,
      );
      if (isPlay) {
        subscribeStream(streamName: liveStreamName, streamID: liveStreamId, streamUserId: streamUserId);
      } else {
        goLive();
      }
      EasyLoading.dismiss();
    } else {
      Get.offNamed("/login");
    }
  }

  void goLive() async {
    if (authService.currentUser.value.accessToken != '') {
      liveStreamingService.liveStreamComments.value.comments = [];
      liveStreamingService.liveStreamComments.refresh();
      countdownToLaunch();
      liveStreamingService.isStreamSubscribe.value = false;
      var response = await CommonHelper.sendRequestToServer(
        endPoint: 'start-stream',
        requestData: {
          "stream_name": liveStreamingService.currentLiveStreamName,
        },
        method: "post",
      );
      print("goLiveresponse.body ${response.body}");
      if (response.statusCode == 200) {
        liveStreamingService.currentLiveStreamId = json.decode(response.body)['stream_id'];
        print("currentLiveStreamId ${liveStreamingService.currentLiveStreamId}");
        authService.pusher.subscribe(
          channelName: 'private-stream.${liveStreamingService.currentLiveStreamId}',
          onEvent: (e) {
            print("e.eventNamee.eventName ${e.eventName}");
            if (e.eventName == "App\\Events\\StreamJoinEvent") {
              var data = jsonDecode(e!.data!);
              appendJoinedLiveStreamMessage(data: data);
            } else if (e.eventName == "App\\Events\\StreamNewCommentEvent") {
              print("StreamNewCommentEvent listened");
              var data = jsonDecode(e!.data!);
              appendCommentInLiveStream(data: data);
            } else if (e.eventName == "App\\Events\\StreamExitEvent") {
              var data = jsonDecode(e!.data!);
              appendJoinedLiveStreamMessage(data: data, exit: true);
            } else if (e.eventName == "App\\Events\\StreamSendGiftEvent") {
              var data = jsonDecode(e!.data!);
              receivedGiftNotify(data: data);
              appendGiftLiveStreamMessage(data: data);
            }
          },
        );

        await initAgora();
      } else {
        throw Exception(response.body);
      }
    } else {
      Get.offNamed("/login");
    }
  }

  receivedGiftNotify({required data}) {
    if (data != null) {
      data = jsonDecode(jsonEncode(data));
      print("receivedGiftNotify ${liveStreamingService.currentLiveStreamId} $data");
      var giftNotificationData = data['content'];
      var content = jsonDecode(jsonEncode(giftNotificationData));
      print("receivedGiftNotify ${liveStreamingService.currentLiveStreamId} $content");
      try {
        liveStreamingService.notificationMessage.value = content['title'].toString().tr;
        liveStreamingService.notificationMessage.refresh();
        liveStreamingService.notificationGiftIcon.value = content['image'];
        liveStreamingService.notificationGiftIcon.refresh();
        offset.value = Offset(0.05, offset.value.dy);
        offset.refresh();
        print("receivedGiftNotify1 ${liveStreamingService.currentLiveStreamId} $content");
      } catch (e, s) {
        print("$e $s");
      }
      liveConfettiControllerCenter.play();
      Timer(const Duration(seconds: 4), () {
        liveConfettiControllerCenter.stop();
      });
      Timer(const Duration(seconds: 6), () {
        offset.value = Offset(-5, offset.value.dy);
        offset.refresh();
      });
    }
  }

  void openLiveStreamList(context) {
    if (authService.currentUser.value.accessToken != '') {
      Get.offNamed('/live-users');
    } else {
      Get.offNamed("/login");
    }
  }

  Future<void> subscribeStream({int streamID = 0, String streamName = "", int streamUserId = 0}) async {
    if (authService.currentUser.value.accessToken != '') {
      liveStreamingService.isStreamSubscribe.value = true;
      authService.pusher.subscribe(
        channelName: 'private-stream.$streamID',
        onEvent: (e) {
          print("e.eventNamee.eventName ${e.eventName}");
          if (e.eventName == "App\\Events\\StreamJoinEvent") {
            var data = jsonDecode(e!.data!);
            appendJoinedLiveStreamMessage(data: data);
          } else if (e.eventName == "App\\Events\\StreamNewCommentEvent") {
            print("StreamNewCommentEvent listened");
            var data = jsonDecode(e!.data!);
            appendCommentInLiveStream(data: data);
          } else if (e.eventName == "App\\Events\\StreamExitEvent") {
            var data = jsonDecode(e!.data!);
            appendJoinedLiveStreamMessage(data: data, exit: true);
          } else if (e.eventName == "App\\Events\\StreamSendGiftEvent") {
            var data = jsonDecode(e!.data!);
            receivedGiftNotify(data: data);
            appendGiftLiveStreamMessage(data: data);
          }
        },
      );
      await joinLive(streamID);
      await initEngine();
      Get.offNamed("/live-agora");

      await Future.delayed(const Duration(seconds: 10));
      liveStreamingService.gotoLive.value = false;
      liveStreamingService.gotoLive.refresh();
      liveStreamingService.isAlreadyBroadcasting.value = true;
      liveStreamingService.isAlreadyBroadcasting.refresh();
    } else {
      Get.offNamed("/login");
    }
  }

  Future<void> appendCommentInLiveStream({required data}) async {
    CommentData commentObj = CommentData();
    if (data != null) {
      data = jsonDecode(jsonEncode(data));
      var commentContent = data['content'];
      // var content = jsonDecode(jsonEncode(commentContent['comment']));

      print("data $data content $commentContent ${commentContent.runtimeType}");
      if (commentContent['stream_id'].toString() == liveStreamingService.currentLiveStreamId.toString() && commentContent['user_id'].toString() != authService.currentUser.value.id.toString()) {
        print("Entered");
        commentObj.commentId = commentContent["comment_id"];
        commentObj.userId = commentContent["user_id"] ?? 0;
        commentObj.comment = commentContent["comment"];
        commentObj.username = commentContent["username"];
        commentObj.userDp = commentContent["user_dp"];
        commentObj.time = CommonHelper.getYourCountryTime(DateFormat("yyyy-MM-dd HH:mm:ss").parse(commentContent["added_on"] ?? "")).toString();
        try {
          print("commentObj ${commentObj.toString()}");
          liveStreamingService.liveStreamComments.value.comments.insert(0, commentObj);
          liveStreamingService.liveStreamComments.refresh();
        } catch (e) {
          print("$e commentObj error catch");
        }
      }
    } else {
      if (liveStreamingService.liveComment.trim() != "") {
        liveCommentController.text = '';
        commentObj.userId = authService.currentUser.value.id;
        commentObj.comment = liveStreamingService.liveComment.value;
        commentObj.username = authService.currentUser.value.username;
        commentObj.userDp = authService.currentUser.value.dp;
        commentObj.time = DateTime.now().toString();
        liveStreamingService.liveComment.value = "";
        try {
          liveStreamingService.liveStreamComments.value.comments.insert(0, commentObj);
          liveStreamingService.liveStreamComments.refresh();
        } catch (e) {
          print("$e like");
        }
      }
    }

    await Future.delayed(
      const Duration(
        milliseconds: 100,
      ),
    );

    if (liveStreamCommentsScrollController.positions.isNotEmpty) {
      liveStreamCommentsScrollController.animateTo(
        // liveStreamCommentsScrollController.position.maxScrollExtent,
        0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> addLiveComment(int streamId) async {
    print("addLiveComment ${liveStreamingService.liveComment}");
    FocusScope.of(Get.context!).unfocus();
    liveCommentController = TextEditingController(text: "");
    commentObj = CommentData();
    commentObj.videoId = 0;
    commentObj.streamId = streamId;
    commentObj.comment = liveStreamingService.liveComment.value;
    commentObj.userId = authService.currentUser.value.id;
    commentObj.userDp = authService.currentUser.value.dp;
    commentObj.username = authService.currentUser.value.username;
    commentObj.time = DateTime.now().toString();
    liveStreamingService.liveComment.value = '';
    int commentId = 0;
    print("rere");
    print(DateTime.now().toString());
    try {
      var response =
          await CommonHelper.sendRequestToServer(endPoint: 'add-stream-comment', requestData: {"stream_id": commentObj.streamId.toString(), "comment": commentObj.comment.toString()}, method: "post");
      commentId = json.decode(response.body)['comment_id'];
      commentObj.commentId = commentId;
      liveStreamingService.liveStreamComments.value.comments.insert(0, commentObj);
      liveStreamingService.liveStreamComments.refresh();
      loadMoreUpdateView.value = true;
      loadMoreUpdateView.refresh();
      liveStreamCommentsScrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    } catch (e) {
      print(e.toString());
      commentId = 0;
      Fluttertoast.showToast(msg: "There's some issue with the server".tr);
    }
  }

  Future<void> appendJoinedLiveStreamMessage({required data, bool exit = false}) async {
    print("appendJoinedLiveStreamMessage called ${DateTime.now().toString()}");
    CommentData commentObj = new CommentData();
    if (data != null) {
      data = jsonDecode(jsonEncode(data));
      int streamId = int.parse(data['stream_id'].toString());
      var memberData = jsonDecode(jsonEncode(data['member']));
      if (streamId.toString() == liveStreamingService.currentLiveStreamId.toString()) {
        commentObj.commentId = 0;
        commentObj.userId = memberData["user_id"] ?? 0;
        String comment = "";

        if (!exit) {
          if (memberData['user_id'].toString() != authService.currentUser.value.id.toString()) {
            comment += "${memberData["username"]} ${'has'.tr} ";
            liveStreamingService.liveStreamViewers.add(memberData['user_id']);
            liveStreamingService.liveStreamViewers.refresh();
          } else {
            comment += "${'You have'.tr} ";
          }
          comment += "${'joined the live.'.tr}";
        } else {
          if (memberData['user_id'].toString() != authService.currentUser.value.id.toString()) {
            comment += "${memberData["username"]} has ";
            liveStreamingService.liveStreamViewers.remove(memberData['user_id']);
            liveStreamingService.liveStreamViewers.refresh();
          } else {
            comment += "${'You have'.tr} ";
          }
          comment += "${'left the live'.tr}";
        }
        commentObj.comment = comment;
        commentObj.username = memberData["username"];
        commentObj.userDp = memberData["user_dp"];
        commentObj.time = CommonHelper.getYourCountryTime(DateFormat("yyyy-MM-dd HH:mm:ss").parse(DateTime.now().toString())).toString();
      }
      try {
        liveStreamingService.liveStreamComments.value.comments.insert(0, commentObj);
        liveStreamingService.liveStreamComments.refresh();
      } catch (e) {
        print("$e appendJoinedLiveStreamMessage");
      }
      await Future.delayed(
        const Duration(
          milliseconds: 100,
        ),
      );

      if (liveStreamCommentsScrollController.positions.isNotEmpty) {
        liveStreamCommentsScrollController.animateTo(
          // liveStreamCommentsScrollController.position.maxScrollExtent,
          0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<void> appendGiftLiveStreamMessage({required data, bool exit = false}) async {
    print("appendGiftLiveStreamMessage called ${DateTime.now().toString()}");
    CommentData commentObj = new CommentData();
    if (data != null) {
      data = jsonDecode(jsonEncode(data));
      print("receivedGiftNotify ${liveStreamingService.currentLiveStreamId} $data");
      var giftNotificationData = data['content'];
      var content = jsonDecode(jsonEncode(giftNotificationData));
      print("receivedGiftNotify ${liveStreamingService.currentLiveStreamId} $content");
      int streamId = int.parse(content['stream_id'].toString());

      if (streamId.toString() == liveStreamingService.currentLiveStreamId.toString()) {
        liveStreamingService.totalCurrentLiveStreamCoins.value += int.parse(content['coins'].toString());
        liveStreamingService.totalCurrentLiveStreamCoins.refresh();
        liveStreamingService.totalCurrentLiveStreamGifts.value += 1;
        liveStreamingService.totalCurrentLiveStreamGifts.refresh();
        print("liveStreamingService.totalCurrentLiveStreamCoins.value ${liveStreamingService.totalCurrentLiveStreamCoins.value}");
        commentObj.commentId = 0;
        commentObj.userId = content["user_id"] ?? 0;

        commentObj.comment = content['title'].toString().replaceAll("you ", "").replaceAll("your ", "").tr;

        commentObj.username = content["username"] ?? "";
        commentObj.userDp = content["user_dp"] ?? "";
        commentObj.type = "G";
        commentObj.commentGiftImage = liveStreamingService.notificationGiftIcon.value;
        commentObj.time = CommonHelper.getYourCountryTime(DateFormat("yyyy-MM-dd HH:mm:ss").parse(DateTime.now().toString())).toString();
        try {
          liveStreamingService.liveStreamComments.value.comments.insert(0, commentObj);
          liveStreamingService.liveStreamComments.refresh();
        } catch (e) {
          print("$e appendJoinedLiveStreamMessage");
        }
        await Future.delayed(
          const Duration(
            milliseconds: 100,
          ),
        );

        if (liveStreamCommentsScrollController.positions.isNotEmpty) {
          liveStreamCommentsScrollController.animateTo(
            // liveStreamCommentsScrollController.position.maxScrollExtent,
            0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
          );
        }
      }
    }
  }

  onSearchChanged(String query) {
    searchKeyword = "";
    showLoadMore = true;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchKeyword = query;
      fetchLiveUsers();
    });
  }

  Future<void> fetchLiveUsers() async {
    showLoader.value = true;
    showLoader.refresh();
    EasyLoading.show(status: '${'Loading'.tr}...');
    var response = await CommonHelper.sendRequestToServer(
        endPoint: 'get-live-users',
        requestData: {
          'page': page.toString(),
          'search': searchKeyword.toString(),
        },
        method: "post");
    var jsonData = json.decode(response.body);

    EasyLoading.dismiss();
    showLoader.value = false;
    showLoader.refresh();
    if (jsonData['status']) {
      if (page == 1) {
        liveStreamingService.liveUsersData.value = FollowingModel();
        liveStreamingService.liveUsersData.refresh();
        if (liveStreamingService.liveUsersData.value.users.isEmpty) {
          scrollController = ScrollController(debugLabel: DateTime.now().millisecondsSinceEpoch.toString());
        }
        liveStreamingService.liveUsersData.value = FollowingModel.fromJSON(response);
      } else {
        liveStreamingService.liveUsersData.value.users.addAll(FollowingModel.fromJSON(response).users);
      }
      liveStreamingService.liveUsersData.refresh();
      if (liveStreamingService.liveUsersData.value.users.length >= liveStreamingService.liveUsersData.value.total) {
        showLoadMore = false;
      }
      if (page == 1) {
        scrollListener = () {
          if (scrollController.hasClients) {
            if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
              if (liveStreamingService.liveUsersData.value.users.length != liveStreamingService.liveUsersData.value.total && showLoadMore) {
                page = page + 1;
                fetchLiveUsers();
              }
            }
          }
        };
        scrollController.addListener(scrollListener);
      }
    }
  }

  countdownToLaunch() {
    countTimer.value = 5;
    countTimer.refresh();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countTimer.value--;
      countTimer.refresh();
      if (countTimer.value == 0) {
        Get.offNamed("/live-agora");
        liveStreamingService.gotoLive.value = false;
        liveStreamingService.gotoLive.refresh();
        timer.cancel();
        countTimer.value = 5;
        countTimer.refresh();
      }
    });
  }
}
