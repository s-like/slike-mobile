import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseService extends GetxService {
  var selectedProduct = ProductDetails(currencyCode: '', description: '', id: '', title: '', price: '', rawPrice: 0, currencySymbol: '').obs;
}
