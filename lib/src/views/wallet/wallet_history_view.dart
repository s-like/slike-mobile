import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core.dart';

class WalletHistoryView extends GetView<WalletController> {
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
        Get.offNamed("/my-wallet");
        return Future.value(false);
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Get.theme.primaryColor,
            centerTitle: true,
            title: "Wallet History".text.textStyle(Get.theme.appBarTheme.titleTextStyle).make(),
            leading: InkWell(
              child: Icon(
                Icons.arrow_back_ios,
                color: Get.theme.indicatorColor,
              ),
              onTap: () {
                controller.search = "";
                controller.page = 1;
                controller.showLoadMore = true;
                if (walletService.walletData.value.data.isNotEmpty) {
                  controller.scrollController.removeListener(controller.scrollListener);
                }
                Get.offNamed("/my-wallet");
              },
            ),
          ),
          body: Obx(
            () => Container(
              width: Get.width,
              height: Get.height,
              color: Get.theme.primaryColor,
              child: ListView.separated(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                controller: controller.scrollController,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: walletService.walletData.value.data.length,
                itemBuilder: (context, index) {
                  WalletItem item = walletService.walletData.value.data.elementAt(index);
                  return TransactionWidget(item: item);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },
              ).pSymmetric(v: 10),
            ),
          ),
        ),
      ),
    );
  }
}
