# Parametric-Light-Matrix
使用 Processing 建立參數化燈光模擬系統，透過參數探索光在空間中的節奏、流動與聚合型態。

# Light_Time

## 執行環境

- Processing 4.x（建議）
- 無需額外安裝 Library
- 建議螢幕解析度 ≥ 800×300

## 核心流程

1. 使用 `PGraphics` 將文字繪製成離螢幕影像
2. 讀取文字影像的 pixel 資料
3. 以單一垂直掃描柱（scanX）逐步掃描畫面
4. 只在掃描柱位置顯示 LED 點
5. 透過掃描移動，讓人眼拼接成完整文字<br><br><br>

# 2Dsimulation

## 執行環境

- Processing 4.x（建議）
- 無需額外安裝 Library
- 使用預設 Renderer 或 P2D 即可

## 燈光資料結構

- `numLights`：燈柱數量（預設 20 根）
- `numSegments`：每根燈柱的垂直 pixel 數
- `brightness[i][s]`：
  - `i`：第 i 根燈
  - `s`：該燈第 s 個 pixel
  - 值域：0 ～ 100（亮度）

## 目前支援的排列方式

| 排列名稱 | 說明 |
|--------|----|
| Center | 燈由中心向外排列，聚焦中心 |
| Outward | 從中心向外擴散排列 |
| Parallel | 燈柱彼此平行，形成平面矩陣 |
| Radiation | 以中心為原點的放射排列 |
| Ring | 燈柱沿圓環排列 |
| Same_side | 所有燈集中於同一側 |
| Vertical_circle | 每根燈自身形成垂直圓形結構 |

## 燈光效果

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

## 操作方式

1. 啟動 Processing 程式
2. 在畫面左上角輸入文字
3. 按下 Enter
4. 系統會依關鍵字切換燈光效果
5. 畫面會顯示目前模式名稱<br><br><br>

# 3Dsimulation

## 執行環境

- Processing 4.x
- Renderer：`P3D`（必要）
- 無需額外 Library
- 建議解析度：900 × 480 以上

## 燈光資料結構

- `numLights`：燈柱數量（預設 20 根）
- `numSegments`：每根燈柱上的 pixel 分段數
- `brightness[i][s]`：
  - `i`：第 i 根燈
  - `s`：該燈第 s 個垂直 pixel
  - 值域：0～100（亮度）

## 目前支援的排列方式

可透過 **鍵盤數字鍵 1～7** 切換排列方式：

| Key | Layout 名稱 | 說明 |
|----|------------|----|
| 1 | Parallel | 一字排（平行直立燈柱） |
| 2 | Ring | 240° 直立圓弧排列 |
| 3 | Radiation | 240° 外傾 45° 放射圓弧 |
| 4 | Same_side | 240° 括號形貝茲曲線 |
| 5 | Center | 貝茲曲線（沿半徑外開） |
| 6 | Outward | 貝茲曲線（+rx / +rz 外張） |
| 7 | Vertical_circle | 每根燈自身形成垂直圓環 |

## 燈光效果

使用者可透過 **輸入文字 + Enter** 切換燈光效果：

| 效果名稱 | 關鍵字 | 說明 |
|-------|------|----|
| CALM | calm / 平靜 | 整體同步呼吸 |
| WAVE | wave / 波浪 | 沿 index 流動的波形 |
| TENSE | tense / 緊張 | 閃爍、不穩定跳動 |
| EXPAND | expand / 擴張 | 從中心向外擴散 |
| WIND | wind / 風 | 帶狀掃過的流動 |
| FREEDOM | free / freedom / 自由 | 粒子般漂流 |
| SEEK | seek / 追尋 | 一束光來回搜尋 |
| CLOCKWISE | clockwise / cw / 順時針 | 沿圓順時針跑動 |
| COUNTERCLOCKWISE | ccw / 逆時針 | 反方向跑動 |
| LOOKUP | lookup / up / 仰望 | 從下往上點亮 |
| LOOKDOWN | lookdown / down / 俯視 | 從上往下點亮 |
| WAKE | wake / 甦醒 | 燈一支支被喚醒 |
| BROKEN | broken / 破碎 | 隨機啟動與碎裂流動 |

## 操作方式總覽

### 鍵盤操作

- **輸入文字 + Enter**：切換燈光效果
- **1～7**：切換排列方式
- **方向鍵 ↑ ↓ ← →**：旋轉視角

---

### 滑鼠操作（相機控制）

- **滑鼠拖曳**：旋轉 3D 視角
- **滑鼠滾輪**：縮放鏡頭（Zoom）

---

## 視覺與座標說明

- 使用 `P3D` 模式繪製
- 燈條以 **sphere** 模擬 LED pixel
- 地板為 XZ 平面
- Y 軸為高度方向
- 相機可自由旋轉與縮放，用於觀察空間結構
