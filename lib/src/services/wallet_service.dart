import 'package:get/get.dart';

import '../core.dart';

class WalletService extends GetxService {
  var walletData = WalletModel().obs;
  var paymentRequestsData = PaymentRequestModel().obs;
}
