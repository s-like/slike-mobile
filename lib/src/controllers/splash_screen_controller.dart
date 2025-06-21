import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:custom_platform_device_id/platform_device_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as HTTP;
import 'package:uni_links5/uni_links.dart';

import '../core.dart';

class SplashScreenController extends GetxController {
  ValueNotifier<bool> processing = new ValueNotifier(true);

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  late StreamSubscription _sub;
  // double percent = 0.0;
  late Timer timer;
  var redirection = true.obs;
  bool isInternetOn = true;
  // bool firstTimeLoad = false;
  final Connectivity _connectivity = Connectivity();
  static const platform = const MethodChannel('com.flutter.epic/epic');
  MainService mainService = Get.find();
  var loadingPercent = 0.0.obs;
  ChatService chatService = Get.find();
  ChatController chatController = Get.find();
  DashboardService dashboardService = Get.find();
  DashboardController dashboardController = Get.find();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  
  // Flag to prevent multiple getVideos calls during splash
  bool _isInitializing = false;
  bool videosLoaded = false;

  @override
  void onInit() async {
    // initializing();
    super.onInit();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  onClose() {
    _connectivitySubscription.cancel();
    _isInitializing = false;
    videosLoaded = false;
  }

  // Method to reset initialization flags (useful for testing or re-initialization)
  void resetInitializationFlags() {
    _isInitializing = false;
    videosLoaded = false;
  }

  pushNotifications() {
    print("pushNotifications");
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      print("pushNotifications3333 $message");
      if (message != null) {
        notificationAction(message.data);
        redirection.value = false;
        redirection.refresh();
      }
    });
    print("pushNotifications2");
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      print("pushNotifications3");
      RemoteNotification? notification = message!.notification!;
      print("djsadagdgsdgd ${message.data}");
      //AndroidNotification android = message.notification?.android;
      if (notification.body != null) {
        String type = message.data['type'];
        int id = int.parse(message.data['id']);
        if (type == "chat") {
          chatService.unreadMessageCount.value++;
          chatService.unreadMessageCount.refresh();
          if (id != chatService.currentConversation.value.id) {
            ChatController chatController = Get.find();
            chatController.myConversations(1);
            ScaffoldMessenger.of(Get.context!).showSnackBar(
              SnackBar(
                backgroundColor: Get.theme.colorScheme.primary,
                action: SnackBarAction(
                  label: 'Open'.tr,
                  textColor: Get.theme.primaryColor,
                  onPressed: () {
                    notificationAction(message.data);
                  },
                ),
                content: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    notification.title! + " sent a message",
                    style: TextStyle(color: Get.theme.primaryColor, fontSize: 16),
                  ),
                ),
                duration: Duration(seconds: 5),
                width: Get.width * 0.90,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0, // Inner padding for SnackBar content.
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              backgroundColor: mainService.setting.value.buttonColor,
              action: SnackBarAction(
                label: 'Open'.tr,
                textColor: Get.theme.indicatorColor,
                onPressed: () {
                  notificationAction(message.data);
                },
              ),
              content: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  notification.title!,
                  style: TextStyle(color: Get.theme.indicatorColor, fontSize: 16),
                ),
              ),
              duration: Duration(seconds: 5),
              width: Get.width * 0.90,
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0, // Inner padding for SnackBar content.
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          );
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      String type = message.data['type'];
      int id = int.parse(message.data['id']);
      if (type == "chat") {
        if (id != chatService.currentConversation.value.id) {
          chatController.myConversations(1);
          notificationAction(message.data);
        }
      } else {
        notificationAction(message.data);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('B new onMessageOpenedApp event was published!');
      String type = message.data['type'];
      int id = int.parse(message.data['id']);
      print("ConvIDS ${chatService.currentConversation.value.id}  ------ ${message.data}");
      if (type == "chat") {
        if (id != chatService.currentConversation.value.id) {
          chatController.myConversations(1);
          notificationAction(message.data);
        }
      } else {
        print("ELSEEEE");
        // notificationAction(message.data);
      }
    });

    FirebaseMessaging.onBackgroundMessage((message) {
      print('C new onMessageOpenedApp event was published!');
      String type = message.data['type'];
      int id = int.parse(message.data['id']);
      if (type == "chat") {
        if (id != chatService.currentConversation.value.id) {
          chatController.myConversations(1);
          return notificationAction(message.data);
        } else {
          NotificationController notificationController = Get.find();
          return notificationController.notificationsList(1);
        }
      } else {
        return notificationAction(message.data);
      }
    });
  }

  notificationAction(message) async {
    String type = message['type'];
    int id = int.parse(message['id']);
    if (type == "like" || type == "comment" || type == "video") {
      mainService.userVideoObj.value.videoId = id;
      mainService.userVideoObj.refresh();
      await dashboardController.getVideos();
      Get.offNamed('/home');
      if (type == "comment") {
        Timer(Duration(seconds: 2), () {
          dashboardController.hideBottomBar.value = true;
          dashboardController.hideBottomBar.refresh();
          dashboardController.videoIndex = 0;
          dashboardController.showBannerAd.value = false;
          dashboardController.showBannerAd.refresh();
          dashboardController.pc.open();
          Video videoObj = new Video();
          videoObj.videoId = id;
          dashboardController.getComments(videoObj).whenComplete(() {
            dashboardService.commentsLoaded.value = true;
            dashboardService.commentsLoaded.refresh();
          });
        });
      }
    } else if (type == "follow") {
      UserController userController = Get.find();
      userController.openUserProfile(id);
    } else if (type == "chat") {
      int userId = int.parse(message['user_id']);
      String personName = message['person_name'];
      String userDp = message['user_dp'];
      User _onlineUsersModel = new User();
      _onlineUsersModel.convId = id;
      _onlineUsersModel.id = userId;
      _onlineUsersModel.name = personName;
      _onlineUsersModel.userDP = userDp;
      chatService.conversationUser.value = _onlineUsersModel;
    }
  }

  initializing() async {
    if (_isInitializing) return; // Prevent multiple calls
    
    try {
      await initConnectivity();
      
      // Start loading timer with faster updates for video splash
      timer = Timer.periodic(Duration(milliseconds: 100), (_) {
        print('Percent Update');
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          loadingPercent.value += 2; // Faster progress for video
          if (loadingPercent.value >= 100) {
            timer.cancel();
            loadingPercent.value = 100;
          }
          loadingPercent.refresh();
        });
      });
      
      // Load data if internet is available
      if (isInternetOn) {
        await loadData();
      } else {
        // If no internet, still complete the loading
        await Future.delayed(Duration(seconds: 2));
        loadingPercent.value = 100;
        loadingPercent.refresh();
        timer.cancel();
        
        // Load videos only once
        if (!videosLoaded) {
          try {
            await dashboardController.getVideos(showErrorMessages: false);
            videosLoaded = true;
          } catch (e) {
            print('Error loading videos during splash: $e');
            // Don't show error toast during splash screen
          }
        }
        
        Get.offNamed('/home');
      }
    } catch (e) {
      print('Error in splash screen initialization: $e');
      // Ensure we still navigate to home even if there's an error
      loadingPercent.value = 100;
      loadingPercent.refresh();
      if (timer.isActive) {
        timer.cancel();
      }
      await Future.delayed(Duration(milliseconds: 1));
      
      // Load videos only once
      if (!videosLoaded) {
        try {
          await dashboardController.getVideos(showErrorMessages: false);
          videosLoaded = true;
        } catch (e) {
          print('Error loading videos during splash: $e');
          // Don't show error toast during splash screen
        }
      }
      
      Get.offNamed('/home');
    }
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } on PlatformException catch (e) {
      print(e.toString());
      // Default to internet available if we can't check
      isInternetOn = true;
    }
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    print("_updateConnectionStatus ");

    if (result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.mobile)) {
      print("Internet (wifi)");
      isInternetOn = true;
      if (!mainService.firstTimeLoad.value) {
        if (mainService.isOnNoInternetPage.value) {
          Navigator.maybePop(Get.context!);
        }
      } else {
        print("Internet (wifi) but first load");
        await loadData();
      }
    } else {
      mainService.isOnNoInternetPage.value = true;
      mainService.isOnNoInternetPage.refresh();
      Get.toNamed('/no-internet');
      isInternetOn = false;
      print("Internet (closed)");
    }
  }

  printHashKeyOnConsoleLog() async {
    try {
      await platform.invokeMethod("printHashKeyOnConsoleLog");
    } catch (e) {
      print(e);
    }
  }

  Future<void> initUniLinks() async {
    _sub = uriLinkStream.listen((Uri? uri) async {
      var id;
      if (Platform.isIOS) {
        var urlList = uri.toString().split("/");
        String encodedId = urlList.last;
        Codec<String, String> stringToBase64 = utf8.fuse(base64);
        id = stringToBase64.decode(encodedId);
      } else {
        id = uri!.queryParameters['id'];
      }
      if (id != "" && id != null && redirection.value == true) {
        mainService.userVideoObj.value.videoId = int.parse(id);
        mainService.userVideoObj.refresh();
        try {
          await dashboardController.getVideos(showErrorMessages: false);
        } catch (e) {
          print('Error loading videos in uniLinks: $e');
        }
        Get.offNamed('/home', arguments: 0);
      }
    }, onError: (err) {});
    if (!_sub.isPaused && redirection.value == true) {
      try {
        final initialLink = await getInitialLink();
        if (initialLink != null) {
          var id;
          if (Platform.isIOS) {
            var urlList = Uri.parse(initialLink).toString().split("/");
            String encodedId = urlList.last;
            Codec<String, String> stringToBase64 = utf8.fuse(base64);
            id = stringToBase64.decode(encodedId);
          } else {
            id = Uri.parse(initialLink).queryParameters['id'];
          }
          if (id != "" && id != null) {
            mainService.userVideoObj.value.videoId = int.parse(id);
            mainService.userVideoObj.refresh();

            try {
              await dashboardController.getVideos(showErrorMessages: false);
            } catch (e) {
              print('Error loading videos in uniLinks: $e');
            }
            Get.offNamed('/home');
          } else {
            try {
              await dashboardController.getVideos(showErrorMessages: false);
            } catch (e) {
              print('Error loading videos in uniLinks: $e');
            }
            Get.offNamed('/home');
          }
        } else {
          dashboardService.showFollowingPage.value = false;
          dashboardService.showFollowingPage.refresh();
          try {
            await dashboardController.getVideos(showErrorMessages: false);
          } catch (e) {
            print('Error loading videos in uniLinks: $e');
          }
          Get.offNamed('/home');
        }
      } on PlatformException {
        print("Error.....");
      }
    }
  }

  Future<void> addGuestUserForFCMToken() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? platformId = "";
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.model} ${androidInfo.serialNumber}');
      dashboardService.androidDeviceInfo = androidInfo;
      platformId = androidInfo.serialNumber;
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ios ${iosInfo.utsname.machine} ${iosInfo.model} ${iosInfo.data} ${Get.mediaQuery.viewPadding} ${iosInfo.utsname}');
      dashboardService.iosDeviceInfo = iosInfo;
      platformId = iosInfo.identifierForVendor;
    }
    FirebaseMessaging.instance.getToken().then((value) {
      if (value != "" && value != null) {
        addGuestUser(value, platformId);
      }
    });
  }

  addGuestUser(token, platformId) async {
    try {
      await CommonHelper.sendRequestToServer(endPoint: 'add-guest-user', method: "post", requestData: {"fcm_token": token.toString(), "platform_id": platformId.toString()});
    } catch (e) {
      print("ADD GUEST USER" + e.toString());
    }
  }

  Future<void> loadData() async {
    if (_isInitializing) return; // Prevent multiple calls
    _isInitializing = true;
    
    print("mainService.setting.value.fetched ${mainService.setting.value.fetched}");
    if (!mainService.setting.value.fetched) {
      UserController userController = Get.find();

      mainService.setting.value.fetched = true;
      // printHashKeyOnConsoleLog();
      await initSettings();
      // dashboardController.getGifts();

      await userController.userUniqueId();
      await userController.checkIfAuthenticated();
      // WalletController walletController = Get.find();
      // walletController.fetchMyWallet(showLoader: false);
      AuthService authService = Get.find();
      if (authService.currentUser.value.id == 0 || authService.currentUser.value.accessToken == '') {
        addGuestUserForFCMToken();
      } else {
        userController.updateFCMTokenForUser();
      }

      // getDeviceInfo(); // if (mounted) {
      pushNotifications();
      initUniLinks();
      unawaited(dashboardController.preCacheVideoThumbs());
      
      // Complete loading
      loadingPercent.value = 100;
      loadingPercent.refresh();
      if (timer.isActive) {
        timer.cancel();
      }

      // Wait a bit for video to complete if needed
      await Future.delayed(Duration(milliseconds: 300));
      
      // Load videos only once
      if (!videosLoaded) {
        try {
          await dashboardController.getVideos(showErrorMessages: false);
          videosLoaded = true;
        } catch (e) {
          print('Error loading videos during splash: $e');
          // Don't show error toast during splash screen
        }
      }
      
      Get.offNamed('/home');
    } else {
      // If settings are already fetched, just navigate to home
      loadingPercent.value = 100;
      loadingPercent.refresh();
      if (timer.isActive) {
        timer.cancel();
      }
      await Future.delayed(Duration(milliseconds: 300));
      
      // Load videos only once
      if (!videosLoaded) {
        try {
          await dashboardController.getVideos(showErrorMessages: false);
          videosLoaded = true;
        } catch (e) {
          print('Error loading videos during splash: $e');
          // Don't show error toast during splash screen
        }
      }
      
      Get.offNamed('/home');
    }
  }

  Future<Setting> initSettings() async {
    Setting _setting;
    try {
      HTTP.Response response = await CommonHelper.sendRequestToServer(endPoint: 'app-configration', requestData: {"data_var": "data"});

      if (response.statusCode == 200) {
        if (json.decode(response.body)['data'] != null) {
          _setting = Setting.fromJSON(json.decode(response.body)['data']);
          mainService.setting.value = _setting;
          mainService.setting.refresh();
          Get.clearTranslations();
          print("mainService.setting.value.translations ${mainService.setting.value.translations['ru']}");
          Get.addTranslations(mainService.setting.value.translations);
        }
      } else {
        print("error in query ");
      }
    } catch (e) {
      print("error in query $e");
      return Setting.fromJSON({});
    }
    return mainService.setting.value;
  }

  Future<void> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.model} ${androidInfo.serialNumber}');
      dashboardService.androidDeviceInfo = androidInfo;
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ios ${iosInfo.utsname.machine} ${iosInfo.model} ${iosInfo.data} ${Get.mediaQuery.viewPadding} ${iosInfo.utsname}');
      dashboardService.iosDeviceInfo = iosInfo;
    }
  }
}
