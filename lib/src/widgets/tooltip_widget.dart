import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyTooltip extends StatelessWidget {
  final Widget child;
  final String message;

  MyTooltip({required this.message, required this.child});

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<State<Tooltip>>();
    return Tooltip(
      key: key,
      richMessage: WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: Container(
            padding: const EdgeInsets.all(5),
            constraints:
            BoxConstraints(maxWidth: Get.width * 0.8),
            child: Text(message,style: TextStyle(color: Get.theme.primaryColor,fontSize: 15),),
          )),
      decoration: BoxDecoration(
        color:Get.theme.indicatorColor,
        borderRadius: const BorderRadius.all(
            Radius.circular(4)),
      ),
      //message: message,
      preferBelow:false,

      verticalOffset: 10,
      padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(key),
        child: child,
      ),
    );
  }

  void _onTap(GlobalKey key) {
    final dynamic tooltip = key.currentState;
    tooltip?.ensureTooltipVisible();
  }
}
