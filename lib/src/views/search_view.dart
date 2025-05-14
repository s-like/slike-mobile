import 'dart:async';

import 'package:animations/animations.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core.dart';

class SearchView extends StatefulWidget {
  SearchView({Key? key}) : super(key: key);
  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  SearchViewController searchController = Get.find();
  SearchService searchService = Get.find();
  AuthService authService = Get.find();
  MainService mainService = Get.find();
  DashboardService dashboardService = Get.find();
  DashboardController dashboardController = Get.find();

  @override
  void initState() {
    print(
        "dashboardController.showBannerAd.value ${dashboardController.showBannerAd.value} ${dashboardService.bottomPadding.value} ${dashboardService.bottomPadding.value + Get.mediaQuery.viewPadding.bottom + 50} ${Get.height}");
    super.initState();
    searchController.getAds();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (Get.currentRoute == "/search") {
          searchService.currentHashTag.value = BannerModel.fromJSON({});
          searchService.currentHashTag.refresh();
          dashboardService.showFollowingPage.value = false;
          dashboardService.showFollowingPage.refresh();
          Get.offNamed('/home');
          return Future.value(true);
        } else {
          return Future.value(false);
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          if (searchService.currentHashTag.value != BannerModel.fromJSON({})) {
            searchService.currentHashTag.value = BannerModel.fromJSON({});
            searchService.currentHashTag.refresh();
            Get.back();
            return Future.value(false);
          } else {
            dashboardService.showFollowingPage.value = false;
            dashboardService.showFollowingPage.refresh();
            dashboardController.getVideos();
            dashboardService.currentPage.value = 0;
            dashboardService.pageController.value.animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
            dashboardService.pageController.refresh();
            return Future.value(false);
          }
        },
        child: Scaffold(
          backgroundColor: Get.theme.primaryColor,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Get.theme.primaryColor,
            leadingWidth: 50,
            leading: GestureDetector(
              onTap: () async {
                print("currentRouteName ${Get.currentRoute}");
                searchService.currentHashTag.value = BannerModel.fromJSON({});
                searchService.currentHashTag.refresh();
                if (Get.currentRoute == "/search") {
                  searchService.currentHashTag.value = BannerModel.fromJSON({});
                  searchService.currentHashTag.refresh();
                  dashboardService.showFollowingPage.value = false;
                  dashboardService.showFollowingPage.refresh();
                  Get.offNamed('/home');
                  // dashboardController.getVideos();
                } else {
                  dashboardService.showFollowingPage.value = false;
                  dashboardService.showFollowingPage.refresh();
                  // dashboardController.getVideos();
                  dashboardService.currentPage.value = 0;
                  dashboardService.pageController.value.animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
                  dashboardService.pageController.refresh();
                }
              },
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: Get.theme.iconTheme.color,
              ),
            ),
            title: TextField(
              controller: searchController.searchController,
              style: TextStyle(
                color: Get.theme.iconTheme.color,
                fontSize: 16.0,
              ),
              obscureText: false,
              keyboardType: TextInputType.text,
              onChanged: (String val) {
                setState(() {
                  searchController.searchKeyword = val;
                });
                if (val.length > 2) {
                  Timer(Duration(seconds: 1), () {
                    searchController.getSearchData(1);
                  });
                }
                if (val.length == 0) {
                  searchController.page = 1;
                  searchController.getData();
                }
              },
              decoration: new InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Get.theme.highlightColor, width: 0.3),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Get.theme.highlightColor, width: 0.3),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Get.theme.dividerColor, width: 0.3),
                ),
                hintText: "Search".tr,
                hintStyle: TextStyle(fontSize: 16.0, color: Get.theme.indicatorColor.withValues(alpha:0.6)),
                suffixIcon: IconButton(
                  padding: EdgeInsets.only(bottom: 12),
                  onPressed: () {
                    searchController.searchController.clear();
                    searchController.searchKeyword = "";
                    searchController.page = 1;
                    searchController.getData();
                  },
                  icon: Icon(
                    Icons.clear,
                    color: (searchController.searchKeyword.length > 0) ? Colors.grey : Get.theme.primaryColor,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
          body: Container(
            height: Get.height - (dashboardService.bottomPadding.value + Get.mediaQuery.viewPadding.bottom + 50),
            child: Stack(
              children: [
                Obx(() {
                  print("searchService.currentHashTag.value.tag ${searchService.currentHashTag.value.tag}");
                  return SingleChildScrollView(
                    controller: searchController.scrollController,
                    child: searchController.searchKeyword == ""
                        ? Container(
                            width: Get.width,
                            color: Get.theme.primaryColor,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10, left: 10),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      child: Text(
                                        'Challenges'.tr,
                                        style: TextStyle(
                                          color: Get.theme.indicatorColor,
                                          fontSize: 19,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 150,
                                  width: Get.width,
                                  child: CarouselSlider(
                                    options: CarouselOptions(
                                      enlargeCenterPage: true,
                                      viewportFraction: 0.98,
                                      aspectRatio: 2.0,
                                      height: 170.0,
                                      initialPage: 0,
                                      autoPlay: true,
                                      autoPlayInterval: Duration(seconds: 8),
                                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                                      enableInfiniteScroll: true,
                                      reverse: false,
                                    ),
                                    items: searchService.searchPageData.value.banners.map((var bannerHashtag) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return OpenContainer(
                                            transitionType: ContainerTransitionType.fade,
                                            tappable: false,
                                            onClosed: (v) {},
                                            openBuilder: (BuildContext context, VoidCallback _) {
                                              return HashVideosView();
                                            },
                                            useRootNavigator: true,
                                            transitionDuration: Duration(seconds: 2),
                                            closedElevation: 6.0,
                                            closedShape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(15),
                                              ),
                                            ),
                                            closedColor: Colors.black,
                                            closedBuilder: (BuildContext context, VoidCallback openContainer) {
                                              return Container(
                                                width: Get.width,
                                                child: CachedNetworkImage(
                                                  imageUrl: bannerHashtag.banner,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) => Center(
                                                    child: CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                                  ),
                                                ),
                                              ).onTap(() {
                                                openContainer();
                                                searchController.page = 1;
                                                print("bannerHashtag ${bannerHashtag.tag}");
                                                searchService.currentHashTag.value = bannerHashtag;
                                                searchController.getHashTagPageData();
                                              });
                                            },
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 13, bottom: 2, left: 10),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      child: Text(
                                        searchService.currentHashTag.value.tag != "" ? "Top Videos".tr : 'Recommended'.tr,
                                        style: TextStyle(
                                          color: Get.theme.indicatorColor,
                                          fontSize: 19,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                (searchService.searchPageData.value.videos.isNotEmpty)
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 8.0, left: 3, right: 3),
                                        child: Container(
                                          width: Get.width,
                                          // height: Get.height -
                                          //     ((searchService.currentHashTag.value.tag == "" && searchService.hashData.value.banners.isNotEmpty ? 400 : 190) +
                                          //         dashboardService.bottomPadding.value +
                                          //         Get.mediaQuery.viewPadding.bottom +
                                          //         50),
                                          child: GridView.builder(
                                            primary: false,
                                            padding: const EdgeInsets.all(2),
                                            shrinkWrap: true,
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                                              height: 150,
                                              crossAxisCount: 3,
                                              crossAxisSpacing: 1,
                                              mainAxisSpacing: 1,
                                            ),
                                            // itemCount: searchService.hashData.value.videos.length,
                                            itemCount: searchService.searchPageData.value.videos.length,
                                            itemBuilder: (BuildContext context, int i) {
                                              return GestureDetector(
                                                onTap: () async {
                                                  print("searchService.currentHashTag.value.id");
                                                  print(searchService.currentHashTag.value.id.toString() + mainService.userVideoObj.value.hashTag + searchService.currentHashTag.value.tag);
                                                  if (searchService.currentHashTag.value.id > 0) {
                                                    mainService.userVideoObj.value.hashTag = searchService.currentHashTag.value.tag;
                                                    mainService.userVideoObj.value.name = "#${searchService.currentHashTag.value.tag}";
                                                  } else {
                                                    mainService.userVideoObj.value.userId = searchService.searchPageData.value.videos[i].userId;
                                                    mainService.userVideoObj.value.name = searchService.searchPageData.value.videos[i].username + "'s";
                                                  }
                                                  mainService.userVideoObj.value.videoId = searchService.searchPageData.value.videos[i].id;
                                                  searchService.currentHashTag.value = BannerModel.fromJSON({});
                                                  searchService.currentHashTag.refresh();
                                                  dashboardController.getVideos().whenComplete(() {
                                                    dashboardService.currentPage.value = 0;
                                                    dashboardService.pageController.value
                                                        .animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
                                                    dashboardService.pageController.refresh();
                                                  });
                                                },
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: <Widget>[
                                                    Container(
                                                        height: Get.height,
                                                        width: Get.width,
                                                        child: searchService.searchPageData.value.videos[i].thumb != ""
                                                            ? Container(
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(mainService.setting.value.gridBorderRadius),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Get.theme.shadowColor.withValues(alpha:0.5),
                                                                      blurRadius: 3.0, // soften the shadow
                                                                      spreadRadius: 0.0, //extend the shadow
                                                                      offset: Offset(
                                                                        0.0, // Move to right 10  horizontally
                                                                        0.0, // Move to bottom 5 Vertically
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                // padding: const EdgeInsets.all(1),
                                                                child: CachedNetworkImage(
                                                                  imageUrl: searchService.searchPageData.value.videos[i].thumb,
                                                                  placeholder: (context, url) => Center(
                                                                    child: CommonHelper.showLoaderSpinner(Get.theme.highlightColor),
                                                                  ),
                                                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              )
                                                            : ClipRRect(
                                                                borderRadius: BorderRadius.circular(5.0),
                                                                child: Image.asset(
                                                                  'assets/images/noVideo.jpg',
                                                                  fit: BoxFit.fill,
                                                                ),
                                                              )),
                                                    Positioned(
                                                      bottom: 20,
                                                      child: Container(
                                                        width: 35.0,
                                                        height: 35.0,
                                                        decoration: new BoxDecoration(
                                                          borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                                                          border: new Border.all(
                                                            color: Get.theme.shadowColor.withValues(alpha:0.5),
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        child: Container(
                                                          width: 35.0,
                                                          height: 35.0,
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(50.0),
                                                            child: CachedNetworkImage(
                                                              imageUrl: searchService.searchPageData.value.videos[i].dp,
                                                              placeholder: (context, url) => CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                                              height: 60.0,
                                                              width: 60.0,
                                                              fit: BoxFit.fitHeight,
                                                              errorWidget: (a, b, c) {
                                                                return Image.asset(
                                                                  "assets/images/video-logo.png",
                                                                  fit: BoxFit.cover,
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: 5,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            searchService.searchPageData.value.videos[i].username,
                                                            style: TextStyle(
                                                              color: Get.theme.primaryColor,
                                                              fontSize: 11,
                                                              fontFamily: 'RockWellStd',
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          searchService.searchPageData.value.videos[i].isVerified == true ? SizedBox(width: 5) : Container(),
                                                          searchService.searchPageData.value.videos[i].isVerified == true
                                                              ? Icon(
                                                                  Icons.verified,
                                                                  color: Colors.blueAccent,
                                                                  size: 16,
                                                                )
                                                              : Container(),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                    : (!searchController.showLoader.value)
                                        ? Center(
                                            child: Container(
                                              height: Get.height - 360,
                                              width: Get.width,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.videocam,
                                                    size: 30,
                                                    color: Get.theme.iconTheme.color,
                                                  ),
                                                  Text(
                                                    "No Videos Found".tr,
                                                    style: TextStyle(
                                                      color: Get.theme.indicatorColor.withValues(alpha:0.6),
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
                          )
                        : Container(
                            width: Get.width,
                            color: Get.theme.primaryColor,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10, left: 10),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      child: Text(
                                        'Tags'.tr,
                                        style: TextStyle(
                                          color: Get.theme.indicatorColor,
                                          fontSize: 19,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                if (dashboardController.showBannerAd.value) Center(child: Container(width: Get.width, child: BannerAdWidget())),
                                SizedBox(
                                  height: 15,
                                ),
                                (searchService.searchData.value.hashTags.length > 0)
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: Get.width,
                                          height: Get.height * 0.12,
                                          child: ListView.builder(
                                            controller: searchController.hashScrollController,
                                            primary: false,
                                            scrollDirection: Axis.horizontal,
                                            padding: const EdgeInsets.all(10),
                                            itemCount: searchService.searchData.value.hashTags.length,
                                            itemBuilder: (BuildContext context, int i) {
                                              return Container(
                                                padding: EdgeInsets.all(3.0),
                                                child: InkWell(
                                                  onTap: () async {
                                                    SearchService searchService = Get.find();
                                                    searchService.currentHashTag.value.tag = searchService.searchData.value.hashTags[i].toString().replaceAll("#", "");
                                                    searchService.navigatedToHashVideoPageFromDashboard.value = true;
                                                    SearchViewController searchController = Get.find();
                                                    await searchController.getHashTagPageData();
                                                    Get.offNamed("/hash-tag");
                                                  },
                                                  child: Center(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(mainService.setting.value.gridBorderRadius),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: mainService.setting.value.gridItemBorderColor!,
                                                            blurRadius: 3.0, // soften the shadow
                                                            spreadRadius: 0.0, //extend the shadow
                                                            offset: Offset(
                                                              0.0, // Move to right 10  horizontally
                                                              0.0, // Move to bottom 5 Vertically
                                                            ),
                                                          )
                                                        ],
                                                        color: Get.theme.highlightColor,
                                                      ),
                                                      padding: const EdgeInsets.all(10),
                                                      child: Text(
                                                        "#" + searchService.searchData.value.hashTags[i].toString(),
                                                        style: TextStyle(color: Get.theme.indicatorColor),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                    : (!searchController.showLoader.value)
                                        ? Center(
                                            child: Container(
                                              height: Get.height / 4,
                                              width: Get.width,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.person,
                                                    size: 30,
                                                    color: Get.theme.iconTheme.color,
                                                  ),
                                                  Text(
                                                    "No Tags Found".tr,
                                                    style: TextStyle(
                                                      color: Get.theme.indicatorColor.withValues(alpha:0.5),
                                                      fontSize: 15,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container(),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10, left: 10),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      child: Text(
                                        'Users'.tr,
                                        style: TextStyle(
                                          color: Get.theme.indicatorColor,
                                          fontSize: 19,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                (searchService.searchData.value.users.length > 0)
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: Get.width,
                                          height: Get.height * 0.25,
                                          child: ListView.builder(
                                            controller: searchController.userScrollController,
                                            primary: false,
                                            scrollDirection: Axis.horizontal,
                                            padding: const EdgeInsets.all(2),
                                            itemCount: searchService.searchData.value.users.length,
                                            itemBuilder: (BuildContext context, int i) {
                                              return Container(
                                                padding: EdgeInsets.all(3.0),
                                                width: Get.width * 0.30,
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    if (searchService.searchData.value.users[i].userId == authService.currentUser.value.id) {
                                                      dashboardService.currentPage.value = 4;
                                                      dashboardService.currentPage.refresh();
                                                      dashboardService.pageController.value
                                                          .animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
                                                      dashboardService.pageController.refresh();
                                                    } else {
                                                      UserController userCon = Get.find();
                                                      userCon.openUserProfile(searchService.searchData.value.users[i].userId);
                                                    }
                                                  },
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: <Widget>[
                                                      Container(
                                                        height: Get.height,
                                                        width: Get.width,
                                                        child: searchService.searchData.value.users[i].userDP != ""
                                                            ? Container(
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(mainService.setting.value.gridBorderRadius),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: mainService.setting.value.gridItemBorderColor!,
                                                                      blurRadius: 3.0, // soften the shadow
                                                                      spreadRadius: 0.0, //extend the shadow
                                                                      offset: Offset(
                                                                        0.0, // Move to right 10  horizontally
                                                                        0.0, // Move to bottom 5 Vertically
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                padding: const EdgeInsets.all(1),
                                                                child: ClipRRect(
                                                                  borderRadius: BorderRadius.circular(
                                                                    5.0,
                                                                  ),
                                                                  child: CachedNetworkImage(
                                                                    imageUrl: searchService.searchData.value.users[i].userDP,
                                                                    placeholder: (context, url) => Center(
                                                                      child: CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                                                    ),
                                                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                ),
                                                              )
                                                            : ClipRRect(
                                                                borderRadius: BorderRadius.circular(5.0),
                                                                child: Image.asset(
                                                                  'assets/images/noVideo.jpg',
                                                                  fit: BoxFit.fill,
                                                                ),
                                                              ),
                                                      ),
                                                      Positioned(
                                                        bottom: 20,
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              padding: EdgeInsets.symmetric(horizontal: 5),
                                                              child: Text(
                                                                "${searchService.searchData.value.users[i].fName}  \n"
                                                                "${searchService.searchData.value.users[i].lName} ",
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  color: Get.theme.indicatorColor,
                                                                  fontSize: 11,
                                                                  fontFamily: 'RockWellStd',
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ),
                                                            searchService.searchData.value.users[i].isVerified == true ? SizedBox(width: 5) : Container(),
                                                            searchService.searchData.value.users[i].isVerified == true
                                                                ? Icon(
                                                                    Icons.verified,
                                                                    color: Get.theme.highlightColor,
                                                                    size: 16,
                                                                  )
                                                                : Container(),
                                                          ],
                                                        ),
                                                      ),
                                                      Positioned(
                                                        bottom: 5,
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              padding: EdgeInsets.symmetric(horizontal: 5),
                                                              child: Text(
                                                                searchService.searchData.value.users[i].username,
                                                                style: TextStyle(
                                                                  color: Get.theme.indicatorColor,
                                                                  fontSize: 11,
                                                                  fontFamily: 'RockWellStd',
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ),
                                                            searchService.searchData.value.users[i].isVerified == true ? SizedBox(width: 5) : Container(),
                                                            searchService.searchData.value.users[i].isVerified == true
                                                                ? Icon(
                                                                    Icons.verified,
                                                                    color: Get.theme.highlightColor,
                                                                    size: 16,
                                                                  )
                                                                : Container(),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                    : (!searchController.showLoader.value)
                                        ? Center(
                                            child: Container(
                                              height: Get.height / 4,
                                              width: Get.width,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.person,
                                                    size: 30,
                                                    color: Get.theme.iconTheme.color,
                                                  ),
                                                  Text(
                                                    "No Users Found".tr,
                                                    style: TextStyle(
                                                      color: Get.theme.indicatorColor.withValues(alpha:0.6),
                                                      fontSize: 15,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container(),
                                Padding(
                                  padding: const EdgeInsets.only(top: 13, bottom: 2, left: 10),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      child: Text(
                                        'Videos',
                                        style: TextStyle(
                                          color: Get.theme.indicatorColor,
                                          fontSize: 19,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                (searchService.searchData.value.videos.length > 0)
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: Get.width,
                                          height: Get.height * (0.35),
                                          child: ListView.builder(
                                            controller: searchController.videoScrollController,
                                            primary: false,
                                            scrollDirection: Axis.horizontal,
                                            padding: const EdgeInsets.all(2),
                                            itemCount: searchService.searchData.value.videos.length,
                                            itemBuilder: (BuildContext context, int i) {
                                              return Container(
                                                padding: EdgeInsets.all(3.0),
                                                width: Get.width * (0.43),
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    print("searchService.currentHashTag.value.id");
                                                    print(searchService.currentHashTag.value.id.toString() + mainService.userVideoObj.value.hashTag + searchService.currentHashTag.value.tag);
                                                    print(searchService.currentHashTag.value.tag);
                                                    if (searchService.currentHashTag.value.id > 0) {
                                                      mainService.userVideoObj.value.hashTag = searchService.currentHashTag.value.tag;
                                                      mainService.userVideoObj.value.name = "#${searchService.currentHashTag.value.tag}";
                                                    } else {
                                                      mainService.userVideoObj.value.userId = searchService.searchData.value.videos[i].userId;
                                                      mainService.userVideoObj.value.name = searchService.searchData.value.videos[i].username + "'s";
                                                    }
                                                    mainService.userVideoObj.value.userId = searchService.searchData.value.videos[i].userId;
                                                    mainService.userVideoObj.value.videoId = searchService.searchData.value.videos[i].id;
                                                    mainService.userVideoObj.value.name = searchService.searchData.value.videos[i].username + "'s";
                                                    searchService.currentHashTag.value = BannerModel.fromJSON({});
                                                    searchService.currentHashTag.refresh();
                                                    dashboardService.currentPage.value = 0;
                                                    dashboardService.postIds = [];
                                                    dashboardController.getVideos().whenComplete(() {
                                                      dashboardService.pageController.value
                                                          .animateToPage(dashboardService.currentPage.value, duration: Duration(milliseconds: 100), curve: Curves.linear);
                                                      dashboardService.pageController.refresh();
                                                    });
                                                  },
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: <Widget>[
                                                      Container(
                                                          height: Get.height,
                                                          width: Get.width,
                                                          child: searchService.searchData.value.videos[i].thumb != ""
                                                              ? Container(
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(mainService.setting.value.gridBorderRadius),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: mainService.setting.value.gridItemBorderColor!,
                                                                        blurRadius: 3.0, // soften the shadow
                                                                        spreadRadius: 0.0, //extend the shadow
                                                                        offset: Offset(
                                                                          0.0, // Move to right 10  horizontally
                                                                          0.0, // Move to bottom 5 Vertically
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  padding: const EdgeInsets.all(1),
                                                                  child: ClipRRect(
                                                                    borderRadius: BorderRadius.circular(
                                                                      5.0,
                                                                    ),
                                                                    child: CachedNetworkImage(
                                                                      imageUrl: searchService.searchData.value.videos[i].thumb,
                                                                      placeholder: (context, url) => Center(
                                                                        child: CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color),
                                                                      ),
                                                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                                                      fit: BoxFit.cover,
                                                                    ),
                                                                  ),
                                                                )
                                                              : ClipRRect(
                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                  child: Image.asset(
                                                                    'assets/images/noVideo.jpg',
                                                                    fit: BoxFit.fill,
                                                                  ),
                                                                )),
                                                      Positioned(
                                                        bottom: 20,
                                                        child: Container(
                                                          width: 35.0,
                                                          height: 35.0,
                                                          decoration: new BoxDecoration(
                                                            borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                                                            border: new Border.all(
                                                              color: Get.theme.shadowColor.withValues(alpha:0.5),
                                                              width: 1.0,
                                                            ),
                                                          ),
                                                          child: Container(
                                                            width: 35.0,
                                                            height: 35.0,
                                                            decoration: new BoxDecoration(
                                                              image: new DecorationImage(
                                                                  image: (searchService.searchData.value.videos[i].dp != "")
                                                                      ? CachedNetworkImageProvider(
                                                                          searchService.searchData.value.videos[i].dp,
                                                                        )
                                                                      : AssetImage(
                                                                          'assets/images/default-user.png',
                                                                        ) as ImageProvider,
                                                                  fit: BoxFit.contain),
                                                              borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        bottom: 5,
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              searchService.searchData.value.videos[i].username,
                                                              style: TextStyle(
                                                                color: Get.theme.indicatorColor,
                                                                fontSize: 11,
                                                                fontFamily: 'RockWellStd',
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            searchService.searchData.value.videos[i].isVerified == true ? SizedBox(width: 5) : Container(),
                                                            searchService.searchData.value.videos[i].isVerified == true
                                                                ? Icon(
                                                                    Icons.verified,
                                                                    color: Get.theme.highlightColor,
                                                                    size: 16,
                                                                  )
                                                                : Container(),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                    : (!searchController.showLoader.value)
                                        ? Center(
                                            child: Container(
                                              height: Get.height / 4,
                                              width: Get.width,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.videocam,
                                                    size: 30,
                                                    color: Get.theme.iconTheme.color,
                                                  ),
                                                  Text(
                                                    "No Videos Found".tr,
                                                    style: TextStyle(
                                                      color: Get.theme.indicatorColor,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container(),
                              ],
                            ),
                          ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingMenu {
  static const String LOGOUT = 'Logout';
  static const String EDIT_PROFILE = 'Edit Profile';
  static const List<String> choices = <String>[EDIT_PROFILE, LOGOUT];
}
