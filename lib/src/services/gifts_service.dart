import 'package:get/get.dart';

import '../core.dart';

class GiftService extends GetxService {
  var gifts = <Gift>[].obs;

  var myGiftsData = MyGiftsModel().obs;
}
