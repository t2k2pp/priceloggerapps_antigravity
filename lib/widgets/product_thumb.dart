import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductThumb extends StatelessWidget {
  final Product product;
  final double size;
  final double radius;

  const ProductThumb({
    Key? key,
    required this.product,
    this.size = 56.0,
    this.radius = 14.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    try {
      final colorStr = product.color.replaceAll('0x', '').replaceAll('#', '');
      final colorVal = int.parse(colorStr, radix: 16);
      // アルファ値が設定されていない場合は不透明にする (0xFF000000)
      bgColor = Color(colorVal.toUnsigned(32) | 0xFF000000);
    } catch (e) {
      bgColor = const Color(0xFFF3ECE2); // エラー発生時のフォールバック色
    }

    final double innerFontSize = size * 0.55;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: Colors.black.withOpacity(0.04),
          width: 1.0,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        product.emoji,
        style: TextStyle(
          fontSize: innerFontSize,
          height: 1.0,
        ),
      ),
    );
  }
}
