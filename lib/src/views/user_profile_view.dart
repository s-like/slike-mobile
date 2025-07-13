import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  @override
  void initState() {
    userController.page = 1;
    userController.isProfileExpand.value = false;
    userController.isProfileExpand.refresh();
    userController.startProfileListner();
    fetchUserProfile();
    userController.getAds();
    super.initState();
  }

  Future fetchUserProfile() async {
    await userController.getUsersProfile(userController.page);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.black, statusBarIconBrightness: Brightness.light),
    );
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.black,
        body: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              // HEADER
              _buildHeader(),
              // TAB BAR
              _buildTabBar(),
              // MAIN CONTENT
              _buildTabBarView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        // Background image
        Container(
          width: double.infinity,
          height: 340,
          child: userService.userProfile.value.largeProfilePic.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: userService.userProfile.value.largeProfilePic,
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.4),
                  colorBlendMode: BlendMode.darken,
                )
              : Image.asset('assets/images/default-user.png', fit: BoxFit.cover),
        ),
        // Top right chat icon
        Positioned(
          top: 50,
          right: 10,
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
          ),
        ),
        // User Name and Follow icon
        Positioned(
          left: 0,
          right: 0,
          bottom: 16,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userService.userProfile.value.name.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(width: 15),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFD600),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person_add, color: Colors.black, size: 24),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.black,
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        indicatorColor: Color(0xFFFFD600),
        indicatorWeight: 4,
        labelColor: Color(0xFFFFD600),
        unselectedLabelColor: Colors.white,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
        tabs: [
          Tab(text: 'BIO'),
          Tab(text: 'SHORT'),
          Tab(text: 'FEEDS'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return Expanded(
      child: TabBarView(
        children: [
          _buildBioTab(),
          _buildVideosGrid(),
          _buildVideosGrid(),
        ],
      ),
    );
  }

  Widget _buildBioTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialIcon('assets/icons/facebook.svg', Color(0xFF1877F3)),
                _buildSocialIcon('assets/icons/google.svg', Colors.red),
                _buildSocialIcon('assets/icons/chat.svg', Colors.blueAccent),
                _buildSocialIcon('assets/icons/share.svg', Colors.green),
                _buildSocialIcon('assets/icons/wallet.svg', Colors.purple),
              ],
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Text('FITNESS COACH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(width: 8),
                Icon(Icons.shield, color: Colors.orange, size: 24),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: Color(0xFFFFD600), shape: BoxShape.circle),
                ),
                SizedBox(width: 8),
                Text('${CommonHelper.formatter(userService.userProfile.value.totalFollowers.toString())} followers',
                    style: TextStyle(color: Color(0xFFFFD600), fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            SizedBox(height: 20),
            _buildInfoRow(Icons.fitness_center, 'Athlète'),
            SizedBox(height: 12),
            _buildInfoRow(Icons.emoji_events, 'M.olympiade 2026 champion d\'olympiade'),
            SizedBox(height: 12),
            _buildInfoRow(Icons.people, 'champion du peuple 23'),
            SizedBox(height: 12),
            _buildInfoRow(Icons.store, 'Propriétaire@ champ'),
            SizedBox(height: 12),
            _buildInfoRow(Icons.card_giftcard, '@champibell'),
            SizedBox(height: 12),
            _buildInfoRow(Icons.local_dining, '@abcnutrition'),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(String assetPath, Color bgColor) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(assetPath, width: 20, height: 20, colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn)),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.amber, size: 20),
        SizedBox(width: 12),
        Expanded(child: Text(text, style: TextStyle(color: Colors.white, fontSize: 15))),
      ],
    );
  }

  Widget _buildVideosGrid() {
    return Obx(() {
      final videos = userService.userProfile.value.userVideos;
      final isLoading = userController.videosLoader.value;

      if (isLoading && videos.isEmpty) {
        return Center(child: CircularProgressIndicator(color: Color(0xFFFFD600)));
      }

      if (videos.isEmpty) {
        return Center(
          child: Text("No videos yet!", style: TextStyle(color: Colors.white, fontSize: 16)),
        );
      }
      return NotificationListener<ScrollEndNotification>(
        onNotification: (scrollEnd) {
          if (scrollEnd.metrics.atEdge) {
            bool isTop = scrollEnd.metrics.pixels == 0;
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
        child: GridView.builder(
          padding: EdgeInsets.all(4.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 3 / 4,
          ),
          itemCount: videos.length,
          itemBuilder: (BuildContext context, int index) {
            final item = videos.elementAt(index);
            return GestureDetector(
              onTap: () {
                // Don't set user filtering - show all videos
                mainService.userVideoObj.value.userId = 0;
                mainService.userVideoObj.value.videoId = item.videoId;
                mainService.userVideoObj.value.name = "";
                dashboardService.showFollowingPage.value = false;
                dashboardService.postIds = [];
                dashboardService.currentPage.value = 0;
                dashboardController.getVideos().whenComplete(() {
                  Get.offAllNamed('/home');
                });
              },
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          item.videoThumbnail.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: item.videoThumbnail,
                                  placeholder: (context, url) => Center(child: CircularProgressIndicator(color: Color(0xFFFFD600))),
                                  fit: BoxFit.cover,
                                )
                              : Image.asset('assets/images/noVideo.jpg', fit: BoxFit.cover),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    CommonHelper.formatter(item.totalViews.toString()),
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(Icons.article_outlined, color: Colors.white, size: 12),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "WORKOUT", // Placeholder for title
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            );
          },
        ),
      );
    });
  }
}
