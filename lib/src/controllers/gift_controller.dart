import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeleton_loader/skeleton_loader.dart';

import '../core.dart';

class GiftController extends GetxController {
  ScrollController myGiftsScrollController = ScrollController();
  bool isSendingGift = false;
  WalletService walletService = Get.find();
  bool showLoadMore = true;
  int myGiftsPage = 1;
  late VoidCallback myGiftsScrollListener;
  GiftService giftService = Get.find();
  var activeGiftIndex = 0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  Future<void> sendGift({required Gift gift, int id = 0, bool isLivePage = false}) async {
    if (!CommonHelper.returnFromApiIfInternetIsOff()) {
      return;
    }
    if (gift.coins < walletService.walletData.value.totalWalletAmount) {
      if (!isSendingGift) {
        EasyLoading.show(status: "${"Sending gift".tr}...");
        isSendingGift = true;
        Map<String, dynamic> data = {
          "gift_id": gift.id.toString(),
        };
        String endPoint = 'send-stream-gift';

        if (!isLivePage) {
          endPoint = 'send-gift';
          data["video_id"] = id.toString();
        } else {
          // url = CommonHelper.getUri('send-stream-gift');
          data["stream_id"] = id.toString();
        }

        var resp = await CommonHelper.sendRequestToServer(endPoint: endPoint, method: "post", requestData: data);
        var response = jsonDecode(resp.body);
        isSendingGift = false;
        EasyLoading.dismiss();
        print("resp $response");
        if (response['status']) {
          activeGiftIndex.value = 999;
          activeGiftIndex.refresh();
          walletService.walletData.value.totalWalletAmount = response["wallet_amount"];
          walletService.walletData.refresh();
          Get.back();
          Fluttertoast.showToast(msg: "Gift sent successfully".tr);
          if (isLivePage) {
            LiveStreamingController liveStreamingController = Get.find();
            liveStreamingController.liveConfettiControllerCenter.play();
            await Future.delayed(const Duration(seconds: 4));
            Timer(const Duration(seconds: 4), () => liveStreamingController.liveConfettiControllerCenter.stop());
          } else {
            DashboardController dashboardController = Get.find();
            dashboardController.postConfettiControllerCenter.play();
            Timer(const Duration(seconds: 4), () => dashboardController.postConfettiControllerCenter.stop());
          }
        } else {
          Fluttertoast.showToast(msg: response["msg"]);
        }
      } else {}
    } else {
      Fluttertoast.showToast(msg: "You don't have enough coins to send the gift. Kindly purchase some coins first.".tr);
      InAppPurchaseController inAppPurchaseController = Get.find();
      inAppPurchaseController.initStoreInfo();
    }
  }

  Future<void> fetchMyGiftsList({showLoader = false}) async {
    if (showLoader) EasyLoading.show(status: 'loading...');
    var response = await CommonHelper.sendRequestToServer(endPoint: 'my-gifts', requestData: {'page': myGiftsPage.toString()});

    if (showLoader) EasyLoading.dismiss();

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status']) {
        if (myGiftsPage == 1) {
          showLoadMore = true;
          myGiftsScrollController = ScrollController();
          giftService.myGiftsData.value = MyGiftsModel.fromJSON(jsonData);
        } else {
          giftService.myGiftsData.value.data.addAll(MyGiftsModel.fromJSON(jsonData).data);
        }
        giftService.myGiftsData.refresh();
        if (giftService.myGiftsData.value.data.length >= giftService.myGiftsData.value.totalRecords) {
          print("showLoadMore $showLoadMore");
          showLoadMore = false;
        }
        if (myGiftsPage == 1) {
          myGiftsScrollListener = () {
            print(
                "myGiftsScrollController.position.pixels == myGiftsScrollController.position.maxScrollExtent ${myGiftsScrollController.position.pixels} == ${myGiftsScrollController.position.maxScrollExtent}");
            if (myGiftsScrollController.position.pixels == myGiftsScrollController.position.maxScrollExtent) {
              print(
                  "giftService.myGiftsData.value.data.length != giftService.myGiftsData.value.totalRecords ${giftService.myGiftsData.value.data.length} != ${giftService.myGiftsData.value.totalRecords} && $showLoadMore");
              if (giftService.myGiftsData.value.data.length != giftService.myGiftsData.value.totalRecords && showLoadMore) {
                myGiftsPage = myGiftsPage + 1;
                fetchMyGiftsList();
              }
            }
          };
          myGiftsScrollController.addListener(myGiftsScrollListener);
        }
      }
    }
  }

  openGiftsWidget({int id = 0, bool isLivePage = false}) {
    showModalBottomSheet<void>(
        isDismissible: true,
        isScrollControlled: true,
        barrierColor: Colors.black.withValues(alpha:0.9),
        context: Get.context!,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setState /*You can rename this!*/) {
            return Container(
              height: Get.height * 0.6,
              width: Get.width,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Container(
                    width: Get.width,
                    color: Get.theme.colorScheme.secondary.withValues(alpha:0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/icons/coins.png',
                              width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                            ).pOnly(right: 3),
                            Obx(
                              () => walletService.walletData.value.totalWalletAmount.text.center
                                  .textStyle(Get.theme.textTheme.headlineMedium)
                                  .size(16)
                                  .color(Get.theme.colorScheme.secondary)
                                  .make()
                                  .centered(),
                            ),
                          ],
                        ),
                        "Send Gift".text.center.textStyle(Get.theme.textTheme.headlineMedium).size(16).color(Get.theme.colorScheme.secondary).make().centered(),
                        InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(
                            Icons.close,
                            size: 22,
                            color: Get.theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ).pSymmetric(h: 15, v: 15),
                  ).pOnly(bottom: 10),
                  Expanded(
                    child: GridView.builder(
                        primary: false,
                        padding: const EdgeInsets.all(2),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                          height: 130,
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: giftService.gifts.length,
                        itemBuilder: (BuildContext context, int i) {
                          Gift gift = giftService.gifts.elementAt(i);
                          return Stack(
                            children: [
                              Container(
                                width: 110,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  // color: activeGiftIndex.value != i ? Get.theme.colorScheme.secondary.withValues(alpha:0.05) : Get.theme.primaryColorDark.withValues(alpha:0.6),
                                  color: Get.theme.colorScheme.secondary.withValues(alpha:0.05),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    gift.icon.contains(".svg")
                                        ? SvgPicture.network(
                                            gift.icon,
                                            // width: 80,

                                            height: 60,
                                            fit: BoxFit.fill,
                                            allowDrawingOutsideViewBox: true,
                                          ).pOnly(bottom: 10)
                                        : CachedNetworkImage(
                                            imageUrl: gift.icon,
                                            progressIndicatorBuilder: (context, url, downloadProgress) {
                                              return SkeletonLoader(
                                                builder: AspectRatio(
                                                  aspectRatio: 1.3,
                                                  child: Container(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                items: 1,
                                              );
                                            },
                                            // width: 80,
                                            height: 60,
                                            fit: BoxFit.fill,
                                          ).pOnly(bottom: 10),
                                    /*gift.name.text.center
                                          .textStyle(Get.theme.textTheme.headlineMedium)
                                          .size(15)
                                          .color(activeGiftIndex.value != i ? Get.theme.colorScheme.primary : Get.theme.primaryColor)
                                          .make()
                                          .centered()
                                          .fittedBox()
                                          .pOnly(bottom: 5, left: 3, right: 3),*/
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        gift.coins.text.center
                                            .textStyle(Get.theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold))
                                            .size(15)
                                            .color(Get.theme.colorScheme.secondary)
                                            .make()
                                            .centered(),
                                        Image.asset(
                                          "assets/icons/coin.png",
                                          width: 18.0,
                                        ).pOnly(left: 3),
                                      ],
                                    ),
                                  ],
                                ).pSymmetric(v: 10),
                              ).onTap(() {
                                activeGiftIndex.value = i;
                                activeGiftIndex.refresh();
                                sendGift(gift: gift, id: id, isLivePage: isLivePage);
                              }),
                            ],
                          );
                        }).pSymmetric(h: 15),
                  ),
                ],
              ),
            );
          });
        });
  }
}
