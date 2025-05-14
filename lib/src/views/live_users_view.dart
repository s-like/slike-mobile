import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core.dart';

class LiveUsersView extends StatefulWidget {
  LiveUsersView({Key? key}) : super(key: key);

  @override
  _LiveUsersViewState createState() => _LiveUsersViewState();
}

class _LiveUsersViewState extends State<LiveUsersView> {
  UserController userController = Get.find();
  DashboardService dashboardService = Get.find();
  MainService mainService = Get.find();
  LiveStreamingService liveStreamingService = Get.find();
  LiveStreamingController liveStreamController = Get.find();
  DashboardController dashboardController = Get.find();
  @override
  void initState() {
    userController.getLiveUsers(1);
    super.initState();
  }

  Widget build(BuildContext context) {
    var size = Get.mediaQuery.size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;
    return Obx(() {
      return Scaffold(
        key: userController.userScaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: Get.theme.primaryColor,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () {
              return userController.getLiveUsers(1);
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                height: Get.height,
                width: Get.width,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 15, 0, 0),
                      child: Container(
                        height: 24,
                        width: Get.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () async {
                                Get.back();
                              },
                              child: Icon(
                                Icons.arrow_back,
                                size: 20,
                                color: Get.theme.iconTheme.color,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: Container(
                                width: Get.width - 50,
                                child: TextField(
                                  controller: userController.searchController,
                                  style: TextStyle(
                                    color: Get.theme.indicatorColor,
                                    fontSize: 16.0,
                                  ),
                                  obscureText: false,
                                  keyboardType: TextInputType.text,
                                  onChanged: (String val) {
                                    setState(() {
                                      userController.searchKeyword = val;
                                    });
                                    if (val.length > 2) {
                                      Timer(Duration(seconds: 1), () {
                                        userController.getUsers(1);
                                      });
                                    }
                                  },
                                  decoration: new InputDecoration(
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(color: mainService.setting.value.buttonColor!, width: 0.3),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: mainService.setting.value.buttonColor!, width: 0.3),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: mainService.setting.value.buttonColor!, width: 0.3),
                                    ),
                                    hintText: "Search".tr,
                                    hintStyle: TextStyle(fontSize: 16.0, color: Get.theme.indicatorColor.withValues(alpha: 0.5)),
                                    suffixIcon: IconButton(
                                      padding: EdgeInsets.only(bottom: 12),
                                      onPressed: () {
                                        userController.searchController.clear();
                                        setState(() {
                                          userController.searchKeyword = "";
                                        });
                                        userController.getUsers(1);
                                      },
                                      icon: Icon(
                                        Icons.clear,
                                        color: (userController.searchKeyword.length > 0) ? Get.theme.iconTheme.color : Colors.transparent,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 13, bottom: 2, left: 15),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          child: Text(
                            'Live Users'.tr,
                            style: TextStyle(
                              color: Get.theme.indicatorColor,
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    (liveStreamingService.liveUsersData.value.users.length > 0)
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: Get.width,
                              height: Get.height - 110,
                              child: GridView.builder(
                                controller: userController.scrollController1,
                                primary: false,
                                padding: const EdgeInsets.all(2),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: (itemWidth / itemHeight),
                                  crossAxisSpacing: 2,
                                  mainAxisSpacing: 2,
                                  crossAxisCount: 3,
                                ),
                                itemCount: liveStreamingService.liveUsersData.value.users.length,
                                itemBuilder: (BuildContext context, int i) {
                                  final item = liveStreamingService.liveUsersData.value.users.elementAt(i);
                                  print("item.userDP");
                                  print(item.userDP);
                                  return InkWell(
                                    onTap: () {
                                      liveStreamController.redirectToLive(isPlay: true, liveStreamName: item.streamName, liveStreamId: item.streamId, streamUserId: item.id);
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        Container(
                                          height: Get.height,
                                          width: Get.width,
                                          child: item.userDP != ""
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(5),
                                                    /*boxShadow: [
                                                      BoxShadow(
                                                        color: mainService.setting.value.gridItemBorderColor!,
                                                        blurRadius: 2.0, // soften the shadow
                                                        spreadRadius: 0.0, //extend the shadow
                                                        offset: Offset(
                                                          0.0, // Move to right 10  horizontally

                                                          0.0, // Move to bottom 5 Vertically
                                                        ),
                                                      )
                                                    ],*/
                                                  ),
                                                  padding: const EdgeInsets.all(1),
                                                  child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(5.0),
                                                      child: CachedNetworkImage(
                                                        imageUrl: item.userDP,
                                                        placeholder: (context, url) => Center(
                                                          child: CommonHelper.showLoaderSpinner(Colors.white),
                                                        ),
                                                        fit: BoxFit.cover,
                                                      )),
                                                )
                                              : ClipRRect(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  child: Image.asset(
                                                    'assets/images/noVideo.jpg',
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                        ),
                                        /* Container(
                                                    color: mainService.setting.value.dividerColor,
                                                  ),*/
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: Container(
                                            width: 30.0,
                                            height: 20.0,
                                            decoration: new BoxDecoration(
                                              image: new DecorationImage(
                                                  image: AssetImage(
                                                    'assets/icons/live1.png',
                                                  ) as ImageProvider,
                                                  fit: BoxFit.contain),
                                              borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 10,
                                          child: Row(
                                            children: [
                                              Text(
                                                item.username,
                                                style: TextStyle(
                                                  color: Get.theme.primaryColor,
                                                  fontSize: 11,
                                                  fontFamily: 'RockWellStd',
                                                  fontWeight: FontWeight.bold,
                                                  shadows: <Shadow>[
                                                    Shadow(
                                                      offset: Offset(1.0, 1.0),
                                                      blurRadius: 3.0,
                                                      color: Colors.white,
                                                    ),
                                                    Shadow(
                                                      offset: Offset(1.0, 1.0),
                                                      blurRadius: 8.0,
                                                      color: Colors.black,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              item.isVerified == true
                                                  ? Icon(
                                                      Icons.verified,
                                                      color: Get.theme.highlightColor,
                                                      size: 16,
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                        /*Positioned(
                                                    bottom: -5,
                                                    child: ButtonTheme(
                                                      minWidth: 80,
                                                      height: 25,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.transparent,
                                                          padding: EdgeInsets.all(0),
                                                          // shape: RoundedRectangleBorder(
                                                          //   borderRadius: BorderRadius.circular(100.0),
                                                          // ),
                                                        ),
                                                        child: Container(
                                                          height: 25,
                                                          width: 80,
                                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(3.0), color: mainService.setting.value.buttonColor),
                                                          child: Center(
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              children: <Widget>[
                                                                ((userController.followUserId != item.userId))
                                                                    ? Text(
                                                                        item.followText,
                                                                        style: TextStyle(
                                                                          color: Get.theme.indicatorColor,
                                                                          fontWeight: FontWeight.bold,
                                                                          fontSize: 11,
                                                                          fontFamily: 'RockWellStd',
                                                                        ),
                                                                      )
                                                                    :CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color!),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            userController.followUnfollowUser(item.userId, i);
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),*/
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        : (!userController.showUserLoader)
                            ? Center(
                                child: Container(
                                  height: Get.height - 360,
                                  width: Get.width,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.all(10),
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(100),
                                          border: Border.all(
                                            width: 2,
                                            color: mainService.setting.value.dividerColor!,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          color: Get.theme.iconTheme.color,
                                          size: 20,
                                        ),
                                      ),
                                      Text(
                                        "No User Yet".tr,
                                        style: TextStyle(
                                          color: Get.theme.indicatorColor,
                                          fontSize: 15,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
