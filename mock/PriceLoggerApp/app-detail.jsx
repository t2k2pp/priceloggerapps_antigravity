// ─────────────────────────────────────────────────────────────
// 商品詳細画面（過去記録一覧 + 金額推移グラフ + 単価計算）
// ─────────────────────────────────────────────────────────────
function DetailScreen({ product, allProducts, onBack, onMergeOpen, onAddRecord }) {
  const [storeFilter, setStoreFilter] = React.useState('all');
  const [multiStore, setMultiStore] = React.useState(false);
  const [calcQty, setCalcQty] = React.useState(product.unitType === 'weight' ? 450 : 5);

  const latest = latestPrice(product);
  const recordsSorted = [...product.records].sort((a, b) => b.date.localeCompare(a.date));
  const usedStores = [...new Set(product.records.map(r => r.store))];

  // 統計
  const prices = product.records.map(r => r.priceTax);
  const avg = Math.round(prices.reduce((s,v)=>s+v,0) / prices.length);
  const min = Math.min(...prices);
  const max = Math.max(...prices);

  // 単価計算
  const baseUnit = latest ? latest.priceTax / latest.qty : 0;
  const calcPrice = Math.round(baseUnit * calcQty);
  const perUnit = Math.round(baseUnit * (product.unitType === 'weight' ? 100 : 1));

  // 同名の別登録があるか
  const sameNameOther = allProducts.filter(p => p.id !== product.id && p.name === product.name);

  return (
    <div style={{ background: COLOR.bg, minHeight: '100%', paddingBottom: 40 }}>
      {/* ヘッダー */}
      <div style={{
        padding: '8px 16px 12px',
        display: 'flex', alignItems: 'center', gap: 8, position: 'sticky', top: 0, zIndex: 5,
        background: COLOR.bg,
      }}>
        <button onClick={onBack} style={{
          width: 40, height: 40, borderRadius: 14, border: 'none',
          background: COLOR.card, cursor: 'pointer', color: COLOR.ink,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 1px 2px rgba(0,0,0,0.04)',
        }}>
          <Icon name="chevronLeft" size={20} strokeWidth={2.3}/>
        </button>
        <div style={{ flex: 1 }}/>
        <button style={{
          width: 40, height: 40, borderRadius: 14, border: 'none',
          background: COLOR.card, cursor: 'pointer', color: COLOR.ink2,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 1px 2px rgba(0,0,0,0.04)',
        }}>
          <Icon name="more" size={20}/>
        </button>
      </div>

      {/* 商品ヘッダー */}
      <div style={{ padding: '0 20px 20px' }}>
        <div style={{ display: 'flex', gap: 16, alignItems: 'center' }}>
          <div style={{
            width: 88, height: 88, borderRadius: 22,
            background: product.color, flexShrink: 0,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 4px 12px rgba(0,0,0,0.06)',
          }}>
            <span style={{ fontSize: 52 }}>{product.emoji}</span>
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 11, fontWeight: 600, color: COLOR.accent, letterSpacing: 0.5 }}>
              {CATEGORIES.find(c => c.id === product.category)?.emoji} {CATEGORIES.find(c => c.id === product.category)?.label}
            </div>
            <div style={{ fontSize: 20, fontWeight: 800, color: COLOR.ink, fontFamily: '"Noto Sans JP"', letterSpacing: -0.3, marginTop: 2, lineHeight: 1.25 }}>
              {product.name}
            </div>
            <div style={{ fontSize: 13, color: COLOR.ink2, marginTop: 2 }}>{product.detail}</div>
          </div>
        </div>

        {/* 最新価格サマリ */}
        {latest && (
          <div style={{
            marginTop: 16, padding: 16, borderRadius: 18,
            background: `linear-gradient(135deg, ${COLOR.accentSoft}, #fff)`,
            border: `1px solid ${COLOR.accentSoft}`,
          }}>
            <div style={{ fontSize: 11, fontWeight: 600, color: COLOR.ink2, letterSpacing: 0.3 }}>最新の記録</div>
            <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginTop: 4 }}>
              <div>
                <Price value={latest.priceTax} size={30} color={COLOR.accentDeep}/>
                <span style={{ fontSize: 11, color: COLOR.ink3, marginLeft: 6 }}>（税抜 {latest.price}円）</span>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{ fontSize: 12, color: COLOR.ink2, display: 'flex', alignItems: 'center', gap: 5, justifyContent: 'flex-end' }}>
                  <StoreDot store={latest.store}/> {latest.store}
                </div>
                <div style={{ fontSize: 11, color: COLOR.ink3, marginTop: 2 }}>{formatDateFull(latest.date)}</div>
              </div>
            </div>
          </div>
        )}

        {/* 同名商品の統合提案 */}
        {sameNameOther.length > 0 && (
          <div onClick={onMergeOpen} style={{
            marginTop: 10, padding: '10px 14px', borderRadius: 14,
            background: '#fff', border: `1px dashed ${COLOR.accent}`,
            display: 'flex', alignItems: 'center', gap: 10, cursor: 'pointer',
          }}>
            <div style={{
              width: 32, height: 32, borderRadius: 10, background: COLOR.accentSoft,
              display: 'flex', alignItems: 'center', justifyContent: 'center', color: COLOR.accent,
            }}>
              <Icon name="merge" size={18}/>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 13, fontWeight: 700, color: COLOR.ink }}>
                同名商品が {sameNameOther.length}件 あります
              </div>
              <div style={{ fontSize: 11, color: COLOR.ink2, marginTop: 1 }}>
                同一商品として統合できます
              </div>
            </div>
            <Icon name="chevronRight" size={16} color={COLOR.ink3}/>
          </div>
        )}
      </div>

      {/* 単価計算 */}
      {latest && (
        <div style={{ padding: '0 16px 20px' }}>
          <div style={{ fontSize: 12, fontWeight: 700, color: COLOR.ink2, padding: '0 4px 8px', letterSpacing: 0.3 }}>
            単価計算
          </div>
          <div style={{ background: COLOR.card, borderRadius: 18, padding: 16, boxShadow: '0 1px 2px rgba(0,0,0,0.03)' }}>
            {/* 単価 */}
            <div style={{
              display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              paddingBottom: 14, borderBottom: `1px solid ${COLOR.line}`,
            }}>
              <div>
                <div style={{ fontSize: 11, color: COLOR.ink2 }}>
                  {product.unitType === 'weight' ? '100gあたり' : '1個あたり'}
                </div>
                <div style={{ fontSize: 13, color: COLOR.ink3, marginTop: 1 }}>
                  {latest.priceTax}円 ÷ {latest.qty}{product.unitType === 'weight' ? 'g' : '個'} × {product.unitType === 'weight' ? '100' : '1'}
                </div>
              </div>
              <Price value={perUnit} size={24} color={COLOR.ink}/>
            </div>

            {/* 任意量の価格換算 */}
            <div style={{ paddingTop: 14 }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
                <div style={{ fontSize: 13, fontWeight: 600, color: COLOR.ink }}>
                  {product.unitType === 'weight' ? '重さ換算' : '個数換算'}
                </div>
                <Price value={calcPrice} size={22} color={COLOR.accent}/>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                <input
                  type="range"
                  min={product.unitType === 'weight' ? 50 : 1}
                  max={product.unitType === 'weight' ? 1000 : 30}
                  step={product.unitType === 'weight' ? 10 : 1}
                  value={calcQty}
                  onChange={e => setCalcQty(Number(e.target.value))}
                  style={{ flex: 1, accentColor: COLOR.accent }}
                />
                <div style={{
                  padding: '6px 12px', background: COLOR.accentSoft, borderRadius: 10,
                  fontSize: 13, fontWeight: 700, color: COLOR.accentDeep, minWidth: 64, textAlign: 'center',
                  fontFamily: '"Noto Sans JP"',
                }}>
                  {calcQty}{product.unitType === 'weight' ? 'g' : '個'}
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* 価格推移グラフ */}
      <div style={{ padding: '0 16px 20px' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 4px 8px' }}>
          <div style={{ fontSize: 12, fontWeight: 700, color: COLOR.ink2, letterSpacing: 0.3 }}>
            価格推移
          </div>
          <button onClick={() => setMultiStore(!multiStore)} style={{
            border: 'none', background: multiStore ? COLOR.accentSoft : 'transparent',
            color: multiStore ? COLOR.accentDeep : COLOR.ink2, fontSize: 11, fontWeight: 700,
            padding: '4px 10px', borderRadius: 10, cursor: 'pointer',
            fontFamily: '"Noto Sans JP"',
          }}>
            店舗ごとに色分け {multiStore ? 'ON' : 'OFF'}
          </button>
        </div>
        <div style={{ background: COLOR.card, borderRadius: 18, padding: '16px 12px', boxShadow: '0 1px 2px rgba(0,0,0,0.03)' }}>
          {/* 店舗フィルタ */}
          {!multiStore && usedStores.length > 1 && (
            <div style={{ display: 'flex', gap: 6, padding: '0 4px 12px', flexWrap: 'wrap' }}>
              <button onClick={() => setStoreFilter('all')} style={chipStyle(storeFilter === 'all')}>
                すべて
              </button>
              {usedStores.map(s => (
                <button key={s} onClick={() => setStoreFilter(s)} style={chipStyle(storeFilter === s)}>
                  <StoreDot store={s}/> {s}
                </button>
              ))}
            </div>
          )}
          <PriceChart records={product.records} storeFilter={multiStore ? 'all' : storeFilter} multiStore={multiStore}/>
          {/* 凡例 */}
          {multiStore && (
            <div style={{ display: 'flex', gap: 10, padding: '8px 4px 0', flexWrap: 'wrap' }}>
              {usedStores.map(s => (
                <div key={s} style={{ display: 'flex', alignItems: 'center', gap: 5, fontSize: 11, color: COLOR.ink2, fontWeight: 600 }}>
                  <span style={{ width: 12, height: 2, background: STORE_COLORS[s] || COLOR.accent, borderRadius: 1 }}/>
                  {s}
                </div>
              ))}
            </div>
          )}
          {/* 統計 */}
          <div style={{
            display: 'flex', justifyContent: 'space-around', marginTop: 14,
            paddingTop: 14, borderTop: `1px solid ${COLOR.line}`,
          }}>
            <Stat label="最安" value={min} color="oklch(0.58 0.17 145)"/>
            <Stat label="平均" value={avg} color={COLOR.ink}/>
            <Stat label="最高" value={max} color={COLOR.accent}/>
          </div>
        </div>
      </div>

      {/* 過去記録 */}
      <div style={{ padding: '0 16px 24px' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 4px 8px' }}>
          <div style={{ fontSize: 12, fontWeight: 700, color: COLOR.ink2, letterSpacing: 0.3 }}>
            過去の記録 <span style={{ color: COLOR.ink3, fontWeight: 500 }}>（{recordsSorted.length}件）</span>
          </div>
          <button onClick={onAddRecord} style={{
            border: 'none', background: 'transparent', color: COLOR.accent, fontSize: 12,
            fontWeight: 700, cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 4,
            fontFamily: '"Noto Sans JP"',
          }}>
            <Icon name="plus" size={14} strokeWidth={2.5}/>記録を追加
          </button>
        </div>
        <div style={{ background: COLOR.card, borderRadius: 18, overflow: 'hidden', boxShadow: '0 1px 2px rgba(0,0,0,0.03)' }}>
          {recordsSorted.map((r, i) => {
            const unit = unitPrice(r, product);
            return (
              <div key={r.id} style={{
                padding: '12px 16px',
                borderTop: i === 0 ? 'none' : `1px solid ${COLOR.line}`,
                display: 'flex', alignItems: 'center', gap: 12,
              }}>
                <div style={{
                  width: 40, height: 40, borderRadius: 10,
                  background: COLOR.accentSoft, display: 'flex', flexDirection: 'column',
                  alignItems: 'center', justifyContent: 'center', color: COLOR.accentDeep,
                  fontFamily: '"Noto Sans JP"', flexShrink: 0,
                }}>
                  <div style={{ fontSize: 9, fontWeight: 700, lineHeight: 1 }}>{r.date.slice(5,7)}月</div>
                  <div style={{ fontSize: 14, fontWeight: 800, lineHeight: 1.1 }}>{parseInt(r.date.slice(8,10))}</div>
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 13, fontWeight: 700, color: COLOR.ink, display: 'flex', alignItems: 'center', gap: 6 }}>
                    <StoreDot store={r.store}/> {r.store}
                  </div>
                  <div style={{ fontSize: 11, color: COLOR.ink3, marginTop: 1 }}>
                    {product.unitType === 'weight' ? `100gあたり ${unit}円` : `1個あたり ${unit}円`}
                  </div>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <Price value={r.priceTax} size={15}/>
                  <div style={{ fontSize: 10, color: COLOR.ink3, marginTop: 1 }}>税抜 {r.price}円</div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

function chipStyle(active) {
  return {
    display: 'inline-flex', alignItems: 'center', gap: 5,
    padding: '5px 10px', borderRadius: 999, border: 'none',
    background: active ? COLOR.chipBgActive : COLOR.chipBg,
    color: active ? '#fff' : COLOR.ink2,
    fontSize: 11, fontWeight: 700, cursor: 'pointer',
    fontFamily: '"Noto Sans JP"',
  };
}

function Stat({ label, value, color }) {
  return (
    <div style={{ textAlign: 'center' }}>
      <div style={{ fontSize: 10, color: COLOR.ink3, fontWeight: 600 }}>{label}</div>
      <div style={{ marginTop: 3 }}>
        <Price value={value} size={15} color={color}/>
      </div>
    </div>
  );
}

Object.assign(window, { DetailScreen });
