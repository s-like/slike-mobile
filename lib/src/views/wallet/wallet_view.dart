import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core.dart';

class WalletView extends GetView<WalletController> {
  WalletService walletService = Get.find();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        controller.search = "";
        controller.page = 1;
        controller.showLoadMore = true;
        if (walletService.walletData.value.data.isNotEmpty) {
          controller.scrollController.removeListener(controller.scrollListener);
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
            title: "My Wallet".text.textStyle(Get.theme.appBarTheme.titleTextStyle).make(),
            leading: InkWell(
              child: Icon(
                Icons.arrow_back_ios,
                color: Get.theme.indicatorColor,
                size: 20,
              ),
              onTap: () {
                controller.search = "";
                controller.page = 1;
                controller.showLoadMore = true;
                if (walletService.walletData.value.data.isNotEmpty) {
                  controller.scrollController.removeListener(controller.scrollListener);
                }
                Get.back();
              },
            ),
            actions: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircleAvatar(
                  backgroundColor: Get.theme.highlightColor,
                  backgroundImage: Get.find<AuthService>().currentUser.value.userDP.isNotEmpty
                      ? CachedNetworkImageProvider(Get.find<AuthService>().currentUser.value.userDP)
                      : AssetImage(Get.find<AuthService>().currentUser.value.gender == "M" ? "assets/images/avatar-man.png" : "assets/images/avatar-woman.png") as ImageProvider,
                ),
              ).pOnly(right: 10)
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () {
              WalletController walletController = Get.find();
              walletController.page = 1;
              return walletController.fetchMyWallet();
            },
            child: Obx(
              () => Container(
                width: Get.width,
                height: Get.height,
                color: Get.theme.primaryColor,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Get.theme.primaryColorDark.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              "Balance".text.textStyle(Get.theme.textTheme.headlineSmall).bold.color(Get.theme.primaryColor).size(20).make().pOnly(bottom: 5),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/coins.svg",
                                    colorFilter: ColorFilter.mode(Get.theme.primaryColor, BlendMode.srcIn),
                                    width: 25,
                                  ).pOnly(right: 7),
                                  walletService.walletData.value.totalWalletAmount.text.textStyle(Get.theme.textTheme.headlineLarge).bold.color(Get.theme.primaryColor).size(40).make(),
                                  Transform.translate(
                                    offset: const Offset(5, 8),
                                    child: "coins".text.textStyle(Get.theme.textTheme.bodySmall).bold.color(Get.theme.primaryColor).make(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Icon(
                            Icons.account_balance_wallet,
                            color: Get.theme.primaryColor,
                            size: 80,
                          )
                        ],
                      ).pSymmetric(v: 25),
                    ).pSymmetric(h: 20),
                    const SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            InAppPurchaseController inAppPurchaseController = Get.find();
                            inAppPurchaseController.initStoreInfo();
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Get.theme.primaryColorDark,
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Get.theme.colorScheme.secondary,
                                      blurRadius: 5.0,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.add_circle_outline,
                                  color: Get.theme.primaryColor,
                                  size: 35,
                                ).centered(),
                              ).pOnly(bottom: 10),
                              "Top up".text.textStyle(Get.theme.textTheme.headlineSmall).bold.color(Get.theme.primaryColorDark).size(15).make(),
                            ],
                          ).pOnly(right: 30),
                        ),
                        InkWell(
                          onTap: () {
                            InAppPurchaseController inAppPurchaseController = Get.find();
                            inAppPurchaseController.initStoreInfo(false);
                            Get.toNamed('withdraw');
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Get.theme.primaryColorDark,
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Get.theme.colorScheme.secondary,
                                      blurRadius: 5.0,
                                    ),
                                  ],
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/payout.svg",
                                  colorFilter: ColorFilter.mode(Get.theme.primaryColor, BlendMode.srcIn),
                                  width: 35,
                                ).centered(),
                              ).pOnly(bottom: 10),
                              "Payout".text.textStyle(Get.theme.textTheme.headlineSmall).bold.color(Get.theme.primaryColorDark).size(15).make(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    walletService.walletData.value.data.isNotEmpty
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              "Recent Transaction".text.textStyle(Get.theme.textTheme.headlineSmall).bold.color(Get.theme.colorScheme.secondary).size(17).make(),
                              "View All".text.textStyle(Get.theme.textTheme.headlineSmall).bold.color(Get.theme.primaryColorDark).size(13).make().onTap(() {
                                Get.toNamed('wallet-history');
                              }),
                            ],
                          ).pSymmetric(h: 20)
                        : const SizedBox(),
                    SizedBox(
                      height: walletService.walletData.value.data.isNotEmpty ? 10 : 0,
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: walletService.walletData.value.data.take(10).length,
                        itemBuilder: (context, index) {
                          WalletItem item = walletService.walletData.value.data.take(10).elementAt(index);
                          return TransactionWidget(item: item);
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider();
                        },
                      ),
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
