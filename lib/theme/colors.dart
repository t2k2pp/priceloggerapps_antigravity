import 'dart:ui';

class AppColors {
  static const Color bg = Color(0xFFFAF6F1);            // 温かみのあるオフホワイト
  static const Color card = Color(0xFFFFFFFF);          // カード・ダイアログの白
  static const Color ink = Color(0xFF2B2622);           // 濃いブラウン（文字用）
  static const Color ink2 = Color(0xFF6B6059);          // 中間の温かいグレー（補足テキスト）
  static const Color ink3 = Color(0xFFA39890);          // 明るい温かいグレー（非活性・薄い線）
  static const Color line = Color(0xFFEEE6DC);          // 区切り線
  static const Color accent = Color(0xFFEC6A3A);        // コーラルオレンジ（アクセント）
  static const Color accentSoft = Color(0xFFFDE9DF);    // 薄いコーラル
  static const Color accentDeep = Color(0xFFC4481E);    // 濃いコーラル
  static const Color chipBg = Color(0xFFF3ECE2);        // チップの標準背景
  static const Color chipBgActive = Color(0xFFEC6A3A);  // チップのアクティブ背景

  // 店舗別の色（折れ線グラフ用）
  static const Map<String, Color> storeColors = {
    'カスミ': Color(0xFFE05E36),
    'ウェルシア': Color(0xFF2C7BE5),
    'ヨークベニマル': Color(0xFF00A86B),
    'マルエツ': Color(0xFFB84DB8),
    'セブンイレブン': Color(0xFFD98A29),
  };

  static Color getStoreColor(String storeName) {
    return storeColors[storeName] ?? accent;
  }
}
