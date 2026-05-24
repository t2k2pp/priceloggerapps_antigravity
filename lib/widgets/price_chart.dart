import 'dart:math';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/colors.dart';

class PriceChart extends StatelessWidget {
  final List<PriceRecord> records;
  final String storeFilter;
  final bool multiStore;
  final double height;

  const PriceChart({
    Key? key,
    required this.records,
    this.storeFilter = 'all',
    this.multiStore = false,
    this.height = 180.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Container(
        height: height,
        alignment: Alignment.center,
        child: const Text(
          '記録がありません',
          style: TextStyle(color: AppColors.ink3, fontSize: 13),
        ),
      );
    }

    // フィルタリング処理
    List<PriceRecord> filteredRecords = [];
    if (multiStore || storeFilter == 'all') {
      filteredRecords = List<PriceRecord>.from(records);
    } else {
      filteredRecords = records.where((r) => r.store == storeFilter).toList();
    }

    if (filteredRecords.isEmpty) {
      return Container(
        height: height,
        alignment: Alignment.center,
        child: const Text(
          'この店舗の記録はありません',
          style: TextStyle(color: AppColors.ink3, fontSize: 13),
        ),
      );
    }

    // 日付昇順（古い順）にソート
    filteredRecords.sort((a, b) => a.date.compareTo(b.date));

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: _ChartPainter(
              allSortedRecords: filteredRecords,
              multiStore: multiStore,
              storeFilter: storeFilter,
            ),
          ),
        );
      },
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<PriceRecord> allSortedRecords;
  final bool multiStore;
  final String storeFilter;

  _ChartPainter({
    required this.allSortedRecords,
    required this.multiStore,
    required this.storeFilter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final prices = allSortedRecords.map((r) => r.priceTax).toList();
    final double minP = prices.reduce(min).toDouble();
    final double maxP = prices.reduce(max).toDouble();
    
    final double padY = max(20.0, (maxP - minP) * 0.3);
    final double yMin = max(0.0, minP - padY);
    final double yMax = maxP + padY;
    final double yRange = (yMax - yMin == 0) ? 1.0 : (yMax - yMin);

    const double padL = 44.0;
    const double padR = 14.0;
    const double padT = 14.0;
    const double padB = 28.0;

    final double chartW = size.width - padL - padR;
    final double chartH = size.height - padT - padB;

    double getX(int index, int total) {
      if (total <= 1) return padL + chartW / 2;
      return padL + (chartW * index) / (total - 1);
    }

    double getY(double val) {
      return padT + chartH - ((val - yMin) / yRange) * chartH;
    }

    // 1. グリッドとY軸ラベルの描画
    final gridPaint = Paint()
      ..color = AppColors.line
      ..strokeWidth = 1.0;

    const int yTicksCount = 3;
    final List<double> tickVals = List.generate(
      yTicksCount,
      (i) => yMin + (yRange * i) / (yTicksCount - 1),
    );

    for (var v in tickVals) {
      final yVal = getY(v);
      // グリッド点線の描画
      _drawDashedLine(
        canvas,
        Offset(padL, yVal),
        Offset(size.width - padR, yVal),
        gridPaint,
        3.0,
        3.0,
      );

      // Y軸テキスト描画
      final textPainter = TextPainter(
        text: TextSpan(
          text: v.round().toString(),
          style: const TextStyle(
            color: AppColors.ink3,
            fontSize: 10,
            fontFamily: 'Noto Sans JP',
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(padL - textPainter.width - 6, yVal - textPainter.height / 2),
      );
    }

    // 2. X軸ラベルの描画（日付）
    for (int i = 0; i < allSortedRecords.length; i++) {
      final r = allSortedRecords[i];
      final xVal = getX(i, allSortedRecords.length);
      final dateStr = _formatDate(r.date);

      final textPainter = TextPainter(
        text: TextSpan(
          text: dateStr,
          style: const TextStyle(
            color: AppColors.ink3,
            fontSize: 10,
            fontFamily: 'Noto Sans JP',
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(xVal - textPainter.width / 2, size.height - padB + 6),
      );
    }

    // 3. 折れ線の描画
    if (multiStore) {
      // 店舗ごとにグループ化して描画
      final Map<String, List<PriceRecord>> byStore = {};
      for (var r in allSortedRecords) {
        byStore.putIfAbsent(r.store, () => []).add(r);
      }

      byStore.forEach((store, recs) {
        final List<Offset> points = [];
        for (var r in recs) {
          // X座標はグローバルの日付順インデックスと一致させる
          final globalIdx = allSortedRecords.indexWhere((s) => s.id == r.id);
          points.add(Offset(getX(globalIdx, allSortedRecords.length), getY(r.priceTax.toDouble())));
        }

        final storeColor = AppColors.getStoreColor(store);
        _drawLinesAndPoints(canvas, points, storeColor, showGradient: false, chartBottom: padT + chartH);
      });
    } else {
      // 単一店舗または全店舗一括描画 ( storeFilter で指定 )
      final List<Offset> points = [];
      for (int i = 0; i < allSortedRecords.length; i++) {
        points.add(Offset(getX(i, allSortedRecords.length), getY(allSortedRecords[i].priceTax.toDouble())));
      }

      final chartColor = storeFilter == 'all'
          ? AppColors.accent
          : AppColors.getStoreColor(storeFilter);

      _drawLinesAndPoints(canvas, points, chartColor, showGradient: true, chartBottom: padT + chartH);
    }
  }

  void _drawLinesAndPoints(
    Canvas canvas,
    List<Offset> points,
    Color color, {
    required bool showGradient,
    required double chartBottom,
  }) {
    if (points.isEmpty) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    // 1本以上の線を描画できる場合
    if (points.length > 1) {
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);

      // 下塗りのグラデーション (単一色の時のみ)
      if (showGradient) {
        final fillPath = Path()
          ..moveTo(points[0].dx, points[0].dy);
        for (int i = 1; i < points.length; i++) {
          fillPath.lineTo(points[i].dx, points[i].dy);
        }
        fillPath.lineTo(points.last.dx, chartBottom);
        fillPath.lineTo(points.first.dx, chartBottom);
        fillPath.close();

        final fillPaint = Paint()
          ..color = color.withOpacity(0.08)
          ..style = PaintingStyle.fill;

        canvas.drawPath(fillPath, fillPaint);
      }
    }

    // データポイント（円）の描画
    final outerPointPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final innerPointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (var pt in points) {
      canvas.drawCircle(pt, 4.0, innerPointPaint);
      canvas.drawCircle(pt, 4.0, outerPointPaint);
    }
  }

  // 点線を描画するヘルパー
  void _drawDashedLine(
      Canvas canvas, Offset p1, Offset p2, Paint paint, double dashWidth, double dashSpace) {
    double distance = (p2 - p1).distance;
    int count = (distance / (dashWidth + dashSpace)).floor();
    Offset direction = (p2 - p1) / distance;
    for (int i = 0; i < count; i++) {
      double start = i * (dashWidth + dashSpace);
      canvas.drawLine(
        p1 + direction * start,
        p1 + direction * (start + dashWidth),
        paint,
      );
    }
  }

  // 日付の簡易フォーマット (YYYY-MM-DD -> MM/DD)
  String _formatDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length >= 3) {
        return '${parts[1]}/${parts[2]}';
      }
    } catch (_) {}
    return dateStr;
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.allSortedRecords != allSortedRecords ||
        oldDelegate.multiStore != multiStore ||
        oldDelegate.storeFilter != storeFilter;
  }
}
