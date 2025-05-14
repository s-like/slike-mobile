import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core.dart';

class LanguageView extends GetView<LanguageController> {
  var loc = Get.locale.obs;
  MainService mainService = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(Get.width / 10),
        child: AppBar(
          leading: InkWell(
            child: Icon(
              Icons.arrow_back_ios,
              size: 16,
            ),
            onTap: () {
              Get.back();
            },
          ),
          // backgroundColor: Get.theme.accentColor,
          elevation: 0,
          centerTitle: true,
          title: "Select Language".tr.text.make(),
        ),
      ),
      backgroundColor: Get.theme.primaryColor,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: Get.width,
              height: Get.height,
              padding: EdgeInsets.all(20),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                  height: 120,
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                padding: EdgeInsets.zero,
                scrollDirection: Axis.vertical,
                itemCount: mainService.setting.value.languages.length,
                itemBuilder: (context, i) {
                  AppLanguage language = mainService.setting.value.languages.elementAt(i);
                  return Obx(
                    () => Container(
                      decoration: BoxDecoration(
                        borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
                        border: controller.languageCode.value == language.languageCode
                            ? Border.all(
                                color: Get.theme.primaryColorDark,
                                width: 2.0,
                              )
                            : Border.all(
                                color: Get.theme.colorScheme.primary.withValues(alpha:0.4),
                                width: 1.0,
                              ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: language.flag,
                                  width: 70,
                                ),
                                language.language.trim().tr.text.textStyle(Get.textTheme.bodyMedium).make()
                              ],
                              mainAxisAlignment: MainAxisAlignment.center,
                            ),
                          ),
                          Positioned(
                            child: controller.languageCode.value == language.languageCode
                                ? SvgPicture.asset(
                                    'assets/icons/checked-l.svg',
                                    width: 30,
                                    height: 30,
                                    colorFilter: ColorFilter.mode(Get.theme.primaryColorDark, BlendMode.srcIn),
                                  )
                                : Container(),
                            top: 5,
                            right: 5,
                          )
                        ],
                      ),
                    ).onTap(() {
                      controller.languageCode.value = language.languageCode;
                      controller.languageCode.refresh();
                    }),
                  );
                },
                /*separatorBuilder: (context, index) {
                  return Divider(
                    color: Colors.white,
                    thickness: 0.1,
                  );
                },*/
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: InkWell(
                onTap: () {
                  controller.setLocale();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  margin: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Get.theme.colorScheme.secondary),
                  child: "Apply".tr.text.center.textStyle(Get.textTheme.headlineMedium!.copyWith(color: Get.theme.primaryColor, fontSize: 20)).make(),
                ).px16(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
