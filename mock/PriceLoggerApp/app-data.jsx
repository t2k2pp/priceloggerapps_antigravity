// データと定数
const CATEGORIES = [
  { id: 'all', label: 'すべて', emoji: '🛒' },
  { id: 'food', label: '食品', emoji: '🍱' },
  { id: 'meat', label: '肉・魚', emoji: '🥩' },
  { id: 'veg', label: '野菜', emoji: '🥬' },
  { id: 'drink', label: '飲料', emoji: '🥤' },
  { id: 'daily', label: '日用品', emoji: '🧴' },
  { id: 'sweets', label: 'お菓子', emoji: '🍪' },
  { id: 'other', label: 'その他', emoji: '📦' },
];

const STORES = ['カスミ', 'ウェルシア', 'ヨークベニマル', 'マルエツ', 'セブンイレブン'];

// 店舗ごとの色（シンプル折れ線グラフで使用）
const STORE_COLORS = {
  'カスミ':       'oklch(0.65 0.19 35)',   // coral
  'ウェルシア':    'oklch(0.62 0.17 255)',  // blue
  'ヨークベニマル': 'oklch(0.62 0.17 145)',  // green
  'マルエツ':      'oklch(0.62 0.17 305)',  // purple
  'セブンイレブン': 'oklch(0.70 0.16 80)',   // amber
};

// サンプル商品データ
// records: 購入履歴 { date, store, price, priceTax, qty, unit }
const INITIAL_PRODUCTS = [
  {
    id: 'p1',
    name: 'たまご',
    detail: '10個入り',
    category: 'food',
    emoji: '🥚',
    color: 'oklch(0.92 0.08 85)',
    unitType: 'count', unitBase: 10,
    records: [
      { id: 'r1', date: '2026-04-15', store: 'カスミ',    price: 198, priceTax: 214, qty: 10 },
      { id: 'r2', date: '2026-04-02', store: 'カスミ',    price: 208, priceTax: 224, qty: 10 },
      { id: 'r3', date: '2026-03-18', store: 'ヨークベニマル', price: 228, priceTax: 246, qty: 10 },
      { id: 'r4', date: '2026-03-05', store: 'カスミ',    price: 218, priceTax: 235, qty: 10 },
      { id: 'r5', date: '2026-02-20', store: 'マルエツ',   price: 248, priceTax: 267, qty: 10 },
      { id: 'r6', date: '2026-02-08', store: 'カスミ',    price: 188, priceTax: 203, qty: 10 },
    ],
  },
  {
    id: 'p2',
    name: '大粒むきえび',
    detail: '170g',
    category: 'meat',
    emoji: '🦐',
    color: 'oklch(0.88 0.09 25)',
    unitType: 'weight', unitBase: 170,
    records: [
      { id: 'r10', date: '2026-04-12', store: 'カスミ', price: 395, priceTax: 427, qty: 170 },
      { id: 'r11', date: '2026-03-20', store: 'カスミ', price: 398, priceTax: 430, qty: 170 },
      { id: 'r12', date: '2026-02-28', store: 'ヨークベニマル', price: 448, priceTax: 484, qty: 170 },
      { id: 'r13', date: '2026-02-10', store: 'カスミ', price: 378, priceTax: 408, qty: 170 },
    ],
  },
  {
    id: 'p3',
    name: 'オロナミンC',
    detail: '10本入り',
    category: 'drink',
    emoji: '🥤',
    color: 'oklch(0.90 0.12 95)',
    unitType: 'count', unitBase: 10,
    records: [
      { id: 'r20', date: '2026-04-10', store: 'ウェルシア', price: 748, priceTax: 808 , qty: 10},
      { id: 'r21', date: '2026-03-15', store: 'ウェルシア', price: 768, priceTax: 829, qty: 10 },
      { id: 'r22', date: '2026-02-28', store: 'セブンイレブン', price: 880, priceTax: 950, qty: 10 },
      { id: 'r23', date: '2026-02-14', store: 'ウェルシア', price: 738, priceTax: 797, qty: 10 },
      { id: 'r24', date: '2026-01-20', store: 'ウェルシア', price: 758, priceTax: 819, qty: 10 },
    ],
  },
  {
    id: 'p4',
    name: '国産鶏もも肉',
    detail: '300g',
    category: 'meat',
    emoji: '🍗',
    color: 'oklch(0.85 0.10 30)',
    unitType: 'weight', unitBase: 300,
    records: [
      { id: 'r30', date: '2026-04-14', store: 'ヨークベニマル', price: 387, priceTax: 418, qty: 300 },
      { id: 'r31', date: '2026-04-03', store: 'カスミ',     price: 420, priceTax: 454, qty: 300 },
      { id: 'r32', date: '2026-03-22', store: 'ヨークベニマル', price: 378, priceTax: 408, qty: 300 },
      { id: 'r33', date: '2026-03-08', store: 'マルエツ',    price: 410, priceTax: 443, qty: 300 },
    ],
  },
  {
    id: 'p5',
    name: '国産鶏もも肉',
    detail: '400g',
    category: 'meat',
    emoji: '🍗',
    color: 'oklch(0.85 0.10 30)',
    unitType: 'weight', unitBase: 400,
    records: [
      { id: 'r40', date: '2026-04-11', store: 'カスミ',    price: 528, priceTax: 570, qty: 400 },
      { id: 'r41', date: '2026-03-25', store: 'ヨークベニマル', price: 498, priceTax: 538, qty: 400 },
      { id: 'r42', date: '2026-02-18', store: 'カスミ',    price: 548, priceTax: 592, qty: 400 },
    ],
  },
  {
    id: 'p6',
    name: 'どん兵衛 きつねうどん',
    detail: '1食',
    category: 'food',
    emoji: '🍜',
    color: 'oklch(0.90 0.08 65)',
    unitType: 'count', unitBase: 1,
    records: [
      { id: 'r50', date: '2026-04-16', store: 'セブンイレブン', price: 158, priceTax: 171, qty: 1 },
      { id: 'r51', date: '2026-04-01', store: 'ウェルシア',    price: 138, priceTax: 149, qty: 1 },
      { id: 'r52', date: '2026-03-12', store: 'カスミ',      price: 128, priceTax: 138, qty: 1 },
      { id: 'r53', date: '2026-02-26', store: 'セブンイレブン', price: 158, priceTax: 171, qty: 1 },
      { id: 'r54', date: '2026-02-05', store: 'マルエツ',     price: 148, priceTax: 160, qty: 1 },
    ],
  },
  {
    id: 'p7',
    name: 'キャベツ',
    detail: '1玉',
    category: 'veg',
    emoji: '🥬',
    color: 'oklch(0.90 0.09 140)',
    unitType: 'count', unitBase: 1,
    records: [
      { id: 'r60', date: '2026-04-13', store: 'ヨークベニマル', price: 198, priceTax: 214, qty: 1 },
      { id: 'r61', date: '2026-04-02', store: 'カスミ',    price: 238, priceTax: 257, qty: 1 },
      { id: 'r62', date: '2026-03-19', store: 'マルエツ',   price: 168, priceTax: 181, qty: 1 },
    ],
  },
  {
    id: 'p8',
    name: '明治ブルガリアヨーグルト',
    detail: '400g',
    category: 'food',
    emoji: '🥛',
    color: 'oklch(0.93 0.04 100)',
    unitType: 'weight', unitBase: 400,
    records: [
      { id: 'r70', date: '2026-04-09', store: 'カスミ', price: 178, priceTax: 192, qty: 400 },
      { id: 'r71', date: '2026-03-28', store: 'ウェルシア', price: 168, priceTax: 181, qty: 400 },
      { id: 'r72', date: '2026-03-11', store: 'カスミ', price: 188, priceTax: 203, qty: 400 },
    ],
  },
  {
    id: 'p9',
    name: 'ポテトチップス うすしお',
    detail: '60g',
    category: 'sweets',
    emoji: '🥔',
    color: 'oklch(0.92 0.08 75)',
    unitType: 'weight', unitBase: 60,
    records: [
      { id: 'r80', date: '2026-04-08', store: 'セブンイレブン', price: 158, priceTax: 171, qty: 60 },
      { id: 'r81', date: '2026-03-22', store: 'ウェルシア', price: 128, priceTax: 138, qty: 60 },
    ],
  },
  {
    id: 'p10',
    name: 'トイレットペーパー',
    detail: '12ロール',
    category: 'daily',
    emoji: '🧻',
    color: 'oklch(0.93 0.03 60)',
    unitType: 'count', unitBase: 12,
    records: [
      { id: 'r90', date: '2026-04-07', store: 'ウェルシア', price: 398, priceTax: 430, qty: 12 },
      { id: 'r91', date: '2026-03-14', store: 'カスミ', price: 438, priceTax: 473, qty: 12 },
    ],
  },
];

// 最新の価格を取得（税込）
function latestPrice(product) {
  if (!product.records.length) return null;
  const sorted = [...product.records].sort((a,b) => b.date.localeCompare(a.date));
  return sorted[0];
}

// 単価計算（100gあたり or 1個あたり）
function unitPrice(record, product) {
  if (!record) return null;
  if (product.unitType === 'weight') {
    return Math.round(record.priceTax / record.qty * 100); // 100gあたり
  } else {
    return Math.round(record.priceTax / record.qty); // 1個あたり
  }
}

function formatDate(str) {
  const [y,m,d] = str.split('-');
  return `${m}/${d}`;
}

function formatDateFull(str) {
  const [y,m,d] = str.split('-');
  return `${y}年${parseInt(m)}月${parseInt(d)}日`;
}

Object.assign(window, {
  CATEGORIES, STORES, STORE_COLORS, INITIAL_PRODUCTS,
  latestPrice, unitPrice, formatDate, formatDateFull,
});
