import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../theme/colors.dart';
import '../theme/constants.dart';
import '../widgets/product_thumb.dart';

class AddScreen extends StatefulWidget {
  final Product? existingProduct;
  final Function(Map<String, dynamic> data) onSave;
  final VoidCallback onCancel;

  const AddScreen({
    Key? key,
    this.existingProduct,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  // 基本情報（新規のみ）
  final _nameController = TextEditingController();
  final _detailController = TextEditingController();
  String _category = 'food';
  String _unitType = 'count';
  String _emoji = '🥚';
  String _color = '0xFFFFF4D4';
  String _imageMode = 'emoji'; // emoji, photo (for mock visualization)

  // 購入情報（新規・既存共通）
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();
  final _priceTaxController = TextEditingController();
  String _store = 'カスミ';
  DateTime _date = DateTime.now();

  final List<String> _emojiChoices = [
    '🥚', '🦐', '🥤', '🍗', '🍜', '🥬', '🥛', '🥔', '🧻', '🍱',
    '🍎', '🥕', '🧀', '🍞', '🥫', '🍚', '🍅', '🥦', '🍌', '🥩',
    '🧴', '🧼', '🪥', '🍪'
  ];

  final List<String> _colorChoices = [
    '0xFFFFF4D4', '0xFFFFE4D6', '0xFFFFF4C8', '0xFFFEDECB', '0xFFFFF0D9',
    '0xFFE6F5DE', '0xFFF3F6E3', '0xFFFFF4DC', '0xFFF7F2EA', '0xFFE0F2FE',
    '0xFFF3E8FF'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingProduct != null) {
      final p = widget.existingProduct!;
      _nameController.text = p.name;
      _detailController.text = p.detail;
      _category = p.category;
      _unitType = p.unitType;
      _emoji = p.emoji;
      _color = p.color;
      _qtyController.text = p.unitBase.toStringAsFixed(0).replaceAll(RegExp(r'\.0$'), '');
    } else {
      _qtyController.text = '1';
    }

    // 税抜価格のリスナーを設定して、税込価格を自動計算する（8%食品税）
    _priceController.addListener(_onPriceChanged);
  }

  @override
  void dispose() {
    _priceController.removeListener(_onPriceChanged);
    _nameController.dispose();
    _detailController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _priceTaxController.dispose();
    super.dispose();
  }

  void _onPriceChanged() {
    final priceText = _priceController.text;
    if (priceText.isNotEmpty) {
      final priceVal = double.tryParse(priceText);
      if (priceVal != null) {
        // 食品等軽減税率の8%を想定
        final taxIncluded = (priceVal * 1.08).round();
        // ユーザー入力の邪魔をしないように、現在税込価格が空か、自動計算された値と同じ場合のみ更新
        _priceTaxController.text = taxIncluded.toString();
      }
    } else {
      _priceTaxController.clear();
    }
  }

  bool get _canSave {
    final nameValid = widget.existingProduct != null || _nameController.text.trim().isNotEmpty;
    final qtyValid = double.tryParse(_qtyController.text) != null && double.parse(_qtyController.text) > 0;
    final priceValid = int.tryParse(_priceController.text) != null;
    final priceTaxValid = int.tryParse(_priceTaxController.text) != null;
    return nameValid && qtyValid && priceValid && priceTaxValid;
  }

  void _handleSave() {
    if (!_canSave) return;

    final name = widget.existingProduct?.name ?? _nameController.text.trim();
    final detail = widget.existingProduct?.detail ?? _detailController.text.trim();
    final category = widget.existingProduct?.category ?? _category;
    final emoji = widget.existingProduct?.emoji ?? _emoji;
    final color = widget.existingProduct?.color ?? _color;
    final unitType = widget.existingProduct?.unitType ?? _unitType;
    final unitBase = double.parse(_qtyController.text);

    final record = {
      'id': 'r${DateTime.now().millisecondsSinceEpoch}',
      'date': DateFormat('yyyy-MM-dd').format(_date),
      'store': _store,
      'price': int.parse(_priceController.text),
      'priceTax': int.parse(_priceTaxController.text),
      'qty': double.parse(_qtyController.text),
    };

    widget.onSave({
      'name': name,
      'detail': detail,
      'category': category,
      'emoji': emoji,
      'color': color,
      'unitType': unitType,
      'unitBase': unitBase,
      'record': record,
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('ja', 'JP'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accent,
              onPrimary: Colors.white,
              onSurface: AppColors.ink,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.existingProduct == null;

    // 単価の計算プレビュー
    int? unitPricePreview;
    final qtyVal = double.tryParse(_qtyController.text);
    final priceTaxVal = int.tryParse(_priceTaxController.text);
    if (qtyVal != null && qtyVal > 0 && priceTaxVal != null) {
      if (_unitType == 'weight') {
        unitPricePreview = (priceTaxVal / qtyVal * 100).round();
      } else {
        unitPricePreview = (priceTaxVal / qtyVal).round();
      }
    }

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
        title: Text(
          isNew ? '新しい商品' : '記録を追加',
          style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 10.0, bottom: 10.0),
            child: ElevatedButton(
              onPressed: _canSave ? _handleSave : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                disabledBackgroundColor: AppColors.line,
                foregroundColor: Colors.white,
                disabledForegroundColor: AppColors.ink3,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text(
                '保存',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品画像プレビュー（新規のみ）
            if (isNew) ...[
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: _imageMode == 'photo'
                        ? const Color(0xFFECE4D8)
                        : Color(int.parse(_color.replaceAll('0x', ''), radix: 16) | 0xFF000000),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  alignment: Alignment.center,
                  child: _imageMode == 'photo'
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.camera_alt_outlined, size: 30, color: AppColors.ink3),
                            SizedBox(height: 4),
                            Text('写真を追加', style: TextStyle(fontSize: 10, color: AppColors.ink3, fontWeight: FontWeight.w600))
                          ],
                        )
                      : Text(
                          _emoji,
                          style: const TextStyle(fontSize: 60),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              // 画像モード切り替え
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildImageModeButton('emoji', '絵文字', Icons.emoji_emotions_outlined),
                  const SizedBox(width: 8),
                  _buildImageModeButton('icon', 'アイコン', Icons.image_outlined),
                  const SizedBox(width: 8),
                  _buildImageModeButton('photo', '写真', Icons.camera_alt_outlined),
                ],
              ),
              const SizedBox(height: 16),

              // 絵文字ピッカー
              if (_imageMode == 'emoji') ...[
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 2, offset: const Offset(0, 1))
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: _emojiChoices.length,
                    itemBuilder: (context, index) {
                      final item = _emojiChoices[index];
                      final isSelected = _emoji == item;
                      return GestureDetector(
                        onTap: () => setState(() => _emoji = item),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.accentSoft : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(item, style: const TextStyle(fontSize: 20)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // カラーピッカー
                SizedBox(
                  height: 30,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _colorChoices.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final item = _colorChoices[index];
                      final isSelected = _color == item;
                      final colorVal = int.parse(item.replaceAll('0x', ''), radix: 16);
                      return GestureDetector(
                        onTap: () => setState(() => _color = item),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Color(colorVal | 0xFF000000),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: AppColors.ink, width: 2, strokeAlign: BorderSide.strokeAlignOutside)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],

            // 既存商品の表示ヘッダー（既存のみ）
            if (widget.existingProduct != null) ...[
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 2, offset: const Offset(0, 1))
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ProductThumb(product: widget.existingProduct!, size: 56),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.existingProduct!.name,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.existingProduct!.detail,
                            style: const TextStyle(
                              color: AppColors.ink2,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 商品情報セクション（新規のみ）
            if (isNew) ...[
              _buildSectionTitle('商品情報'),
              _buildCard([
                _buildTextField('商品名', '例: たまご', _nameController, required: true),
                const Divider(color: AppColors.line, height: 1),
                _buildTextField('詳細（容量など）', '例: 10個入り / 170g', _detailController),
                const Divider(color: AppColors.line, height: 1),
                _buildCategorySelector(),
                const Divider(color: AppColors.line, height: 1),
                _buildUnitTypeSelector(),
              ]),
              const SizedBox(height: 20),
            ],

            // 購入情報セクション
            _buildSectionTitle('購入情報'),
            _buildCard([
              _buildQtyField(),
              const Divider(color: AppColors.line, height: 1),
              _buildPriceField('価格（税抜）', _priceController, required: true),
              const Divider(color: AppColors.line, height: 1),
              _buildPriceField('価格（税込）', _priceTaxController, required: true, highlight: true),
              const Divider(color: AppColors.line, height: 1),
              _buildStoreSelector(),
              const Divider(color: AppColors.line, height: 1),
              _buildDateField(),
            ]),
            const SizedBox(height: 16),

            // 単価プレビュー
            if (unitPricePreview != null) ...[
              Container(
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text('¥', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _unitType == 'weight' ? '100gあたり' : '1個あたり',
                            style: const TextStyle(
                              color: AppColors.ink2,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                unitPricePreview.toLocaleString(),
                                style: const TextStyle(
                                  color: AppColors.accentDeep,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Text(
                                '円',
                                style: TextStyle(
                                  color: AppColors.accentDeep,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildImageModeButton(String mode, String label, IconData icon) {
    final isSelected = _imageMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _imageMode = mode),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.ink : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 2, offset: const Offset(0, 1))
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 13, color: isSelected ? Colors.white : AppColors.ink2),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.ink2,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.ink2,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildTextField(String label, String placeholder, TextEditingController controller, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel(label, required: required),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(color: AppColors.ink3, fontSize: 14),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
              border: InputBorder.none,
            ),
            style: const TextStyle(color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.w500),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool required = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.ink2,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          )
        ]
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('カテゴリ'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: appCategories
                .where((c) => c.id != 'all')
                .map((c) => GestureDetector(
                      onTap: () => setState(() => _category = c.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                        decoration: BoxDecoration(
                          color: _category == c.id ? AppColors.chipBgActive : AppColors.chipBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(c.emoji, style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 4),
                            Text(
                              c.label,
                              style: TextStyle(
                                color: _category == c.id ? Colors.white : AppColors.ink,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('単位'),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildUnitButton('count', '個数', '🔢'),
              const SizedBox(width: 8),
              _buildUnitButton('weight', '重さ(g)', '⚖️'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitButton(String type, String label, String icon) {
    final isSelected = _unitType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _unitType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.ink : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? null : Border.all(color: AppColors.line),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.ink2,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQtyField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel(_unitType == 'weight' ? '重さ' : '数量', required: true),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _qtyController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: AppColors.ink3, fontSize: 14),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.w500),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.chipBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _unitType == 'weight' ? 'g' : '個',
                  style: const TextStyle(color: AppColors.ink2, fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceField(String label, TextEditingController controller, {bool required = false, bool highlight = false}) {
    return Container(
      color: highlight ? const Color(0xFFFFF8F4) : null,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel(label, required: required),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text('¥', style: TextStyle(color: AppColors.ink3, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: AppColors.ink3, fontSize: 18),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 4.0),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: AppColors.ink, fontSize: 18, fontWeight: FontWeight.w700),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const Text('円', style: TextStyle(color: AppColors.ink3, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('店舗', required: true),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: appStores
                .map((s) => GestureDetector(
                      onTap: () => setState(() => _store = s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _store == s ? AppColors.ink : AppColors.card,
                          borderRadius: BorderRadius.circular(999),
                          border: _store == s ? null : Border.all(color: AppColors.line),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.getStoreColor(s),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              s,
                              style: TextStyle(
                                color: _store == s ? Colors.white : AppColors.ink2,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.ink3),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                DateFormat('yyyy年M月d日').format(_date),
                style: const TextStyle(color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.ink3),
          ],
        ),
      ),
    );
  }
}

// 便利な数値拡張フォーマッター
extension NumberFormatExtension on int {
  String toLocaleString() {
    final formatter = NumberFormat('#,###');
    return formatter.format(this);
  }
}
