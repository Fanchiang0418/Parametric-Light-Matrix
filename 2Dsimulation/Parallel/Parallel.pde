int numLights = 20;        // 燈的數量（沿圓一圈）
float stageMargin = 80;    // 舞台左右預留空間
float lightWidth = 6;      // 每顆 pixel 在射線上的最大直徑
float lightHeight = 100;   // 每根燈柱的長度（沿射線方向）
int numSegments = 10;      // 每條燈切成幾個 pixel
float[][] brightness;      // brightness[i][s]：第 i 根燈、第 s 格的亮度

// ====== 燈光語言相關變數 ======
int effectMode = 0;          // 0~10：各種燈光語言
String inputText = "";       // 使用者輸入的字串

// ====================== setup / draw ======================

void setup() {
  size(900, 480);                 
  colorMode(HSB, 360, 100, 100);  
  rectMode(CENTER);
  textAlign(LEFT, TOP);
  textSize(16);

  brightness = new float[numLights][numSegments];
  
  // 初始亮度（之後會被 updateLights 覆蓋）
  for (int i = 0; i < numLights; i++) {
    for (int s = 0; s < numSegments; s++) {
      brightness[i][s] = 40;  
    }
  }
}

void draw() {
  background(0);
  updateLights();    // 根據 effectMode 更新亮度
  drawLights();      // 畫出圓形放射的 pixel
  drawUI();          // 顯示輸入文字 & 目前模式
}

// 畫舞台區域（只是視覺上的邊界）
void drawStage() {
  noFill();
  stroke(180);
  strokeWeight(2);

  float stageLeft   = stageMargin;
  float stageRight  = width - stageMargin;
  float stageTop    = 80;
  float stageBottom = height - 80;

  // 白色長方形（舞台外框）
  rectMode(CORNERS);
  rect(stageLeft, stageTop, stageRight, stageBottom);

  // ========= 四個角往外拉斜線 =========
  float len = 80;  // 斜線長度
  stroke(80);

  // 左上角
  line(stageLeft, stageTop, stageLeft - len, stageTop - len);
  // 右上角
  line(stageRight, stageTop, stageRight + len, stageTop - len);
  // 左下角
  line(stageLeft, stageBottom, stageLeft - len, stageBottom + len);
  // 右下角
  line(stageRight, stageBottom, stageRight + len, stageBottom + len);
}

// ====================== 燈光效果分流 ======================

void updateLights() {
  if (effectMode == 0) {
    updateCalm();            // 平靜
  } else if (effectMode == 1) {
    updateWave();            // 波浪
  } else if (effectMode == 2) {
    updateTense();           // 緊張
  } else if (effectMode == 3) {
    updateExpand();          // 擴張
  } else if (effectMode == 4) {
    updateWind();            // 風
  } else if (effectMode == 5) {
    updateFree();            // 自由
  } else if (effectMode == 6) {
    updateSeek();            // 追尋
  } else if (effectMode == 7) {
    updateClockwise();       // 順時針
  } else if (effectMode == 8) {
    updateCounterClockwise();// 逆時針
  } else if (effectMode == 9) {
    updateLookUp();          // 仰望
  } else if (effectMode == 10) {
    updateLookDown();        // 俯視
  } else if (effectMode == 11) {
    updateWake();            // 甦醒
  }
    else if (effectMode == 12) {
    updateBroken();          // 破碎
  }
}

// ====================== 各種效果 ======================

// 0. 平靜：整體緩慢呼吸
void updateCalm() {
  float t = frameCount * 0.02;
  float base = map(sin(t), -1, 1, 30, 80);  // 整體亮度

  for (int i = 0; i < numLights; i++) {
    for (int s = 0; s < numSegments; s++) {
      float offset = (i + s) * 0.1;
      brightness[i][s] = constrain(base + 5 * sin(t + offset), 0, 100);
    }
  }
}

// 1. 波浪：沿 index 有流動感
void updateWave() {
  float t = frameCount * 0.08;
  for (int i = 0; i < numLights; i++) {
    float phaseX = i * 0.6;
    for (int s = 0; s < numSegments; s++) {
      float phaseY = s * 0.25;
      float v = sin(t + phaseX + phaseY);          // -1 ~ 1
      brightness[i][s] = map(v, -1, 1, 10, 100);
    }
  }
}

// 2. 緊張：隨機跳動＋閃爍
void updateTense() {
  float t = frameCount * 0.3;
  for (int i = 0; i < numLights; i++) {
    for (int s = 0; s < numSegments; s++) {
      float noiseVal = noise(i * 0.3, s * 0.4, t * 0.1);
      float flicker = (frameCount % 5 == 0) ? 100 : 40;
      brightness[i][s] = map(noiseVal, 0, 1, 20, flicker);
    }
  }
}

// 3. 擴張：從中間往兩側擴散
void updateExpand() {
  float t = frameCount * 0.04;

  float centerIndex = (numLights - 1) / 2.0;
  float maxRadius = numLights / 2.0 + 1;
  float radius = map(sin(t), -1, 1, 0, maxRadius);

  for (int i = 0; i < numLights; i++) {
    float dist = abs(i - centerIndex);

    for (int s = 0; s < numSegments; s++) {
      float edgeDiff = abs(dist - radius);
      float v = map(edgeDiff, 0, maxRadius, 100, 10);
      v = constrain(v, 10, 100);

      float heightFactor = map(s, 0, numSegments - 1, 1.0, 0.7);
      brightness[i][s] = v * heightFactor;
    }
  }
}

// 4. 風：像一陣一陣風從側面掃過去
void updateWind() {
  float t = frameCount * 0.03;

  float bandCenter = map(sin(t * 0.7), -1, 1, -2, numLights + 1);
  float bandWidth = 3.0;

  for (int i = 0; i < numLights; i++) {
    for (int s = 0; s < numSegments; s++) {
      float n = noise(i * 0.25 + t * 0.4, s * 0.15);
      float base = map(n, 0, 1, 15, 60);

      float dist = abs(i - bandCenter);
      float gust = map(dist, 0, bandWidth, 40, 0);
      if (gust < 0) gust = 0;

      float heightFactor = map(s, 0, numSegments - 1, 1.0, 0.5);

      brightness[i][s] = constrain((base + gust) * heightFactor, 0, 100);
    }
  }
}

// 5. 自由：像光粒子自由漂流
void updateFree() {
  float t = frameCount * 0.015;

  float xSpeed = 0.006;
  float ySpeed = 0.009;
  float zSpeed = 0.0025;

  for (int i = 0; i < numLights; i++) {
    for (int s = 0; s < numSegments; s++) {
      float nx = i * 0.22 + t * xSpeed * 150;
      float ny = s * 0.35 + t * ySpeed * 150;
      float nz = t * zSpeed * 300;

      float n = noise(nx, ny, nz);
      float base = map(n, 0, 1, 10, 100);

      float drift = sin(t + s * 0.8 + i * 0.3) * 10;

      brightness[i][s] = constrain(base + drift, 5, 100);
    }
  }
}

// 6. 追尋：一束光沿 index 來回掃描
void updateSeek() {
  float t = frameCount * 0.04;

  float seeker = map(sin(t), -1, 1, 0, numLights - 1);
  float beamWidth = 2.5;

  for (int i = 0; i < numLights; i++) {
    float dist = abs(i - seeker);

    for (int s = 0; s < numSegments; s++) {
      float edge = map(dist, 0, beamWidth, 100, 5);
      edge = constrain(edge, 5, 100);

      float heightFactor = map(s, 0, numSegments - 1, 1.0, 0.6);

      float jitter = 0;
      if (dist < beamWidth * 0.7) {
        float jNoise = noise(i * 0.3, s * 0.5, t * 3.0);
        jitter = map(jNoise, 0, 1, -10, 10);
      }

      float bri = edge * heightFactor + jitter;
      brightness[i][s] = constrain(bri, 0, 100);
    }
  }
}

// 7. 順時針跑動：一顆沿圓順時針跑，有尾巴
void updateClockwise() {
  // 跑動速度
  float speed = 0.4;  

  // 頭部位置（逆時針 = 正向遞增）
  float head = (frameCount * speed) % numLights;

  // 光束寬度（包含頭＋尾巴）
  float beamWidth = 3.5;

  for (int i = 0; i < numLights; i++) {

    // wrap-around 距離（從 0 跑到 numLights 再回 0）
    float diff = abs(i - head);
    float dist = min(diff, numLights - diff);

    for (int s = 0; s < numSegments; s++) {

      // 距離越近越亮
      float v = map(dist, 0, beamWidth, 100, 5);
      v = constrain(v, 5, 100);

      // segment 高度影響（下面亮，上面暗）
      float heightFactor = map(s, 0, numSegments - 1, 1.0, 0.6);

      brightness[i][s] = v * heightFactor;
    }
  }
}

// 8. 逆時針跑動
void updateCounterClockwise() {
  // 一圈跑動的速度（越大越快）
  float speed = 0.4;   // 每 frame 前進的「燈數」、速度

  // 計算順時針方向的「頭部」位置（float，可以在 index 之間）
  float steps = (frameCount * speed) % numLights;     // 0 ~ numLights
  float head  = (numLights - 1) - steps;              // 反向 → 順時針

  // 光束寬度（包含頭＋尾巴）
  float beamWidth = 3.5;

  for (int i = 0; i < numLights; i++) {
    // 考慮繞圈的最短距離（0 左右要接起來）
    float diff = abs(i - head);
    float dist = min(diff, numLights - diff); // wrap-around 距離

    for (int s = 0; s < numSegments; s++) {
      // 距離 head 越近越亮，越遠越暗
      float v = map(dist, 0, beamWidth, 100, 5);
      v = constrain(v, 5, 100);

      // 高度因素：下面亮、上面暗一點（像貼著地面跑的光）
      float heightFactor = map(s, 0, numSegments - 1, 1.0, 0.6);

      brightness[i][s] = v * heightFactor;

    }
  }
}

// 9. 仰望：從最底 pixel 一路往上灌滿
void updateLookUp() {
  float speed = 0.12;
  float level = (frameCount * speed) % (numSegments + 1);   // 0 ~ numSegments

  for (int i = 0; i < numLights; i++) {
    for (int s = 0; s < numSegments; s++) {
      float bri;

      if (s <= level) {
        float edge = abs(s - level);
        bri = map(edge, 0, 1.5, 100, 70);
      } else {
        bri = 5;
      }

      brightness[i][s] = constrain(bri, 0, 100);
    }
  }
}

// 10. 俯視：從最頂端往下亮到最底（仰望相反）
void updateLookDown() {
  float speed = 0.12;
  float level = (frameCount * speed) % (numSegments + 1);

  for (int i = 0; i < numLights; i++) {
    for (int s = 0; s < numSegments; s++) {
      float bri;
      int topIndex = numSegments - 1 - s;

      if (topIndex <= level) {
        float edge = abs(topIndex - level);
        bri = map(edge, 0, 1.5, 100, 70);
      } else {
        bri = 5;
      }

      brightness[i][s] = constrain(bri, 0, 100);
    }
  }
}

// 11. 甦醒：LED 燈一支支隨機亮起 → 全亮 → 歸零 → 重來
void updateWake() {
  // 每「一支」負責的時間長度（用 frame 數控制快慢）
  float phaseFrames = 30.0;         // 越大越慢，越小越快
  float allOnFrames = phaseFrames * numLights; // 全部亮完的時間
  float pauseFrames = 40.0;         // 全亮後黑回去的停頓時間

  float cycleFrames = allOnFrames + pauseFrames;
  float t = frameCount % cycleFrames;  // t 在 0 ~ cycleFrames 循環

  // 先做一個固定亂數的順序（每輪順序一樣，不抖動）
  randomSeed(9999);
  int[] order = new int[numLights];
  for (int i = 0; i < numLights; i++) {
    order[i] = i;
  }
  // 洗牌（Fisher–Yates）
  for (int i = numLights - 1; i > 0; i--) {
    int r = int(random(i + 1));
    int tmp = order[i];
    order[i] = order[r];
    order[r] = tmp;
  }

  // 逐支燈處理
  for (int k = 0; k < numLights; k++) {

    // 找出這一支燈在順序中的 rank（第幾個被喚醒）
    int rank = 0;
    for (int i = 0; i < numLights; i++) {
      if (order[i] == k) {
        rank = i;
        break;
      }
    }

    // 這支燈的 fade-in 區間 [start, end)
    float start = rank * phaseFrames;
    float end   = start + phaseFrames;

    float bri;  // 這支燈此刻的亮度（0~100）

    if (t < start) {
      // 還沒輪到它：保持暗
      bri = 5;
    } else if (t < end) {
      // 正在從暗 → 亮 的階段
      float p = (t - start) / phaseFrames;   // 0 ~ 1
      bri = map(p, 0, 1, 5, 100);
    } else if (t < allOnFrames) {
      // 已經亮完，但別的還在排隊：保持全亮
      bri = 100;
    } else {
      // 全亮後的 pause：全部回到暗
      bri = 5;
    }

    // 把這支燈「整條」都設成同樣亮度
    for (int s = 0; s < numSegments; s++) {
      brightness[k][s] = bri;
    }
  }
}

// 12. 破碎：
void updateBroken() {

  // 有幾根燈已經被「啟動」了（0 ~ numLights）
  float speedStep = 0.2;                     // 啟動速度（越大越快有更多根加入）
  int step = int(frameCount * speedStep) % (numLights + 1);

  // 做一個固定亂數的啟動順序（每次動畫一樣，不會抖來抖去）
  randomSeed(9999);
  int[] order = new int[numLights];
  for (int i = 0; i < numLights; i++) order[i] = i;

  // Fisher–Yates 洗牌
  for (int i = numLights - 1; i > 0; i--) {
    int r = int(random(i + 1));
    int tmp = order[i];
    order[i] = order[r];
    order[r] = tmp;
  }

  // 跑馬參數
  float runSpeed = 0.15;   // 跑馬燈沿著一根燈柱往上的速度
  float tailLen  = 2.0;    // 尾巴長度（越大尾巴越長）

  // 逐根燈處理
  for (int k = 0; k < numLights; k++) {

    // 這一根有沒有「被啟動」？
    // 以及它在啟動順序中的 rank（第幾個被啟動）
    boolean active = false;
    int rank = -1;
    for (int t = 0; t < step; t++) {
      if (order[t] == k) {
        active = true;
        rank = t;
        break;
      }
    }

    if (!active) {
      // 還沒被啟動：整根都很暗
      for (int s = 0; s < numSegments; s++) {
        brightness[k][s] = 5;
      }
      continue;
    }

    // 已被啟動：在這一根燈柱上跑一顆流水燈
    // head 代表「亮點」目前跑到第幾個 segment（0 在最底）
    float head = (frameCount * runSpeed + rank * 0.5) % (numSegments + tailLen);

    for (int s = 0; s < numSegments; s++) {
      float dist = abs(s - head);

      float bri;
      if (dist <= tailLen) {
        // 距離 head 越近越亮，越遠越暗
        bri = map(dist, 0, tailLen, 100, 20);
      } else {
        bri = 5;
      }

      brightness[k][s] = constrain(bri, 0, 100);
    }
  }
}


// ====================== 畫圓形放射 pixel ======================

void drawLights() {
  ellipseMode(CENTER);
  noStroke();

  float stageLeft   = stageMargin;
  float stageRight  = width - stageMargin;
  float stageTop    = 80;
  float stageBottom = height - 80;

  float segmentHeight = lightHeight / numSegments;
  float usableWidth = (stageRight - stageLeft) - lightWidth;

  // 圓的直徑：用每格寬、高裡比較小的那個，乘以 0.8 留一點空隙
  float dotDiameter = min(lightWidth, segmentHeight) * 0.6;

  for (int i = 0; i < numLights; i++) {

    // 計算每條燈 x 的位置（左右貼齊）
    float x;
    if (numLights == 1) {
      x = stageLeft + (stageRight - stageLeft) / 2.0;
    } else {
      x = stageLeft + lightWidth/2 + i * (usableWidth / (numLights - 1));
    }

    // 畫這一條燈的 N 個 segment
    for (int s = 0; s < numSegments; s++) {
      float bri = brightness[i][s];   // 每段自己的亮度值

      fill(0, 0, bri);   // 白光 (HSB: H=0, S=0, B=bri)

      // segment 的中心 y（從底部開始往上堆）
      float y = stageBottom - segmentHeight/2 - s * segmentHeight;

      // 改成畫圓
      ellipse(x, y, dotDiameter, dotDiameter);
    }
  }
}

// ====================== UI：輸入文字 & 顯示模式 ======================

void drawUI() {
  fill(180);
  text("Enter > " + inputText, 20, 20);

  String modeName = "";
  if (effectMode == 0) modeName = "CALM";
  else if (effectMode == 1) modeName = "WAVE";
  else if (effectMode == 2) modeName = "TENSE";
  else if (effectMode == 3) modeName = "EXPAND";
  else if (effectMode == 4) modeName = "WIND";
  else if (effectMode == 5) modeName = "FREEDOM";
  else if (effectMode == 6) modeName = "SEEK";
  else if (effectMode == 7) modeName = "CLOCKWISE";
  else if (effectMode == 8) modeName = "COUNTERCLOCKWISE";
  else if (effectMode == 9) modeName = "LOOKUP";
  else if (effectMode == 10) modeName = "LOOKDOWN";
  else if (effectMode == 11) modeName = "WAKE";
  else if (effectMode == 12) modeName = "BROKEN";

  text("Current > " + modeName, 20, 40);
}

// ====================== 文字輸入 → 燈光字典 ======================

void keyPressed() {
  // Enter：分析輸入字串，切換燈光模式
  if (key == ENTER || key == RETURN) {
    String word = inputText.trim();
    applyKeyword(word);
    inputText = "";             // 清空輸入
  } 
  // Backspace：刪掉最後一個字
  else if (key == BACKSPACE) {
    if (inputText.length() > 0) {
      inputText = inputText.substring(0, inputText.length()-1);
    }
  } 
  // 一般字元：加到輸入字串後面（忽略特殊控制鍵）
  else if (key != CODED) {
    inputText += key;
  }
}

void applyKeyword(String word) {
  println("收到關鍵字：" + word);

  if (word.equals("平靜") || word.equalsIgnoreCase("calm")) {
    effectMode = 0;
  } 
  else if (word.equals("波浪") || word.equalsIgnoreCase("wave")) {
    effectMode = 1;
  } 
  else if (word.equals("緊張") || word.equalsIgnoreCase("tense")) {
    effectMode = 2;
  }
  else if (word.equals("擴張") || word.equalsIgnoreCase("expand")) {
    effectMode = 3;
  }
  else if (word.equals("風") || word.equalsIgnoreCase("wind")) {  
    effectMode = 4;
  }
  else if (word.equals("自由") || word.equalsIgnoreCase("freedom") || word.equalsIgnoreCase("free")) {
    effectMode = 5;
  }
  else if (word.equals("追尋") || word.equalsIgnoreCase("seek") || word.equalsIgnoreCase("search")) {
    effectMode = 6;   
  }
  else if (word.equals("順時針") || word.equalsIgnoreCase("clockwise") || word.equalsIgnoreCase("cw")) {
    effectMode = 7;
  }
  else if (word.equals("逆時針") || word.equalsIgnoreCase("counterclockwise") || word.equalsIgnoreCase("ccw")) {
    effectMode = 8;
  }
  else if (word.equals("仰望") || word.equalsIgnoreCase("lookup")  || word.equalsIgnoreCase("up")) {
    effectMode = 9;
  }
  else if (word.equals("俯視") || word.equals("俯瞰") || word.equalsIgnoreCase("lookdown") || word.equalsIgnoreCase("descend") || word.equalsIgnoreCase("down")) {
    effectMode = 10;
  }
  else if (word.equals("萌發") || word.equals("甦醒") || word.equalsIgnoreCase("germinate") || word.equalsIgnoreCase("init") || word.equalsIgnoreCase("spark") || word.equalsIgnoreCase("wake")) {
    effectMode = 11; 
  }
  else if (word.equals("破碎") || word.equalsIgnoreCase("broken")) {
    effectMode = 12; 
  }
  else {
    println("這個字還沒有對應的燈光語言，可以之後加進來。");
  }
}
