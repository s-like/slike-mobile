import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as HTTP;
import 'package:in_app_purchase/in_app_purchase.dart';

import '../core.dart';

class WalletController extends GetxController {
  ScrollController scrollController = ScrollController();
  ScrollController myGiftsScrollController = ScrollController();
  var showLoader = true.obs;
  // WalletApi walletApi = Get.find();
  WalletService walletService = Get.find();
  bool showLoadMore = true;
  late VoidCallback scrollListener;
  String search = '';
  int page = 1;
  var exchangeRate = 0.0.obs;
  var paymentEmail = "".obs;
  GlobalKey<FormState> formKey = GlobalKey();
  var selectedItem = ProductDetails(currencyCode: '', description: '', id: '', title: '', price: '', rawPrice: 0, currencySymbol: '').obs;
  InAppPurchaseController inAppPurchaseController = Get.find();
  var totalAmountSelected = 0.0.obs;
  var totalAmountToPay = 0.0.obs;
  var activeButton = 0.obs;
  int myGiftsPage = 1;
  var upiId = "".obs;
  // var exchangeRate = 0.0.obs;
  var accountHolderName = "".obs;
  var accountBankName = "".obs;
  var accountNumber = "".obs;
  var iban = "".obs;
  var accountIfscCode = "".obs;
  var country = "".obs;
  var countryFlag = "".obs;
  late VoidCallback myGiftsScrollListener;
  var withdrawAmountController = TextEditingController().obs;
  ScrollController withdrawRequestsScrollController = ScrollController();
  late VoidCallback withdrawRequestsScrollListener;
  var activeTab = 'P'.obs;
  GlobalKey<FormState> bankFormKey = GlobalKey();
  GlobalKey<FormState> paypalFormKey = GlobalKey();
  GlobalKey<FormState> upiFormKey = GlobalKey();
  TextEditingController countryController = TextEditingController();
  var city = "".obs;
  var address = "".obs;
  var postCode = "".obs;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  Future<void> fetchExchangeRate() async {
    final url = Uri.parse('https://api.exchangerate-api.com/v4/latest/INR'); // Example API
    try {
      final response = await HTTP.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // setState(() {
        exchangeRate.value = data['rates']['USD'];
        exchangeRate.refresh();
        print(exchangeRate.value);
        // });
      } else {
        throw Exception('Failed to fetch exchange rate');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  bool validateIBAN(String iban) {
    // Remove spaces and convert to uppercase
    iban = iban.replaceAll(' ', '').toUpperCase();

    // Check for general format using regex
    final regex = RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z0-9]{1,30}$');
    if (!regex.hasMatch(iban)) return false;

    // Rearrange: Move first 4 characters to the end
    String rearranged = iban.substring(4) + iban.substring(0, 4);

    // Convert letters to numbers (A=10, B=11, ..., Z=35)
    String numericIBAN = rearranged.split('').map((char) {
      if (RegExp(r'[A-Z]').hasMatch(char)) {
        return (char.codeUnitAt(0) - 55).toString();
      } else {
        return char;
      }
    }).join();

    // Perform modulo 97 check
    BigInt ibanNumber = BigInt.parse(numericIBAN);
    return ibanNumber % BigInt.from(97) == BigInt.one;
  }

  Future<void> fetchMyWallet({showLoader = false}) async {
    if (showLoader) EasyLoading.show(status: 'loading...');
    print("ssssssss1");
    HTTP.Response responseVar = await CommonHelper.sendRequestToServer(endPoint: "wallet-history", requestData: {'page': page.toString()});
    print(responseVar.body);
    var response = jsonDecode(responseVar.body);
    if (showLoader) EasyLoading.dismiss();
    if (response['status']) {
      if (page == 1) {
        fetchExchangeRate();
        scrollController = ScrollController();
        walletService.walletData.value = WalletModel.fromJSON(response);
      } else {
        walletService.walletData.value.data.addAll(WalletModel.fromJSON(response).data);
      }
      walletService.walletData.refresh();
      if (walletService.walletData.value.data.length >= walletService.walletData.value.totalRecords) {
        showLoadMore = false;
      }
      if (page == 1) {
        scrollListener = () {
          if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
            if (walletService.walletData.value.data.length != walletService.walletData.value.totalRecords && showLoadMore) {
              page = page + 1;
              fetchMyWallet();
            }
          }
        };
        scrollController.addListener(scrollListener);
      }
    }
  }

  double applyChargesOnAmount(double tax, double amount) {
    double netAmount = amount * tax * 0.01;
    return netAmount;
  }

  double getNetAmount(double conversionFeeAmount, double convenienceFeeAmount, double actualPrice) {
    double netAmount = actualPrice - (conversionFeeAmount + convenienceFeeAmount);
    totalAmountToPay.value = netAmount;
    totalAmountToPay.refresh();
    return netAmount;
  }

  Future<void> sendPaymentRequest() async {
    Map<String, dynamic> data = {};
    data['payment_type_id'] = '1';

    if (activeTab.value == "B") {
      data['acc_holder_name'] = accountHolderName.value.toString();
      data['bank_name'] = accountBankName.value.toString();
      data['acc_no'] = accountNumber.value.toString();
      data['ifsc_code'] = accountIfscCode.value.toString();
      data['iban'] = iban.value.toString();
      data['country'] = country.value.toString();
      data['city'] = city.value.toString();
      data['address'] = address.value.toString();
      data['postcode'] = postCode.value.toString();
    } else if (activeTab.value == "U") {
      data['upi'] = upiId.value;
    } else {
      data['payment_id'] = paymentEmail.value;
    }
    data['coins'] = totalAmountSelected.value.toString();
    data['amount'] = (totalAmountToPay.value * exchangeRate.value).toStringAsFixed(2);
    data['currency'] = "\$";
    data['currency_code'] = "USD";
    print(data);

    EasyLoading.show(status: 'loading...');
    HTTP.Response responseVar = await CommonHelper.sendRequestToServer(endPoint: "withdraw-request", requestData: data, method: 'post');
    var response = jsonDecode(responseVar.body);
    EasyLoading.dismiss();
    if (response['status']) {
      Get.back();
      totalAmountSelected.value = 0.0;
      totalAmountSelected.refresh();
      selectedItem.value = ProductDetails(currencyCode: '', description: '', id: '', title: '', price: '', rawPrice: 0, currencySymbol: '');
      selectedItem.refresh();
      withdrawAmountController.value = TextEditingController(text: "");
      paymentEmail.value = "";
      paymentEmail.refresh();
      upiId.value = "";
      upiId.refresh();
      activeButton.value = 0;
      activeButton.refresh();
      fetchMyWallet();
      page = 1;
      Fluttertoast.showToast(msg: "Withdrawal request submitted successfully!", backgroundColor: Colors.green, textColor: Colors.white);
    }
  }

  getWithdrawRequests({bool showLoader = false}) async {
    if (showLoader) EasyLoading.show(status: 'loading...');

    HTTP.Response responseVar = await CommonHelper.sendRequestToServer(endPoint: "withdraw-request-list", requestData: {'page': page.toString()});
    var response = jsonDecode(responseVar.body);

    if (showLoader) EasyLoading.dismiss();
    if (response['status']) {
      if (page == 1) {
        withdrawRequestsScrollController = ScrollController();
        walletService.paymentRequestsData.value = PaymentRequestModel.fromJSON(response);
      } else {
        walletService.paymentRequestsData.value.data.addAll(PaymentRequestModel.fromJSON(response).data);
      }
      walletService.paymentRequestsData.refresh();
      if (walletService.paymentRequestsData.value.data.length >= walletService.paymentRequestsData.value.totalRecords) {
        showLoadMore = false;
      }
      if (page == 1) {
        withdrawRequestsScrollListener = () {
          if (withdrawRequestsScrollController.position.pixels == withdrawRequestsScrollController.position.maxScrollExtent) {
            if (walletService.paymentRequestsData.value.data.length != walletService.paymentRequestsData.value.totalRecords && showLoadMore) {
              page = page + 1;
              getWithdrawRequests();
            }
          }
        };
        withdrawRequestsScrollController.addListener(withdrawRequestsScrollListener);
      }
    }
  }
}
