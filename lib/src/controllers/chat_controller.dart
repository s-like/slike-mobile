import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as HTTP;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../core.dart';

class ChatController extends GetxController {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final msgController = TextEditingController();
  DateTime now = DateTime.now();
  ScrollController scrollController = new ScrollController();
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
  bool loadingChat = false;
  var emojiShowing = false.obs;

  String amPm = "";
  bool showChatLoader = true;
  int conversationPage = 1;
  int userId = 0;

  String message = "";
  VoidCallback listener = () {};
  double scrollPos = 0.0;
  OnlineUsersModel userObj = OnlineUsersModel();
  ScrollController chatScrollController = new ScrollController();
  var showFloatingScrollToBottom = false.obs;
  var min = 0.obs;
  var max = 0.obs;
  var newMessageCount = 0.obs;

  ChatController() {
    scrollController = new ScrollController();
  }

  @override
  void onInit() {
    scaffoldKey = new GlobalKey<ScaffoldState>();

    // TODO: implement onInit
    super.onInit();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  /*Future<void> chatHistoryListing(page) async {
    if (page > 1) {
      showLoader.value = true;
      showLoader.refresh();
    } else {
      showLoad = true;
    }
    try {
      HTTP.Response response = await CommonHelper.sendRequestToServer(endPoint: 'chat-history', requestData: {'page': page.toString()}, method: "post");
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          if (page > 1) {
            chatService.conversations.value.mess.insertAll(0, ChatModel.fromJSON(json.decode(response.body)['data']).chatMessages);
          } else {
            chatService.chatHistoryData.value = ChatModel.fromJSON(json.decode(response.body)['data']);
          }
          chatService.chatHistoryData.refresh();
          return chatService.chatData.value;
        } else {
          return ChatModel.fromJSON({});
        }
      } else {
        return ChatModel.fromJSON({});
      }
    } catch (e) {
      print(e.toString());
      return ChatModel.fromJSON({});
    }
    chatApi.chatHistoryListing(page).then((obj) {
      showLoad = false;
      if (page > 1) {
        showLoader.value = false;
        showLoader.refresh();
        loadMoreUpdateView.value = true;
        loadMoreUpdateView.refresh();
      }
      if (obj.totalChat == obj.chatMessages.length) {
        loadMoreConversations = false;
      }
      scrollController.addListener(() {
        if (scrollController.position.pixels == 0) {
          if (obj.chatMessages.length != obj.totalChat && loadMoreConversations) {
            page = page + 1;
            chatHistoryListing(page);
          }
        }
      });
    }).catchError((e) {
      showLoader.value = false;
      showLoader.refresh();
      print(e);
    });
  }*/

  Future<void> myConversations(page, {showApiLoader = true}) async {
    EasyLoading.show(status: "${'Loading'.tr}....");
    if (page > 1) {
      if (showApiLoader) {
        showLoad = true;
      }
    } else {
      if (showApiLoader) {
        showLoader.value = true;
        showLoader.refresh();
        showLoading = true;
      }
      scrollController = new ScrollController();
    }
    if (!showApiLoader) {
      showLoader.value = true;
      showLoader.refresh();
      showLoading = false;
    }
    try {
      var response = await CommonHelper.sendRequestToServer(endPoint: 'conversation/get', method: "post", requestData: {'page': page.toString(), 'search': searchKeyword});
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        print("jsonData ${response.body}");
        if (jsonData['status']) {
          if (page > 1) {
            chatService.conversations.value.data.addAll(ConversationsModel.fromJSON(json.decode(response.body)).data);
          } else {
            chatService.conversations.value = ConversationsModel.fromJSON(json.decode(response.body));
          }
          chatService.conversations.value.data.forEach((element) {
            if (chatService.onlineUserIds.contains(element.userId)) {
              element.online = true;
            }
          });
          chatService.conversations.refresh();
        }
      }
    } catch (e) {
      print("Get Conversations $e");
    }
    showLoad = false;
    showLoading = false;
    showLoader.value = false;
    showLoader.refresh();

    EasyLoading.dismiss();

    if (chatService.conversations.value.total == chatService.conversations.value.data.length) {
      loadMoreConversations = false;
    }
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (chatService.conversations.value.data.length != chatService.conversations.value.total && loadMoreConversations) {
          page = page + 1;
          myConversations(page);
        }
      }
    });
  }

  Future<void> getPeople(page) async {
    EasyLoading.show(status: "${'Loading'.tr}....");
    showLoader.value = true;
    showLoader.refresh();
    scrollController = new ScrollController();

    try {
      var response = await CommonHelper.sendRequestToServer(endPoint: 'chat-users', requestData: {'page': page.toString(), 'search': searchKeyword}, method: "post");
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          if (page > 1) {
            chatService.peopleData.value.users.addAll(FollowingModel.fromJSON(json.decode(response.body)['data']).users);
          } else {
            chatService.peopleData.value = FollowingModel.fromJSON(json.decode(response.body)['data']);
          }
          chatService.peopleData.value.users.forEach((element) {
            if (chatService.onlineUserIds.contains(element.id)) {
              element.online = true;
            }
          });
          chatService.peopleData.refresh();
        }
      }
    } catch (e) {
      print("getPeopleError $e");
    }

    showLoader.value = false;
    showLoader.refresh();
    EasyLoading.dismiss();
    if (chatService.peopleData.value.users.length == chatService.peopleData.value.totalRecords) {
      loadMoreConversations = false;
    }
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (chatService.peopleData.value.users.length != chatService.peopleData.value.totalRecords && loadMoreConversations) {
          page = page + 1;
          getPeople(page);
        }
      }
    });
  }

  Future createConversation(int userId) async {
    var requestData = {
      'user_id': userId.toString(),
    };
    HTTP.Response response = await CommonHelper.sendRequestToServer(endPoint: 'conversation/store', requestData: requestData, method: "post");
    if (response.statusCode == 200) {
      print("response.body $userId ${response.body}");
      var jsonData = jsonDecode(response.body);
      if (jsonData['status']) {
        chatService.currentConversation.value.id = jsonData['id'];
        chatService.currentConversation.value.userId = userId;
      } else {
        chatService.currentConversation.value.id = 0;
      }
    } else {
      var jsonData = jsonDecode(response.body);
      Fluttertoast.showToast(msg: jsonData['msg'].tr);
    }
  }

  void chatScrollToBottom() {
    if (chatScrollController.hasClients) {
      chatScrollController.animateTo(
        chatScrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 2000),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> loadChat() async {
    showLoader.value = true;
    showLoader.refresh();
    if (chatService.currentConversation.value.messages.length == 0) {
      chatScrollController = new ScrollController();
      if (chatService.currentConversation.value.id > 0) {
        Map<String, String> additionalHeaders = {
          "X-Socket-Id": authService.socketId.value,
        };

        CommonHelper.sendRequestToServer(endPoint: 'message/${chatService.currentConversation.value.id}/read', requestData: {"data_var": "data"}, additionalHeaders: additionalHeaders, method: "post");
        authService.pusher.subscribe(channelName: 'private-chat.${chatService.currentConversation.value.id}', onEvent: onChatEvent);
      }
    }
    loadingChat = true;
    HTTP.Response response = await CommonHelper.sendRequestToServer(
      endPoint: 'message/${chatService.currentConversation.value.id}/get-messages',
      requestData: {'skip': chatService.currentConversation.value.messages.length.toString(), 'new': "true"},
      method: "post",
    );
    loadingChat = false;
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status']) {
        print("json.decode(response.body)['data'] ${json.decode(response.body)}");
        var data = ChatMessage.parseData(json.decode(response.body)['data']);
        chatService.currentConversation.value.totalMessages = json.decode(response.body)['total'];
        if (chatService.currentConversation.value.messages.isEmpty) {
          if (chatService.currentConversation.value.messages.isEmpty) {
            chatService.currentConversation.value.messages = data;
          } else {
            chatService.currentConversation.value.messages.addAll(data);
          }
          chatService.currentConversation.refresh();
          try {
            showLoader.value = false;
            showLoader.refresh();
            if (chatService.currentConversation.value.totalMessages == chatService.currentConversation.value.totalMessages.length) {
              showChatLoader = false;
            }
            Timer(
                Duration(
                  milliseconds: 1000,
                ), () {
              if (chatService.currentConversation.value.messages.length <= 20) {
                chatScrollToBottom();
                listener = () async {
                  if (chatScrollController.positions.isNotEmpty && chatScrollController.position.pixels == 0) {
                    if (showChatLoader && loadingChat == false) {
                      loadChat();
                    }
                  }
                };
                chatScrollController.addListener(listener);
                if (chatScrollController.positions.isNotEmpty) {
                  scrollPos = chatScrollController.position.maxScrollExtent;
                }
              }
            });
          } catch (e) {
            showLoader.value = false;
            showLoader.refresh();
            print("catchedError");
            print(e);
          }
        }
      }
    }
  }

  appendMsg({data, timestamp}) async {
    print("appendMsg $timestamp");
    DateTime timeNow = DateTime.now();
    var formatterDate = new DateFormat('dd MMM yyyy');
    var formatterDateTime = new DateFormat('yyyy-MM-dd HH:mm:ss');
    if (timeNow.hour > 11) {
      amPm = 'PM';
    } else {
      amPm = 'AM';
    }
    ChatMessage chatMessageObj = new ChatMessage();
    if (data != null) {
      data = jsonDecode(jsonEncode(data));
      var content = data['content'];
      chatMessageObj.convId = content["conversation_id"];
      chatMessageObj.userId = content["from_id"] ?? 0;
      chatMessageObj.msg = content["msg"];
      chatMessageObj.id = content["message_id"];
      chatMessageObj.isRead = true;
      chatMessageObj.sentDate = formatterDate.format(timeNow);
      chatMessageObj.sentDatetime = formatterDateTime.format(timeNow);
      chatMessageObj.sentOn = (timeNow.hour > 12)
          ? '${(timeNow.hour - 12).toString().length == 1 ? "0" + (timeNow.hour - 12).toString() : timeNow.hour}:${timeNow.minute.toString().length == 1 ? "0" + timeNow.minute.toString() : timeNow.minute} $amPm'
          : '${timeNow.hour.toString().length == 1 ? "0" + timeNow.hour.toString() : timeNow.hour.toString()}:${timeNow.minute.toString().length == 1 ? "0" + timeNow.minute.toString() : timeNow.minute.toString()} $amPm';
      chatMessageObj.timestamp = timestamp == null ? 0 : timestamp;
      if (content["msg"] != null && content["msg"].trim() != "") {
        if (content["conversation_id"] == chatService.currentConversation.value.id) {
          chatService.currentConversation.value.messages.insert(0, chatMessageObj);
          chatService.currentConversation.refresh();
          chatService.conversations.value.data.elementAt(0).messages.insert(0, chatMessageObj);
          chatService.conversations.refresh();
        } else {
          try {
            Conversation latestChat = chatService.conversations.value.data.removeAt(chatService.conversations.value.data.indexWhere((element) => element.id == content["conversation_id"]));
            latestChat.message = content["msg"];
            latestChat.time = chatMessageObj.sentDatetime;
            chatService.conversations.value.data.insert(0, latestChat);
            chatService.conversations.refresh();
          } catch (e) {
            HTTP.Response response = await CommonHelper.sendRequestToServer(endPoint: "conversation/get", requestData: {'page': page.toString(), 'search': ""}, method: 'post');
            if (response.statusCode == 200) {
              var jsonData = json.decode(response.body);
              if (jsonData['status']) {
                if (page > 1) {
                  chatService.conversations.value.data.addAll(ConversationsModel.fromJSON(json.decode(response.body)).data);
                } else {
                  chatService.conversations.value = ConversationsModel.fromJSON(json.decode(response.body));
                }
                chatService.conversations.value.data.forEach((element) {
                  if (chatService.onlineUserIds.contains(element.userId)) {
                    element.online = true;
                  }
                });
                chatService.conversations.refresh();
              }
            } else {
              Fluttertoast.showToast(msg: "Error fetching data".tr);
            }
          }
          Map<String, String> additionalHeaders = {
            "X-Socket-Id": authService.socketId.value,
          };
          CommonHelper.sendRequestToServer(endPoint: 'message/${chatService.currentConversation.value.id}/read', requestData: {"data_var": "data"}, additionalHeaders: additionalHeaders);
        }
      }
    } else {
      msgController.text = '';
      chatMessageObj.convId = chatService.currentConversation.value.id;
      chatMessageObj.userId = authService.currentUser.value.id;
      chatMessageObj.msg = message;
      chatMessageObj.isRead = true;
      chatMessageObj.sentDate = formatterDate.format(timeNow);
      chatMessageObj.sentDatetime = formatterDateTime.format(timeNow);
      chatMessageObj.sentOn = (timeNow.hour > 12)
          ? '${(timeNow.hour - 12).toString().length == 1 ? "0" + (timeNow.hour - 12).toString() : timeNow.hour}:${timeNow.minute.toString().length == 1 ? "0" + timeNow.minute.toString() : timeNow.minute} $amPm'
          : '${timeNow.hour.toString().length == 1 ? "0" + timeNow.hour.toString() : timeNow.hour.toString()}:${timeNow.minute.toString().length == 1 ? "0" + timeNow.minute.toString() : timeNow.minute.toString()} $amPm';
      chatMessageObj.timestamp = timestamp;
      if (message.trim() != "") {
        message = "";
        try {
          chatService.currentConversation.value.messages.insert(0, chatMessageObj);
          chatService.currentConversation.refresh();
          Conversation latestChat = chatService.conversations.value.data.removeAt(chatService.currentConversation.value.messages.indexWhere((element) => element.convId == chatMessageObj.convId));
          latestChat.message = chatMessageObj.msg;
          latestChat.time = chatMessageObj.sentDatetime;
          chatService.conversations.value.data.insert(0, latestChat);
          chatService.conversations.refresh();
        } catch (e) {
          print("$e like");
        }
      }
    }
    await Future.delayed(
      Duration(
        milliseconds: 100,
      ),
    );
    if (chatScrollController.positions.isNotEmpty)
      chatScrollController.animateTo(
        chatScrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
  }

  Future<void> sendMsg() async {
    int timeNow = DateTime.now().millisecondsSinceEpoch;
    print("authService.socketId.value ${authService.socketId.value} ${Get.find<AuthService>().currentUser.value.accessToken}");

    if (message.isNotEmpty) {
      String tempMsg = message;
      appendMsg(timestamp: timeNow);
      Map<String, String> additionalHeaders = {
        "X-Socket-Id": authService.socketId.value,
      };
      print("sendMsg");
      print({
        'msg': tempMsg,
        'to_user': chatService.currentConversation.value.userId,
        "timestamp": timeNow.toString(),
      });
      HTTP.Response response = await CommonHelper.sendRequestToServer(
        endPoint: 'message/${chatService.currentConversation.value.id}/store',
        requestData: {
          'msg': tempMsg,
          'to_user': chatService.currentConversation.value.userId,
          "timestamp": timeNow.toString(),
        },
        method: "post",
        additionalHeaders: additionalHeaders,
      );

      var jsonData = jsonDecode(response.body);

      if (!jsonData['status']) {
        Fluttertoast.showToast(msg: jsonData['msg'].tr);
        // ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text('${}')));
        chatService.currentConversation.value.messages.removeWhere((element) => element.timestamp.toString() == jsonData['timestamp'].toString());
        chatService.currentConversation.refresh();
      }
    }
  }

  Future<void> typing(type) async {
    Map<String, String> additionalHeaders = {
      "X-Socket-Id": authService.socketId.value,
    };

    await CommonHelper.sendRequestToServer(
        endPoint: 'message/${chatService.currentConversation.value.id}/typing',
        requestData: {
          'typing': type.toString(),
        },
        method: "post",
        additionalHeaders: additionalHeaders);
  }

  onEmojiSelected(Emoji emoji) {
    msgController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(TextPosition(offset: msgController.text.length));
    message = msgController.text;
  }

  onBackspacePressed() {
    msgController
      ..text = msgController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(TextPosition(offset: msgController.text.length));
    message = msgController.text;
  }

/*
  joinSocketUser() async {
    LiveStreamingService liveStreamingService = Get.find();

    print("Enter in joinSocketUser");
    echoObj.join('chat').here((PusherEvent? users) {
      print("Enter in Here ${users!.data}");
      authService.socketId.value = echoObj.socketId()!;
      print("Socket Id ${echoObj.socketId()}");
      authService.socketId.refresh();
      List<int> ids = [];
      if (users.data != null) {
        ids = CommonHelper.parsePusherEventData(users.data);
        chatService.onlineUserIds.value = ids;
        chatService.onlineUserIds.refresh();
        chatApi.onlineUsersList(ids.join(','));
      }
      if (chatService.onlineUserIds.value.length > 0 && chatService.conversations.value.data.length > 0) {
        for (int i = 0; i < chatService.conversations.value.data.length; i++) {
          for (int j = 0; j < chatService.onlineUserIds.value.length; j++) {
            if (chatService.onlineUserIds.value.elementAt(j).toString() == chatService.conversations.value.data.elementAt(i).userId.toString()) {
              chatService.conversations.value.data.elementAt(i).online = true;
              chatService.conversations.refresh();
            }
          }
        }
      }
    }).joining((PusherEvent? user) {
      print("Enter in Joining ${user!.userId}");
      if (user.userId != null && chatService.conversations.value.data.length > 0) {
        for (int i = 0; i < chatService.conversations.value.data.length; i++) {
          if (user.userId == chatService.conversations.value.data.elementAt(i).userId.toString()) {
            chatService.conversations.value.data.elementAt(i).online = true;
            chatService.conversations.refresh();
          }
        }
        if (!chatService.onlineUserIds.value.contains(int.parse(user.userId!))) {
          chatService.onlineUserIds.value.add(int.parse(user.userId!));
          chatService.onlineUserIds.refresh();
          chatApi.onlineUsersList(user.userId!);
        }
      }
    }).leaving((PusherEvent? user) {
      print("Enter in Leaving ${user!.userId}");
      if (user != null && user.userId != null && chatService.conversations.value.data.length > 0) {
        for (int i = 0; i < chatService.conversations.value.data.length; i++) {
          if (user.userId == chatService.conversations.value.data.elementAt(i).userId.toString()) {
            chatService.conversations.value.data.elementAt(i).online = false;
            chatService.conversations.refresh();
          }
        }
        if (chatService.onlineUserIds.value.contains(int.parse(user.userId!))) {
          chatService.onlineUserIds.value.remove(int.parse(user.userId!));
          chatService.onlineUserIds.refresh();
          chatService.onlineUsers.value.removeWhere((element) => element.id == int.parse(user.userId!));
          chatService.onlineUsers.refresh();
        }
      }
      print("Stream User Leaving ${user!.userId} $user");
      print(liveStreamingService.liveStreamViewers.value);
      int leftUserIndex = liveStreamingService.liveStreamViewers.value.indexWhere((element) => element.toString() == user.userId.toString());
      if (leftUserIndex > -1) {
        liveStreamingService.liveStreamViewers.value.removeAt(leftUserIndex);
        liveStreamingService.liveStreamViewers.refresh();
      }
    }).listen('PresenceEvent', (e) {
      print(e);
    });
  }
*/

  connectPusher() async {
    // if (!CommonHelper.returnFromApiIfInternetIsOff()) {
    //   return;
    // }
    if (kDebugMode) print('connectPusherEcho ${Get.find<AuthService>().currentUser.value.accessToken}');
    if (kDebugMode) print('$baseUrl/api/broadcasting/auth');
    /*PusherOptions options = PusherOptions(
      // encrypted: true,
      // host: "${GlobalConfiguration().get('host')}",
      cluster: "${GlobalConfiguration().get('pusher_app_cluster')}",
      // wsPort: 6001,
      // wssPort: 6001,
      auth: PusherAuth(
        '$baseUrl/api/broadcasting/auth',
        headers: {
          'Authorization': 'Bearer ${Get.find<AuthService>().currentUser.value.accessToken}',
        },
      ),
    );
    // echo?.disconnect();
    PusherClient pusherClient = PusherClient(
      "${GlobalConfiguration().get('pusher_key')}",
      options,
      autoConnect: true,
      enableLogging: true,
    );
    Echo _echo = Echo(
      broadcaster: EchoBroadcasterType.Pusher,
      client: pusherClient,
      options: {
        'auth': {
          'headers': {
            'Authorization': 'Bearer ${Get.find<AuthService>().currentUser.value.accessToken}',
          },
        },
        'authEndpoint': '$baseUrl/api/broadcasting/auth',
      },
    );
    // Accessing pusher instance
    _echo.connector.pusher.onConnectionStateChange((state) {
      if (kDebugMode) print(33333333333333.toString());
      if (kDebugMode) print(state?.currentState.toString());
      if ("CONNECTED" == state?.currentState.toString()) {
        if (kDebugMode) print("Entered condition");
        authService.echo = _echo;
        connectSocketClient();
      }
      // Get.find<AuthService>().currentUser.value.socketId = _echo!.socketId();
    });*/

    // _echo.join('chat').here((users) {
    //   if (kDebugMode) print(users);
    // }).joining((user) {
    //   if (kDebugMode) print(user);
    // }).leaving((user) {
    //   if (kDebugMode) print(user);
    // }).listen('PresenceEvent44444', (e) {
    //   if (kDebugMode) print(e);
    // });
    print("pusherKey:::: $pusherKey");
    try {
      await authService.pusher.init(
        apiKey: pusherKey,
        cluster: pusherAppCluster,
        // authEndpoint: '$baseUrl/api/broadcasting/auth',
        authParams: {
          'headers': {
            'Authorization': 'Bearer ${Get.find<AuthService>().currentUser.value.accessToken}',
          }
        },
        onConnectionStateChange: onConnectionStateChange,
        onError: onError,
        onSubscriptionSucceeded: onSubscriptionSucceeded,
        // onEvent: onEvent,
        onSubscriptionError: onSubscriptionError,
        onDecryptionFailure: onDecryptionFailure,
        onMemberAdded: onMemberAdded,
        onMemberRemoved: onMemberRemoved,
        onAuthorizer: onAuthorizer,
      );
      await authService.pusher.subscribe(channelName: "chat");
      await authService.pusher.connect();
      if (authService.socketId.value == "") {
        var socketId = await authService.pusher.getSocketId();
        print("authService.socketId.value ${authService.socketId.value}");
        authService.socketId.value = socketId;
      }
    } catch (e) {
      print("Already Subscribed $e");
    }
  }

  dynamic onAuthorizer(String channelName, String socketId, dynamic options) async {
    if (!CommonHelper.returnFromApiIfInternetIsOff()) {
      return;
    }
    print("onAuthorizerSocket $socketId");
    var authUrl = '${baseUrl}api/broadcasting/auth';
    authService.socketId.value = socketId;
    authService.socketId.refresh();
    var result = await HTTP.post(
      Uri.parse(authUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${Get.find<AuthService>().currentUser.value.accessToken}',
      },
      body: 'socket_id=$socketId&channel_name=$channelName',
    );

    log("onAuthorizerSocket result.body");
    log(result.body);

    return jsonDecode(result.body);
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    log("Connection: $currentState");
  }

  void onError(String message, int? code, dynamic e) {
    log("onError: $message code: $code exception: $e");
  }

  void onEvent(PusherEvent event) {
    log("onEvent: $event");
  }

  void onChatEvent(event) {
    if (!CommonHelper.returnFromApiIfInternetIsOff()) {
      return;
    }
    log("onEvent: $event");
    if (event.eventName == "App\\Events\\NewChatMsg") {
      print("dsfsdfsdfsdfsdf");
      var data = jsonDecode(event.data!);
      appendMsg(data: data);
    }
    if (event.eventName == "App\\Events\\UserTyping") {
      print("dsfsdfsdfsdfsdf");
      var data = jsonDecode(event.data!);
      if (kDebugMode) print("Time: ${data['content']['time']} $data");
      if (data['typing'] == "true") {
        chatService.showTyping.value = true;
        chatService.showTyping.refresh();
      } else {
        chatService.showTyping.value = false;
        chatService.showTyping.refresh();
      }
    }
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    log("onSubscriptionSucceeded: $channelName data: $data");
    final me = authService.pusher.getChannel(channelName)?.me;
    log("Me: $me");
  }

  void onSubscriptionError(String message, dynamic e) {
    log("onSubscriptionError: $message Exception: $e");
  }

  void onDecryptionFailure(String event, String reason) {
    log("onDecryptionFailure: $event reason: $reason");
  }

  void onMemberAdded(String channelName, PusherMember member) {
    log("onMemberAdded: $channelName user: $member");
  }

  void onMemberRemoved(String channelName, PusherMember member) {
    log("onMemberRemoved: $channelName user: $member");
  }

/*  dynamic onAuthorizer(String channelName, String socketId, dynamic options) {
    return {"auth": "foo:bar", "channel_data": '{"user_id": 1}', "shared_secret": "foobar"};
  }*/

  void onTriggerEventPressed() async {
    authService.pusher.trigger(
      PusherEvent(
        channelName: "chat",
        eventName: "UserTyping",
        data: {},
      ),
    );
  }

  List<ChatMessage> parseChatMessages(response) {
    if (kDebugMode) print(response);
    // try {
    List list = response;
    if (list.isNotEmpty) {
      List<ChatMessage> attrList = list.map((data) => ChatMessage.fromJSON(data)).toList();
      return attrList;
    } else {
      return [];
    }
  }

  Future<void> getChatSettings() async {
    var rs = await CommonHelper.sendRequestToServer(endPoint: 'get-chat-with', method: "post", requestData: {"data_var": "data"});
    if (rs.statusCode == 200) {
      var jsonData = json.decode(rs.body);
      print("jsonData ${rs.body}");
      if (jsonData['status'] && jsonData['chatWith'] != null) {
        chatService.chatSettings.value = jsonData['chatWith'];
        chatService.chatSettings.refresh();
      }
    }
  }

  Future<void> updateChatSetting() async {
    var rs = await CommonHelper.sendRequestToServer(
        endPoint: 'get-chat-with',
        requestData: {
          "chat_with": chatService.chatSettings.value,
        },
        method: "post");

    if (rs.statusCode == 200) {
      Fluttertoast.showToast(msg: "Chat setting updated!".tr);
      // ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text('')));
    }
  }

  fetchChat() async {
    print("chatService.conversationUser.value.convId");
    print(chatService.conversationUser.value.convId);
    chatService.currentConversation.value.id = chatService.conversationUser.value.convId;
    if (chatService.currentConversation.value.id == 0) {
      await createConversation(chatService.conversationUser.value.id);
    }
    loadChat();
  }
}
