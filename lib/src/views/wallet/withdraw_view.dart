import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core.dart';

class WithdrawView extends GetView<WalletController> {
  WalletService walletService = Get.find();
  InAppPurchaseController inAppPurchaseController = Get.find();
  MainService mainService = Get.find();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        controller.totalAmountToPay.value = 0.0;
        controller.totalAmountToPay.refresh();
        controller.selectedItem.value = ProductDetails(currencyCode: '', description: '', id: '', title: '', price: '', rawPrice: 0, currencySymbol: '');
        controller.selectedItem.refresh();
        controller.paymentEmail.value = "";
        controller.paymentEmail.refresh();
        controller.activeButton.value = 0;
        controller.activeButton.refresh();
        Get.back();
        return Future.value(false);
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Get.theme.primaryColor,
            centerTitle: true,
            title: "Payout".text.textStyle(Get.theme.appBarTheme.titleTextStyle).make(),
            leading: InkWell(
              child: Icon(
                Icons.arrow_back_ios,
                color: Get.theme.indicatorColor,
                size: 20,
              ),
              onTap: () {
                controller.totalAmountToPay.value = 0.0;
                controller.totalAmountToPay.refresh();
                controller.selectedItem.value = ProductDetails(currencyCode: '', description: '', id: '', title: '', price: '', rawPrice: 0, currencySymbol: '');
                controller.selectedItem.refresh();
                controller.paymentEmail.value = "";
                controller.paymentEmail.refresh();
                controller.activeButton.value = 0;
                controller.activeButton.refresh();
                Get.back();
              },
            ),
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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Get.theme.primaryColorDark.withValues(alpha:0.5),
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
                                "Total Balance".text.textStyle(Get.theme.textTheme.headlineSmall).bold.color(Get.theme.primaryColor).size(20).make().pOnly(bottom: 5),
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
                            ),
                          ],
                        ).pSymmetric(v: 25),
                      ).pSymmetric(h: 20),
                      const SizedBox(
                        height: 10,
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'View ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Get.theme.indicatorColor,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.underline,
                            decorationStyle: TextDecorationStyle.solid,
                            decorationThickness: 1,
                          ),
                          children: <TextSpan>[
                            TextSpan(text: 'pending payout', style: TextStyle(fontWeight: FontWeight.bold, color: Get.theme.primaryColorDark)),
                            const TextSpan(text: ' requests'),
                          ],
                        ),
                      ).objectCenterRight().paddingOnly(right: 20).onTap(() async {
                        await controller.getWithdrawRequests(showLoader: true);
                        Get.toNamed("/payment-request");
                      }),
                      const SizedBox(
                        height: 10,
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'You can withdraw minimum ',
                          style: TextStyle(fontSize: 17, color: Get.theme.indicatorColor, fontWeight: FontWeight.w400),
                          children: <TextSpan>[
                            TextSpan(text: '${mainService.setting.value.minimumWithdrawLimit}', style: TextStyle(fontWeight: FontWeight.bold, color: Get.theme.primaryColorDark)),
                            const TextSpan(text: ' coins at least.'),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Obx(
                        () => TextField(
                          enabled: true,
                          controller: controller.withdrawAmountController.value,
                          decoration: InputDecoration(
                            hintText: 'Please enter amount to be withdrawn.'.tr,
                            hintStyle: const TextStyle(fontSize: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                            focusedErrorBorder:
                                OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                            filled: true,
                            fillColor: Get.theme.primaryColor,
                            contentPadding: const EdgeInsets.all(
                              15,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onSubmitted: (value) {
                            if (value != "" && int.parse(value) >= mainService.setting.value.minimumWithdrawLimit) {
                              if (int.parse(value) <= walletService.walletData.value.totalWalletAmount) {
                                controller.selectedItem.value = inAppPurchaseController.products.elementAt(0);
                                controller.selectedItem.refresh();
                                controller.totalAmountSelected.value = double.parse(value);
                                controller.totalAmountSelected.refresh();
                              } else {
                                AwesomeDialog(
                                  dialogBackgroundColor: Get.theme.primaryColor,
                                  context: Get.context!,
                                  animType: AnimType.scale,
                                  dialogType: DialogType.warning,
                                  body: Padding(
                                    padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        "Low Balance".text.center.textStyle(Get.textTheme.headlineLarge!.copyWith(color: Get.theme.indicatorColor, fontSize: 22)).make().centered().pOnly(bottom: 10),
                                        "You don't have enough balance to withdraw."
                                            .text
                                            .center
                                            .textStyle(Get.textTheme.bodyLarge!.copyWith(color: Get.theme.indicatorColor))
                                            .make()
                                            .centered()
                                            .pOnly(bottom: 20),
                                        InkWell(
                                          onTap: () async {
                                            controller.withdrawAmountController.value = TextEditingController(text: walletService.walletData.value.totalWalletAmount.toString());
                                            Get.back();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              color: Get.theme.primaryColorDark,
                                            ),
                                            child: "OK".text.size(18).center.color(Get.theme.primaryColor).make().centered().pSymmetric(h: 10, v: 15),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ).show();
                                controller.selectedItem.value = inAppPurchaseController.products.elementAt(0);
                                controller.selectedItem.refresh();
                                controller.totalAmountSelected.value = double.parse(walletService.walletData.value.totalWalletAmount.toString());
                                controller.totalAmountSelected.refresh();
                              }
                            } else {
                              controller.totalAmountSelected.value = 0;
                              controller.totalAmountSelected.refresh();
                            }
                          },
                          onChanged: (value) async {
                            print(33333);
                            if (value != "" && int.parse(value) >= 500) {
                              print(walletService.walletData.value.totalWalletAmount);
                              if (int.parse(value) <= walletService.walletData.value.totalWalletAmount) {
                                print(walletService.walletData.value.totalWalletAmount);
                                controller.selectedItem.value = inAppPurchaseController.products.elementAt(0);
                                controller.selectedItem.refresh();
                                controller.totalAmountSelected.value = double.parse(value);
                                controller.totalAmountSelected.refresh();
                                //print(controller.totalAmountSelected.value);
                              } else {
                                AwesomeDialog(
                                  dialogBackgroundColor: Get.theme.primaryColor,
                                  context: Get.context!,
                                  animType: AnimType.scale,
                                  dialogType: DialogType.warning,
                                  body: Padding(
                                    padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        "Low Balance".text.center.textStyle(Get.textTheme.headlineLarge!.copyWith(color: Get.theme.indicatorColor, fontSize: 22)).make().centered().pOnly(bottom: 10),
                                        "You don't have enough balance to withdraw."
                                            .text
                                            .center
                                            .textStyle(Get.textTheme.bodyLarge!.copyWith(color: Get.theme.indicatorColor))
                                            .make()
                                            .centered()
                                            .pOnly(bottom: 20),
                                        InkWell(
                                          onTap: () async {
                                            controller.withdrawAmountController.value = TextEditingController(text: walletService.walletData.value.totalWalletAmount.toString());
                                            Get.back();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              color: Get.theme.primaryColorDark,
                                            ),
                                            child: "OK".text.size(18).center.color(Get.theme.primaryColor).make().centered().pSymmetric(h: 10, v: 15),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ).show();
                                controller.selectedItem.value = inAppPurchaseController.products.elementAt(0);
                                controller.selectedItem.refresh();
                                controller.totalAmountSelected.value = double.parse(walletService.walletData.value.totalWalletAmount.toString());
                                controller.totalAmountSelected.refresh();
                              }
                            } else {
                              controller.totalAmountSelected.value = 0;
                              controller.totalAmountSelected.refresh();
                            }
                          },
                        ).marginSymmetric(horizontal: 20),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      controller.totalAmountSelected.value >= mainService.setting.value.minimumWithdrawLimit
                          ? Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    "Price :".text.textStyle(Get.theme.textTheme.headlineLarge).size(16).color(Get.theme.colorScheme.secondary).make().pOnly(right: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        "\$".text.textStyle(Get.theme.textTheme.headlineLarge).size(14).color(Get.theme.colorScheme.secondary).make(),
                                        (controller.totalAmountSelected.value * controller.exchangeRate.value)
                                            .toStringAsFixed(2)
                                            .text
                                            .textStyle(Get.theme.textTheme.headlineLarge)
                                            .size(16)
                                            .color(Get.theme.colorScheme.secondary)
                                            .make(),
                                      ],
                                    ),
                                  ],
                                ).pOnly(bottom: 5, right: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    "Conversion fee (10%) :".text.textStyle(Get.theme.textTheme.headlineLarge).size(16).color(Get.theme.colorScheme.secondary).make().pOnly(right: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        "- \$".text.textStyle(Get.theme.textTheme.headlineLarge).size(14).color(Get.theme.colorScheme.primary).make(),
                                        (controller.applyChargesOnAmount(conversionFee, controller.totalAmountSelected.value) * controller.exchangeRate.value)
                                            .toStringAsFixed(2)
                                            .text
                                            .textStyle(Get.theme.textTheme.headlineLarge)
                                            .size(16)
                                            .color(Get.theme.colorScheme.primary)
                                            .make(),
                                      ],
                                    ),
                                  ],
                                ).pOnly(bottom: 5, right: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    "Convenience fee (15%) :".text.textStyle(Get.theme.textTheme.headlineLarge).size(16).color(Get.theme.colorScheme.secondary).make().pOnly(right: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        "- \$".text.textStyle(Get.theme.textTheme.headlineLarge).size(14).color(Get.theme.colorScheme.primary).make(),
                                        (controller.applyChargesOnAmount(convenienceFee, controller.totalAmountSelected.value) * controller.exchangeRate.value)
                                            .toStringAsFixed(2)
                                            .text
                                            .textStyle(Get.theme.textTheme.headlineLarge)
                                            .size(16)
                                            .color(Get.theme.colorScheme.primary)
                                            .make(),
                                      ],
                                    ),
                                  ],
                                ).pOnly(bottom: 10, right: 20),
                                Divider(
                                  color: Get.theme.indicatorColor,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    "Net Amount :".text.textStyle(Get.theme.textTheme.headlineLarge).size(16).color(Get.theme.colorScheme.secondary).make().pOnly(right: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        "\$".text.textStyle(Get.theme.textTheme.headlineLarge).size(14).bold.color(Get.theme.primaryColorDark).make(),
                                        (controller.getNetAmount(controller.applyChargesOnAmount(10.0, controller.totalAmountSelected.value),
                                                    controller.applyChargesOnAmount(15.0, controller.totalAmountSelected.value), controller.totalAmountSelected.value) *
                                                controller.exchangeRate.value)
                                            .toStringAsFixed(2)
                                            .text
                                            .textStyle(Get.theme.textTheme.headlineLarge)
                                            .size(16)
                                            .bold
                                            .color(Get.theme.primaryColorDark)
                                            .make(),
                                      ],
                                    ),
                                  ],
                                ).pOnly(right: 20),
                                Divider(
                                  color: Get.theme.indicatorColor,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          controller.activeTab.value = 'P';
                                          controller.activeTab.refresh();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(color: controller.activeTab.value == 'P' ? Get.theme.primaryColorDark : Get.theme.dividerColor, width: 2),
                                              right: BorderSide(color: Get.theme.dividerColor, width: 0),
                                            ),
                                          ),
                                          child: "PayPal"
                                              .text
                                              .center
                                              .textStyle(Get.theme.textTheme.headlineLarge)
                                              .size(18)
                                              .color(controller.activeTab.value == 'P' ? Get.theme.primaryColorDark : Get.theme.indicatorColor.withValues(alpha:0.5))
                                              .make()
                                              .p(10),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          controller.activeTab.value = 'U';
                                          controller.activeTab.refresh();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(color: controller.activeTab.value == 'U' ? Get.theme.primaryColorDark : Get.theme.dividerColor, width: 2),
                                              right: BorderSide(color: Get.theme.dividerColor, width: 0),
                                            ),
                                          ),
                                          child: "UPI"
                                              .text
                                              .center
                                              .textStyle(Get.theme.textTheme.headlineLarge)
                                              .size(18)
                                              .color(controller.activeTab.value == 'U' ? Get.theme.primaryColorDark : Get.theme.indicatorColor.withValues(alpha:0.5))
                                              .make()
                                              .p(10),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          controller.activeTab.value = 'B';
                                          controller.activeTab.refresh();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(color: controller.activeTab.value == 'B' ? Get.theme.primaryColorDark : Get.theme.dividerColor, width: 2),
                                              right: BorderSide(color: Get.theme.dividerColor, width: 0),
                                            ),
                                          ),
                                          child: "Bank"
                                              .text
                                              .center
                                              .textStyle(Get.theme.textTheme.headlineLarge)
                                              .size(18)
                                              .color(controller.activeTab.value == 'B' ? Get.theme.primaryColorDark : Get.theme.indicatorColor.withValues(alpha:0.5))
                                              .make()
                                              .p(10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                controller.activeTab.value == 'P'
                                    ? Form(
                                        key: controller.paypalFormKey,
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              style: TextStyle(color: Get.theme.colorScheme.secondary, fontWeight: FontWeight.w300),
                                              keyboardType: TextInputType.text,
                                              onChanged: (input) {
                                                controller.paymentEmail.value = input;
                                                controller.paymentEmail.refresh();
                                              },
                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                              validator: (input) {
                                                if (GetUtils.isBlank(input)!) {
                                                  return "This field is required!";
                                                } else {
                                                  return null;
                                                }
                                              },
                                              decoration: InputDecoration(
                                                hintText: "Enter Paypal Profile Link",
                                                contentPadding: const EdgeInsets.symmetric(
                                                  vertical: 18,
                                                  horizontal: 0,
                                                ),
                                                prefixIconConstraints: const BoxConstraints(minWidth: 23, maxHeight: 20),
                                                prefixIcon: Padding(
                                                  padding: const EdgeInsets.only(right: 15),
                                                  child: Icon(
                                                    Icons.link,
                                                    color: Get.theme.indicatorColor,
                                                  ),
                                                ),
                                                // suffixIcon: showCloseIcon! ? IconButton(onPressed: () => onPressed!.call(), icon: Icon(Icons.close, size: 20, color: Get.theme.primaryColor)).pOnly(left: 15, right: 15) : null,
                                                errorStyle: const TextStyle(fontSize: 13),
                                                hintStyle: Get.theme.textTheme.bodyLarge!.copyWith(color: Get.theme.indicatorColor),
                                                border: UnderlineInputBorder(
                                                    borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                focusedBorder: UnderlineInputBorder(
                                                    borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                enabledBorder: UnderlineInputBorder(
                                                    borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                errorBorder: UnderlineInputBorder(
                                                    borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                focusedErrorBorder: UnderlineInputBorder(
                                                    borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                              ),
                                            ).pSymmetric(h: 20).pOnly(bottom: 10),
                                            "( For ex: https://www.paypal.com/paypalme/abc )".text.bold.size(13).color(Colors.black54).make().pSymmetric(h: 20).objectCenterLeft(),
                                          ],
                                        ).pSymmetric(h: 0, v: 10),
                                      )
                                    : controller.activeTab.value == 'U'
                                        ? Form(
                                            key: controller.upiFormKey,
                                            child: TextFormField(
                                              style: TextStyle(color: Get.theme.colorScheme.secondary, fontWeight: FontWeight.w300),
                                              keyboardType: TextInputType.text,
                                              onChanged: (input) {
                                                controller.upiId.value = input;
                                                controller.upiId.refresh();
                                              },
                                              validator: (input) => RegExp(r"^[0-9A-Za-z.-]{2,256}@[A-Za-z]{2,64}$").hasMatch(input!) ? null : "Wrong UPI ID",
                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                              autocorrect: true,
                                              decoration: InputDecoration(
                                                hintText: "Enter UPI ID",
                                                contentPadding: const EdgeInsets.symmetric(
                                                  vertical: 18,
                                                  horizontal: 0,
                                                ),
                                                prefixIconConstraints: const BoxConstraints(minWidth: 23, maxHeight: 20),
                                                prefixIcon: Padding(
                                                  padding: const EdgeInsets.only(right: 8),
                                                  child: SvgPicture.asset(
                                                    "assets/icons/upi.svg",
                                                    width: 40,
                                                  ),
                                                ),
                                                errorStyle: const TextStyle(fontSize: 13),
                                                hintStyle: Get.theme.textTheme.bodyLarge!.copyWith(color: Get.theme.indicatorColor),
                                                border: UnderlineInputBorder(
                                                    borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                focusedBorder: UnderlineInputBorder(
                                                    borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                enabledBorder: UnderlineInputBorder(
                                                    borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                errorBorder: UnderlineInputBorder(
                                                    borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                focusedErrorBorder: UnderlineInputBorder(
                                                    borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                              ),
                                            ).pSymmetric(h: 20).pOnly(bottom: 10).pSymmetric(h: 0, v: 10),
                                          )
                                        : Form(
                                            key: controller.bankFormKey,
                                            child: Column(
                                              children: [
                                                TextFormField(
                                                  controller: controller.countryController,
                                                  readOnly: true,
                                                  style: TextStyle(color: Get.theme.colorScheme.secondary, fontWeight: FontWeight.w300),
                                                  onChanged: (input) {
                                                    controller.country.value = input;
                                                    controller.country.refresh();
                                                  },
                                                  onTap: () {
                                                    showCountryPicker(
                                                      context: context,
                                                      countryListTheme: CountryListThemeData(
                                                        flagSize: 25,
                                                        backgroundColor: Colors.white,
                                                        textStyle: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                                                        bottomSheetHeight: 500, // Optional. Country list modal height
                                                        //Optional. Sets the border radius for the bottomsheet.
                                                        borderRadius: const BorderRadius.only(
                                                          topLeft: Radius.circular(20.0),
                                                          topRight: Radius.circular(20.0),
                                                        ),
                                                        //Optional. Styles the search field.
                                                        inputDecoration: InputDecoration(
                                                          labelText: 'Search',
                                                          hintText: 'Start typing to search',
                                                          prefixIcon: const Icon(Icons.search),
                                                          border: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color: const Color(0xFF8C98A8).withValues(alpha:0.2),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      onSelect: (Country country) {
                                                        print('Select country: ${country.displayName} ${country.flagEmoji}');
                                                        controller.country.value = country.name;
                                                        controller.countryController.text = country.name;
                                                        controller.countryFlag.value = country.flagEmoji;
                                                      },
                                                    );
                                                  },
                                                  keyboardType: TextInputType.text,
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'Country is required';
                                                    }
                                                    return null; // Valid IFSC code
                                                  },
                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                  autocorrect: true,
                                                  decoration: InputDecoration(
                                                    hintText: "Select Country",
                                                    contentPadding: const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                      horizontal: 0,
                                                    ),
                                                    prefixIconConstraints: const BoxConstraints(maxWidth: 50),
                                                    prefixIcon: Obx(
                                                      () => Text(
                                                        controller.countryFlag.value == "" ? "🇮🇳" : controller.countryFlag.value,
                                                        style: const TextStyle(fontSize: 16),
                                                      ).pOnly(right: 10),
                                                    ),
                                                    errorStyle: const TextStyle(fontSize: 13),
                                                    hintStyle: Get.theme.textTheme.bodyLarge!.copyWith(color: Get.theme.indicatorColor),
                                                    border: UnderlineInputBorder(
                                                        borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                    focusedBorder: UnderlineInputBorder(
                                                        borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                    enabledBorder: UnderlineInputBorder(
                                                        borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                    errorBorder: UnderlineInputBorder(
                                                        borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                    focusedErrorBorder: UnderlineInputBorder(
                                                        borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                  ),
                                                ).pSymmetric(h: 20).pOnly(bottom: 10),
                                                controller.country.value.isNotEmpty
                                                    ? Column(
                                                        children: [
                                                          TextFormField(
                                                            style: TextStyle(color: Get.theme.colorScheme.secondary, fontWeight: FontWeight.w300),
                                                            keyboardType: TextInputType.text,
                                                            onChanged: (input) {
                                                              controller.accountHolderName.value = input;
                                                              controller.accountHolderName.refresh();
                                                            },
                                                            validator: (input) {
                                                              if (input!.isEmpty) {
                                                                return "Account holder's name field is required!";
                                                              } else {
                                                                return null;
                                                              }
                                                            },
                                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                                            autocorrect: true,
                                                            decoration: InputDecoration(
                                                              hintText: "Enter Account holder's name",
                                                              contentPadding: const EdgeInsets.symmetric(
                                                                vertical: 18,
                                                                horizontal: 0,
                                                              ),
                                                              prefixIconConstraints: const BoxConstraints(minWidth: 23, maxHeight: 20),
                                                              prefixIcon: Padding(
                                                                padding: const EdgeInsets.only(right: 8),
                                                                child: Icon(
                                                                  Icons.person_2,
                                                                  color: Get.theme.indicatorColor,
                                                                  size: 18,
                                                                ),
                                                              ),
                                                              errorStyle: const TextStyle(fontSize: 13),
                                                              hintStyle: Get.theme.textTheme.bodyLarge!.copyWith(color: Get.theme.indicatorColor),
                                                              border: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              focusedBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              enabledBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              errorBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              focusedErrorBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                            ),
                                                          ).pSymmetric(h: 20).pOnly(bottom: 10),
                                                          TextFormField(
                                                            style: TextStyle(color: Get.theme.colorScheme.secondary, fontWeight: FontWeight.w300),
                                                            keyboardType: TextInputType.text,
                                                            onChanged: (input) {
                                                              controller.accountBankName.value = input;
                                                              controller.accountBankName.refresh();
                                                            },
                                                            validator: (input) {
                                                              if (input!.isEmpty) {
                                                                return "Bank name field is required!";
                                                              } else {
                                                                return null;
                                                              }
                                                            },
                                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                                            autocorrect: true,
                                                            decoration: InputDecoration(
                                                              hintText: "Enter Bank name",
                                                              contentPadding: const EdgeInsets.symmetric(
                                                                vertical: 18,
                                                                horizontal: 0,
                                                              ),
                                                              prefixIconConstraints: const BoxConstraints(minWidth: 23, maxHeight: 20),
                                                              prefixIcon: Padding(
                                                                padding: const EdgeInsets.only(right: 8),
                                                                child: Icon(
                                                                  Icons.account_balance,
                                                                  color: Get.theme.indicatorColor,
                                                                  size: 18,
                                                                ),
                                                              ),
                                                              errorStyle: const TextStyle(fontSize: 13),
                                                              hintStyle: Get.theme.textTheme.bodyLarge!.copyWith(color: Get.theme.indicatorColor),
                                                              border: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              focusedBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              enabledBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              errorBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              focusedErrorBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                            ),
                                                          ).pSymmetric(h: 20).pOnly(bottom: 10),
                                                        ],
                                                      )
                                                    : const SizedBox(),
                                                controller.country.value.isNotEmpty && controller.country.value == "India"
                                                    ? Column(
                                                        children: [
                                                          TextFormField(
                                                            style: TextStyle(color: Get.theme.colorScheme.secondary, fontWeight: FontWeight.w300),
                                                            onChanged: (input) {
                                                              controller.accountNumber.value = input;
                                                              controller.accountNumber.refresh();
                                                            },
                                                            keyboardType: TextInputType.number,
                                                            validator: (value) {
                                                              if (value == null || value.isEmpty) {
                                                                return 'Account number is required';
                                                              }
                                                              if (value.length < 8 || value.length > 16) {
                                                                return 'Account number must be 8-16 digits long';
                                                              }
                                                              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                                                return 'Account number must contain only digits';
                                                              }
                                                              return null; // Valid account number
                                                            },
                                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                                            autocorrect: true,
                                                            decoration: InputDecoration(
                                                              hintText: "Enter Account number",
                                                              contentPadding: const EdgeInsets.symmetric(
                                                                vertical: 16,
                                                                horizontal: 0,
                                                              ),
                                                              prefixIconConstraints: const BoxConstraints(minWidth: 23, maxHeight: 20),
                                                              prefixIcon: Padding(
                                                                padding: const EdgeInsets.only(right: 8),
                                                                child: Icon(
                                                                  Icons.account_box,
                                                                  color: Get.theme.indicatorColor,
                                                                  size: 18,
                                                                ),
                                                              ),
                                                              errorStyle: const TextStyle(fontSize: 13),
                                                              hintStyle: Get.theme.textTheme.bodyLarge!.copyWith(color: Get.theme.indicatorColor),
                                                              border: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              focusedBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              enabledBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              errorBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              focusedErrorBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                            ),
                                                          ).pSymmetric(h: 20).pOnly(bottom: 10),
                                                          TextFormField(
                                                            style: TextStyle(color: Get.theme.colorScheme.secondary, fontWeight: FontWeight.w300),
                                                            onChanged: (input) {
                                                              controller.accountIfscCode.value = input;
                                                              controller.accountIfscCode.refresh();
                                                            },
                                                            // keyboardType: TextInputType.text,
                                                            textCapitalization: TextCapitalization.characters,
                                                            validator: (value) {
                                                              if (value == null || value.isEmpty) {
                                                                return 'IFSC code is required';
                                                              }
                                                              if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value)) {
                                                                return 'Invalid IFSC code format';
                                                              }
                                                              return null; // Valid IFSC code
                                                            },
                                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                                            autocorrect: true,
                                                            decoration: InputDecoration(
                                                              hintText: "Enter IFSC code",
                                                              contentPadding: const EdgeInsets.symmetric(
                                                                vertical: 18,
                                                                horizontal: 0,
                                                              ),
                                                              prefixIconConstraints: const BoxConstraints(minWidth: 23, maxHeight: 20),
                                                              prefixIcon: Padding(
                                                                padding: const EdgeInsets.only(right: 8),
                                                                child: Icon(
                                                                  Icons.account_balance,
                                                                  color: Get.theme.indicatorColor,
                                                                  size: 16,
                                                                ),
                                                              ),
                                                              errorStyle: const TextStyle(fontSize: 13),
                                                              hintStyle: Get.theme.textTheme.bodyLarge!.copyWith(color: Get.theme.indicatorColor),
                                                              border: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              focusedBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              enabledBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              errorBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              focusedErrorBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                            ),
                                                          ).pSymmetric(h: 20).pOnly(bottom: 10),
                                                        ],
                                                      )
                                                    : controller.country.value.isNotEmpty && controller.country.value == "Pakistan"
                                                        ? TextFormField(
                                                            style: TextStyle(color: Get.theme.colorScheme.secondary, fontWeight: FontWeight.w300),
                                                            onChanged: (input) {
                                                              controller.iban.value = input;
                                                              controller.iban.refresh();
                                                            },
                                                            keyboardType: TextInputType.text,
                                                            textCapitalization: TextCapitalization.characters,
                                                            validator: (value) {
                                                              if (value == null || value.isEmpty) {
                                                                return 'IBAN is required';
                                                              }
                                                              if (!controller.validateIBAN(value)) {
                                                                return 'Invalid IBAN format';
                                                              }
                                                              return null; // Valid IBAN
                                                            },
                                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                                            autocorrect: true,
                                                            decoration: InputDecoration(
                                                              hintText: "Enter IBAN (e.g: DE89370400440532013000)",
                                                              contentPadding: const EdgeInsets.symmetric(
                                                                vertical: 16,
                                                                horizontal: 0,
                                                              ),
                                                              prefixIconConstraints: const BoxConstraints(minWidth: 23, maxHeight: 20),
                                                              prefixIcon: Padding(
                                                                padding: const EdgeInsets.only(right: 8),
                                                                child: Icon(
                                                                  Icons.account_box,
                                                                  color: Get.theme.indicatorColor,
                                                                  size: 18,
                                                                ),
                                                              ),
                                                              errorStyle: const TextStyle(fontSize: 13),
                                                              hintStyle: Get.theme.textTheme.bodyLarge!.copyWith(color: Get.theme.indicatorColor),
                                                              border: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              focusedBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              enabledBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              errorBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              focusedErrorBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                            ),
                                                          ).pSymmetric(h: 20).pOnly(bottom: 10)
                                                        : const SizedBox(),
                                                controller.country.value.isNotEmpty
                                                    ? Column(
                                                        children: [
                                                          TextFormField(
                                                            style: TextStyle(color: Get.theme.colorScheme.secondary, fontWeight: FontWeight.w300),
                                                            onChanged: (input) {
                                                              controller.city.value = input;
                                                              controller.city.refresh();
                                                            },
                                                            keyboardType: TextInputType.number,
                                                            validator: (value) {
                                                              if (value == null || value.isEmpty) {
                                                                return 'City is required';
                                                              }
                                                              return null; // Valid IFSC code
                                                            },
                                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                                            autocorrect: true,
                                                            decoration: InputDecoration(
                                                              hintText: "Enter City",
                                                              contentPadding: const EdgeInsets.symmetric(
                                                                vertical: 16,
                                                                horizontal: 0,
                                                              ),
                                                              prefixIconConstraints: const BoxConstraints(minWidth: 23, maxHeight: 20),
                                                              prefixIcon: Padding(
                                                                padding: const EdgeInsets.only(right: 8),
                                                                child: Icon(
                                                                  Icons.location_city,
                                                                  color: Get.theme.indicatorColor,
                                                                  size: 18,
                                                                ),
                                                              ),
                                                              errorStyle: const TextStyle(fontSize: 13),
                                                              hintStyle: Get.theme.textTheme.bodyLarge!.copyWith(color: Get.theme.indicatorColor),
                                                              border: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              focusedBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              enabledBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              errorBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              focusedErrorBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                            ),
                                                          ).pSymmetric(h: 20).pOnly(bottom: 10),
                                                          TextFormField(
                                                            style: TextStyle(color: Get.theme.colorScheme.secondary, fontWeight: FontWeight.w300),
                                                            onChanged: (input) {
                                                              controller.address.value = input;
                                                              controller.address.refresh();
                                                            },
                                                            keyboardType: TextInputType.number,
                                                            validator: (value) {
                                                              if (value == null || value.isEmpty) {
                                                                return 'Address is required';
                                                              }
                                                              return null; // Valid IFSC code
                                                            },
                                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                                            autocorrect: true,
                                                            maxLength: 200,
                                                            maxLines: 4,
                                                            decoration: InputDecoration(
                                                              hintText: "Enter Address",
                                                              contentPadding: const EdgeInsets.symmetric(
                                                                vertical: 18,
                                                                horizontal: 0,
                                                              ),
                                                              prefixIconConstraints: const BoxConstraints(minWidth: 23, maxHeight: 20),
                                                              prefixIcon: Padding(
                                                                padding: const EdgeInsets.only(right: 8, top: 0),
                                                                child: Icon(
                                                                  Icons.home,
                                                                  color: Get.theme.indicatorColor,
                                                                  size: 18,
                                                                ),
                                                              ),
                                                              errorStyle: const TextStyle(fontSize: 13),
                                                              hintStyle: Get.theme.textTheme.bodyLarge!.copyWith(color: Get.theme.indicatorColor),
                                                              border: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              focusedBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              enabledBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              errorBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              focusedErrorBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                            ),
                                                          ).pSymmetric(h: 20).pOnly(bottom: 10),
                                                          TextFormField(
                                                            style: TextStyle(color: Get.theme.colorScheme.secondary, fontWeight: FontWeight.w300),
                                                            onChanged: (input) {
                                                              controller.postCode.value = input;
                                                              controller.postCode.refresh();
                                                            },
                                                            keyboardType: TextInputType.number,
                                                            validator: (value) {
                                                              if (value == null || value.isEmpty) {
                                                                return 'Post Code is required';
                                                              }
                                                              return null; // Valid IFSC code
                                                            },
                                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                                            autocorrect: true,
                                                            decoration: InputDecoration(
                                                              hintText: "Enter Post Code",
                                                              contentPadding: const EdgeInsets.symmetric(
                                                                vertical: 18,
                                                                horizontal: 0,
                                                              ),
                                                              prefixIconConstraints: const BoxConstraints(minWidth: 23, maxHeight: 20),
                                                              prefixIcon: Padding(
                                                                padding: const EdgeInsets.only(right: 8),
                                                                child: Icon(
                                                                  Icons.local_post_office,
                                                                  color: Get.theme.indicatorColor,
                                                                  size: 16,
                                                                ),
                                                              ),
                                                              errorStyle: const TextStyle(fontSize: 13),
                                                              hintStyle: Get.theme.textTheme.bodyLarge!.copyWith(color: Get.theme.indicatorColor),
                                                              border: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              focusedBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              enabledBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              errorBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                              focusedErrorBorder: UnderlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(0), borderSide: BorderSide(width: 0.5, color: Get.theme.colorScheme.secondary.withValues(alpha:0.5))),
                                                            ),
                                                          ).pSymmetric(h: 20),
                                                        ],
                                                      )
                                                    : const SizedBox()
                                              ],
                                            ).pSymmetric(v: 10),
                                          ),
                              ],
                            )
                          : const SizedBox(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Get.theme.primaryColorDark,
            child: Icon(
              Icons.send,
              color: Get.theme.primaryColor,
            ),
            onPressed: () {
              print(controller.activeTab.value);
              if (controller.activeTab.value == "B") {
                if (controller.bankFormKey.currentState!.validate()) {
                  controller.sendPaymentRequest();
                }
              } else if (controller.activeTab.value == "U") {
                if (controller.upiFormKey.currentState!.validate()) {
                  controller.sendPaymentRequest();
                }
              } else {
                if (controller.paypalFormKey.currentState!.validate()) {
                  controller.sendPaymentRequest();
                }
              }
            },
            // ...FloatingActionButton properties...
          ),
        ),
      ),
    );
  }
}
