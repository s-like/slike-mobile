import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../core.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  String dataShared = "No Data";
  SplashScreenController splashScreenController = Get.find();
  MainService mainService = Get.find();
  late BuildContext context;
  DateTime currentBackPressTime = DateTime.now();
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  bool _videoCompleted = false;
  bool _appInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    // Start initialization after a short delay
    Timer(Duration(milliseconds: 500), () {
      _initializeApp();
    });
    
    // Fallback timer to ensure app doesn't get stuck
    Timer(Duration(seconds: 10), () {
      if (!_appInitialized || !_videoCompleted) {
        print('Fallback timer triggered - navigating to home');
        _navigateToHome();
      }
    });
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset('assets/animations/splashvideo.mp4');
      await _videoController.initialize();
      _videoController.setLooping(false);
      _videoController.play();
      setState(() {
        _isVideoInitialized = true;
      });
      
      // Listen for video completion
      _videoController.addListener(() {
        if (_videoController.value.position >= _videoController.value.duration) {
          // Video finished, check if app initialization is also complete
          _checkAndNavigate();
        }
      });
    } catch (e) {
      print('Error initializing video: $e');
      setState(() {
        _isVideoInitialized = false;
      });
      // If video fails, mark as completed and rely on app initialization
      _videoCompleted = true;
      _checkAndNavigate();
    }
  }

  void _checkAndNavigate() {
    _videoCompleted = true;
    if (_appInitialized && _videoCompleted) {
      _navigateToHome();
    }
  }

  Future<void> _initializeApp() async {
    try {
      await splashScreenController.initializing();
      _appInitialized = true;
      _checkAndNavigate();
    } catch (e) {
      print('Error in splash screen initialization: $e');
      // Fallback navigation
      await Future.delayed(Duration(seconds: 1));
      _navigateToHome();
    }
  }

  Future<void> _navigateToHome() async {
    try {
      // Only call getVideos if not already loaded
      if (!splashScreenController.videosLoaded) {
        await splashScreenController.dashboardController.getVideos(showErrorMessages: false);
        splashScreenController.videosLoaded = true;
      }
      Get.offNamed('/home');
    } catch (e) {
      print('Error navigating to home: $e');
      // Don't show error toast during splash screen
      Get.offNamed('/home');
    }
  }

  @override
  void dispose() {
    try {
      if (_videoController != null) {
        _videoController.dispose();
      }
    } catch (e) {
      print('Error disposing video controller: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WillPopScope(
        onWillPop: () {
          DateTime now = DateTime.now();
          if (now.difference(currentBackPressTime) > Duration(seconds: 2)) {
            currentBackPressTime = now;
            Fluttertoast.showToast(msg: "Tap again to exit an app.".tr);
            return Future.value(false);
          }
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          return Future.value(true);
        },
        child: Container(
          height: Get.height,
          width: Get.width,
          child: Center(
            child: _isVideoInitialized
                ? AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: VideoPlayer(_videoController),
                  )
                : Container(
                    // Empty container while video loads - no loading indicator
                    color: Colors.black,
                  ),
          ),
        ),
      ),
    );
  }
}
