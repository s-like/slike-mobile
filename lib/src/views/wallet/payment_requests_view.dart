import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core.dart';

class PaymentRequestView extends GetView<WalletController> {
  WalletService walletService = Get.find();

  PaymentRequestView({key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Get.theme.primaryColor,
          centerTitle: true,
          title: "Payment Requests".text.textStyle(Get.theme.appBarTheme.titleTextStyle).make(),
          leading: InkWell(
            child: Icon(
              Icons.arrow_back_ios,
              color: Get.theme.indicatorColor,
              size: 20,
            ),
            onTap: () {
              Get.back();
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
              itemCount: walletService.paymentRequestsData.value.data.length,
              itemBuilder: (context, index) {
                PaymentRequest item = walletService.paymentRequestsData.value.data.elementAt(index);
                return PaymentRequestWidget(item: item);
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
            ).pSymmetric(v: 10),
          ),
        ),
      ),
    );
  }
}
