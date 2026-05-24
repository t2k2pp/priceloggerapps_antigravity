import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class StorageService {
  static const String _keyProducts = 'price_logger_products';

  // 保存されている商品をロード（無ければ初期サンプルデータを返す）
  Future<List<Product>> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getString(_keyProducts);

    if (productsJson == null) {
      final initialList = _getInitialProducts();
      await saveProducts(initialList);
      return initialList;
    }

    try {
      final List<dynamic> decoded = jsonDecode(productsJson);
      return decoded
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // エラー発生時は安全策として初期データを返す
      return _getInitialProducts();
    }
  }

  // 商品リストをローカルに保存する
  Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(products.map((p) => p.toJson()).toList());
    await prefs.setString(_keyProducts, encoded);
  }

  // モックに同梱されているサンプル商品データ
  List<Product> _getInitialProducts() {
    return [
      Product(
        id: 'p1',
        name: 'たまご',
        detail: '10個入り',
        category: 'food',
        emoji: '🥚',
        color: '0xFFFFF4D4',
        unitType: 'count',
        unitBase: 10.0,
        records: [
          PriceRecord(
              id: 'r1',
              date: '2026-04-15',
              store: 'カスミ',
              price: 198,
              priceTax: 214,
              qty: 10.0),
          PriceRecord(
              id: 'r2',
              date: '2026-04-02',
              store: 'カスミ',
              price: 208,
              priceTax: 224,
              qty: 10.0),
          PriceRecord(
              id: 'r3',
              date: '2026-03-18',
              store: 'ヨークベニマル',
              price: 228,
              priceTax: 246,
              qty: 10.0),
          PriceRecord(
              id: 'r4',
              date: '2026-03-05',
              store: 'カスミ',
              price: 218,
              priceTax: 235,
              qty: 10.0),
          PriceRecord(
              id: 'r5',
              date: '2026-02-20',
              store: 'マルエツ',
              price: 248,
              priceTax: 267,
              qty: 10.0),
          PriceRecord(
              id: 'r6',
              date: '2026-02-08',
              store: 'カスミ',
              price: 188,
              priceTax: 203,
              qty: 10.0),
        ],
      ),
      Product(
        id: 'p2',
        name: '大粒むきえび',
        detail: '170g',
        category: 'meat',
        emoji: '🦐',
        color: '0xFFFFE4D6',
        unitType: 'weight',
        unitBase: 170.0,
        records: [
          PriceRecord(
              id: 'r10',
              date: '2026-04-12',
              store: 'カスミ',
              price: 395,
              priceTax: 427,
              qty: 170.0),
          PriceRecord(
              id: 'r11',
              date: '2026-03-20',
              store: 'カスミ',
              price: 398,
              priceTax: 430,
              qty: 170.0),
          PriceRecord(
              id: 'r12',
              date: '2026-02-28',
              store: 'ヨークベニマル',
              price: 448,
              priceTax: 484,
              qty: 170.0),
          PriceRecord(
              id: 'r13',
              date: '2026-02-10',
              store: 'カスミ',
              price: 378,
              priceTax: 408,
              qty: 170.0),
        ],
      ),
      Product(
        id: 'p3',
        name: 'オロナミンC',
        detail: '10本入り',
        category: 'drink',
        emoji: '🥤',
        color: '0xFFFFF4C8',
        unitType: 'count',
        unitBase: 10.0,
        records: [
          PriceRecord(
              id: 'r20',
              date: '2026-04-10',
              store: 'ウェルシア',
              price: 748,
              priceTax: 808,
              qty: 10.0),
          PriceRecord(
              id: 'r21',
              date: '2026-03-15',
              store: 'ウェルシア',
              price: 768,
              priceTax: 829,
              qty: 10.0),
          PriceRecord(
              id: 'r22',
              date: '2026-02-28',
              store: 'セブンイレブン',
              price: 880,
              priceTax: 950,
              qty: 10.0),
          PriceRecord(
              id: 'r23',
              date: '2026-02-14',
              store: 'ウェルシア',
              price: 738,
              priceTax: 797,
              qty: 10.0),
          PriceRecord(
              id: 'r24',
              date: '2026-01-20',
              store: 'ウェルシア',
              price: 758,
              priceTax: 819,
              qty: 10.0),
        ],
      ),
      Product(
        id: 'p4',
        name: '国産鶏もも肉',
        detail: '300g',
        category: 'meat',
        emoji: '🍗',
        color: '0xFFFEDECB',
        unitType: 'weight',
        unitBase: 300.0,
        records: [
          PriceRecord(
              id: 'r30',
              date: '2026-04-14',
              store: 'ヨークベニマル',
              price: 387,
              priceTax: 418,
              qty: 300.0),
          PriceRecord(
              id: 'r31',
              date: '2026-04-03',
              store: 'カスミ',
              price: 420,
              priceTax: 454,
              qty: 300.0),
          PriceRecord(
              id: 'r32',
              date: '2026-03-22',
              store: 'ヨークベニマル',
              price: 378,
              priceTax: 408,
              qty: 300.0),
          PriceRecord(
              id: 'r33',
              date: '2026-03-08',
              store: 'マルエツ',
              price: 410,
              priceTax: 443,
              qty: 300.0),
        ],
      ),
      Product(
        id: 'p5',
        name: '国産鶏もも肉',
        detail: '400g',
        category: 'meat',
        emoji: '🍗',
        color: '0xFFFEDECB',
        unitType: 'weight',
        unitBase: 400.0,
        records: [
          PriceRecord(
              id: 'r40',
              date: '2026-04-11',
              store: 'カスミ',
              price: 528,
              priceTax: 570,
              qty: 400.0),
          PriceRecord(
              id: 'r41',
              date: '2026-03-25',
              store: 'ヨークベニマル',
              price: 498,
              priceTax: 538,
              qty: 400.0),
          PriceRecord(
              id: 'r42',
              date: '2026-02-18',
              store: 'カスミ',
              price: 548,
              priceTax: 592,
              qty: 400.0),
        ],
      ),
      Product(
        id: 'p6',
        name: 'どん兵衛 きつねうどん',
        detail: '1食',
        category: 'food',
        emoji: '🍜',
        color: '0xFFFFF0D9',
        unitType: 'count',
        unitBase: 1.0,
        records: [
          PriceRecord(
              id: 'r50',
              date: '2026-04-16',
              store: 'セブンイレブン',
              price: 158,
              priceTax: 171,
              qty: 1.0),
          PriceRecord(
              id: 'r51',
              date: '2026-04-01',
              store: 'ウェルシア',
              price: 138,
              priceTax: 149,
              qty: 1.0),
          PriceRecord(
              id: 'r52',
              date: '2026-03-12',
              store: 'カスミ',
              price: 128,
              priceTax: 138,
              qty: 1.0),
          PriceRecord(
              id: 'r53',
              date: '2026-02-26',
              store: 'セブンイレブン',
              price: 158,
              priceTax: 171,
              qty: 1.0),
          PriceRecord(
              id: 'r54',
              date: '2026-02-05',
              store: 'マルエツ',
              price: 148,
              priceTax: 160,
              qty: 1.0),
        ],
      ),
      Product(
        id: 'p7',
        name: 'キャベツ',
        detail: '1玉',
        category: 'veg',
        emoji: '🥬',
        color: '0xFFE6F5DE',
        unitType: 'count',
        unitBase: 1.0,
        records: [
          PriceRecord(
              id: 'r60',
              date: '2026-04-13',
              store: 'ヨークベニマル',
              price: 198,
              priceTax: 214,
              qty: 1.0),
          PriceRecord(
              id: 'r61',
              date: '2026-04-02',
              store: 'カスミ',
              price: 238,
              priceTax: 257,
              qty: 1.0),
          PriceRecord(
              id: 'r62',
              date: '2026-03-19',
              store: 'マルエツ',
              price: 168,
              priceTax: 181,
              qty: 1.0),
        ],
      ),
      Product(
        id: 'p8',
        name: '明治ブルガリアヨーグルト',
        detail: '400g',
        category: 'food',
        emoji: '🥛',
        color: '0xFFF3F6E3',
        unitType: 'weight',
        unitBase: 400.0,
        records: [
          PriceRecord(
              id: 'r70',
              date: '2026-04-09',
              store: 'カスミ',
              price: 178,
              priceTax: 192,
              qty: 400.0),
          PriceRecord(
              id: 'r71',
              date: '2026-03-28',
              store: 'ウェルシア',
              price: 168,
              priceTax: 181,
              qty: 400.0),
          PriceRecord(
              id: 'r72',
              date: '2026-03-11',
              store: 'カスミ',
              price: 188,
              priceTax: 203,
              qty: 400.0),
        ],
      ),
      Product(
        id: 'p9',
        name: 'ポテトチップス うすしお',
        detail: '60g',
        category: 'sweets',
        emoji: '🥔',
        color: '0xFFFFF4DC',
        unitType: 'weight',
        unitBase: 60.0,
        records: [
          PriceRecord(
              id: 'r80',
              date: '2026-04-08',
              store: 'セブンイレブン',
              price: 158,
              priceTax: 171,
              qty: 60.0),
          PriceRecord(
              id: 'r81',
              date: '2026-03-22',
              store: 'ウェルシア',
              price: 128,
              priceTax: 138,
              qty: 60.0),
        ],
      ),
      Product(
        id: 'p10',
        name: 'トイレットペーパー',
        detail: '12ロール',
        category: 'daily',
        emoji: '🧻',
        color: '0xFFF7F2EA',
        unitType: 'count',
        unitBase: 12.0,
        records: [
          PriceRecord(
              id: 'r90',
              date: '2026-04-07',
              store: 'ウェルシア',
              price: 398,
              priceTax: 430,
              qty: 12.0),
          PriceRecord(
              id: 'r91',
              date: '2026-03-14',
              store: 'カスミ',
              price: 438,
              priceTax: 473,
              qty: 12.0),
        ],
      ),
    ];
  }
}
