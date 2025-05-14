import 'package:get/get.dart';

import '../core.dart';

class LiveStreamingService extends GetxService {
  var liveUsersData = FollowingModel().obs;
  var liveStreamComments = CommentModel().obs;
  var liveStreamViewers = [].obs;
  var gotoLive = true.obs;
  var isStreamSubscribe = true.obs;
  int currentLiveStreamId = 0;
  String currentLiveStreamName = "";
  var liveComment = "".obs;
  String id = "";
  bool userScreen = false;
  bool isPlay = true;

  var isAlreadyBroadcasting = false.obs;
  var currentLiveStreamOwnerId = "".obs;
  String agoraToken = "";

  var totalCurrentLiveStreamCoins = 0.obs;
  var totalCurrentLiveStreamGifts = 0.obs;
  var notificationGiftIcon = "https://filmsdream.nyc3.cdn.digitaloceanspaces.com/gifts/apagpmjouMWBg5poVqe0Cby5kB56YOi0k3AvNiK3.gif".obs;
  var notificationMessage = "User sent you a gift".obs;

  @override
  void onInit() async {
    super.onInit();
  }
}
