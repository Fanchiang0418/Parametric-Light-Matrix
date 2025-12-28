# Parametric-Light-Matrix
使用 Processing 建立參數化燈光模擬系統，透過參數探索光在空間中的節奏、流動與聚合型態。

## 執行環境

- Processing 4.x（建議）
- 無需額外安裝 Library
- 使用預設 Renderer 或 P2D 即可

---

## 系統架構說明

### 燈光資料結構

- `numLights`：燈柱數量（預設 20 根）
- `numSegments`：每根燈柱的垂直 pixel 數
- `brightness[i][s]`：
  - `i`：第 i 根燈
  - `s`：該燈第 s 個 pixel
  - 值域：0 ～ 100（亮度）

---

### 架構設計重點（重要）

本系統採用 **「排列（Layout）× 效果（Effect）」分離設計**：

- **排列（Layout）**
  - 決定燈在空間中的幾何位置
  - 只影響繪製方式（draw）
- **效果（Effect）**
  - 決定亮度如何隨時間變化
  - 使用相同的 brightness matrix

👉 更換排列方式時，**所有燈光效果完全共用，不需修改效果邏輯**

---

## 目前支援的排列方式（Layout）

> 以下排列 **只影響燈的空間分布方式**，  
> 所有燈光效果（CALM / WAVE / SEEK…）在各排列下行為相同。

| 排列名稱 | 說明 |
|--------|----|
| Center | 燈由中心向外排列，聚焦中心 |
| Outward | 從中心向外擴散排列 |
| Parallel | 燈柱彼此平行，形成平面矩陣 |
| Radiation | 以中心為原點的放射排列 |
| Ring | 燈柱沿圓環排列 |
| Same_side | 所有燈集中於同一側 |
| Vertical_circle | 每根燈自身形成垂直圓形結構 |

---

## 燈光效果（Effect Mode）

使用者可透過 **鍵盤輸入文字 + Enter** 切換燈光語意效果。

| 模式名稱 | 關鍵字 | 說明 |
|-------|------|----|
| CALM | calm / 平靜 | 整體緩慢呼吸 |
| WAVE | wave / 波浪 | 沿 index 流動的波形 |
| TENSE | tense / 緊張 | 閃爍、不穩定跳動 |
| EXPAND | expand / 擴張 | 從中心向外擴散 |
| WIND | wind / 風 | 成帶狀掃過 |
| FREEDOM | free / freedom / 自由 | 粒子般自由漂移 |
| SEEK | seek / 追尋 | 一束光來回搜尋 |
| CLOCKWISE | clockwise / cw / 順時針 | 沿圓順時針跑動 |
| COUNTERCLOCKWISE | ccw / 逆時針 | 反向跑動 |
| LOOKUP | lookup / up / 仰望 | 從下往上點亮 |
| LOOKDOWN | lookdown / down / 俯視 | 從上往下點亮 |
| WAKE | wake / 甦醒 | 燈一支支被喚醒 |
| BROKEN | broken / 破碎 | 隨機啟動與碎裂跑動 |

---

## 操作方式

1. 啟動 Processing 程式
2. 在畫面左上角輸入文字
3. 按下 Enter
4. 系統會依關鍵字切換燈光效果
5. 畫面會顯示目前模式名稱

---

## 設計理念

- 將燈光視為 **矩陣化資料（brightness matrix）**
- 分離空間結構（排列）與時間行為（效果）
- 便於擴充與重組不同燈光語言
- 可對應實體燈具或外部控制系統

---

## 未來擴充方向

- 語言／文字語意 → 自動對應燈光效果
- MIDI / 音訊 / 感測器控制
- 將亮度矩陣輸出至實體燈具
- 新增更多排列與語意效果
