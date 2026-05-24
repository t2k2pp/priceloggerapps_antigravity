class PriceRecord {
  final String id;
  final String date; // YYYY-MM-DD
  final String store;
  final int price; // 税抜価格
  final int priceTax; // 税込価格
  final double qty; // 数量（個数またはグラム）

  PriceRecord({
    required this.id,
    required this.date,
    required this.store,
    required this.price,
    required this.priceTax,
    required this.qty,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'store': store,
        'price': price,
        'priceTax': priceTax,
        'qty': qty,
      };

  factory PriceRecord.fromJson(Map<String, dynamic> json) => PriceRecord(
        id: json['id'] as String,
        date: json['date'] as String,
        store: json['store'] as String,
        price: (json['price'] as num).toInt(),
        priceTax: (json['priceTax'] as num).toInt(),
        qty: (json['qty'] as num).toDouble(),
      );

  // 最新の購入価格と単位情報から単価（100gあたり or 1個あたり）を計算する
  int calculateUnitPrice(String unitType) {
    if (qty == 0) return 0;
    if (unitType == 'weight') {
      return (priceTax / qty * 100).round(); // 100gあたり
    } else {
      return (priceTax / qty).round(); // 1個あたり
    }
  }
}

class Product {
  final String id;
  final String name;
  final String detail;
  final String category;
  final String emoji;
  final String color; // 例: "0xFF..." の16進数文字列
  final String unitType; // 'count' または 'weight'
  final double unitBase; // 単位基準値 (例: 10個、170gなど)
  final List<PriceRecord> records;

  Product({
    required this.id,
    required this.name,
    required this.detail,
    required this.category,
    required this.emoji,
    required this.color,
    required this.unitType,
    required this.unitBase,
    required this.records,
  });

  PriceRecord? get latestRecord {
    if (records.isEmpty) return null;
    // 日付の降順（新しい順）でソート
    final sorted = List<PriceRecord>.from(records)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.first;
  }

  Product copyWith({
    String? id,
    String? name,
    String? detail,
    String? category,
    String? emoji,
    String? color,
    String? unitType,
    double? unitBase,
    List<PriceRecord>? records,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      detail: detail ?? this.detail,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      unitType: unitType ?? this.unitType,
      unitBase: unitBase ?? this.unitBase,
      records: records ?? this.records,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'detail': detail,
        'category': category,
        'emoji': emoji,
        'color': color,
        'unitType': unitType,
        'unitBase': unitBase,
        'records': records.map((r) => r.toJson()).toList(),
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    final recordsJson = json['records'] as List;
    final recordsList = recordsJson
        .map((r) => PriceRecord.fromJson(r as Map<String, dynamic>))
        .toList();
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      detail: json['detail'] as String,
      category: json['category'] as String,
      emoji: json['emoji'] as String,
      color: json['color'] as String,
      unitType: json['unitType'] as String,
      unitBase: (json['unitBase'] as num).toDouble(),
      records: recordsList,
    );
  }
}
