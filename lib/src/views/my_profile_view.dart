import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import '../core.dart';

class MyProfileView extends StatefulWidget {
  MyProfileView({Key? key}) : super(key: key);
  @override
  _MyProfileViewState createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  UserController userController = Get.find();
  MainService mainService = Get.find();
  AuthService authService = Get.find();
  UserService userService = Get.find();
  DashboardService dashboardService = Get.find();
  DashboardController dashboardController = Get.find();
  final UserProfileController userProfileController = Get.find();
  @override
  void initState() {
    authService.currentUser.value.userVideos = [];
    // authService.currentUser.refresh();
    userController.page = 1;
    userController.isProfileExpand.value = false;
    userController.isProfileExpand.refresh();
    // userController.profileScrollController.removeListener(userController.profileScrollListener);
    userController.startProfileListner();
    userController.getMyProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Get.theme.primaryColor, statusBarIconBrightness: Brightness.light),
    );
    return Scaffold(
      backgroundColor: Get.theme.primaryColor,
      body: WillPopScope(
        onWillPop: () {
          userController.isProfileExpand.value = false;
          userController.isProfileExpand.refresh();
          userController.profileScrollController.removeListener(userController.profileScrollListener);
          dashboardController.getVideos();
          dashboardService.currentPage.value = 0;
          dashboardService.pageController.value.animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
          dashboardService.currentPage.refresh();
          dashboardService.pageController.refresh();
          return Future.value(false);
        },
        child: Obx(
          () => SafeArea(
            bottom: true,
            child: !userController.showLoader.value
                ? RefreshIndicator(
                    onRefresh: () {
                      authService.currentUser.value.userVideos = [];
                      userController.page = 0;
                      return userController.getMyProfile();
                    },
                    child: NotificationListener<ScrollEndNotification>(
                      onNotification: (scrollEnd) {
                        if (scrollEnd.metrics.atEdge) {
                          bool isTop = scrollEnd.metrics.pixels == 0;
                          print(isTop);
                          if (isTop) {
                            return false;
                          }
                          if (authService.currentUser.value.userVideos.length != authService.currentUser.value.totalVideos) {
                            userController.page = userController.page + 1;
                            userController.getMyProfile();
                          }
                        }
                        return false;
                      },
                      child: CustomScrollView(
                        shrinkWrap: true,
                        controller: userController.profileScrollController,
                        physics: AlwaysScrollableScrollPhysics(),
                        slivers: <Widget>[
                          SliverAppBar(
                            scrolledUnderElevation: 0,
                            automaticallyImplyLeading: false,
                            elevation: 1,
                            pinned: true,
                            snap: false,
                            floating: false,
                            leading: !userController.isProfileExpand.value
                                ? InkWell(
                                    onTap: () {
                                      userController.isProfileExpand.value = false;
                                      userController.isProfileExpand.refresh();
                                      userController.profileScrollController.removeListener(userController.profileScrollListener);
                                      dashboardController.getVideos();
                                      dashboardService.currentPage.value = 0;
                                      dashboardService.pageController.value.animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
                                      dashboardService.currentPage.refresh();
                                      dashboardService.pageController.refresh();
                                    },
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      color: Get.theme.iconTheme.color,
                                      size: 20,
                                    ),
                                  )
                                : SizedBox(),
                            expandedHeight: userController.sliverExpandableHgt.value,
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
                                                            Get.back();
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
                                                        imageProvider: CachedNetworkImageProvider((authService.currentUser.value.largeProfilePic.toLowerCase().contains(".jpg") ||
                                                                authService.currentUser.value.largeProfilePic.toLowerCase().contains(".jpeg") ||
                                                                authService.currentUser.value.largeProfilePic.toLowerCase().contains(".png") ||
                                                                authService.currentUser.value.largeProfilePic.toLowerCase().contains(".gif") ||
                                                                authService.currentUser.value.largeProfilePic.toLowerCase().contains(".bmp") ||
                                                                authService.currentUser.value.largeProfilePic.toLowerCase().contains("fbsbx.com") ||
                                                                authService.currentUser.value.largeProfilePic.toLowerCase().contains("googleusercontent.com"))
                                                            ? authService.currentUser.value.largeProfilePic
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
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(100),
                                                child: authService.currentUser.value.smallProfilePic != ""
                                                    ? CachedNetworkImage(
                                                        imageUrl: (authService.currentUser.value.smallProfilePic.toLowerCase().contains(".jpg") ||
                                                                authService.currentUser.value.smallProfilePic.toLowerCase().contains(".jpeg") ||
                                                                authService.currentUser.value.smallProfilePic.toLowerCase().contains(".png") ||
                                                                authService.currentUser.value.smallProfilePic.toLowerCase().contains(".gif") ||
                                                                authService.currentUser.value.smallProfilePic.toLowerCase().contains(".bmp") ||
                                                                authService.currentUser.value.smallProfilePic.toLowerCase().contains("fbsbx.com") ||
                                                                authService.currentUser.value.smallProfilePic.toLowerCase().contains("googleusercontent.com"))
                                                            ? authService.currentUser.value.smallProfilePic
                                                            : '$baseUrl' + "default/user-dummy-pic.png",
                                                        placeholder: (context, url) => CommonHelper.showLoaderSpinner(mainService.setting.value.iconColor!),
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
                                            child: Stack(
                                              children: [
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        "@${authService.currentUser.value.username}".text.color(mainService.setting.value.textColor!).size(20).make(),
                                                        authService.currentUser.value.isVerified == true
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
                                                            onTap: () async {
                                                              await userProfileController.fetchLoggedInUserInformation();
                                                              Get.toNamed('/edit-profile');
                                                            },
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                color: Get.theme.highlightColor,
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                              child: 'Edit Profile'
                                                                  .tr
                                                                  .text
                                                                  .center
                                                                  .textStyle(
                                                                    Get.textTheme.bodyLarge!.copyWith(color: Get.theme.indicatorColor, fontSize: 14),
                                                                  )
                                                                  .make()
                                                                  .centered()
                                                                  .pSymmetric(v: 5, h: 10),
                                                            ),
                                                          ).pOnly(right: 10),
                                                          InkWell(
                                                            onTap: () {
                                                              Get.toNamed("/my-profile-info");
                                                            },
                                                            child: Stack(
                                                              children: [
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                    color: Get.theme.highlightColor,
                                                                    borderRadius: BorderRadius.circular(10),
                                                                  ),
                                                                  child: 'Share Profile'
                                                                      .tr
                                                                      .text
                                                                      .center
                                                                      .textStyle(
                                                                        Get.textTheme.bodyLarge!.copyWith(color: Get.theme.indicatorColor, fontSize: 14),
                                                                      )
                                                                      .make()
                                                                      .centered()
                                                                      .pSymmetric(v: 5, h: 10),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Positioned(
                                                  right: 10,
                                                  top: 10,
                                                  child: IconButton(
                                                    onPressed: () async {
                                                      userController.myProfileScaffoldKey.currentState!.openDrawer();
                                                    },
                                                    icon: Icon(
                                                      Icons.person_2,
                                                      color: Get.theme.iconTheme.color,
                                                      size: 20.0,
                                                    ),
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
                                    Stack(
                                      children: [
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
                                                          Get.back();
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
                                                      imageProvider: CachedNetworkImageProvider((authService.currentUser.value.largeProfilePic.toLowerCase().contains(".jpg") ||
                                                              authService.currentUser.value.largeProfilePic.toLowerCase().contains(".jpeg") ||
                                                              authService.currentUser.value.largeProfilePic.toLowerCase().contains(".png") ||
                                                              authService.currentUser.value.largeProfilePic.toLowerCase().contains(".gif") ||
                                                              authService.currentUser.value.largeProfilePic.toLowerCase().contains(".bmp") ||
                                                              authService.currentUser.value.largeProfilePic.toLowerCase().contains("fbsbx.com") ||
                                                              authService.currentUser.value.largeProfilePic.toLowerCase().contains("googleusercontent.com"))
                                                          ? authService.currentUser.value.largeProfilePic
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
                                              child: authService.currentUser.value.smallProfilePic != ""
                                                  ? CachedNetworkImage(
                                                      imageUrl: (authService.currentUser.value.smallProfilePic.toLowerCase().contains(".jpg") ||
                                                              authService.currentUser.value.smallProfilePic.toLowerCase().contains(".jpeg") ||
                                                              authService.currentUser.value.smallProfilePic.toLowerCase().contains(".png") ||
                                                              authService.currentUser.value.smallProfilePic.toLowerCase().contains(".gif") ||
                                                              authService.currentUser.value.smallProfilePic.toLowerCase().contains(".bmp") ||
                                                              authService.currentUser.value.smallProfilePic.toLowerCase().contains("fbsbx.com") ||
                                                              authService.currentUser.value.smallProfilePic.toLowerCase().contains("googleusercontent.com"))
                                                          ? authService.currentUser.value.smallProfilePic
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
                                        ).centered(),
                                        Positioned(
                                          right: 10,
                                          child: Row(
                                            children: [
                                              IconButton(
                                                onPressed: () async {
                                                  WalletController walletController = Get.find();
                                                  walletController.page = 1;
                                                  walletController.fetchMyWallet();
                                                  Get.toNamed('/my-wallet');
                                                },
                                                icon: Icon(
                                                  Icons.account_balance_wallet,
                                                  color: Get.theme.iconTheme.color,
                                                  size: 25.0,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () async {
                                                  Get.toNamed("/settings");
                                                },
                                                icon: Icon(
                                                  Icons.settings,
                                                  color: Get.theme.iconTheme.color,
                                                  size: 25.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ).pOnly(bottom: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        "@${authService.currentUser.value.username}".text.color(Get.theme.indicatorColor).size(20).make(),
                                        authService.currentUser.value.isVerified == true
                                            ? Icon(
                                                Icons.verified,
                                                color: Get.theme.iconTheme.color,
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
                                            "${authService.currentUser.value.totalVideos}".text.color(Get.theme.indicatorColor).size(20).make().pOnly(bottom: 1),
                                            "Posts".tr.text.color(Get.theme.indicatorColor.withValues(alpha:0.8)).size(15).make(),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            "${authService.currentUser.value.totalVideosLike}".text.color(Get.theme.indicatorColor).size(20).make().pOnly(bottom: 1),
                                            "Likes".tr.text.color(Get.theme.indicatorColor.withValues(alpha:0.8)).size(15).make(),
                                          ],
                                        ),
                                        InkWell(
                                          onTap: () {
                                            if (authService.currentUser.value.totalFollowings != '0') {
                                              userService.followListUserId = authService.currentUser.value.id;
                                              userService.followListType.value = 0;
                                              Get.toNamed("/followers", preventDuplicates: false);
                                            }
                                          },
                                          child: Column(
                                            children: [
                                              "${authService.currentUser.value.totalFollowings}".text.color(Get.theme.indicatorColor).size(20).make().pOnly(bottom: 1),
                                              "Following".tr.text.color(Get.theme.indicatorColor.withValues(alpha:0.8)).size(15).make(),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            if (authService.currentUser.value.totalFollowers != '0') {
                                              userService.followListUserId = authService.currentUser.value.id;
                                              userService.followListType.value = 1;
                                              Get.toNamed("/followers", preventDuplicates: false);
                                            }
                                          },
                                          child: Column(
                                            children: [
                                              "${authService.currentUser.value.totalFollowers}".text.color(Get.theme.indicatorColor).size(20).make().pOnly(bottom: 1),
                                              "Followers".tr.text.color(Get.theme.indicatorColor.withValues(alpha:0.8)).size(15).make(),
                                            ],
                                          ),
                                        )
                                      ],
                                    ).pSymmetric(h: 20, v: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              await userProfileController.fetchLoggedInUserInformation();
                                              Get.toNamed('/edit-profile');
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Get.theme.highlightColor,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: 'Edit Profile'
                                                  .tr
                                                  .text
                                                  .center
                                                  .textStyle(
                                                    Get.textTheme.bodyLarge!.copyWith(color: Get.theme.primaryColor, fontSize: 18),
                                                  )
                                                  .make()
                                                  .centered()
                                                  .pSymmetric(v: 9),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              Get.toNamed("/my-profile-info");
                                            },
                                            child: Stack(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Get.theme.highlightColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  // child: 'My Friends'
                                                  child: 'Share Profile'
                                                      .tr
                                                      .text
                                                      .center
                                                      .textStyle(
                                                        Get.textTheme.bodyLarge!.copyWith(color: Get.theme.primaryColor, fontSize: 18),
                                                      )
                                                      .make()
                                                      .centered()
                                                      .pSymmetric(v: 9),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ).pSymmetric(h: 20, v: 5),
                                    SizedBox(
                                      width: Get.width,
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          return authService.currentUser.value.bio.isNotEmpty
                                              ? "${authService.currentUser.value.bio} ".text.center.color(Get.theme.indicatorColor.withValues(alpha:0.8)).size(12).make().pSymmetric(v: 5).centered()
                                              : SizedBox();
                                        },
                                      ),
                                    ),
                                    authService.currentUser.value.website.isNotEmpty
                                        ? Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/icons/link.svg',
                                                width: 15.0,
                                                colorFilter: ColorFilter.mode(Get.theme.iconTheme.color!, BlendMode.srcIn),
                                              ).pSymmetric(h: 5),
                                              "${authService.currentUser.value.website.replaceAll("https://", "").replaceAll("/", "")}"
                                                  .text
                                                  .color(
                                                    Get.theme.indicatorColor.withValues(alpha:0.8),
                                                  )
                                                  .size(12)
                                                  .bold
                                                  .make(),
                                            ],
                                          ).onTap(() {
                                            userController.launchURL(authService.currentUser.value.website);
                                          })
                                        : SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                authService.currentUser.value.userVideos.isNotEmpty
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
                                            itemCount: authService.currentUser.value.userVideos.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              final item = authService.currentUser.value.userVideos.elementAt(index);
                                              return InkWell(
                                                onTap: () async {
                                                  mainService.userVideoObj.value.userId = authService.currentUser.value.id;
                                                  mainService.userVideoObj.value.videoId = item.videoId;
                                                  mainService.userVideoObj.value.hashTag = "";
                                                  mainService.userVideoObj.refresh();
                                                  dashboardService.showFollowingPage.value = false;
                                                  dashboardService.showFollowingPage.refresh();
                                                  dashboardService.currentPage.value = 0;
                                                  dashboardService.currentPage.refresh();
                                                  dashboardService.postIds = [];
                                                  dashboardController.getVideos();
                                                  dashboardService.pageController.value.animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
                                                  dashboardService.pageController.refresh();
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
                                                                errorWidget: (context, url, error) => CachedNetworkImage(
                                                                  height: 150,
                                                                  memCacheWidth: 150,
                                                                  width: Get.width * 0.4,
                                                                  imageUrl: item.videoThumbnail,
                                                                  placeholder: (context, url) => CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                                                  fit: BoxFit.cover,
                                                                ),
                                                                fit: BoxFit.cover,
                                                              )
                                                            : item.videoThumbnail != ""
                                                                ? CachedNetworkImage(
                                                                    height: 150,
                                                                    memCacheWidth: 150,
                                                                    width: Get.width * 0.4,
                                                                    imageUrl: item.videoThumbnail,
                                                                    placeholder: (context, url) => CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                                                    fit: BoxFit.cover,
                                                                  )
                                                                : Image.asset(
                                                                    'assets/images/noVideo.jpg',
                                                                    height: 150,
                                                                    width: Get.width * 0.4,
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                      ),
                                                      Container(
                                                        width: Get.width * 0.4,
                                                        height: 150,
                                                        color: Colors.black26,
                                                      ),
                                                      Positioned(
                                                        bottom: 10,
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
                                                              Expanded(
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    showCupertinoModalPopup(
                                                                      context: context,
                                                                      builder: (BuildContext context) => CupertinoActionSheet(
                                                                        actions: [
                                                                          CupertinoActionSheetAction(
                                                                            child: Text("Edit"),
                                                                            onPressed: () {
                                                                              Get.back(closeOverlays: true);
                                                                              Get.toNamed("/edit-video");
                                                                            },
                                                                          ),
                                                                          CupertinoActionSheetAction(
                                                                            child: Text("Delete"),
                                                                            onPressed: () {
                                                                              Get.back(closeOverlays: true);
                                                                              userController.showDeleteAlert("Delete Confirmation".tr, "Do you realy want to delete the video".tr, item.videoId);
                                                                            },
                                                                          ),
                                                                        ],
                                                                        cancelButton: CupertinoActionSheetAction(
                                                                          child: Text("Cancel".tr),
                                                                          onPressed: () {
                                                                            Get.back(closeOverlays: true);
                                                                          },
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child: Icon(
                                                                    Icons.more_vert,
                                                                    size: 18,
                                                                    color: Get.theme.iconTheme.color,
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
                  )
                : Container(),
          ),
        ),
      ),
      // drawer: Container(
      //   width: 250,
      //   child: Drawer(
      //     child: Stack(
      //       children: [
      //         Container(
      //           color: mainService.setting.value.appbarColor,
      //           child: ListView(
      //             padding: EdgeInsets.zero,
      //             children: <Widget>[
      //               Container(
      //                 height: 150,
      //                 child: DrawerHeader(
      //                   child: Row(
      //                     children: [
      //                       Expanded(
      //                         child: Container(
      //                           height: 80,
      //                           width: 80,
      //                           decoration: BoxDecoration(
      //                             borderRadius: BorderRadius.circular(100),
      //                             color: mainService.setting.value.accentColor,
      //                           ),
      //                           child: ClipRRect(
      //                             borderRadius: BorderRadius.circular(100),
      //                             child: authService.currentUser.value.smallProfilePic != null
      //                                 ? CachedNetworkImage(
      //                                     imageUrl: (authService.currentUser.value.smallProfilePic.toLowerCase().contains(".jpg") ||
      //                                             authService.currentUser.value.smallProfilePic.toLowerCase().contains(".jpeg") ||
      //                                             authService.currentUser.value.smallProfilePic.toLowerCase().contains(".png") ||
      //                                             authService.currentUser.value.smallProfilePic.toLowerCase().contains(".gif") ||
      //                                             authService.currentUser.value.smallProfilePic.toLowerCase().contains(".bmp") ||
      //                                             authService.currentUser.value.smallProfilePic.toLowerCase().contains("fbsbx.com") ||
      //                                             authService.currentUser.value.smallProfilePic.toLowerCase().contains("googleusercontent.com"))
      //                                         ? authService.currentUser.value.smallProfilePic
      //                                         : '$baseUrl' + "default/user-dummy-pic.png",
      //                                     placeholder: (context, url) => CommonHelper.showLoaderSpinner(mainService.setting.value.iconColor!),
      //                                     fit: BoxFit.fill,
      //                                     width: 80,
      //                                     height: 80,
      //                                   )
      //                                 : Image.asset(
      //                                     'assets/images/default-user.png',
      //                                     fit: BoxFit.fill,
      //                                     width: 80,
      //                                     height: 80,
      //                                   ),
      //                           ).pLTRB(3, 3, 3, 3),
      //                         ).objectCenterLeft(),
      //                       ),
      //                       Expanded(
      //                         child: Column(
      //                           mainAxisAlignment: MainAxisAlignment.center,
      //                           crossAxisAlignment: CrossAxisAlignment.start,
      //                           children: [
      //                             "${authService.currentUser.value.name}".text.color(mainService.setting.value.accentColor!).ellipsis.bold.size(18).make(),
      //                             SizedBox(
      //                               height: 8,
      //                             ),
      //                             "(${authService.currentUser.value.username})".text.color(mainService.setting.value.textColor!).ellipsis.size(14).make(),
      //                           ],
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                   decoration: BoxDecoration(
      //                     color: Color(0XFF15161a).withValues(alpha:0.1),
      //                     border: Border(
      //                       bottom: BorderSide(
      //                         width: 0.5,
      //                         color: mainService.setting.value.dividerColor!,
      //                       ),
      //                     ),
      //                   ),
      //                   margin: EdgeInsets.all(0.0),
      //                   padding: EdgeInsets.symmetric(
      //                     horizontal: 20,
      //                     vertical: 20,
      //                   ),
      //                 ),
      //               ),
      //               ListTile(
      //                 // contentPadding: EdgeInsets.zero,
      //                 leading: Icon(
      //                   Icons.person,
      //                   color: mainService.setting.value.iconColor,
      //                   size: 25,
      //                 ),
      //                 title: 'Edit Profile'.text.color(mainService.setting.value.textColor!).size(16).wide.make(),
      //                 onTap: () {
      //                   Get.back(closeOverlays: true);
      //                   Get.toNamed("/edit-profile");
      //                 },
      //               ),
      //               ListTile(
      //                 leading: Icon(
      //                   Icons.verified_user,
      //                   color: mainService.setting.value.iconColor,
      //                   size: 25,
      //                 ),
      //                 title: 'Verification'.text.color(mainService.setting.value.textColor!).size(16).wide.make(),
      //                 onTap: () {
      //                   Get.back(closeOverlays: true);
      //                   Get.toNamed('/verify-profile');
      //                 },
      //               ),
      //               ListTile(
      //                 leading: Icon(
      //                   Icons.block,
      //                   color: mainService.setting.value.iconColor,
      //                   size: 25,
      //                 ),
      //                 title: 'Blocked User'.tr.text.color(mainService.setting.value.textColor!).size(16).wide.make(),
      //                 onTap: () {
      //                   Get.back(closeOverlays: true);
      //                   Get.toNamed('/blocked-users');
      //                 },
      //               ),
      //               ListTile(
      //                 leading: Icon(
      //                   Icons.lock,
      //                   color: mainService.setting.value.iconColor,
      //                   size: 25,
      //                 ),
      //                 title: 'Change Password'.tr.text.color(mainService.setting.value.textColor!).size(16).wide.make(),
      //                 onTap: () {
      //                   Get.back(closeOverlays: true);
      //                   Get.toNamed('/change-password');
      //                 },
      //               ),
      //               /*ListTile(
      //                       leading: Icon(
      //                         Icons.delete_forever,
      //                         color: mainService.setting.value.iconColor,
      //                         textDirection:UI.TextDirection.rtl,
      //                         size: 25,
      //                       ),
      //                       title: 'Delete Profile Instruction'.text.color(mainService.setting.value.textColor!).size(16).wide.make(),
      //                       onTap: () {
      //                         String url = GlobalConfiguration().get('base_url') + "data-delete";
      //                         _con.launchURL(url);
      //                       },
      //                     ),*/
      //               ListTile(
      //                 leading: Icon(
      //                   Icons.notifications,
      //                   color: mainService.setting.value.iconColor,
      //                   textDirection: UI.TextDirection.rtl,
      //                   size: 25,
      //                 ),
      //                 title: 'Notifications'.text.color(mainService.setting.value.textColor!).size(16).wide.make(),
      //                 onTap: () {
      //                   Get.toNamed("/notification-settings");
      //                 },
      //               ),
      //               ListTile(
      //                 leading: Icon(
      //                   Icons.language,
      //                   color: mainService.setting.value.iconColor,
      //                   textDirection: UI.TextDirection.rtl,
      //                   size: 25,
      //                 ),
      //                 title: 'Languages'.tr.text.color(mainService.setting.value.textColor!).size(16).wide.make(),
      //                 onTap: () {
      //                   Get.toNamed("/languages");
      //                 },
      //               ),
      //               ListTile(
      //                 leading: Icon(
      //                   Icons.chat,
      //                   color: mainService.setting.value.iconColor,
      //                   textDirection: UI.TextDirection.rtl,
      //                   size: 25,
      //                 ),
      //                 title: 'Chat Setting'.tr.text.color(mainService.setting.value.textColor!).size(16).wide.make(),
      //                 onTap: () {
      //                   Get.toNamed("/chat-settings");
      //                 },
      //               ),
      //               ListTile(
      //                 leading: Icon(
      //                   Icons.delete_forever,
      //                   color: mainService.setting.value.iconColor,
      //                   textDirection: UI.TextDirection.rtl,
      //                   size: 25,
      //                 ),
      //                 title: 'Delete Profile'.tr.text.color(mainService.setting.value.textColor!).size(16).wide.make(),
      //                 onTap: () {
      //                   Get.back(closeOverlays: true);
      //                   userController.deleteProfileConfirmation().whenComplete(() async {
      //                     dashboardService.showFollowingPage.value = false;
      //                     dashboardService.showFollowingPage.refresh();
      //                     dashboardController.getVideos();
      //                     Get.offNamed("/home");
      //                   });
      //                 },
      //               ),
      //               ListTile(
      //                 leading: Icon(
      //                   Icons.logout,
      //                   color: mainService.setting.value.iconColor,
      //                   textDirection: UI.TextDirection.rtl,
      //                   size: 25,
      //                 ),
      //                 title: 'Logout'.tr.text.color(mainService.setting.value.textColor!).size(16).wide.make(),
      //                 onTap: () async {
      //                   Get.back(closeOverlays: true);
      //                   await userController.logout();
      //                   dashboardService.showFollowingPage.value = false;
      //                   dashboardService.showFollowingPage.refresh();
      //                   dashboardService.currentPage.value = 0;
      //                   dashboardService.currentPage.refresh();
      //                   dashboardController.getVideos();
      //                   dashboardService.pageController.value.animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
      //                   dashboardService.pageController.refresh();
      //                 },
      //               ),
      //             ],
      //           ),
      //         ),
      //         Positioned(
      //           bottom: 0,
      //           left: 10,
      //           child: Container(
      //             child: Center(
      //               child: Padding(
      //                 padding: const EdgeInsets.all(8.0),
      //                 child: Text(
      //                   "${'App Version'.tr}:  ${authService.currentUser.value.appVersion}",
      //                   style: TextStyle(
      //                     color: mainService.setting.value.textColor,
      //                   ),
      //                 ),
      //               ),
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
