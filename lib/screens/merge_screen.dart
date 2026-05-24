import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/colors.dart';
import '../widgets/product_thumb.dart';
import '../screens/add_screen.dart'; // 数値フォーマッター拡張の利用

class MergeScreen extends StatefulWidget {
  final Product product;
  final List<Product> candidates;
  final VoidCallback onCancel;
  final Function(List<String> selectedIds) onMerge;

  const MergeScreen({
    Key? key,
    required this.product,
    required this.candidates,
    required this.onCancel,
    required this.onMerge,
  }) : super(key: key);

  @override
  State<MergeScreen> createState() => _MergeScreenState();
}

class _MergeScreenState extends State<MergeScreen> {
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    // 初期選択：現在の製品およびすべての統合候補
    _selectedIds = {widget.product.id, ...widget.candidates.map((c) => c.id)};
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = [widget.product, ...widget.candidates];
    final selectedProducts = allProducts.where((p) => _selectedIds.contains(p.id)).toList();
    final totalRecords = selectedProducts.fold<int>(0, (sum, p) => sum + p.records.length);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: TextButton(
          onPressed: widget.onCancel,
          child: const Text(
            'キャンセル',
            style: TextStyle(
              color: AppColors.ink2,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        leadingWidth: 90,
        title: const Text(
          '商品を統合',
          style: TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 120.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. バナー・説明
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accentSoft, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.merge_type, color: AppColors.accent, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '「${widget.product.name}」を統合',
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '同名で登録された別の記録を1つの商品としてまとめられます。\n重さ・個数の違う記録もまとめて価格推移を比較できます。',
                        style: TextStyle(
                          color: AppColors.ink2,
                          fontSize: 12,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. 選択リスト
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Text(
                    '統合する商品を選択（${_selectedIds.size}件）',
                    style: const TextStyle(
                      fontSize: 11,
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
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allProducts.length,
                    separatorBuilder: (context, index) => const Divider(color: AppColors.line, height: 1),
                    itemBuilder: (context, index) {
                      final p = allProducts[index];
                      final isSelected = _selectedIds.contains(p.id);
                      final latest = p.latestRecord;

                      return InkWell(
                        onTap: () => _toggleSelection(p.id),
                        child: Container(
                          color: isSelected ? const Color(0xFFFFFBF8) : Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                          child: Row(
                            children: [
                              // チェックマーク
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.accent : Colors.white,
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                    color: isSelected ? AppColors.accent : AppColors.line,
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: isSelected
                                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              // サムネイル
                              ProductThumb(product: p, size: 44),
                              const SizedBox(width: 12),
                              // 製品情報
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: const TextStyle(
                                        color: AppColors.ink,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${p.detail} · ${p.records.length}件の記録',
                                      style: const TextStyle(
                                        color: AppColors.ink2,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 最新価格
                              if (latest != null)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      latest.priceTax.toLocaleString(),
                                      style: const TextStyle(
                                        color: AppColors.ink,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 1),
                                    const Text(
                                      '円',
                                      style: TextStyle(
                                        color: AppColors.ink,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // 3. 統合後プレビュー
                const Padding(
                  padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Text(
                    '統合後のプレビュー',
                    style: TextStyle(
                      fontSize: 11,
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
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ProductThumb(product: widget.product, size: 48),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.product.name,
                                  style: const TextStyle(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$totalRecords件の記録に統合されます',
                                  style: const TextStyle(
                                    color: AppColors.ink2,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.chipBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.lightbulb_outline, size: 14, color: AppColors.ink),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '重さや個数が異なる記録は、100gあたり / 1個あたりの単価で比較できるようになります',
                                style: TextStyle(
                                  color: AppColors.ink2,
                                  fontSize: 10,
                                  height: 1.5,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. 固定実行ボタン
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 30.0, top: 16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.bg.withOpacity(0.0), AppColors.bg],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.3],
                ),
              ),
              child: ElevatedButton(
                onPressed: _selectedIds.length >= 2
                    ? () => widget.onMerge(_selectedIds.toList())
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  disabledBackgroundColor: AppColors.line,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: AppColors.ink3,
                  elevation: 0,
                  shadowColor: AppColors.accent.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  '${_selectedIds.length}件の商品を統合',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Noto Sans JP'),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
extension SetSizeExtension<T> on Set<T> {
  int get size => length;
}
