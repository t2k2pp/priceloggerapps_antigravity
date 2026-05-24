// ─────────────────────────────────────────────────────────────
// 統合画面: 同名の別登録を統合
// ─────────────────────────────────────────────────────────────
function MergeScreen({ product, candidates, onCancel, onMerge }) {
  const [selected, setSelected] = React.useState(new Set([product.id, ...candidates.map(c => c.id)]));

  const toggle = (id) => {
    const next = new Set(selected);
    if (next.has(id)) next.delete(id); else next.add(id);
    setSelected(next);
  };

  const allProducts = [product, ...candidates];
  const selectedList = allProducts.filter(p => selected.has(p.id));
  const totalRecords = selectedList.reduce((s, p) => s + p.records.length, 0);

  return (
    <div style={{ background: COLOR.bg, minHeight: '100%', paddingBottom: 120 }}>
      <div style={{
        padding: '8px 16px 12px',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        position: 'sticky', top: 0, background: COLOR.bg, zIndex: 5,
      }}>
        <button onClick={onCancel} style={{
          border: 'none', background: 'transparent', color: COLOR.ink2,
          fontSize: 14, fontWeight: 600, cursor: 'pointer', fontFamily: '"Noto Sans JP"',
        }}>キャンセル</button>
        <div style={{ fontSize: 15, fontWeight: 700, color: COLOR.ink }}>商品を統合</div>
        <div style={{ width: 70 }}/>
      </div>

      <div style={{ padding: '0 20px 20px' }}>
        <div style={{
          background: `linear-gradient(135deg, ${COLOR.accentSoft}, #fff)`,
          borderRadius: 18, padding: 16,
        }}>
          <div style={{ display: 'flex', gap: 10, alignItems: 'center', marginBottom: 8 }}>
            <Icon name="merge" size={20} color={COLOR.accent}/>
            <div style={{ fontSize: 15, fontWeight: 800, color: COLOR.ink }}>「{product.name}」を統合</div>
          </div>
          <div style={{ fontSize: 12, color: COLOR.ink2, lineHeight: 1.6 }}>
            同名で登録された別の記録を1つの商品としてまとめられます。<br/>
            重さ・個数の違う記録もまとめて価格推移を比較できます。
          </div>
        </div>
      </div>

      <div style={{ padding: '0 16px' }}>
        <div style={{ fontSize: 11, fontWeight: 700, color: COLOR.ink2, padding: '0 4px 8px', letterSpacing: 0.3 }}>
          統合する商品を選択（{selected.size}件）
        </div>
        <div style={{ background: COLOR.card, borderRadius: 18, overflow: 'hidden', boxShadow: '0 1px 2px rgba(0,0,0,0.03)' }}>
          {allProducts.map((p, i) => {
            const isSel = selected.has(p.id);
            const latest = latestPrice(p);
            return (
              <div key={p.id} onClick={() => toggle(p.id)} style={{
                padding: '14px 16px', display: 'flex', alignItems: 'center', gap: 12,
                borderTop: i === 0 ? 'none' : `1px solid ${COLOR.line}`, cursor: 'pointer',
                background: isSel ? '#FFFBF8' : '#fff',
              }}>
                <div style={{
                  width: 22, height: 22, borderRadius: 7,
                  border: `2px solid ${isSel ? COLOR.accent : COLOR.line}`,
                  background: isSel ? COLOR.accent : '#fff',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  flexShrink: 0,
                }}>
                  {isSel && <Icon name="check" size={13} color="#fff" strokeWidth={3}/>}
                </div>
                <ProductThumb product={p} size={44}/>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 14, fontWeight: 700, color: COLOR.ink }}>{p.name}</div>
                  <div style={{ fontSize: 11, color: COLOR.ink2, marginTop: 1 }}>
                    {p.detail} · {p.records.length}件の記録
                  </div>
                </div>
                {latest && <Price value={latest.priceTax} size={13}/>}
              </div>
            );
          })}
        </div>
      </div>

      {/* 統合後のプレビュー */}
      <div style={{ padding: '20px 16px 0' }}>
        <div style={{ fontSize: 11, fontWeight: 700, color: COLOR.ink2, padding: '0 4px 8px', letterSpacing: 0.3 }}>
          統合後のプレビュー
        </div>
        <div style={{ background: COLOR.card, borderRadius: 18, padding: 16, boxShadow: '0 1px 2px rgba(0,0,0,0.03)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 12 }}>
            <ProductThumb product={product} size={48}/>
            <div>
              <div style={{ fontSize: 15, fontWeight: 700, color: COLOR.ink }}>{product.name}</div>
              <div style={{ fontSize: 11, color: COLOR.ink2 }}>
                {totalRecords}件の記録に統合されます
              </div>
            </div>
          </div>
          <div style={{ fontSize: 11, color: COLOR.ink3, lineHeight: 1.5, padding: 10, background: COLOR.chipBg, borderRadius: 10 }}>
            💡 重さや個数が異なる記録は、<b style={{ color: COLOR.ink }}>100gあたり / 1個あたり</b>の単価で比較できるようになります
          </div>
        </div>
      </div>

      {/* 実行ボタン */}
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0,
        padding: '16px 16px 40px', background: `linear-gradient(to top, ${COLOR.bg} 70%, transparent)`,
      }}>
        <button onClick={() => onMerge([...selected])} disabled={selected.size < 2} style={{
          width: '100%', padding: 16, borderRadius: 16, border: 'none',
          background: selected.size >= 2 ? COLOR.accent : COLOR.line,
          color: selected.size >= 2 ? '#fff' : COLOR.ink3,
          fontSize: 15, fontWeight: 700, cursor: selected.size >= 2 ? 'pointer' : 'not-allowed',
          fontFamily: '"Noto Sans JP"',
          boxShadow: selected.size >= 2 ? '0 6px 16px rgba(236,106,58,0.3)' : 'none',
        }}>
          {selected.size}件の商品を統合
        </button>
      </div>
    </div>
  );
}

Object.assign(window, { MergeScreen });
