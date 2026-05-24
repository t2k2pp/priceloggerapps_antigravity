import 'dart:math';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/colors.dart';
import '../theme/constants.dart';
import '../widgets/price_chart.dart';
import '../screens/add_screen.dart'; // 数値フォーマッター拡張の利用

class DetailScreen extends StatefulWidget {
  final Product product;
  final List<Product> allProducts;
  final VoidCallback onBack;
  final Function(List<Product> candidates) onMergeOpen;
  final VoidCallback onAddRecord;

  const DetailScreen({
    Key? key,
    required this.product,
    required this.allProducts,
    required this.onBack,
    required this.onMergeOpen,
    required this.onAddRecord,
  }) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String _storeFilter = 'all';
  bool _multiStore = false;
  late double _calcQty;

  @override
  void initState() {
    super.initState();
    _calcQty = widget.product.unitType == 'weight' ? 450.0 : 5.0;
  }

  @override
  Widget build(BuildContext context) {
    // 画面更新に対応するため、全商品リストから最新の商品情報を取得する
    final product = widget.allProducts.firstWhere(
      (p) => p.id == widget.product.id,
      orElse: () => widget.product,
    );
    final latest = product.latestRecord;

    // 過去記録のソート（日付降順）
    final recordsSorted = List<PriceRecord>.from(product.records)
      ..sort((a, b) => b.date.compareTo(a.date));

    // 使用されている店舗一覧（重複なし）
    final usedStores = product.records.map((r) => r.store).toSet().toList();

    // 統計計算
    int minPrice = 0;
    int maxPrice = 0;
    int avgPrice = 0;
    if (product.records.isNotEmpty) {
      final prices = product.records.map((r) => r.priceTax).toList();
      minPrice = prices.reduce(min);
      maxPrice = prices.reduce(max);
      avgPrice = (prices.reduce((a, b) => a + b) / prices.length).round();
    }

    // 単価計算（最新価格ベース）
    double baseUnit = 0.0;
    int calcPrice = 0;
    int perUnit = 0;
    if (latest != null && latest.qty > 0) {
      baseUnit = latest.priceTax / latest.qty;
      calcPrice = (baseUnit * _calcQty).round();
      perUnit = (baseUnit * (product.unitType == 'weight' ? 100.0 : 1.0)).round();
    }

    // 同名商品の統合提案チェック
    final sameNameOther = widget.allProducts
        .where((p) => p.id != product.id && p.name == product.name)
        .toList();

    final categoryInfo = appCategories.firstWhere(
      (c) => c.id == product.category,
      orElse: () => const CategoryInfo(id: 'other', label: 'その他', emoji: '📦'),
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                )
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.ink, size: 20),
              onPressed: widget.onBack,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  )
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.more_horiz, color: AppColors.ink2),
                onPressed: () {},
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 商品情報ヘッダー
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: Color(int.parse(product.color.replaceAll('0x', ''), radix: 16) | 0xFF000000),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          product.emoji,
                          style: const TextStyle(fontSize: 50),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${categoryInfo.emoji} ${categoryInfo.label}',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product.name,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                letterSpacing: -0.3,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product.detail,
                              style: const TextStyle(
                                color: AppColors.ink2,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 最新の価格サマリーカード
                  if (latest != null) ...[
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accentSoft, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.accentSoft),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '最新の記録',
                            style: TextStyle(
                              color: AppColors.ink2,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    latest.priceTax.toLocaleString(),
                                    style: const TextStyle(
                                      color: AppColors.accentDeep,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 1),
                                  const Text(
                                    '円',
                                    style: TextStyle(
                                      color: AppColors.accentDeep,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '（税抜 ${latest.price}円）',
                                    style: const TextStyle(
                                      color: AppColors.ink3,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: AppColors.getStoreColor(latest.store),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        latest.store,
                                        style: const TextStyle(
                                          color: AppColors.ink2,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatFullDate(latest.date),
                                    style: const TextStyle(
                                      color: AppColors.ink3,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 同名商品の統合提案バナー
                  if (sameNameOther.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => widget.onMergeOpen(sameNameOther),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.accent,
                            style: BorderStyle.solid,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.accentSoft,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.merge_type, color: AppColors.accent, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '同名商品が ${sameNameOther.length}件 あります',
                                    style: const TextStyle(
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  const Text(
                                    '同一商品として統合できます',
                                    style: TextStyle(
                                      color: AppColors.ink2,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.ink3, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 2. 単価計算セクション
            if (latest != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                      child: Text(
                        '単価計算',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink2,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 2, offset: const Offset(0, 1))
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // 基準単価表示
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.unitType == 'weight' ? '100gあたり' : '1個あたり',
                                    style: const TextStyle(color: AppColors.ink2, fontSize: 11),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    '${latest.priceTax}円 ÷ ${latest.qty.toStringAsFixed(0)}${product.unitType == 'weight' ? "g" : "個"} × ${product.unitType == 'weight' ? "100" : "1"}',
                                    style: const TextStyle(color: AppColors.ink3, fontSize: 13),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    perUnit.toLocaleString(),
                                    style: const TextStyle(
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 1),
                                  const Text(
                                    '円',
                                    style: TextStyle(
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.0),
                            child: Divider(color: AppColors.line, height: 1),
                          ),
                          // 任意の量換算
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                product.unitType == 'weight' ? '重さ換算' : '個数換算',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    calcPrice.toLocaleString(),
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 1),
                                  const Text(
                                    '円',
                                    style: TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: _calcQty,
                                  min: product.unitType == 'weight' ? 50.0 : 1.0,
                                  max: product.unitType == 'weight' ? 1000.0 : 30.0,
                                  divisions: product.unitType == 'weight' ? 95 : 29,
                                  activeColor: AppColors.accent,
                                  inactiveColor: AppColors.line,
                                  onChanged: (val) {
                                    setState(() {
                                      _calcQty = val;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.accentSoft,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(minWidth: 70),
                                child: Text(
                                  '${_calcQty.toStringAsFixed(0)}${product.unitType == 'weight' ? "g" : "個"}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.accentDeep,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Noto Sans JP',
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 3. 価格推移グラフ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4.0),
                        child: Text(
                          '価格推移',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink2,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _multiStore = !_multiStore;
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: _multiStore ? AppColors.accentSoft : Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          '店舗ごとに色分け ${_multiStore ? "ON" : "OFF"}',
                          style: TextStyle(
                            color: _multiStore ? AppColors.accentDeep : AppColors.ink2,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 2, offset: const Offset(0, 1))
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 店舗フィルターチップ（multiStore OFFかつ店舗が複数ある場合）
                        if (!_multiStore && usedStores.length > 1) ...[
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('all', 'すべて'),
                                const SizedBox(width: 6),
                                ...usedStores.map((s) => Row(
                                      children: [
                                        _buildFilterChip(s, s, isStore: true),
                                        const SizedBox(width: 6),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // グラフコンポーネント
                        PriceChart(
                          records: product.records,
                          storeFilter: _multiStore ? 'all' : _storeFilter,
                          multiStore: _multiStore,
                        ),

                        // 凡例表示（multiStore ONの場合）
                        if (_multiStore) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            runSpacing: 4,
                            children: usedStores
                                .map((s) => Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 2,
                                          decoration: BoxDecoration(
                                            color: AppColors.getStoreColor(s),
                                            borderRadius: BorderRadius.circular(1),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          s,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.ink2,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ))
                                .toList(),
                          ),
                        ],

                        const SizedBox(height: 14),
                        const Divider(color: AppColors.line, height: 1),
                        const SizedBox(height: 14),

                        // 統計値（最安・平均・最高）
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('最安', minPrice, const Color(0xFF00A86B)),
                            _buildStatItem('平均', avgPrice, AppColors.ink),
                            _buildStatItem('最高', maxPrice, AppColors.accent),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 4. 過去の記録
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          '過去の記録 （${recordsSorted.length}件）',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink2, letterSpacing: 0.3),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: widget.onAddRecord,
                        icon: const Icon(Icons.add, size: 14, color: AppColors.accent),
                        label: const Text('記録を追加', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent)),
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 2, offset: const Offset(0, 1))
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recordsSorted.length,
                      separatorBuilder: (context, index) => const Divider(color: AppColors.line, height: 1),
                      itemBuilder: (context, index) {
                        final r = recordsSorted[index];
                        final unit = r.calculateUnitPrice(product.unitType);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            children: [
                              // 月日表示バッジ
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.accentSoft,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${r.date.split("-")[1]}月',
                                      style: const TextStyle(
                                        color: AppColors.accentDeep,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        height: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      int.parse(r.date.split("-")[2]).toString(),
                                      style: const TextStyle(
                                        color: AppColors.accentDeep,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        height: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // 店舗と単価計算
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: AppColors.getStoreColor(r.store),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          r.store,
                                          style: const TextStyle(
                                            color: AppColors.ink,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      product.unitType == 'weight' ? '100gあたり $unit円' : '1個あたり $unit円',
                                      style: const TextStyle(
                                        color: AppColors.ink3,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 価格表示
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        r.priceTax.toLocaleString(),
                                        style: const TextStyle(
                                          color: AppColors.ink,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 1),
                                      const Text(
                                        '円',
                                        style: TextStyle(
                                          color: AppColors.ink,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    '税抜 ${r.price}円',
                                    style: const TextStyle(
                                      color: AppColors.ink3,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, {bool isStore = false}) {
    final active = _storeFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _storeFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.chipBgActive : AppColors.chipBg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isStore) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.getStoreColor(value),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : AppColors.ink2,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: 'Noto Sans JP',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.ink3, fontSize: 10, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value.toLocaleString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 1),
            Text(
              '円',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatFullDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length >= 3) {
        return '${parts[0]}年${int.parse(parts[1])}月${int.parse(parts[2])}日';
      }
    } catch (_) {}
    return dateStr;
  }
}
