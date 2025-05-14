import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core.dart';

class PaymentRequestWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final PaymentRequest? item;
  const PaymentRequestWidget({Key? key, this.onPressed, this.item}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      minLeadingWidth: 20,
      leading: Icon(
        item!.status == "P"
            ? Icons.hourglass_top
            : item!.status == "S"
                ? Icons.add
                : Icons.cancel,
        color: item!.status == "S"
            ? Colors.green
            : item!.status == "P"
                ? Get.theme.primaryColorDark
                : Get.theme.colorScheme.primary,
        size: 22,
      ),
      title: ("Payment ${(item!.status == "S") ? ' Sent' : (item!.status == "P") ? 'in process' : 'request canceled by admin'}")
          .text
          .textStyle(Get.theme.textTheme.headlineSmall)
          .bold
          .color(Get.theme.colorScheme.secondary)
          .size(14)
          .make(),
      subtitle: item!.createdAt.text.textStyle(Get.theme.textTheme.headlineSmall).color(Get.theme.colorScheme.secondary.withValues(alpha:0.8)).size(11).make(),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/coin.png',
            width: 12,
            fit: BoxFit.fill,
          ).pOnly(right: 5),
          item!.coins.text.textStyle(Get.theme.textTheme.headlineSmall).bold.color(item!.status == "C" ? Colors.green : Get.theme.colorScheme.primary).size(14).make(),
        ],
      ).pOnly(bottom: 2),
    );
  }
}
