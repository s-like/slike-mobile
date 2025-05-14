// ignore_for_file: must_be_immutable
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core.dart';

class GoLiveScreenLanding extends StatefulWidget {
  GoLiveScreenLanding({Key? key}) : super(key: key);

  @override
  _GoLiveScreenLandingState createState() => _GoLiveScreenLandingState();
}

class _GoLiveScreenLandingState extends State<GoLiveScreenLanding> {
  _GoLiveScreenLandingState();
  LiveStreamingController liveStreamController = Get.find();
  LiveStreamingService liveStreamingService = Get.find();
  MainService mainService = Get.find();

  @override
  initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    EasyLoading.dismiss();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: ExactAssetImage('assets/images/splash.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.0)),
            ),
          ),
        ),
        Obx(() {
          return liveStreamingService.gotoLive.value
              ? Obx(
                  () => liveStreamController.countTimer.value < 5
                      ? SizedBox(
                          height: Get.height,
                          width: Get.width,
                          child: liveStreamController.countTimer.value.text.bold.color(Get.theme.primaryColor).size(Get.width * 0.3).make().centered(),
                        )
                      : SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Get.theme.primaryColor,
                          ),
                        ).centered(),
                )
              : SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(
                        height: 35,
                      ),
                      IconButton(
                        onPressed: () {
                          Get.offNamed('/home');
                        },
                        icon: Icon(
                          Icons.close,
                          size: 25,
                          color: Get.theme.primaryColor,
                        ),
                      ),
                      "This live video has ended".tr.text.color(Get.theme.primaryColor).bold.size(20).make().centered(),
                      // const SizedBox(
                      //   height: 15,
                      // ),
                      // "You can watch the video again shortly".text.color(Get.theme.indicatorColor).size(16).make().centered(),
                      const SizedBox(
                        height: 25,
                      ),
                      Divider(
                        color: Get.theme.indicatorColor,
                      ),
                    ],
                  ),
                );
        }),
      ],
    );
  }
}
