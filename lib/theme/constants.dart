class CategoryInfo {
  final String id;
  final String label;
  final String emoji;
  const CategoryInfo({required this.id, required this.label, required this.emoji});
}

const List<CategoryInfo> appCategories = [
  CategoryInfo(id: 'all', label: 'すべて', emoji: '🛒'),
  CategoryInfo(id: 'food', label: '食品', emoji: '🍱'),
  CategoryInfo(id: 'meat', label: '肉・魚', emoji: '🥩'),
  CategoryInfo(id: 'veg', label: '野菜', emoji: '🥬'),
  CategoryInfo(id: 'drink', label: '飲料', emoji: '🥤'),
  CategoryInfo(id: 'daily', label: '日用品', emoji: '🧴'),
  CategoryInfo(id: 'sweets', label: 'お菓子', emoji: '🍪'),
  CategoryInfo(id: 'other', label: 'その他', emoji: '📦'),
];

const List<String> appStores = ['カスミ', 'ウェルシア', 'ヨークベニマル', 'マルエツ', 'セブンイレブン'];
