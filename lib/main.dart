import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models/product.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/add_screen.dart';
import 'screens/merge_screen.dart';
import 'theme/colors.dart';

void main() {
  runApp(const PriceLoggerApp());
}

class PriceLoggerApp extends StatelessWidget {
  const PriceLoggerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'マイ買い物帳',
      theme: ThemeData(
        fontFamily: 'Noto Sans JP',
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          primary: AppColors.accent,
          background: AppColors.bg,
        ),
        useMaterial3: true,
      ),
      // 日本語ロカールの設定
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
      ],
      home: const MainAppLifecyclePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainAppLifecyclePage extends StatefulWidget {
  const MainAppLifecyclePage({Key? key}) : super(key: key);

  @override
  State<MainAppLifecyclePage> createState() => _MainAppLifecyclePageState();
}

class _MainAppLifecyclePageState extends State<MainAppLifecyclePage> {
  final StorageService _storageService = StorageService();
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loaded = await _storageService.loadProducts();
    setState(() {
      _products = loaded;
      _isLoading = false;
    });
  }

  // 商品の追加・レコードの追加を処理
  void _saveProductOrRecord(Map<String, dynamic> data, Product? existingProduct) {
    final recordMap = data['record'] as Map<String, dynamic>;
    final newRecord = PriceRecord(
      id: recordMap['id'] as String,
      date: recordMap['date'] as String,
      store: recordMap['store'] as String,
      price: recordMap['price'] as int,
      priceTax: recordMap['priceTax'] as int,
      qty: recordMap['qty'] as double,
    );

    setState(() {
      if (existingProduct != null) {
        // 既存商品に購入記録を追記
        _products = _products.map((p) {
          if (p.id == existingProduct.id) {
            return p.copyWith(
              records: [...p.records, newRecord],
            );
          }
          return p;
        }).toList();
      } else {
        // 新規商品の作成
        final newProduct = Product(
          id: 'p${DateTime.now().millisecondsSinceEpoch}',
          name: data['name'] as String,
          detail: data['detail'] as String,
          category: data['category'] as String,
          emoji: data['emoji'] as String,
          color: data['color'] as String,
          unitType: data['unitType'] as String,
          unitBase: data['unitBase'] as double,
          records: [newRecord],
        );
        _products = [..._products, newProduct];
      }
    });

    _storageService.saveProducts(_products);
  }

  // 同名商品を統合
  void _mergeProducts(List<String> selectedIds) {
    if (selectedIds.length < 2) return;
    
    // 最初の製品を統合先（ベース）とする
    final targetId = selectedIds.first;
    final productsToMerge = _products.where((p) => selectedIds.contains(p.id)).toList();

    // 全マージ対象の購入履歴を統合
    final List<PriceRecord> allMergedRecords = [];
    for (var p in productsToMerge) {
      allMergedRecords.addAll(p.records);
    }

    // 重複IDがある場合は防ぐためのマップ化
    final Map<String, PriceRecord> uniqueRecords = {};
    for (var r in allMergedRecords) {
      uniqueRecords[r.id] = r;
    }

    final finalRecordsList = uniqueRecords.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // 新しい順にソート

    setState(() {
      _products = _products.map((p) {
        if (p.id == targetId) {
          return p.copyWith(records: finalRecordsList);
        }
        return p;
      }).where((p) => !selectedIds.skip(1).contains(p.id)).toList(); // 統合先以外の製品をリストから除外
    });

    _storageService.saveProducts(_products);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.accent,
          ),
        ),
      );
    }

    return HomeScreen(
      products: _products,
      onAdd: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddScreen(
              onCancel: () => Navigator.pop(context),
              onSave: (data) => _saveProductOrRecord(data, null),
            ),
          ),
        );
      },
      onOpen: (productId) {
        final product = _products.firstWhere((p) => p.id == productId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              product: product,
              allProducts: _products,
              onBack: () => Navigator.pop(context),
              onAddRecord: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddScreen(
                      existingProduct: product,
                      onCancel: () => Navigator.pop(context),
                      onSave: (data) => _saveProductOrRecord(data, product),
                    ),
                  ),
                );
              },
              onMergeOpen: (candidates) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MergeScreen(
                      product: product,
                      candidates: candidates,
                      onCancel: () => Navigator.pop(context),
                      onMerge: (selectedIds) {
                        _mergeProducts(selectedIds);
                        // マージ実行後は、詳細画面の親製品が消えている可能性があるため、ホーム画面まで戻るのが安全
                        Navigator.pop(context); // 統合画面を閉じる
                        Navigator.pop(context); // 詳細画面を閉じる
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
