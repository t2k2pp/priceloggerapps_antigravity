// ─────────────────────────────────────────────────────────────
// 追加画面（新規記録 / 既存商品への記録追加）
// ─────────────────────────────────────────────────────────────
function AddScreen({ onCancel, onSave, existingProduct }) {
  const [step, setStep] = React.useState(1); // 1: 基本情報, 2: 画像
  const [name, setName] = React.useState(existingProduct?.name || '');
  const [detail, setDetail] = React.useState(existingProduct?.detail || '');
  const [category, setCategory] = React.useState(existingProduct?.category || 'food');
  const [store, setStore] = React.useState('カスミ');
  const [price, setPrice] = React.useState('');
  const [priceTax, setPriceTax] = React.useState('');
  const [date, setDate] = React.useState('2026-04-18');
  const [unitType, setUnitType] = React.useState(existingProduct?.unitType || 'count');
  const [qty, setQty] = React.useState(existingProduct?.unitBase || 1);
  const [emoji, setEmoji] = React.useState(existingProduct?.emoji || '🛍');
  const [color, setColor] = React.useState(existingProduct?.color || 'oklch(0.90 0.08 65)');
  const [imageMode, setImageMode] = React.useState('emoji'); // emoji/icon/photo

  // 税抜 → 税込 自動計算（8%食品税想定）
  React.useEffect(() => {
    if (price && !priceTax) {
      const tax = Math.round(Number(price) * 1.08);
      setPriceTax(String(tax));
    }
  }, [price]);

  const canSave = name.trim() && price && priceTax && qty;

  const emojiChoices = ['🥚','🦐','🥤','🍗','🍜','🥬','🥛','🥔','🧻','🍱','🍎','🥕','🧀','🍞','🥫','🍚','🍅','🥦','🍌','🥩','🧴','🧼','🪥','🍪'];
  const colorChoices = [
    'oklch(0.92 0.08 85)', 'oklch(0.88 0.09 25)', 'oklch(0.90 0.12 95)',
    'oklch(0.85 0.10 30)', 'oklch(0.90 0.08 65)', 'oklch(0.90 0.09 140)',
    'oklch(0.93 0.04 100)', 'oklch(0.92 0.08 75)', 'oklch(0.93 0.03 60)',
    'oklch(0.88 0.08 200)', 'oklch(0.90 0.10 320)',
  ];

  const handleSave = () => {
    if (!canSave) return;
    onSave({
      name: name.trim(), detail: detail.trim(), category, emoji, color,
      unitType, unitBase: Number(qty),
      record: {
        id: 'r' + Date.now(), date, store,
        price: Number(price), priceTax: Number(priceTax), qty: Number(qty),
      },
    });
  };

  return (
    <div style={{ background: COLOR.bg, minHeight: '100%', paddingBottom: 100 }}>
      {/* ヘッダー */}
      <div style={{
        padding: '8px 16px 12px',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        position: 'sticky', top: 0, background: COLOR.bg, zIndex: 5,
      }}>
        <button onClick={onCancel} style={{
          border: 'none', background: 'transparent', color: COLOR.ink2,
          fontSize: 14, fontWeight: 600, cursor: 'pointer', padding: '8px 4px',
          fontFamily: '"Noto Sans JP"',
        }}>
          キャンセル
        </button>
        <div style={{ fontSize: 15, fontWeight: 700, color: COLOR.ink, fontFamily: '"Noto Sans JP"' }}>
          {existingProduct ? '記録を追加' : '新しい商品'}
        </div>
        <button onClick={handleSave} disabled={!canSave} style={{
          border: 'none',
          background: canSave ? COLOR.accent : COLOR.line,
          color: canSave ? '#fff' : COLOR.ink3,
          fontSize: 13, fontWeight: 700, cursor: canSave ? 'pointer' : 'not-allowed',
          padding: '8px 16px', borderRadius: 12,
          fontFamily: '"Noto Sans JP"',
          transition: 'all 0.15s',
        }}>
          保存
        </button>
      </div>

      {/* 商品画像プレビュー（絵文字/アイコン/写真） */}
      {!existingProduct && (
        <div style={{ padding: '12px 20px 16px', display: 'flex', justifyContent: 'center' }}>
          <div style={{
            width: 120, height: 120, borderRadius: 28,
            background: imageMode === 'photo' ? '#ECE4D8' : color,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            position: 'relative', overflow: 'hidden',
            boxShadow: '0 4px 16px rgba(0,0,0,0.06)',
          }}>
            {imageMode === 'photo' ? (
              <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', color: COLOR.ink3, gap: 4 }}>
                <Icon name="camera" size={32} strokeWidth={1.8}/>
                <span style={{ fontSize: 10, fontWeight: 600 }}>写真を追加</span>
              </div>
            ) : (
              <span style={{ fontSize: 64 }}>{emoji}</span>
            )}
          </div>
        </div>
      )}

      {/* 画像モード切替 */}
      {!existingProduct && (
        <div style={{ padding: '0 20px 16px', display: 'flex', gap: 6, justifyContent: 'center' }}>
          {[
            { id: 'emoji', label: '絵文字', icon: 'smile' },
            { id: 'icon',  label: 'アイコン', icon: 'image' },
            { id: 'photo', label: '写真',    icon: 'camera' },
          ].map(m => (
            <button key={m.id} onClick={() => setImageMode(m.id)} style={{
              padding: '6px 12px', borderRadius: 10, border: 'none',
              background: imageMode === m.id ? COLOR.ink : COLOR.card,
              color: imageMode === m.id ? '#fff' : COLOR.ink2,
              fontSize: 12, fontWeight: 600, cursor: 'pointer',
              display: 'flex', alignItems: 'center', gap: 5,
              fontFamily: '"Noto Sans JP"',
            }}>
              <Icon name={m.icon} size={13} strokeWidth={2}/>
              {m.label}
            </button>
          ))}
        </div>
      )}

      {/* 絵文字ピッカー */}
      {!existingProduct && imageMode === 'emoji' && (
        <div style={{ padding: '0 16px 16px' }}>
          <div style={{
            background: COLOR.card, borderRadius: 14, padding: '10px 12px',
            display: 'grid', gridTemplateColumns: 'repeat(8, 1fr)', gap: 4,
          }}>
            {emojiChoices.map(e => (
              <button key={e} onClick={() => setEmoji(e)} style={{
                border: 'none', background: emoji === e ? COLOR.accentSoft : 'transparent',
                borderRadius: 8, cursor: 'pointer', aspectRatio: '1/1', fontSize: 20,
              }}>{e}</button>
            ))}
          </div>
          <div style={{ padding: '12px 4px 0', display: 'flex', gap: 6 }}>
            {colorChoices.map(c => (
              <button key={c} onClick={() => setColor(c)} style={{
                width: 22, height: 22, borderRadius: '50%', border: 'none',
                background: c, cursor: 'pointer',
                outline: color === c ? `2px solid ${COLOR.ink}` : 'none',
                outlineOffset: 2,
              }}/>
            ))}
          </div>
        </div>
      )}

      {/* 商品既存の場合のヘッダー */}
      {existingProduct && (
        <div style={{ padding: '12px 20px 16px', display: 'flex', gap: 14, alignItems: 'center' }}>
          <ProductThumb product={existingProduct} size={56}/>
          <div>
            <div style={{ fontSize: 16, fontWeight: 700, color: COLOR.ink, fontFamily: '"Noto Sans JP"' }}>
              {existingProduct.name}
            </div>
            <div style={{ fontSize: 12, color: COLOR.ink2 }}>{existingProduct.detail}</div>
          </div>
        </div>
      )}

      {/* フォーム */}
      <div style={{ padding: '0 16px' }}>
        {/* 商品情報 */}
        {!existingProduct && (
          <FormSection title="商品情報">
            <FormField label="商品名" required>
              <input value={name} onChange={e => setName(e.target.value)} placeholder="例: たまご"
                style={inputStyle}/>
            </FormField>
            <FormField label="詳細（容量など）">
              <input value={detail} onChange={e => setDetail(e.target.value)} placeholder="例: 10個入り / 170g"
                style={inputStyle}/>
            </FormField>
            <FormField label="カテゴリ">
              <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
                {CATEGORIES.filter(c => c.id !== 'all').map(c => (
                  <CategoryChip key={c.id} cat={c} active={category === c.id}
                    onClick={() => setCategory(c.id)} compact/>
                ))}
              </div>
            </FormField>
            <FormField label="単位">
              <div style={{ display: 'flex', gap: 8 }}>
                {[{id:'count', label:'個数', icon:'🔢'},{id:'weight', label:'重さ(g)', icon:'⚖️'}].map(u => (
                  <button key={u.id} onClick={() => setUnitType(u.id)} style={{
                    flex: 1, padding: '10px', borderRadius: 12, border: 'none',
                    background: unitType === u.id ? COLOR.ink : COLOR.card,
                    color: unitType === u.id ? '#fff' : COLOR.ink2,
                    fontSize: 13, fontWeight: 700, cursor: 'pointer',
                    display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
                    fontFamily: '"Noto Sans JP"',
                  }}>
                    <span>{u.icon}</span> {u.label}
                  </button>
                ))}
              </div>
            </FormField>
          </FormSection>
        )}

        {/* 購入情報 */}
        <FormSection title="購入情報">
          <FormField label={`${unitType === 'weight' ? '重さ' : '数量'}`} required>
            <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
              <input type="number" value={qty} onChange={e => setQty(e.target.value)}
                style={{ ...inputStyle, flex: 1 }}/>
              <div style={{
                padding: '10px 14px', background: COLOR.chipBg, borderRadius: 10,
                fontSize: 13, fontWeight: 700, color: COLOR.ink2, minWidth: 40, textAlign: 'center',
                fontFamily: '"Noto Sans JP"',
              }}>
                {unitType === 'weight' ? 'g' : '個'}
              </div>
            </div>
          </FormField>

          <FormField label="価格（税抜）" required>
            <PriceInput value={price} onChange={setPrice}/>
          </FormField>
          <FormField label="価格（税込）" required>
            <PriceInput value={priceTax} onChange={setPriceTax} highlight/>
          </FormField>

          <FormField label="店舗" required>
            <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
              {STORES.map(s => (
                <button key={s} onClick={() => setStore(s)} style={{
                  padding: '8px 12px', borderRadius: 999, border: 'none',
                  background: store === s ? COLOR.ink : COLOR.card,
                  color: store === s ? '#fff' : COLOR.ink2,
                  fontSize: 12, fontWeight: 600, cursor: 'pointer',
                  display: 'flex', alignItems: 'center', gap: 6,
                  fontFamily: '"Noto Sans JP"',
                }}>
                  <StoreDot store={s}/> {s}
                </button>
              ))}
            </div>
          </FormField>

          <FormField label="購入日">
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, ...inputStyle }}>
              <Icon name="calendar" size={16} color={COLOR.ink3}/>
              <input type="date" value={date} onChange={e => setDate(e.target.value)} style={{
                flex: 1, border: 'none', outline: 'none', background: 'transparent',
                fontSize: 14, color: COLOR.ink, fontFamily: '"Noto Sans JP"',
              }}/>
            </div>
          </FormField>
        </FormSection>

        {/* 単価プレビュー */}
        {price && qty && Number(qty) > 0 && (
          <div style={{
            margin: '0 4px 20px', padding: 14, borderRadius: 14,
            background: COLOR.accentSoft, display: 'flex', alignItems: 'center', gap: 12,
          }}>
            <div style={{
              width: 36, height: 36, borderRadius: 10, background: '#fff',
              display: 'flex', alignItems: 'center', justifyContent: 'center', color: COLOR.accent,
            }}>
              <Icon name="yen" size={18}/>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 11, color: COLOR.ink2, fontWeight: 600 }}>
                {unitType === 'weight' ? '100gあたり' : '1個あたり'}
              </div>
              <Price value={Math.round(Number(priceTax || price) / Number(qty) * (unitType === 'weight' ? 100 : 1))}
                size={20} color={COLOR.accentDeep}/>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

const inputStyle = {
  width: '100%', padding: '12px 14px', borderRadius: 12, border: 'none',
  background: COLOR.card, fontSize: 14, color: COLOR.ink, outline: 'none',
  fontFamily: '"Noto Sans JP", system-ui', boxSizing: 'border-box',
  boxShadow: '0 1px 2px rgba(0,0,0,0.03)',
};

function FormSection({ title, children }) {
  return (
    <div style={{ marginBottom: 20 }}>
      <div style={{ fontSize: 11, fontWeight: 700, color: COLOR.ink2, padding: '0 4px 10px', letterSpacing: 0.5 }}>
        {title}
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        {children}
      </div>
    </div>
  );
}

function FormField({ label, required, children }) {
  return (
    <div>
      <div style={{ fontSize: 12, fontWeight: 600, color: COLOR.ink2, marginBottom: 6, paddingLeft: 4 }}>
        {label} {required && <span style={{ color: COLOR.accent }}>*</span>}
      </div>
      {children}
    </div>
  );
}

function PriceInput({ value, onChange, highlight }) {
  return (
    <div style={{
      ...inputStyle,
      display: 'flex', alignItems: 'center', gap: 8,
      background: highlight ? '#FFF8F4' : COLOR.card,
      border: highlight ? `1px solid ${COLOR.accentSoft}` : 'none',
    }}>
      <span style={{ fontSize: 16, color: COLOR.ink3, fontWeight: 600 }}>¥</span>
      <input
        type="number" inputMode="numeric" value={value}
        onChange={e => onChange(e.target.value)}
        placeholder="0"
        style={{
          flex: 1, border: 'none', outline: 'none', background: 'transparent',
          fontSize: 18, fontWeight: 700, color: COLOR.ink,
          fontFamily: '"Noto Sans JP", system-ui',
        }}
      />
      <span style={{ fontSize: 13, color: COLOR.ink3, fontWeight: 600 }}>円</span>
    </div>
  );
}

Object.assign(window, { AddScreen });
