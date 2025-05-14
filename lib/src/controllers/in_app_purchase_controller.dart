import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as HTTP;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../core.dart';

class InAppPurchaseController extends GetxController with GetSingleTickerProviderStateMixin {
  var isApiAvailable = false.obs;
  // List<String> kProductIds = <String>['coins_100', 'coins_500', 'coins_1000', 'coins_5000', 'coins_10000'];
  // List<String> kProductIds = <String>['coins_100', 'coins_500', 'coins_1000', 'coins_5000', 'coins_10000'];
  final InAppPurchase inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> subscription;
  List<String> notFoundIds = <String>[];
  var products = <ProductDetails>[].obs;
  var purchases = <PurchaseDetails>[].obs;
  List<String> consumables = <String>[];
  var activeCoinIndex = 999.obs;
  final bool _kAutoConsume = Platform.isIOS || true;
  InAppPurchaseService inAppPurchaseService = Get.find();
  WalletService walletService = Get.find();
  MainService mainService = Get.find();
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initInAppSubscription();
  }

  Future<void> initInAppSubscription() async {
    final Stream<List<PurchaseDetails>> purchaseUpdated = inAppPurchase.purchaseStream;
    subscription = purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      print(44444);
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      subscription.cancel();
    }, onError: (Object error) {
      // handle error here.
    });
  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.restored) {
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!_kAutoConsume && purchaseDetails.productID == inAppPurchaseService.selectedProduct.value.id) {
            final InAppPurchaseAndroidPlatformAddition androidAddition = inAppPurchase.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  /// Your own business logic to setup a consumable
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    bool isPurchased = await _hasPurchased(purchaseDetails);
    return isPurchased;
  }

  /// Returns purchase of specific product ID
  Future<bool> _hasPurchased(PurchaseDetails purchaseDetails) {
    if (purchaseDetails.productID == inAppPurchaseService.selectedProduct.value.id) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        return Future<bool>.value(true);
      } else {
        return Future<bool>.value(false);
      }
    } else {
      return Future<bool>.value(false);
    }
  }

  Future<void> initStoreInfo([bool showPopup = true]) async {
    final bool isAvailable = await inAppPurchase.isAvailable();
    if (isAvailable) {
      print("API is available on the device");
      isApiAvailable.value = true;
      isApiAvailable.refresh();
      await _getProducts();
      print(44444);
      if (showPopup) {
        coinsWidget();
      }
      return;
    } else {
      print("API is not available on the device");
    }
  }

  /// Get all products available for sale
  Future<void> _getProducts() async {
    final ProductDetailsResponse productDetailResponse = await inAppPurchase.queryProductDetails(mainService.setting.value.productIds.toSet());
    print(productDetailResponse.productDetails.length);
    if (productDetailResponse.productDetails.isNotEmpty) {
      products.value = productDetailResponse.productDetails;
      products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
      products.refresh();
      print(products);
    }
  }

  /// Purchase a product
  Future _buyProduct(ProductDetails prod) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    await inAppPurchase.buyConsumable(purchaseParam: purchaseParam, autoConsume: true);
  }

  String extractCoins(String input) {
    String value = "";
    final regex = RegExp(r'([\d,]+)');
    final match = regex.firstMatch(input);
    if (match != null) {
      value = match.group(1) ?? ''; // Returns the number as a string
    }
    return value + " Coins"; // Returns an empty string if no match found
  }

  coinsWidget() {
    activeCoinIndex.value = 999;
    activeCoinIndex.refresh();
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
                            walletService.walletData.value.totalWalletAmount.text.center
                                .textStyle(Get.theme.textTheme.headlineMedium)
                                .size(16)
                                .color(Get.theme.colorScheme.secondary)
                                .make()
                                .centered(),
                          ],
                        ),
                        "Buy Coins".text.center.textStyle(Get.theme.textTheme.headlineMedium).size(16).color(Get.theme.colorScheme.secondary).make().centered(),
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
                          height: 110,
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: products.length,
                        itemBuilder: (BuildContext context, int i) {
                          ProductDetails item = products.elementAt(i);
                          return Obx(
                            () => Container(
                              width: 110,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: activeCoinIndex.value != i ? Get.theme.colorScheme.secondary.withValues(alpha:0.05) : Get.theme.primaryColorDark.withValues(alpha:0.6),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/icons/coins.png',
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.cover,
                                  ).pOnly(bottom: 10),
                                  extractCoins(item.title)
                                      .text
                                      .center
                                      .textStyle(Get.theme.textTheme.headlineMedium)
                                      .size(15)
                                      .color(activeCoinIndex.value != i ? Get.theme.colorScheme.primary : Get.theme.primaryColor)
                                      .make()
                                      .centered()
                                      .pOnly(bottom: 5),
                                  item.price.text.center
                                      .textStyle(Get.theme.textTheme.headlineSmall)
                                      .size(12)
                                      .color(activeCoinIndex.value != i ? Get.theme.colorScheme.secondary : Get.theme.primaryColor)
                                      .make()
                                      .centered(),
                                ],
                              ).pSymmetric(v: 10),
                            ).onTap(() async {
                              EasyLoading.show(status: 'loading...');
                              inAppPurchaseService.selectedProduct.value = item;
                              inAppPurchaseService.selectedProduct.refresh();
                              activeCoinIndex.value = i;
                              activeCoinIndex.refresh();
                              await _buyProduct(item);
                              EasyLoading.dismiss();
                            }),
                          );
                        }).pSymmetric(h: 15),
                  ),
                ],
              ),
            );
          });
        });
  }

  String extractIntegers(String input) {
    // Use RegExp to find all digits in the string
    final RegExp digitRegExp = RegExp(r'\d+');
    // Combine all matches into a single string
    return digitRegExp.allMatches(input).map((e) => e.group(0)).join();
  }

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    Map<String, dynamic> data = {};
    data['product_id'] = purchaseDetails.productID;
    data['coins'] = extractIntegers(inAppPurchaseService.selectedProduct.value.title);
    data['amount'] = inAppPurchaseService.selectedProduct.value.rawPrice.toString();
    data['raw_amount'] = inAppPurchaseService.selectedProduct.value.price;
    data['status'] = purchaseDetails.status.name;
    data['message'] = '';
    data['transaction_date'] = purchaseDetails.transactionDate ?? '';
    data['transaction_id'] = purchaseDetails.purchaseID ?? '';
    data['source'] = purchaseDetails.verificationData.source;
    print(data);
    EasyLoading.show(status: 'loading...');
    HTTP.Response responseVar = await CommonHelper.sendRequestToServer(endPoint: 'purchase-product', requestData: data, method: "post");
    var response = jsonDecode(responseVar.body);

    EasyLoading.dismiss();
    if (response['status']) {
      Get.back();
      walletService.walletData.value.totalWalletAmount += int.parse(extractIntegers(inAppPurchaseService.selectedProduct.value.title));
      walletService.walletData.refresh();
      Fluttertoast.showToast(msg: "Payment done successfully!", backgroundColor: Colors.green, textColor: Colors.white);
      WalletController walletController = Get.find();
      walletController.fetchMyWallet();
    }
  }
}
