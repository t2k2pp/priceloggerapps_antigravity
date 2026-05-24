import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/colors.dart';
import '../theme/constants.dart';
import '../widgets/product_thumb.dart';
import 'add_screen.dart'; // 数値フォーマッターの利用

class HomeScreen extends StatefulWidget {
  final List<Product> products;
  final VoidCallback onAdd;
  final Function(String productId) onOpen;

  const HomeScreen({
    Key? key,
    required this.products,
    required this.onAdd,
    required this.onOpen,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _selectedStore = 'all';
  String _sortBy = 'recent'; // recent, price, name
  String _layoutMode = 'list'; // list, grid

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. フィルタリング
    List<Product> filtered = widget.products;

    // カテゴリフィルタ
    if (_selectedCategory != 'all') {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }

    // 店舗フィルタ
    if (_selectedStore != 'all') {
      filtered = filtered.where((p) => p.records.any((r) => r.store == _selectedStore)).toList();
    }

    // 検索クエリフィルタ
    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      filtered = filtered
          .where((p) => p.name.toLowerCase().contains(q) || p.detail.toLowerCase().contains(q))
          .toList();
    }

    // 2. ソート
    filtered = List<Product>.from(filtered)..sort((a, b) {
      if (_sortBy == 'name') {
        return a.name.compareTo(b.name);
      } else if (_sortBy == 'price') {
        final pa = a.latestRecord?.priceTax ?? 0;
        final pb = b.latestRecord?.priceTax ?? 0;
        return pa.compareTo(pb);
      } else {
        // recent
        final da = a.latestRecord?.date ?? '';
        final db = b.latestRecord?.date ?? '';
        // 日付の新しい順 (降順)
        return db.compareTo(da);
      }
    });

    final totalRecordsCount = widget.products.fold<int>(0, (sum, p) => sum + p.records.length);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダーエリア
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'マイ買い物帳',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                              letterSpacing: -0.5,
                              fontFamily: 'Noto Sans JP',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.products.length}件の商品 · $totalRecordsCount件の記録',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.ink2,
                            ),
                          ),
                        ],
                      ),
                      // レイアウト切り替えボタン
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            )
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _layoutMode = _layoutMode == 'list' ? 'grid' : 'list';
                            });
                          },
                          icon: Icon(
                            _layoutMode == 'list' ? Icons.grid_view : Icons.view_list,
                            color: AppColors.ink2,
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 検索窓
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.ink3, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: '商品名で検索',
                              hintStyle: TextStyle(color: AppColors.ink3, fontSize: 15),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            style: const TextStyle(color: AppColors.ink, fontSize: 15, fontFamily: 'Noto Sans JP'),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.line,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 12, color: AppColors.ink2),
                            ),
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // カテゴリフィルターチップ（水平スクロール）
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: appCategories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = appCategories[index];
                  final isSelected = _selectedCategory == cat.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat.id;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.chipBgActive : AppColors.chipBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat.emoji, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            cat.label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Noto Sans JP',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // 店舗選択 + 並べ替え
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // 店舗選択
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 2, offset: const Offset(0, 1))
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedStore,
                          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.ink2, size: 16),
                          style: const TextStyle(color: AppColors.ink, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Noto Sans JP'),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedStore = newValue;
                              });
                            }
                          },
                          items: [
                            const DropdownMenuItem(
                              value: 'all',
                              child: Text('🏪 すべての店舗'),
                            ),
                            ...appStores.map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s),
                                ))
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ソート
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 2, offset: const Offset(0, 1))
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sortBy,
                          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.ink2, size: 16),
                          style: const TextStyle(color: AppColors.ink, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Noto Sans JP'),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                _sortBy = newValue;
                              });
                            }
                          },
                          items: const [
                            DropdownMenuItem(value: 'recent', child: Text('最近')),
                            DropdownMenuItem(value: 'price', child: Text('価格順')),
                            DropdownMenuItem(value: 'name', child: Text('名前順')),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),

            // メインコンテンツエリア（商品一覧）
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('🔍', style: TextStyle(fontSize: 40)),
                            SizedBox(height: 12),
                            Text(
                              '該当する商品がありません',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink2),
                            )
                          ],
                        ),
                      ),
                    )
                  : _layoutMode == 'list'
                      ? _buildListView(filtered)
                      : _buildGridView(filtered),
            ),
          ],
        ),
      ),
      // FABボタン
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onAdd,
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildListView(List<Product> products) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 80.0),
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final p = products[index];
        final latest = p.latestRecord;

        // 前回の記録と比較して価格の増減を計算
        bool priceUp = false;
        bool priceDown = false;
        if (p.records.length > 1) {
          final sortedRecords = List<PriceRecord>.from(p.records)
            ..sort((a, b) => b.date.compareTo(a.date));
          final prevPrice = sortedRecords[1].priceTax;
          if (latest != null) {
            priceUp = latest.priceTax > prevPrice;
            priceDown = latest.priceTax < prevPrice;
          }
        }

        return InkWell(
          onTap: () => widget.onOpen(p.id),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 2, offset: const Offset(0, 1))
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ProductThumb(product: p, size: 54),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          fontFamily: 'Noto Sans JP',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              p.detail,
                              style: const TextStyle(color: AppColors.ink2, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (latest != null) ...[
                            const SizedBox(width: 6),
                            Container(width: 2, height: 2, decoration: const BoxDecoration(color: AppColors.ink3, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.getStoreColor(latest.store),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(latest.store, style: const TextStyle(color: AppColors.ink2, fontSize: 12)),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (latest != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            latest.priceTax.toLocaleString(),
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(width: 1),
                          const Text(
                            '円',
                            style: TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (priceUp)
                            const Icon(Icons.arrow_upward, size: 10, color: AppColors.accent),
                          if (priceDown)
                            const Icon(Icons.arrow_downward, size: 10, color: Color(0xFF00A86B)),
                          const SizedBox(width: 2),
                          Text(
                            _formatDate(latest.date),
                            style: const TextStyle(color: AppColors.ink3, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 80.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        final latest = p.latestRecord;
        int? unitPriceVal;
        if (latest != null) {
          unitPriceVal = latest.calculateUnitPrice(p.unitType);
        }

        Color thumbColor;
        try {
          final colorStr = p.color.replaceAll('0x', '').replaceAll('#', '');
          thumbColor = Color(int.parse(colorStr, radix: 16) | 0xFF000000);
        } catch (_) {
          thumbColor = const Color(0xFFF3ECE2);
        }

        return InkWell(
          onTap: () => widget.onOpen(p.id),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 2, offset: const Offset(0, 1))
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 画像エリアと店舗バッジ
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: thumbColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            p.emoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                        if (latest != null)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: AppColors.getStoreColor(latest.store),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    latest.store,
                                    style: const TextStyle(
                                      color: AppColors.ink2,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Noto Sans JP',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // 商品名
                Text(
                  p.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    fontFamily: 'Noto Sans JP',
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                // 詳細
                Text(
                  p.detail,
                  style: const TextStyle(color: AppColors.ink3, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // 価格と単価
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
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
                              fontSize: 16,
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
                    if (unitPriceVal != null)
                      Text(
                        p.unitType == 'weight' ? '$unitPriceVal円/100g' : '$unitPriceVal円/個',
                        style: const TextStyle(color: AppColors.ink3, fontSize: 10),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
}
