import 'dart:math';

import 'package:flutter/material.dart';

class QrScannerOverlayShape extends ShapeBorder {
  QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.8),
    this.borderRadius = 0,
    this.borderLength = 40,
    double? cutOutSize,
    double? cutOutWidth,
    double? cutOutHeight,
    this.hintLines = true,
    this.customRect,
    this.cutOutBottomOffset = 0,
  })  : cutOutWidth = cutOutWidth ?? cutOutSize ?? 250,
        cutOutHeight = cutOutHeight ?? cutOutSize ?? 250 {
    assert(
      borderLength <=
          min(this.cutOutWidth, this.cutOutHeight) / 2 + borderWidth * 2,
      "Border can't be larger than ${min(this.cutOutWidth, this.cutOutHeight) / 2 + borderWidth * 2}",
    );
    assert(
        (cutOutWidth == null && cutOutHeight == null) ||
            (cutOutSize == null && cutOutWidth != null && cutOutHeight != null),
        'Use only cutOutWidth and cutOutHeight or only cutOutSize');
  }

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutWidth;
  final double cutOutHeight;
  final double cutOutBottomOffset;
  final bool hintLines;
  final Rect? customRect;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return _getLeftTopPath(rect)
      ..lineTo(
        rect.right,
        rect.bottom,
      )
      ..lineTo(
        rect.left,
        rect.bottom,
      )
      ..lineTo(
        rect.left,
        rect.top,
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final _borderLength =
        borderLength > min(cutOutHeight, cutOutHeight) / 2 + borderWidth * 2
            ? borderWidthSize / 2
            : borderLength;
    final _cutOutWidth =
        cutOutWidth < width ? cutOutWidth : width - borderOffset;
    final _cutOutHeight =
        cutOutHeight < height ? cutOutHeight : height - borderOffset;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final hintLinesPaint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..color = borderColor
      ..shader = LinearGradient(
        colors: [
          borderColor.withValues(alpha: 0.15),
          borderColor,
          borderColor,
          borderColor.withValues(alpha: 0.15),
        ],
        stops: const [0.25, 0.40, 0.60, 0.75],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(rect);

    final cutOutRect = customRect ?? Rect.fromLTWH(
      rect.left + width / 2 - _cutOutWidth / 2 + borderOffset,
      -cutOutBottomOffset +
          rect.top +
          height / 2 -
          _cutOutHeight / 2 +
          borderOffset,
      _cutOutWidth - borderOffset * 2,
      _cutOutHeight - borderOffset * 2,
    );

    canvas
      ..saveLayer(
        rect,
        backgroundPaint,
      )
      ..drawRect(
        rect,
        backgroundPaint,
      )
      // * main rounded rectangle
      ..drawRRect(
        RRect.fromRectAndRadius(
          cutOutRect,
          Radius.circular(borderRadius),
        ),
        boxPaint,
      )
      // * Draw bottom and top left corner
      ..drawPath(
        Path()
          ..moveTo(cutOutRect.left + _borderLength, cutOutRect.top)
          ..lineTo(cutOutRect.left + borderRadius, cutOutRect.top)
          ..addArc(
            Rect.fromCircle(
              center: Offset(cutOutRect.left + borderRadius, cutOutRect.top + borderRadius),
              radius: borderRadius
            ),
            - (pi) / 2,
            - (pi) / 2,
          )
          ..lineTo(cutOutRect.left, cutOutRect.top + _borderLength)

          ..moveTo(cutOutRect.left, cutOutRect.bottom - _borderLength)
          ..lineTo(cutOutRect.left, cutOutRect.bottom - borderRadius)
          ..addArc(
            Rect.fromCircle(
              center: Offset(cutOutRect.left + borderRadius, cutOutRect.bottom - borderRadius),
              radius: borderRadius
            ),
            pi,
            - (pi / 2),
          )
          ..lineTo(cutOutRect.left + _borderLength, cutOutRect.bottom),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..strokeCap = StrokeCap.round
          ..color = borderColor
      )
      // * Draw bottom and top right corner
      ..drawPath(
        Path()
          ..moveTo(cutOutRect.right - _borderLength, cutOutRect.top)
          ..lineTo(cutOutRect.right - borderRadius, cutOutRect.top)
          ..addArc(
            Rect.fromCircle(
              center: Offset(cutOutRect.right - borderRadius, cutOutRect.top + borderRadius),
              radius: borderRadius
            ),
            -pi / 2,
            pi / 2,
          )

          ..lineTo(cutOutRect.right, cutOutRect.top + _borderLength)

          ..moveTo(cutOutRect.right, cutOutRect.bottom - _borderLength)
          ..lineTo(cutOutRect.right, cutOutRect.bottom - borderRadius)
          ..addArc(
            Rect.fromCircle(
                center: Offset(cutOutRect.right - borderRadius, cutOutRect.bottom - borderRadius),
                radius: borderRadius),
            0,
            pi / 2,
          )
          ..lineTo(cutOutRect.right - _borderLength, cutOutRect.bottom),

        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..strokeCap = StrokeCap.round
          ..color = borderColor
      );
      
      if (hintLines) {
        canvas
          ..drawLine(
            Offset(cutOutRect.left, cutOutRect.top + _borderLength),
            Offset(cutOutRect.right, cutOutRect.top + _borderLength),
            hintLinesPaint
        )
        ..drawLine(
            Offset(cutOutRect.left, cutOutRect.bottom - _borderLength),
            Offset(cutOutRect.right, cutOutRect.bottom - _borderLength),
            hintLinesPaint
        );
      }
      
      canvas.restore();
  }
  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
