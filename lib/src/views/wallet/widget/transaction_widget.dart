import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

import '../../../core.dart';

class TransactionWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final WalletItem? item;
  const TransactionWidget({Key? key, this.onPressed, this.item}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      minLeadingWidth: 20,
      leading: const Icon(
        Icons.check_circle,
        color: Colors.green,
        size: 22,
      ),
      title: (item!.type == "C"
              ? item!.rowAmount.isNotEmpty
                  ? 'Purchased'
                  : 'Received'
              : 'Deducted')
          .text
          .textStyle(Get.theme.textTheme.headlineSmall)
          .bold
          .color(Get.theme.colorScheme.secondary)
          .size(14)
          .make(),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 3),
          Html(
            style: {
              "*": Style(
                color: Get.theme.colorScheme.secondary.withValues(alpha:0.8),
                fontSize: FontSize.small,
                padding: HtmlPaddings.zero,
                margin: Margins.zero,
                lineHeight: LineHeight.em(1.1),
              ),
              "b": Style(
                color: Get.theme.primaryColorDark,
              ),
            },
            shrinkWrap: true,
            data: item!.status,
          ),
          /*Text(
            item!.status.toString(),
            style: TextStyle(
              color: Get.theme.primaryColorDark,
              fontSize: 10.0,
            ),
          ),*/
          MyTooltip(
            message: item!.createdDate.toString(),
            child: Text(
              CommonHelper.timeAgoSinceDate(item!.createdDate.toString(), short: false),
              style: TextStyle(
                color: Get.theme.primaryColorDark,
                fontSize: 10.0,
              ),
            ),
          ),
        ],
      ),
      trailing: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/coin.png',
                width: 12,
                fit: BoxFit.fill,
              ).pOnly(right: 5),
              Icon(
                item!.type == "C" ? Icons.add : Icons.remove,
                color: item!.type == "C" ? Colors.green : Get.theme.colorScheme.primary,
                size: 10,
              ),
              item!.coins.text.textStyle(Get.theme.textTheme.headlineSmall).bold.color(item!.type == "C" ? Colors.green : Get.theme.colorScheme.primary).size(14).make(),
            ],
          ).pOnly(bottom: 2),
          item!.rowAmount.text.textStyle(Get.theme.textTheme.headlineSmall).bold.color(Get.theme.indicatorColor).size(12).make()
        ],
      ),
    );
  }
}
