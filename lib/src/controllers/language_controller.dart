import 'dart:ui';

import 'package:get/get.dart';

import '../core.dart';

class LanguageController extends GetxController {
  var isLoading = false.obs;

  // var locale = Locale(GetStorage().read("language_code") ?? "en").obs;
  var languageCode = "".obs;

  @override
  void onInit() {
    // locale.value = Get.locale ?? Locale(GetStorage().read("language_code") ?? "en");

    languageCode.value = Get.locale != null ? Get.locale!.languageCode : "en";

    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void setLocale() {
    print("setLocale");
    print(languageCode.value);

    GetStorage().write("language_code", languageCode.value);
    GetStorage().write("locale", languageCode.value);
    Get.updateLocale(Locale(languageCode.value));

    Get.back();
  }
}
