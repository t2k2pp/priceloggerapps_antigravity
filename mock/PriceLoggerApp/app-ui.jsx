// ─────────────────────────────────────────────────────────────
// 共通UIコンポーネント
// ─────────────────────────────────────────────────────────────

const COLOR = {
  bg: '#FAF6F1',           // warm off-white
  card: '#FFFFFF',
  ink: '#2B2622',          // warm black
  ink2: '#6B6059',         // warm gray
  ink3: '#A39890',         // lighter warm gray
  line: '#EEE6DC',         // divider
  accent: '#EC6A3A',       // coral orange
  accentSoft: '#FDE9DF',
  accentDeep: '#C4481E',
  chipBg: '#F3ECE2',
  chipBgActive: '#EC6A3A',
};

// SVG アイコン（簡潔なストロークアイコン）
function Icon({ name, size = 20, color = 'currentColor', strokeWidth = 2 }) {
  const s = size;
  const base = { width: s, height: s, viewBox: '0 0 24 24', fill: 'none', stroke: color, strokeWidth, strokeLinecap: 'round', strokeLinejoin: 'round' };
  const paths = {
    search: <><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></>,
    plus: <><path d="M12 5v14M5 12h14"/></>,
    close: <><path d="M18 6 6 18M6 6l12 12"/></>,
    chevronLeft: <><path d="m15 6-6 6 6 6"/></>,
    chevronRight: <><path d="m9 6 6 6-6 6"/></>,
    chevronDown: <><path d="m6 9 6 6 6-6"/></>,
    camera: <><path d="M4 7h3l2-2h6l2 2h3a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V9a2 2 0 0 1 2-2Z"/><circle cx="12" cy="13" r="4"/></>,
    store: <><path d="M3 9l1-5h16l1 5"/><path d="M5 9v11h14V9"/><path d="M9 20v-6h6v6"/></>,
    calendar: <><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18M8 3v4M16 3v4"/></>,
    tag: <><path d="M20.6 13.4 13.4 20.6a2 2 0 0 1-2.8 0L3 13V3h10l7.6 7.6a2 2 0 0 1 0 2.8Z"/><circle cx="8" cy="8" r="1.5"/></>,
    filter: <><path d="M3 5h18M6 12h12M10 19h4"/></>,
    grid: <><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></>,
    list: <><path d="M8 6h13M8 12h13M8 18h13"/><circle cx="4" cy="6" r="1"/><circle cx="4" cy="12" r="1"/><circle cx="4" cy="18" r="1"/></>,
    more: <><circle cx="12" cy="5" r="1.5"/><circle cx="12" cy="12" r="1.5"/><circle cx="12" cy="19" r="1.5"/></>,
    trending: <><path d="m3 17 6-6 4 4 8-8"/><path d="M14 7h7v7"/></>,
    chart: <><path d="M3 3v18h18"/><path d="M7 14l4-4 3 3 5-6"/></>,
    merge: <><path d="M8 6v4a4 4 0 0 0 4 4h0a4 4 0 0 0 4-4V6"/><path d="M12 14v6"/><path d="m9 17 3 3 3-3"/></>,
    check: <><path d="m5 12 5 5L20 7"/></>,
    yen: <><path d="M6 4l6 8 6-8"/><path d="M6 13h12M6 17h12M12 12v8"/></>,
    image: <><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="9" cy="9" r="2"/><path d="m21 15-5-5L5 21"/></>,
    smile: <><circle cx="12" cy="12" r="9"/><path d="M8 14s1.5 2 4 2 4-2 4-2"/><circle cx="9" cy="10" r="1" fill={color} stroke="none"/><circle cx="15" cy="10" r="1" fill={color} stroke="none"/></>,
  };
  return <svg {...base}>{paths[name]}</svg>;
}

// 商品サムネイル（写真 or アイコン or 絵文字）
function ProductThumb({ product, size = 56, radius = 14 }) {
  const inner = size * 0.55;
  return (
    <div style={{
      width: size, height: size, borderRadius: radius,
      background: product.color, flexShrink: 0,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      position: 'relative', overflow: 'hidden',
      boxShadow: 'inset 0 0 0 1px rgba(0,0,0,0.04)',
    }}>
      <span style={{ fontSize: inner, lineHeight: 1 }}>{product.emoji}</span>
    </div>
  );
}

// 価格表示（大きな数字）
function Price({ value, size = 18, unit = '円', color = COLOR.ink, weight = 700 }) {
  return (
    <span style={{ color, fontWeight: weight, fontFamily: '"Noto Sans JP", system-ui', whiteSpace: 'nowrap' }}>
      <span style={{ fontSize: size }}>{value.toLocaleString()}</span>
      <span style={{ fontSize: size * 0.62, marginLeft: 1, fontWeight: 500 }}>{unit}</span>
    </span>
  );
}

// カテゴリバッジ
function CategoryChip({ cat, active, onClick, compact }) {
  return (
    <button onClick={onClick} style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      padding: compact ? '6px 11px' : '8px 14px',
      borderRadius: 999, border: 'none', cursor: 'pointer',
      background: active ? COLOR.chipBgActive : COLOR.chipBg,
      color: active ? '#fff' : COLOR.ink,
      fontSize: compact ? 12 : 13, fontWeight: 600,
      fontFamily: '"Noto Sans JP", system-ui',
      transition: 'all 0.15s',
      whiteSpace: 'nowrap',
    }}>
      <span style={{ fontSize: compact ? 13 : 14 }}>{cat.emoji}</span>
      {cat.label}
    </button>
  );
}

// 店舗バッジ（色付き小ドット）
function StoreDot({ store, size = 8 }) {
  return (
    <span style={{
      display: 'inline-block', width: size, height: size, borderRadius: '50%',
      background: STORE_COLORS[store] || COLOR.ink3, flexShrink: 0,
    }} />
  );
}

Object.assign(window, { COLOR, Icon, ProductThumb, Price, CategoryChip, StoreDot });
