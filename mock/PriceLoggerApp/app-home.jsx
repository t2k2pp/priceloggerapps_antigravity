// ─────────────────────────────────────────────────────────────
// 金額推移グラフ（折れ線、店舗ごとに色分け可能）
// ─────────────────────────────────────────────────────────────
function PriceChart({ records, width = 340, height = 180, storeFilter = 'all', multiStore = false }) {
  if (!records.length) {
    return (
      <div style={{
        width, height, display: 'flex', alignItems: 'center', justifyContent: 'center',
        color: COLOR.ink3, fontSize: 13,
      }}>記録がありません</div>
    );
  }

  const filtered = storeFilter === 'all' ? records : records.filter(r => r.store === storeFilter);
  if (!filtered.length) {
    return (
      <div style={{
        width, height, display: 'flex', alignItems: 'center', justifyContent: 'center',
        color: COLOR.ink3, fontSize: 13,
      }}>この店舗の記録はありません</div>
    );
  }

  const sorted = [...filtered].sort((a,b) => a.date.localeCompare(b.date));
  const prices = sorted.map(r => r.priceTax);
  const minP = Math.min(...prices);
  const maxP = Math.max(...prices);
  const padY = Math.max(20, (maxP - minP) * 0.3);
  const yMin = Math.max(0, minP - padY);
  const yMax = maxP + padY;
  const yRange = yMax - yMin || 1;

  const padL = 44, padR = 14, padT = 14, padB = 28;
  const chartW = width - padL - padR;
  const chartH = height - padT - padB;

  const x = (i, n) => padL + (n <= 1 ? chartW / 2 : (chartW * i) / (n - 1));
  const y = v => padT + chartH - ((v - yMin) / yRange) * chartH;

  // Y 軸ラベル
  const yTicks = 3;
  const tickVals = Array.from({length: yTicks}, (_, i) => Math.round(yMin + (yRange * i) / (yTicks - 1)));

  // 店舗ごと、または単一ライン
  let lines;
  if (multiStore) {
    const byStore = {};
    sorted.forEach(r => { (byStore[r.store] ||= []).push(r); });
    lines = Object.entries(byStore).map(([store, recs]) => {
      const pts = recs.map(r => {
        const idx = sorted.findIndex(s => s.id === r.id);
        return { x: x(idx, sorted.length), y: y(r.priceTax), r, idx };
      });
      return { store, color: STORE_COLORS[store] || COLOR.accent, pts };
    });
  } else {
    lines = [{
      store: null, color: COLOR.accent,
      pts: sorted.map((r, i) => ({ x: x(i, sorted.length), y: y(r.priceTax), r, idx: i })),
    }];
  }

  return (
    <svg width={width} height={height} style={{ display: 'block' }}>
      {/* 背景グリッド */}
      {tickVals.map((v, i) => {
        const yy = y(v);
        return (
          <g key={i}>
            <line x1={padL} y1={yy} x2={width - padR} y2={yy} stroke={COLOR.line} strokeDasharray="3 3"/>
            <text x={padL - 6} y={yy + 4} fill={COLOR.ink3} fontSize={10} textAnchor="end" fontFamily="Noto Sans JP">
              {v.toLocaleString()}
            </text>
          </g>
        );
      })}
      {/* X 軸ラベル */}
      {sorted.map((r, i) => (
        <text key={i} x={x(i, sorted.length)} y={height - 8} fill={COLOR.ink3} fontSize={10} textAnchor="middle" fontFamily="Noto Sans JP">
          {formatDate(r.date)}
        </text>
      ))}
      {/* ライン */}
      {lines.map((line, li) => (
        <g key={li}>
          {line.pts.length > 1 && (
            <>
              {/* グラデーションの下塗り (単色時) */}
              {!multiStore && (
                <path
                  d={`M ${line.pts.map(p => `${p.x},${p.y}`).join(' L ')} L ${line.pts[line.pts.length-1].x},${padT + chartH} L ${line.pts[0].x},${padT + chartH} Z`}
                  fill={line.color}
                  fillOpacity="0.08"
                />
              )}
              <path
                d={`M ${line.pts.map(p => `${p.x},${p.y}`).join(' L ')}`}
                fill="none" stroke={line.color} strokeWidth="2.5"
                strokeLinecap="round" strokeLinejoin="round"
              />
            </>
          )}
          {line.pts.map((p, i) => (
            <g key={i}>
              <circle cx={p.x} cy={p.y} r="4" fill="#fff" stroke={line.color} strokeWidth="2.5"/>
            </g>
          ))}
        </g>
      ))}
    </svg>
  );
}

// ─────────────────────────────────────────────────────────────
// ホーム画面: 検索・フィルタ・一覧
// ─────────────────────────────────────────────────────────────
function HomeScreen({ products, onAdd, onOpen, layout, onLayout, platform }) {
  const [q, setQ] = React.useState('');
  const [cat, setCat] = React.useState('all');
  const [store, setStore] = React.useState('all');
  const [sort, setSort] = React.useState('recent'); // recent / price / name

  let filtered = products;
  if (cat !== 'all') filtered = filtered.filter(p => p.category === cat);
  if (store !== 'all') filtered = filtered.filter(p => p.records.some(r => r.store === store));
  if (q.trim()) {
    const qq = q.trim().toLowerCase();
    filtered = filtered.filter(p => (p.name + p.detail).toLowerCase().includes(qq));
  }

  // ソート
  filtered = [...filtered].sort((a, b) => {
    if (sort === 'name') return a.name.localeCompare(b.name, 'ja');
    if (sort === 'price') {
      const pa = latestPrice(a)?.priceTax || 0;
      const pb = latestPrice(b)?.priceTax || 0;
      return pa - pb;
    }
    // recent
    const da = latestPrice(a)?.date || '';
    const db = latestPrice(b)?.date || '';
    return db.localeCompare(da);
  });

  const headerBg = platform === 'ios' ? COLOR.bg : COLOR.bg;

  return (
    <div style={{ background: COLOR.bg, minHeight: '100%', position: 'relative', paddingBottom: 90 }}>
      {/* ヘッダー */}
      <div style={{
        background: headerBg,
        padding: platform === 'ios' ? '8px 20px 14px' : '12px 16px 14px',
        position: 'sticky', top: 0, zIndex: 5,
      }}>
        <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 12 }}>
          <div>
            <div style={{ fontSize: 24, fontWeight: 800, color: COLOR.ink, letterSpacing: -0.5, fontFamily: '"Noto Sans JP"' }}>
              マイ買い物帳
            </div>
            <div style={{ fontSize: 12, color: COLOR.ink2, marginTop: 2 }}>
              {products.length}件の商品 · {products.reduce((s, p) => s + p.records.length, 0)}件の記録
            </div>
          </div>
          <button onClick={() => onLayout(layout === 'list' ? 'grid' : 'list')} style={{
            width: 36, height: 36, borderRadius: 12, border: 'none',
            background: COLOR.card, cursor: 'pointer', color: COLOR.ink2,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 1px 2px rgba(0,0,0,0.04)',
          }}>
            <Icon name={layout === 'list' ? 'grid' : 'list'} size={18}/>
          </button>
        </div>

        {/* 検索 */}
        <div style={{
          display: 'flex', alignItems: 'center', gap: 10,
          background: COLOR.card, padding: '10px 14px', borderRadius: 14,
          boxShadow: '0 1px 2px rgba(0,0,0,0.03)',
        }}>
          <Icon name="search" size={18} color={COLOR.ink3}/>
          <input
            value={q}
            onChange={e => setQ(e.target.value)}
            placeholder="商品名で検索"
            style={{
              flex: 1, border: 'none', outline: 'none', background: 'transparent',
              fontSize: 15, color: COLOR.ink, fontFamily: '"Noto Sans JP"',
            }}
          />
          {q && (
            <button onClick={() => setQ('')} style={{
              border: 'none', background: COLOR.line, borderRadius: '50%',
              width: 20, height: 20, cursor: 'pointer', display: 'flex',
              alignItems: 'center', justifyContent: 'center', color: COLOR.ink2,
            }}>
              <Icon name="close" size={12} strokeWidth={2.5}/>
            </button>
          )}
        </div>
      </div>

      {/* カテゴリフィルタ */}
      <div style={{
        display: 'flex', gap: 8, padding: '4px 16px 12px', overflowX: 'auto',
        scrollbarWidth: 'none',
      }} className="hide-scrollbar">
        {CATEGORIES.map(c => (
          <CategoryChip key={c.id} cat={c} active={cat === c.id} onClick={() => setCat(c.id)}/>
        ))}
      </div>

      {/* 店舗 + 並び替え */}
      <div style={{ display: 'flex', gap: 8, padding: '0 16px 12px', alignItems: 'center' }}>
        <select value={store} onChange={e => setStore(e.target.value)} style={{
          flex: 1, padding: '8px 12px', borderRadius: 10, border: 'none',
          background: COLOR.card, color: COLOR.ink, fontSize: 13, fontWeight: 600,
          fontFamily: '"Noto Sans JP"', cursor: 'pointer',
          boxShadow: '0 1px 2px rgba(0,0,0,0.03)',
          appearance: 'none', WebkitAppearance: 'none',
          backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%236B6059' stroke-width='2.5' stroke-linecap='round'%3E%3Cpath d='m6 9 6 6 6-6'/%3E%3C/svg%3E")`,
          backgroundRepeat: 'no-repeat', backgroundPosition: 'right 10px center',
          paddingRight: 28,
        }}>
          <option value="all">🏪 すべての店舗</option>
          {STORES.map(s => <option key={s} value={s}>{s}</option>)}
        </select>
        <select value={sort} onChange={e => setSort(e.target.value)} style={{
          padding: '8px 12px', borderRadius: 10, border: 'none',
          background: COLOR.card, color: COLOR.ink, fontSize: 13, fontWeight: 600,
          fontFamily: '"Noto Sans JP"', cursor: 'pointer',
          boxShadow: '0 1px 2px rgba(0,0,0,0.03)',
          appearance: 'none', WebkitAppearance: 'none',
          backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%236B6059' stroke-width='2.5' stroke-linecap='round'%3E%3Cpath d='m6 9 6 6 6-6'/%3E%3C/svg%3E")`,
          backgroundRepeat: 'no-repeat', backgroundPosition: 'right 10px center',
          paddingRight: 28,
        }}>
          <option value="recent">最近</option>
          <option value="price">価格順</option>
          <option value="name">名前順</option>
        </select>
      </div>

      {/* 一覧 */}
      {filtered.length === 0 ? (
        <div style={{ padding: '60px 20px', textAlign: 'center', color: COLOR.ink3 }}>
          <div style={{ fontSize: 40, marginBottom: 12 }}>🔍</div>
          <div style={{ fontSize: 14, fontWeight: 600, color: COLOR.ink2 }}>該当する商品がありません</div>
        </div>
      ) : layout === 'list' ? (
        <ProductList products={filtered} onOpen={onOpen}/>
      ) : (
        <ProductGrid products={filtered} onOpen={onOpen}/>
      )}

      {/* FAB */}
      <button onClick={onAdd} style={{
        position: 'absolute', right: 20, bottom: 24,
        width: 60, height: 60, borderRadius: 20, border: 'none',
        background: COLOR.accent, color: '#fff', cursor: 'pointer',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        boxShadow: '0 8px 20px rgba(236,106,58,0.4), 0 2px 6px rgba(236,106,58,0.25)',
        zIndex: 10,
      }}>
        <Icon name="plus" size={28} strokeWidth={2.5}/>
      </button>
    </div>
  );
}

// リスト表示
function ProductList({ products, onOpen }) {
  return (
    <div style={{ padding: '0 16px', display: 'flex', flexDirection: 'column', gap: 8 }}>
      {products.map(p => {
        const latest = latestPrice(p);
        const prev = p.records.length > 1 ? p.records.sort((a,b)=>b.date.localeCompare(a.date))[1] : null;
        const up = prev && latest.priceTax > prev.priceTax;
        const down = prev && latest.priceTax < prev.priceTax;
        return (
          <div key={p.id} onClick={() => onOpen(p.id)} style={{
            background: COLOR.card, borderRadius: 16, padding: 12,
            display: 'flex', alignItems: 'center', gap: 12, cursor: 'pointer',
            boxShadow: '0 1px 2px rgba(0,0,0,0.03)',
          }}>
            <ProductThumb product={p} size={54}/>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 15, fontWeight: 700, color: COLOR.ink, fontFamily: '"Noto Sans JP"', overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>
                {p.name}
              </div>
              <div style={{ fontSize: 12, color: COLOR.ink2, marginTop: 2, display:'flex', alignItems:'center', gap:8 }}>
                <span>{p.detail}</span>
                <span style={{ width: 2, height: 2, borderRadius: 1, background: COLOR.ink3 }}/>
                {latest && <><StoreDot store={latest.store}/> {latest.store}</>}
              </div>
            </div>
            <div style={{ textAlign: 'right' }}>
              {latest && <Price value={latest.priceTax} size={17}/>}
              <div style={{ fontSize: 10, color: COLOR.ink3, marginTop: 2, display:'flex', alignItems:'center', justifyContent:'flex-end', gap:4 }}>
                {up && <span style={{ color: COLOR.accent }}>↑</span>}
                {down && <span style={{ color: 'oklch(0.58 0.17 145)' }}>↓</span>}
                <span>{latest && formatDate(latest.date)}</span>
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}

// グリッド表示
function ProductGrid({ products, onOpen }) {
  return (
    <div style={{
      padding: '0 16px', display: 'grid',
      gridTemplateColumns: '1fr 1fr', gap: 10,
    }}>
      {products.map(p => {
        const latest = latestPrice(p);
        const up100 = unitPrice(latest, p);
        return (
          <div key={p.id} onClick={() => onOpen(p.id)} style={{
            background: COLOR.card, borderRadius: 16, padding: 12,
            cursor: 'pointer', boxShadow: '0 1px 2px rgba(0,0,0,0.03)',
          }}>
            <div style={{
              width: '100%', aspectRatio: '1/1', background: p.color, borderRadius: 12,
              display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 10,
              position: 'relative', overflow: 'hidden',
            }}>
              <span style={{ fontSize: 52, lineHeight: 1 }}>{p.emoji}</span>
              {latest && (
                <div style={{
                  position: 'absolute', top: 6, right: 6,
                  background: 'rgba(255,255,255,0.95)', borderRadius: 8,
                  padding: '2px 7px', fontSize: 10, fontWeight: 700, color: COLOR.ink2,
                  display: 'flex', alignItems: 'center', gap: 4,
                }}>
                  <StoreDot store={latest.store} size={6}/>
                  {latest.store}
                </div>
              )}
            </div>
            <div style={{ fontSize: 13, fontWeight: 700, color: COLOR.ink, fontFamily: '"Noto Sans JP"', lineHeight: 1.3, overflow:'hidden', display:'-webkit-box', WebkitLineClamp:1, WebkitBoxOrient:'vertical' }}>
              {p.name}
            </div>
            <div style={{ fontSize: 11, color: COLOR.ink3, marginTop: 1 }}>{p.detail}</div>
            <div style={{ marginTop: 6, display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
              {latest && <Price value={latest.priceTax} size={16}/>}
              {up100 && (
                <div style={{ fontSize: 10, color: COLOR.ink3 }}>
                  {p.unitType === 'weight' ? `${up100}円/100g` : `${up100}円/個`}
                </div>
              )}
            </div>
          </div>
        );
      })}
    </div>
  );
}

Object.assign(window, { PriceChart, HomeScreen, ProductList, ProductGrid });
