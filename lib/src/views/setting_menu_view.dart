import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingMenuView extends StatelessWidget {
  const SettingMenuView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFFFFC800)),
          onPressed: () => Get.back(),
        ),
        title: Text('Setting', style: TextStyle(color: Color(0xFFFFC800))),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Background image with overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/setting_bg.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MenuButton(
                  image: 'assets/images/setting_button.png',
                  onTap: () => Get.toNamed('/settings'),
                ),
                SizedBox(height: 24),
                _MenuButton(
                  image: 'assets/images/information_button.png',
                  onTap: () => Get.toNamed('/my-profile-info'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String image;
  final VoidCallback onTap;

  const _MenuButton({
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              width: 150,
              height: 150,
            ),
          ),
        ),
    );
  }
} 