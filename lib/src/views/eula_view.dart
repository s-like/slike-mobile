import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

import '../core.dart';

class EulaView extends StatelessWidget {
  EulaView({Key? key}) : super(key: key);
  DateTime currentBackPressTime = DateTime.now();
  DashboardService dashboardService = Get.find();
  DashboardController dashboardController = Get.find();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();

        if (now.difference(currentBackPressTime) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          Fluttertoast.showToast(msg: "Tap again to exit an app".tr);
          return Future.value(false);
        }
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          automaticallyImplyLeading: false,
          title: Center(
            child: Text(
              dashboardService.eulaData['title'],
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Html(
            shrinkWrap: true,
            data: dashboardService.eulaData['content'],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.blueAccent,
          onPressed: () async {
            dashboardController.updateEULA();
          },
          icon: Icon(Icons.check),
          label: Text("Agree".tr),
        ),
      ),
    );
  }
}
