import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core.dart';

class MyGiftsListView extends GetView<GiftController> {
  MyGiftsListView({key});
  GiftService giftService = Get.find();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        controller.myGiftsPage = 1;
        if (giftService.myGiftsData.value.data.isNotEmpty) {
          controller.myGiftsScrollController.removeListener(controller.myGiftsScrollListener);
        }
        Get.back();
        return Future.value(false);
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Get.theme.primaryColor,
            centerTitle: true,
            title: "My Gifts".text.textStyle(Get.theme.appBarTheme.titleTextStyle).make(),
            leading: InkWell(
              child: Icon(
                Icons.arrow_back_ios,
                color: Get.theme.indicatorColor,
                size: 20,
              ),
              onTap: () {
                controller.myGiftsPage = 1;
                if (giftService.myGiftsData.value.data.isNotEmpty) {
                  controller.myGiftsScrollController.removeListener(controller.myGiftsScrollListener);
                }
                Get.back();
              },
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () {
              controller.myGiftsPage = 1;
              return controller.fetchMyGiftsList(showLoader: true);
            },
            child: Obx(
              () => Container(
                width: Get.width,
                height: Get.height,
                color: Get.theme.primaryColor,
                child: Column(
                  children: [
                    Expanded(
                      child: giftService.myGiftsData.value.data.isNotEmpty
                          ? ListView.separated(
                              padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                              controller: controller.myGiftsScrollController,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: giftService.myGiftsData.value.data.length,
                              itemBuilder: (context, index) {
                                MyGift item = giftService.myGiftsData.value.data.elementAt(index);
                                return ListTile(
                                  minLeadingWidth: 25,
                                  contentPadding: EdgeInsets.zero,
                                  // dense: true,
                                  leading: InkWell(
                                    onTap: () {
                                      UserController userController = Get.find();
                                      userController.openUserProfile(item.fromId);
                                    },
                                    child: CachedNetworkImage(
                                      imageUrl: item.profilePic,
                                      imageBuilder: (context, imageProvider) => Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(Radius.circular(50)),
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover, /*colorFilter: const ColorFilter.mode(Colors.red, BlendMode.colorBurn)*/
                                          ),
                                        ),
                                      ),
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.fill,
                                    ).pOnly(bottom: 3),
                                  ),
                                  title: Row(
                                    children: [
                                      "Gift received"
                                          .text
                                          .textStyle(
                                            Get.theme.textTheme.headlineSmall!.copyWith(
                                              color: Get.theme.colorScheme.primary,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )
                                          .make()
                                          .marginOnly(right: 10),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: item.giftIcon,
                                            width: 15,
                                            fit: BoxFit.fill,
                                          ).marginOnly(right: 3),
                                          "worth ${item.coins} coins".text.textStyle(Get.theme.textTheme.headlineSmall).bold.color(Colors.green).size(12).make(),
                                        ],
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      "${item.username} has sent you a gift on your post"
                                          .text
                                          .textStyle(
                                            Get.theme.textTheme.headlineSmall!.copyWith(
                                              color: Get.theme.indicatorColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )
                                          .make(),
                                      CommonHelper.timeAgoSinceDate(item.createdAt, short: false)
                                          .text
                                          .textStyle(
                                            Get.theme.textTheme.headlineSmall!.copyWith(
                                              color: Get.theme.indicatorColor.withValues(alpha:0.4),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )
                                          .make(),
                                    ],
                                  ),
                                  trailing: (item.file != "")
                                      ? CachedNetworkImage(
                                          imageUrl: item.file,
                                          width: 30,
                                          fit: BoxFit.fitHeight,
                                        ).pOnly(bottom: 3)
                                      : Container(width: 30),
                                );
                              },
                              separatorBuilder: (BuildContext context, int index) {
                                return const Divider();
                              },
                            )
                          : "No data!"
                              .text
                              .center
                              .textStyle(
                                Get.theme.textTheme.headlineSmall!.copyWith(
                                  color: Get.theme.indicatorColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                              .make()
                              .centered(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
