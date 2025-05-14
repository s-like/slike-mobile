import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import '../core.dart';

class UsersProfileView extends StatefulWidget {
  final int userId;
  UsersProfileView({Key? key, this.userId = 0}) : super(key: key);

  @override
  _UsersProfileViewState createState() => _UsersProfileViewState();
}

class _UsersProfileViewState extends State<UsersProfileView> {
  UserController userController = Get.find();
  MainService mainService = Get.find();
  UserService userService = Get.find();
  DashboardService dashboardService = Get.find();
  DashboardController dashboardController = Get.find();
  AuthService authService = Get.find();
  var sliverExpandableHgt = 310.0.obs;
  @override
  void initState() {
    userController.page = 1;
    userController.isProfileExpand.value = false;
    userController.isProfileExpand.refresh();
    // userController.profileScrollController.removeListener(userController.profileScrollListener);
    userController.startProfileListner();
    fetchUserProfile();
    print(sliverExpandableHgt.value);
    userController.getAds();
    super.initState();
  }

  Future fetchUserProfile() async {
    sliverExpandableHgt.value = 310.0;
    sliverExpandableHgt.refresh();
    await userController.getUsersProfile(userController.page);

    if (userService.userProfile.value.website.isNotEmpty) {
      sliverExpandableHgt.value += calculateTextHeight(userService.userProfile.value.website, 13.0, 200.0);
    }
    if (userService.userProfile.value.bio.isNotEmpty) {
      sliverExpandableHgt.value += calculateTextHeight(userService.userProfile.value.bio, 15.0, 200);
    }
    sliverExpandableHgt.refresh();
  }

  double calculateTextHeight(String text, double fontSize, double maxWidth) {
    // Create a TextPainter to measure the height
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize),
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: null, // Allow the text to wrap
    )..layout(maxWidth: maxWidth);

    // Return the calculated height
    return textPainter.size.height;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Get.theme.primaryColor, statusBarIconBrightness: Brightness.light),
    );
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Get.theme.primaryColor,
          key: userController.userProfileScaffoldKey,
          body: WillPopScope(
            onWillPop: () {
              userController.isProfileExpand.value = false;
              userController.isProfileExpand.refresh();
              userController.profileScrollController.removeListener(userController.profileScrollListener);
              if (mainService.fromUsersView.value) {
                mainService.fromUsersView.value = false;
                Get.offNamed('/users');
              } else {
                Get.offNamed('/home');
              }
              return Future.value(false);
            },
            child: Obx(
              () => SafeArea(
                bottom: true,
                child: NotificationListener<ScrollEndNotification>(
                  onNotification: (scrollEnd) {
                    if (scrollEnd.metrics.atEdge) {
                      bool isTop = scrollEnd.metrics.pixels == 0;
                      print(isTop);
                      if (isTop) {
                        return false;
                      }
                      if (userService.userProfile.value.userVideos.length != userService.userProfile.value.totalVideos) {
                        userController.page = userController.page + 1;
                        userController.getUsersProfile(userController.page);
                      }
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    shrinkWrap: true,
                    controller: userController.profileScrollController,
                    slivers: <Widget>[
                      SliverAppBar(
                        scrolledUnderElevation: 0,
                        automaticallyImplyLeading: false,
                        elevation: 1,
                        leading: !userController.isProfileExpand.value
                            ? InkWell(
                                onTap: () {
                                  userController.isProfileExpand.value = false;
                                  userController.isProfileExpand.refresh();
                                  userController.profileScrollController.removeListener(userController.profileScrollListener);
                                  if (mainService.fromUsersView.value) {
                                    mainService.fromUsersView.value = false;
                                    Get.offNamed('/users');
                                  } else {
                                    Get.offNamed('/home');
                                  }
                                },
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: Get.theme.iconTheme.color,
                                ),
                              )
                            : SizedBox(),
                        actions: [
                          authService.currentUser.value.accessToken != ''
                              ? IconButton(
                                  onPressed: () async {
                                    userController.userProfileScaffoldKey.currentState!.openEndDrawer();
                                  },
                                  icon: Icon(
                                    Icons.menu,
                                    color: Get.theme.iconTheme.color,
                                    size: 25.0,
                                  ),
                                )
                              : SizedBox(),
                        ],
                        pinned: true,
                        snap: false,
                        floating: false,
                        expandedHeight: sliverExpandableHgt.value,
                        foregroundColor: Get.theme.indicatorColor,
                        collapsedHeight: 100,
                        backgroundColor: Get.theme.primaryColor,
                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.pin,
                          titlePadding: EdgeInsets.zero,
                          title: userController.isProfileExpand.value
                              ? Container(
                                  width: Get.width,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                            return Scaffold(
                                                backgroundColor: Get.theme.primaryColor,
                                                appBar: PreferredSize(
                                                  preferredSize: Size.fromHeight(45.0),
                                                  child: AppBar(
                                                    leading: InkWell(
                                                      onTap: () {
                                                        if (mainService.fromUsersView.value) {
                                                          Get.back();
                                                        } else {
                                                          Get.offNamed('/home');
                                                        }
                                                      },
                                                      child: Icon(
                                                        Icons.arrow_back_ios,
                                                        size: 20,
                                                        color: Get.theme.iconTheme.color,
                                                      ),
                                                    ),
                                                    iconTheme: IconThemeData(
                                                      color: Get.theme.iconTheme.color, //change your color here
                                                    ),
                                                    // backgroundColor: Color(0xff15161a),
                                                    backgroundColor: Get.theme.primaryColor,
                                                    title: Text(
                                                      "PROFILE PICTURE".tr,
                                                      style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontWeight: FontWeight.w400,
                                                        color: Get.theme.indicatorColor,
                                                      ),
                                                    ),
                                                    centerTitle: true,
                                                  ),
                                                ),
                                                body: Center(
                                                  child: PhotoView(
                                                    enableRotation: true,
                                                    imageProvider: CachedNetworkImageProvider((userService.userProfile.value.largeProfilePic.toLowerCase().contains(".jpg") ||
                                                            userService.userProfile.value.largeProfilePic.toLowerCase().contains(".jpeg") ||
                                                            userService.userProfile.value.largeProfilePic.toLowerCase().contains(".png") ||
                                                            userService.userProfile.value.largeProfilePic.toLowerCase().contains(".gif") ||
                                                            userService.userProfile.value.largeProfilePic.toLowerCase().contains(".bmp") ||
                                                            userService.userProfile.value.largeProfilePic.toLowerCase().contains("fbsbx.com") ||
                                                            userService.userProfile.value.largeProfilePic.toLowerCase().contains("googleusercontent.com"))
                                                        ? userService.userProfile.value.largeProfilePic
                                                        : '$baseUrl' + "default/user-dummy-pic.png"),
                                                  ),
                                                ));
                                          }));
                                        },
                                        child: Container(
                                          height: 80,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(100),
                                            // color: Get.theme.highlightColor,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(100),
                                            child: userService.userProfile.value.smallProfilePic != ""
                                                ? CachedNetworkImage(
                                                    imageUrl: (userService.userProfile.value.smallProfilePic.toLowerCase().contains(".jpg") ||
                                                            userService.userProfile.value.smallProfilePic.toLowerCase().contains(".jpeg") ||
                                                            userService.userProfile.value.smallProfilePic.toLowerCase().contains(".png") ||
                                                            userService.userProfile.value.smallProfilePic.toLowerCase().contains(".gif") ||
                                                            userService.userProfile.value.smallProfilePic.toLowerCase().contains(".bmp") ||
                                                            userService.userProfile.value.smallProfilePic.toLowerCase().contains("fbsbx.com") ||
                                                            userService.userProfile.value.smallProfilePic.toLowerCase().contains("googleusercontent.com"))
                                                        ? userService.userProfile.value.smallProfilePic
                                                        : '$baseUrl' + "default/user-dummy-pic.png",
                                                    placeholder: (context, url) => CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color!),
                                                    fit: BoxFit.fill,
                                                    width: 50,
                                                    height: 50,
                                                    errorWidget: (a, b, c) {
                                                      return Image.asset(
                                                        "assets/images/default-user.png",
                                                        fit: BoxFit.cover,
                                                      );
                                                    },
                                                  )
                                                : Image.asset('assets/images/default-user.png'),
                                          ).pLTRB(4, 4, 4, 4),
                                        ),
                                      ).pOnly(right: 15),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                userService.userProfile.value.username.text.color(mainService.setting.value.textColor!).size(20).make(),
                                                userService.userProfile.value.isVerified == true
                                                    ? Icon(
                                                        Icons.verified,
                                                        color: Get.theme.highlightColor,
                                                        size: 22,
                                                      ).pOnly(left: 5)
                                                    : Container()
                                              ],
                                            ).pOnly(bottom: 8),
                                            SizedBox(
                                              width: Get.width,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      if (authService.currentUser.value.accessToken == '') {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => LoginView(),
                                                          ),
                                                        );
                                                      } else {
                                                        userService.userProfile.value.followText = userService.userProfile.value.followText == "Follow" ? "Following".tr : "Follow".tr;
                                                        userService.userProfile.refresh();
                                                        userController.followUnfollowUserFromUserProfile(widget.userId);
                                                      }
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Get.theme.highlightColor,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: "${userService.userProfile.value.followText}"
                                                          .text
                                                          .center
                                                          .textStyle(
                                                            Get.textTheme.bodyLarge!.copyWith(color: Get.theme.primaryColor, fontSize: 14),
                                                          )
                                                          .make()
                                                          .centered()
                                                          .pSymmetric(v: 5, h: 10),
                                                    ),
                                                  ).pOnly(right: 10),
                                                  InkWell(
                                                    onTap: () async {
                                                      ChatService chatService = Get.find();
                                                      ChatController chatController = Get.find();
                                                      chatService.conversationUser.value.convId = 0;
                                                      chatService.conversationUser.value.id = userService.userProfile.value.id;
                                                      chatService.conversationUser.value.name = userService.userProfile.value.name;
                                                      chatService.conversationUser.value.userDP = userService.userProfile.value.largeProfilePic;
                                                      chatService.conversationUser.value.online = false;
                                                      chatService.conversationUser.refresh();
                                                      await chatController.fetchChat();
                                                      Get.toNamed("/chat");
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Get.theme.highlightColor,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: 'Message'
                                                          .text
                                                          .center
                                                          .textStyle(
                                                            Get.textTheme.bodyLarge!.copyWith(color: Get.theme.primaryColor, fontSize: 14),
                                                          )
                                                          .make()
                                                          .centered()
                                                          .pSymmetric(v: 5, h: 10),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(),
                          background: Container(
                            width: Get.width,
                            child: Column(
                              children: [
                                SizedBox(height: 5),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                      return Scaffold(
                                          backgroundColor: Get.theme.primaryColor,
                                          appBar: PreferredSize(
                                            preferredSize: Size.fromHeight(45.0),
                                            child: AppBar(
                                              leading: InkWell(
                                                onTap: () {
                                                  if (mainService.fromUsersView.value) {
                                                    Get.back();
                                                  } else {
                                                    Get.offNamed('/home');
                                                  }
                                                },
                                                child: Icon(
                                                  Icons.arrow_back_ios,
                                                  size: 20,
                                                  color: Get.theme.iconTheme.color,
                                                ),
                                              ),
                                              iconTheme: IconThemeData(
                                                color: Get.theme.iconTheme.color, //change your color here
                                              ),
                                              // backgroundColor: Color(0xff15161a),
                                              backgroundColor: Get.theme.primaryColor,
                                              title: Text(
                                                "PROFILE PICTURE".tr,
                                                style: TextStyle(
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.w400,
                                                  color: Get.theme.indicatorColor,
                                                ),
                                              ),
                                              centerTitle: true,
                                            ),
                                          ),
                                          body: Center(
                                            child: PhotoView(
                                              enableRotation: true,
                                              imageProvider: CachedNetworkImageProvider((userService.userProfile.value.largeProfilePic.toLowerCase().contains(".jpg") ||
                                                      userService.userProfile.value.largeProfilePic.toLowerCase().contains(".jpeg") ||
                                                      userService.userProfile.value.largeProfilePic.toLowerCase().contains(".png") ||
                                                      userService.userProfile.value.largeProfilePic.toLowerCase().contains(".gif") ||
                                                      userService.userProfile.value.largeProfilePic.toLowerCase().contains(".bmp") ||
                                                      userService.userProfile.value.largeProfilePic.toLowerCase().contains("fbsbx.com") ||
                                                      userService.userProfile.value.largeProfilePic.toLowerCase().contains("googleusercontent.com"))
                                                  ? userService.userProfile.value.largeProfilePic
                                                  : '$baseUrl' + "default/user-dummy-pic.png"),
                                            ),
                                          ));
                                    }));
                                  },
                                  child: Container(
                                    height: Get.width * 0.3,
                                    width: Get.width * 0.3,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      //color: mainService.setting.value.textColor,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: userService.userProfile.value.smallProfilePic != ""
                                          ? CachedNetworkImage(
                                              imageUrl: (userService.userProfile.value.smallProfilePic.toLowerCase().contains(".jpg") ||
                                                      userService.userProfile.value.smallProfilePic.toLowerCase().contains(".jpeg") ||
                                                      userService.userProfile.value.smallProfilePic.toLowerCase().contains(".png") ||
                                                      userService.userProfile.value.smallProfilePic.toLowerCase().contains(".gif") ||
                                                      userService.userProfile.value.smallProfilePic.toLowerCase().contains(".bmp") ||
                                                      userService.userProfile.value.smallProfilePic.toLowerCase().contains("fbsbx.com") ||
                                                      userService.userProfile.value.smallProfilePic.toLowerCase().contains("googleusercontent.com"))
                                                  ? userService.userProfile.value.smallProfilePic
                                                  : '$baseUrl' + "default/user-dummy-pic.png",
                                              placeholder: (context, url) => CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                              fit: BoxFit.fill,
                                              width: 50,
                                              height: 50,
                                              errorWidget: (a, b, c) {
                                                return Image.asset(
                                                  "assets/images/user.png",
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            )
                                          : Image.asset('assets/images/user.png'),
                                    ).pLTRB(4, 4, 4, 4),
                                  ),
                                ).centered().centered().pOnly(bottom: 10).pOnly(bottom: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    userService.userProfile.value.username.text.color(Get.theme.indicatorColor).size(20).make(),
                                    userService.userProfile.value.isVerified == true
                                        ? Icon(
                                            Icons.verified,
                                            color: Get.theme.highlightColor,
                                            size: 22,
                                          ).pOnly(left: 5)
                                        : Container()
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        "${userService.userProfile.value.totalVideos}".text.color(Get.theme.indicatorColor).size(20).make().pOnly(bottom: 1),
                                        "Posts".tr.text.color(Get.theme.indicatorColor.withValues(alpha:0.8)).size(15).make(),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        "${userService.userProfile.value.totalVideosLike}".text.color(Get.theme.indicatorColor).size(20).make().pOnly(bottom: 1),
                                        "Likes".tr.text.color(Get.theme.indicatorColor.withValues(alpha:0.8)).size(15).make(),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        "${userService.userProfile.value.totalFollowings}".text.color(Get.theme.indicatorColor).size(20).make().pOnly(bottom: 1),
                                        "Followings".tr.text.color(Get.theme.indicatorColor.withValues(alpha:0.8)).size(15).make(),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        "${userService.userProfile.value.totalFollowers}".text.color(Get.theme.indicatorColor).size(20).make().pOnly(bottom: 1),
                                        "Followers".tr.text.color(Get.theme.indicatorColor.withValues(alpha:0.8)).size(15).make(),
                                      ],
                                    )
                                  ],
                                ).pSymmetric(h: 20, v: 0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          if (authService.currentUser.value.accessToken == '') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => LoginView(),
                                              ),
                                            );
                                          } else {
                                            userService.userProfile.value.followText = userService.userProfile.value.followText == "Follow" ? "Following".tr : "Follow".tr;
                                            userService.userProfile.refresh();
                                            userController.followUnfollowUserFromUserProfile(widget.userId);
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Get.theme.highlightColor,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: "${userService.userProfile.value.followText}"
                                              .text
                                              .center
                                              .textStyle(
                                                Get.textTheme.bodyLarge!.copyWith(color: Get.theme.primaryColor, fontSize: 18),
                                              )
                                              .make()
                                              .centered()
                                              .pSymmetric(v: 12),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          ChatService chatService = Get.find();
                                          ChatController chatController = Get.find();
                                          chatService.conversationUser.value.convId = 0;
                                          chatService.conversationUser.value.id = userService.userProfile.value.id;
                                          chatService.conversationUser.value.name = userService.userProfile.value.name;
                                          chatService.conversationUser.value.userDP = userService.userProfile.value.largeProfilePic;
                                          chatService.conversationUser.value.online = false;
                                          chatService.conversationUser.refresh();
                                          await chatController.fetchChat();
                                          Get.toNamed("/chat");
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Get.theme.highlightColor,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: 'Message'
                                              .text
                                              .center
                                              .textStyle(
                                                Get.textTheme.bodyLarge!.copyWith(color: Get.theme.primaryColor, fontSize: 18),
                                              )
                                              .make()
                                              .centered()
                                              .pSymmetric(v: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ).pSymmetric(h: 20, v: 5),
                                SizedBox(
                                  width: Get.width,
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return userService.userProfile.value.bio.isNotEmpty
                                          ? "${userService.userProfile.value.bio} ".text.center.color(mainService.setting.value.textColor!.withValues(alpha:0.8)).size(12).make().pSymmetric(v: 5).centered()
                                          : SizedBox();
                                    },
                                  ),
                                ),
                                userService.userProfile.value.website.isNotEmpty
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/link.svg',
                                            width: 15.0,
                                            colorFilter: ColorFilter.mode(Get.theme.iconTheme.color!, BlendMode.srcIn),
                                          ).pSymmetric(h: 5),
                                          "${userService.userProfile.value.website.replaceAll("https://", "").replaceAll("/", "")}"
                                              .text
                                              .color(
                                                Get.theme.indicatorColor.withValues(alpha:0.8),
                                              )
                                              .size(12)
                                              .bold
                                              .make(),
                                        ],
                                      ).onTap(() {
                                        userController.launchURL(userService.userProfile.value.website);
                                      })
                                    : SizedBox(),
                                // userService.userProfile.value.bio.isNotEmpty
                                //     ? "${userService.userProfile.value.bio}".text.color(mainService.setting.value.textColor!.withValues(alpha:0.5)).size(18).make().pSymmetric(v: 5)
                                //     : SizedBox(),
                                // userService.userProfile.value.website.isNotEmpty
                                //     ? Row(
                                //         mainAxisAlignment: MainAxisAlignment.center,
                                //         children: [
                                //           SvgPicture.asset(
                                //             'assets/icons/link.svg',
                                //             width: 20.0,
                                //             color: mainService.setting.value.iconColor,
                                //           ).pSymmetric(h: 5),
                                //           "${userService.userProfile.value.website.replaceAll("https://", "").replaceAll("/", "")}"
                                //               .text
                                //               .color(
                                //                 mainService.setting.value.textColor,
                                //               )
                                //               .size(13)
                                //               .bold
                                //               .make()
                                //               .pSymmetric(v: 5)
                                //               .marginOnly(bottom: 10),
                                //         ],
                                //       ).onTap(() {
                                //         userController.launchURL(userService.userProfile.value.website);
                                //       })
                                //     : SizedBox(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            userService.userProfile.value.userVideos.isNotEmpty
                                ? Container(
                                    padding: EdgeInsets.only(bottom: 10),
                                    child: GridView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        padding: EdgeInsets.only(bottom: 50),
                                        shrinkWrap: true,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                                          height: 150,
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 0,
                                          mainAxisSpacing: 0,
                                        ),
                                        itemCount: userService.userProfile.value.userVideos.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          final item = userService.userProfile.value.userVideos.elementAt(index);
                                          return InkWell(
                                            onTap: () {
                                              mainService.userVideoObj.value.userId = item.userId;
                                              mainService.userVideoObj.value.videoId = item.videoId;
                                              mainService.userVideoObj.value.name = userService.userProfile.value.name.split(" ").first + "'s";
                                              dashboardService.showFollowingPage.value = false;
                                              dashboardService.showFollowingPage.refresh();
                                              dashboardService.postIds = [];
                                              dashboardService.currentPage.value = 0;
                                              dashboardService.currentPage.refresh();
                                              dashboardController.getVideos().whenComplete(() {
                                                Get.offAllNamed('/home');
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(0.5),
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Get.theme.indicatorColor,
                                                    blurRadius: 3.0, // soften the shadow
                                                    spreadRadius: 0.0, //extend the shadow
                                                    offset: Offset(
                                                      0.0, // Move to right 10  horizontally
                                                      0.0, // Move to bottom 5 Vertically
                                                    ),
                                                  )
                                                ],
                                              ),
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    width: Get.width * 0.4,
                                                    child: item.videoGif != ""
                                                        ? CachedNetworkImage(
                                                            height: 150,
                                                            memCacheWidth: 150,
                                                            width: Get.width * 0.4,
                                                            imageUrl: item.videoGif,
                                                            placeholder: (context, url) => CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                                            fit: BoxFit.cover,
                                                            errorWidget: (context, url, error) => CachedNetworkImage(
                                                              height: 150,
                                                              memCacheWidth: 150,
                                                              width: Get.width * 0.4,
                                                              imageUrl: item.videoThumbnail,
                                                              placeholder: (context, url) => CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                        : item.videoThumbnail != ""
                                                            ? CachedNetworkImage(
                                                                memCacheWidth: 150,
                                                                height: 150,
                                                                imageUrl: item.videoThumbnail,
                                                                placeholder: (context, url) => CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                                                fit: BoxFit.cover,
                                                              )
                                                            : Image.asset(
                                                                'assets/images/noVideo.jpg',
                                                                height: 150,
                                                                fit: BoxFit.cover,
                                                              ),
                                                  ),
                                                  Container(
                                                    width: Get.width * 0.4,
                                                    height: 150,
                                                    color: Colors.black12,
                                                  ),
                                                  Positioned(
                                                    bottom: 8,
                                                    child: Container(
                                                      width: Get.width * 0.3,
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Expanded(
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                SvgPicture.asset(
                                                                  'assets/icons/liked.svg',
                                                                  width: 15.0,
                                                                  colorFilter: ColorFilter.mode(Get.theme.primaryColor, BlendMode.srcIn),
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                "${item.totalLikes}".text.color(Get.theme.primaryColor).size(13).make(),
                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                SvgPicture.asset(
                                                                  'assets/icons/views.svg',
                                                                  width: 15.0,
                                                                  colorFilter: ColorFilter.mode(Get.theme.primaryColor, BlendMode.srcIn),
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                "${CommonHelper.formatter(item.totalViews.toString())}".text.color(Get.theme.primaryColor).size(13).make(),
                                                              ],
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
                                        }),
                                  )
                                : !userController.videosLoader.value
                                    ? Container(
                                        height: Get.width * 0.4,
                                        child: "No video yet!".text.size(16).color(Get.theme.indicatorColor.withValues(alpha:0.6)).center.wide.make().centered(),
                                      )
                                    : Container(
                                        width: Get.width,
                                        height: Get.width * 0.40,
                                        child: Center(
                                          child: CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                        ),
                                      )
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          endDrawer: Container(
            width: 250,
            child: Drawer(
              child: Stack(
                children: [
                  Container(
                    color: Get.theme.primaryColor,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        Container(
                          height: 150,
                          child: DrawerHeader(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: Get.theme.highlightColor,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: userService.userProfile.value.smallProfilePic != ""
                                          ? CachedNetworkImage(
                                              imageUrl: (userService.userProfile.value.smallProfilePic.toLowerCase().contains(".jpg") ||
                                                      userService.userProfile.value.smallProfilePic.toLowerCase().contains(".jpeg") ||
                                                      userService.userProfile.value.smallProfilePic.toLowerCase().contains(".png") ||
                                                      userService.userProfile.value.smallProfilePic.toLowerCase().contains(".gif") ||
                                                      userService.userProfile.value.smallProfilePic.toLowerCase().contains(".bmp") ||
                                                      userService.userProfile.value.smallProfilePic.toLowerCase().contains("fbsbx.com") ||
                                                      userService.userProfile.value.smallProfilePic.toLowerCase().contains("googleusercontent.com"))
                                                  ? userService.userProfile.value.smallProfilePic
                                                  : '$baseUrl' + "default/user-dummy-pic.png",
                                              placeholder: (context, url) => CommonHelper.showLoaderSpinner(mainService.setting.value.iconColor!),
                                              fit: BoxFit.fill,
                                              width: 80,
                                              height: 80,
                                            )
                                          : Image.asset(
                                              'assets/images/default-user.png',
                                              fit: BoxFit.fill,
                                              width: 80,
                                              height: 80,
                                            ),
                                    ).pLTRB(3, 3, 3, 3),
                                  ).objectCenterLeft(),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      "${userService.userProfile.value.name}".text.color(Get.theme.highlightColor).ellipsis.bold.size(18).make(),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      "(${userService.userProfile.value.username})".text.color(Get.theme.indicatorColor).ellipsis.size(14).make(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                              color: Color(0XFF15161a).withValues(alpha:0.1),
                              border: Border(
                                bottom: BorderSide(
                                  width: 0.5,
                                  color: Get.theme.dividerColor,
                                ),
                              ),
                            ),
                            margin: EdgeInsets.all(0.0),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                          ),
                        ),
                        ListTile(
                          // contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.block,
                            color: Get.theme.iconTheme.color,
                            size: 25,
                          ),
                          title: "${userService.userProfile.value.blocked == 'yes' ? 'Unblock'.tr : 'Block'}".text.color(Get.theme.indicatorColor).size(16).wide.make(),
                          onTap: () {
                            Navigator.pop(context);
                            userController.blockUser(report: false);
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.verified_user,
                            color: Get.theme.iconTheme.color,
                            size: 25,
                          ),
                          title: "${userService.userProfile.value.blocked == 'yes' ? 'Unblock'.tr : 'Report & Block'}".text.color(Get.theme.indicatorColor).size(16).wide.make(),
                          onTap: () {
                            Navigator.pop(context);
                            userController.blockUser(report: true);
                          },
                        ),
                        /*ListTile(
                            leading: Icon(
                              Icons.delete_forever,
                              color: mainService.setting.value.iconColor,
                              textDirection: TextDirection.rtl,
                              size: 25,
                            ),
                            title: 'Delete Profile Instruction'.text.color(mainService.setting.value.textColor!).size(16).wide.make(),
                            onTap: () {
                              String url = GlobalConfiguration().get('base_url') + "data-delete";
                              userController.launchURL(url);
                            },
                          ),*/
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 10,
                    child: Container(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "${'App Version'.tr}:  ${userService.userProfile.value.appVersion}",
                            style: TextStyle(
                              color: Get.theme.indicatorColor,
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
        ),
        if (userController.showBannerAd.value)
          Positioned(
            bottom: Platform.isAndroid ? 0 : 15,
            child: Center(
              child: Container(
                width: Get.width,
                child: BannerAdWidget(),
              ),
            ),
          ),
      ],
    );
  }
}
