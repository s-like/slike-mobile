import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showReportSubmittedToast(BuildContext context) {
  final overlay = Overlay.of(context);

  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).viewInsets.top + 50,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: ReportSubmittedToast(),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(Duration(seconds: 4), () {
    overlayEntry.remove();
  });
}

class ReportSubmittedToast extends StatelessWidget {
  const ReportSubmittedToast({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: CustomPaint(
            painter: _SpeechBubblePainter(),
            child: Container(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 35),
              child: Text(
                "Report received.\nWe will review the reported content and take necessary action.\n\nThank you."
                    .tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Image.asset(
          'assets/images/reportsuccess.png',
          height: 450,
        )
      ],
    );
  }
}

class _SpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = Colors.black.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Color(0xFFFFC107)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final double borderRadius = 10.0;
    final double tipHeight = 15.0;
    final double tipWidth = 20.0;

    final Rect bubbleRect =
        Rect.fromLTWH(0, 0, size.width, size.height - tipHeight);

    path.moveTo(bubbleRect.left + borderRadius, bubbleRect.top);
    path.lineTo(bubbleRect.right - borderRadius, bubbleRect.top);
    path.quadraticBezierTo(bubbleRect.right, bubbleRect.top, bubbleRect.right,
        bubbleRect.top + borderRadius);
    path.lineTo(bubbleRect.right, bubbleRect.bottom - borderRadius);
    path.quadraticBezierTo(bubbleRect.right, bubbleRect.bottom,
        bubbleRect.right - borderRadius, bubbleRect.bottom);
    path.lineTo(bubbleRect.left + 30 + tipWidth, bubbleRect.bottom);
    path.lineTo(
        bubbleRect.left + 30 + (tipWidth / 2), bubbleRect.bottom + tipHeight);
    path.lineTo(bubbleRect.left + 30, bubbleRect.bottom);
    path.lineTo(bubbleRect.left + borderRadius, bubbleRect.bottom);
    path.quadraticBezierTo(bubbleRect.left, bubbleRect.bottom,
        bubbleRect.left, bubbleRect.bottom - borderRadius);
    path.lineTo(bubbleRect.left, bubbleRect.top + borderRadius);
    path.quadraticBezierTo(bubbleRect.left, bubbleRect.top,
        bubbleRect.left + borderRadius, bubbleRect.top);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
} 