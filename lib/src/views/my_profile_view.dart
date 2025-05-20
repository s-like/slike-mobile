import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      backgroundColor: Colors.black,
      body: DefaultTabController(
        length: 5,
        child: Column(
          children: [
            // HEADER
            Stack(
              children: [
                // Background image
                Container(
                  width: double.infinity,
                  height: 260,
                  child: authService.currentUser.value.largeProfilePic != ''
                      ? CachedNetworkImage(
                          imageUrl: authService.currentUser.value.largeProfilePic,
                          fit: BoxFit.cover,
                        )
                      : Image.asset('assets/images/default-user.png', fit: BoxFit.cover),
                ),
                // Overlay
                Container(
                  width: double.infinity,
                  height: 260,
                  color: Colors.black.withOpacity(0.6),
                ),
                // Top right icons
                Positioned(
                  top: 30,
                  right: 20,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.settings, color: Colors.white, size: 28),
                        onPressed: () => {},
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.white, size: 28),
                        onPressed: () async {
                          await userProfileController.fetchLoggedInUserInformation();
                          Get.toNamed('/edit-profile');
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.qr_code_2, color: Colors.white, size: 28),
                        onPressed: () => Get.toNamed("/my-profile-info"),
                      ),
                    ],
                  ),
                ),
                // Centered profile photo and username
                Positioned(
                  left: 0,
                  right: 0,
                  top: 80,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: CircleAvatar(
                          radius: 48,
                          backgroundImage: authService.currentUser.value.smallProfilePic != ''
                              ? CachedNetworkImageProvider(authService.currentUser.value.smallProfilePic)
                              : AssetImage('assets/images/default-user.png') as ImageProvider,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '@${authService.currentUser.value.username}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // TAB BAR
            Container(
              color: Colors.black,
              child: TabBar(
                isScrollable: false,
                indicatorColor: Color(0xFFFFC800),
                indicatorWeight: 4,
                labelColor: Color(0xFFFFC800),
                unselectedLabelColor: Colors.white,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
                tabs: [
                  Tab(text: 'BIO'),
                  Tab(text: 'SHORT'),
                  Tab(text: 'FEEDS'),
                  Tab(text: 'SHOP'),
                  Tab(text: 'DASHBOARD'),
                ],
              ),
            ),
            // MAIN CONTENT (TabBarView)
            Expanded(
              child: TabBarView(
                children: [
                  // BIO TAB
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Example: Section Title
                          Row(
                            children: [
                              Icon(Icons.sports_martial_arts, color: Color(0xFFFFC800)),
                              SizedBox(width: 8),
                              Text('BOXING', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            ],
                          ),
                          SizedBox(height: 12),
                          // SOCIAL ICONS ROW (moved here)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSocialIcon('assets/icons/kick.svg', Color(0xFF4AC959)),
                              SizedBox(width: 10),
                              _buildSocialIcon('assets/icons/twitch.svg', Color(0xFF9147FF)),
                              SizedBox(width: 10),
                              _buildSocialIcon('assets/icons/youtube.svg', Color(0xFFFF0000)),
                              SizedBox(width: 10),
                              _buildSocialIcon('assets/icons/facebook.svg', Color(0xFF1877F3)),
                              SizedBox(width: 10),
                              _buildSocialIcon('assets/icons/x.svg', Colors.black),
                              SizedBox(width: 10),
                              _buildSocialIcon('assets/icons/snapchat.svg', Color(0xFFFFFC00)),
                              SizedBox(width: 10),
                              _buildSocialIcon('assets/icons/instagram.svg', Color(0xFFE1306C)),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.people, color: Color(0xFFFFC800), size: 18),
                              SizedBox(width: 6),
                              Text('10k ', style: TextStyle(color: Color(0xFFFFC800), fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('followers', style: TextStyle(color: Colors.white, fontSize: 16)),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.emoji_events, color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text('Athlète', style: TextStyle(color: Colors.white, fontSize: 15)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.emoji_events, color: Color(0xFFFFC800), size: 18),
                              SizedBox(width: 6),
                              Expanded(child: Text('M.olympiade 2026 champion d olympide', style: TextStyle(color: Colors.white, fontSize: 15))),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.emoji_events, color: Color(0xFFFFC800), size: 18),
                              SizedBox(width: 6),
                              Expanded(child: Text('champion du peuple 23', style: TextStyle(color: Colors.white, fontSize: 15))),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.verified_user, color: Colors.orange, size: 18),
                              SizedBox(width: 6),
                              Expanded(child: Text('Propriétaire@ champ', style: TextStyle(color: Colors.white, fontSize: 15))),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.alternate_email, color: Colors.orange, size: 18),
                              SizedBox(width: 6),
                              Expanded(child: Text('@champibell', style: TextStyle(color: Colors.white, fontSize: 15))),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.alternate_email, color: Colors.orange, size: 18),
                              SizedBox(width: 6),
                              Expanded(child: Text('@abcnutrition', style: TextStyle(color: Colors.white, fontSize: 15))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // SHORT TAB
                  Obx(() {
                    final videos = authService.currentUser.value.userVideos;
                    final isLoading = userController.showLoader.value;
                    if (isLoading) {
                      return Center(child: CircularProgressIndicator(color: Color(0xFFFFC800)));
                    }
                    if (videos.isEmpty) {
                      return Center(
                        child: Text('No video yet!', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        itemCount: videos.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                          childAspectRatio: 0.7,
                        ),
                        itemBuilder: (context, index) {
                          final item = videos[index];
                          return GestureDetector(
                            onTap: () {
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
                              dashboardService.pageController.value.animateToPage(
                                dashboardService.currentPage.value,
                                duration: Duration(milliseconds: 100),
                                curve: Curves.linear,
                              );
                              dashboardService.pageController.refresh();
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: item.videoGif != ""
                                  ? CachedNetworkImage(
                                      imageUrl: item.videoGif,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(color: Colors.black12),
                                      errorWidget: (context, url, error) => item.videoThumbnail != ""
                                          ? CachedNetworkImage(
                                              imageUrl: item.videoThumbnail,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(color: Colors.black12),
                                            )
                                          : Image.asset('assets/images/noVideo.jpg', fit: BoxFit.cover),
                                    )
                                  : item.videoThumbnail != ""
                                      ? CachedNetworkImage(
                                          imageUrl: item.videoThumbnail,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(color: Colors.black12),
                                        )
                                      : Image.asset('assets/images/noVideo.jpg', fit: BoxFit.cover),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  // FEEDS TAB
                  Center(child: Text('FEEDS', style: TextStyle(color: Colors.white))),
                  // SHOP TAB
                  Center(child: Text('SHOP', style: TextStyle(color: Colors.white))),
                  // DASHBOARD TAB
                  Center(child: Text('DASHBOARD', style: TextStyle(color: Colors.white))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildSocialIcon(String asset, Color bgColor) {
  return CircleAvatar(
    radius: 18,
    backgroundColor: bgColor,
    child: SvgPicture.asset(asset, width: 20, height: 20),
  );
}
