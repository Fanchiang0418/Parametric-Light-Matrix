import processing.event.MouseEvent;  // 滾輪用

// ====== 基本參數 ======
int numLights = 20;        // 燈的數量（沿圓一圈）
float stageMargin = 80;    // 舞台左右預留空間
float lightWidth = 6;      // 每顆 pixel 在射線上的最大直徑
float lightHeight = 100;   // 每根燈柱的長度（沿射線方向）
int numSegments = 10;      // 每條燈切成幾個 pixel
float[][] brightness;      // brightness[i][s]：第 i 根燈、第 s 格的亮度
float groundY;             // 地板高度 & 燈條腳底高度

// ====== 相機控制 ======
float camRotX = -PI/6.0;  // 一開始稍微往後仰
float camRotY = 0;        // 左右旋轉
boolean isDragging = false;
int lastMouseX, lastMouseY;
float camZoom = 1.0;      // 鏡頭縮放倍率（1 = 原始大小）

// ====== 燈光語言相關變數 ======
int effectMode = 0;       // 0~12：各種燈光語言
String inputText = "";    // 使用者輸入的字串

// ====== 排列方式相關變數 ======
// 0: 一字排
// 1: 240° 直立圓弧
// 2: 240° 45° 外傾圓弧
// 3: 240° 括號形貝茲弧線
// 4: 240° 括號形（沿半徑外開）
// 5: 240° 括號（沿半徑外開 +rx/+rz）
// 6: 240° 每根自己繞一圈的圓環
int layoutMode = 0;

// ====================== setup / draw ======================
void setup() {
  size(900, 480, P3D);          // 一定要 P3D 才能畫 sphere
  colorMode(HSB, 360, 100, 100);  
  rectMode(CENTER);
  textAlign(LEFT, TOP);
  textSize(16);

  groundY = height - 180;   // 地板 / 燈條腳底高度
  brightness = new float[numLights][numSegments];
  for (int i = 0; i < numLights; i++) {
    for (int s = 0; s < numSegments; s++) {
      brightness[i][s] = 40;  
    }
  }
}

void draw() {
  background(0);
  updateLights();            // 更新亮度

  noLights();                // 不用系統光源，維持純白球
  colorMode(HSB, 360, 100, 100);

  pushMatrix();
  // 先把舞台移到畫面偏下，像觀眾視角
  translate(width/2, height*0.65, 0);

  // 縮放：越大越近、越小越遠
  scale(camZoom);

  // 相機旋轉
  rotateX(camRotX);
  rotateY(camRotY);

  // 把座標系移回去，讓 drawLights* 用 0~width,0~height 的邏輯
  translate(-width/2, -height/2, 0);

  // 先畫地板，再畫燈
  drawFloor(g, groundY);

  // 依 layoutMode 選排列方式
  if (layoutMode == 0) {
    drawLightsLine(g);          // 一字排
  } else if (layoutMode == 1) {
    drawLightsArc(g);           // 240° 直立圓弧
  } else if (layoutMode == 2) {
    drawLightsArcTilt(g);       // 240° 45° 外傾圓弧
  } else if (layoutMode == 3) {
    drawLightsArcCurve(g);      // 240° 括號形貝茲弧線（新）
  } else if (layoutMode == 4) {
  drawLightsArcCurveRadial(g); // 沿半徑方向彎出去
  } else if (layoutMode == 5) {
  drawLightsArcCurveRadial2(g);   // drawLights3D
  } else if (layoutMode == 6) {
  drawLightsArcRing(g);   // 圓環版
  }

  popMatrix();
  
  // UI 疊在最上層
  hint(DISABLE_DEPTH_TEST);
  drawUI();
  hint(ENABLE_DEPTH_TEST);
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
  } else if (effectMode == 12) {
    updateBroken();          // 破碎
  }
}

// ====================== 各種效果（原樣保留） ======================

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
  float speed = 0.4;  
  float head = (frameCount * speed) % numLights;
  float beamWidth = 3.5;

  for (int i = 0; i < numLights; i++) {
    float diff = abs(i - head);
    float dist = min(diff, numLights - diff);

    for (int s = 0; s < numSegments; s++) {
      float v = map(dist, 0, beamWidth, 100, 5);
      v = constrain(v, 5, 100);

      float heightFactor = map(s, 0, numSegments - 1, 1.0, 0.6);
      brightness[i][s] = v * heightFactor;
    }
  }
}

// 8. 逆時針跑動
void updateCounterClockwise() {
  float speed = 0.4;
  float steps = (frameCount * speed) % numLights;
  float head  = (numLights - 1) - steps;
  float beamWidth = 3.5;

  for (int i = 0; i < numLights; i++) {
    float diff = abs(i - head);
    float dist = min(diff, numLights - diff);

    for (int s = 0; s < numSegments; s++) {
      float v = map(dist, 0, beamWidth, 100, 5);
      v = constrain(v, 5, 100);

      float heightFactor = map(s, 0, numSegments - 1, 1.0, 0.6);
      brightness[i][s] = v * heightFactor;
    }
  }
}

// 9. 仰望：從最底 pixel 一路往上灌滿
void updateLookUp() {
  float speed = 0.12;
  float level = (frameCount * speed) % (numSegments + 1);

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
  float phaseFrames = 30.0;
  float allOnFrames = phaseFrames * numLights;
  float pauseFrames = 40.0;

  float cycleFrames = allOnFrames + pauseFrames;
  float t = frameCount % cycleFrames;

  randomSeed(9999);
  int[] order = new int[numLights];
  for (int i = 0; i < numLights; i++) order[i] = i;

  for (int i = numLights - 1; i > 0; i--) {
    int r = int(random(i + 1));
    int tmp = order[i];
    order[i] = order[r];
    order[r] = tmp;
  }

  for (int k = 0; k < numLights; k++) {
    int rank = 0;
    for (int i = 0; i < numLights; i++) {
      if (order[i] == k) {
        rank = i;
        break;
      }
    }

    float start = rank * phaseFrames;
    float end   = start + phaseFrames;

    float bri;
    if (t < start) {
      bri = 5;
    } else if (t < end) {
      float p = (t - start) / phaseFrames;
      bri = map(p, 0, 1, 5, 100);
    } else if (t < allOnFrames) {
      bri = 100;
    } else {
      bri = 5;
    }

    for (int s = 0; s < numSegments; s++) {
      brightness[k][s] = bri;
    }
  }
}

// 12. 破碎：
void updateBroken() {
  float speedStep = 0.2;
  int step = int(frameCount * speedStep) % (numLights + 1);

  randomSeed(9999);
  int[] order = new int[numLights];
  for (int i = 0; i < numLights; i++) order[i] = i;

  for (int i = numLights - 1; i > 0; i--) {
    int r = int(random(i + 1));
    int tmp = order[i];
    order[i] = order[r];
    order[r] = tmp;
  }

  float runSpeed = 0.15;
  float tailLen  = 2.0;

  for (int k = 0; k < numLights; k++) {

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
      for (int s = 0; s < numSegments; s++) {
        brightness[k][s] = 5;
      }
      continue;
    }

    float head = (frameCount * runSpeed + rank * 0.5) % (numSegments + tailLen);

    for (int s = 0; s < numSegments; s++) {
      float dist = abs(s - head);
      float bri;
      if (dist <= tailLen) {
        bri = map(dist, 0, tailLen, 100, 20);
      } else {
        bri = 5;
      }
      brightness[k][s] = constrain(bri, 0, 100);
    }
  }
}

// ====================== 燈條 + 地板 ======================

// 一字排燈條（按 1）
void drawLightsLine(PGraphics g) {
  g.noStroke();

  float stageLeft   = stageMargin;
  float stageRight  = g.width - stageMargin;
  float stageBottom = groundY;      // 燈條腳底高度 = 地板高度

  float segmentHeight = lightHeight / numSegments;
  float dotRadius = min(lightWidth, segmentHeight) * 0.4;

  for (int i = 0; i < numLights; i++) {

    float x;
    if (numLights == 1) {
      x = stageLeft + (stageRight - stageLeft) / 2.0;
    } else {
      float usableWidth = (stageRight - stageLeft) - lightWidth;
      x = stageLeft + lightWidth/2 + i * (usableWidth / (numLights - 1));
    }

    for (int s = 0; s < numSegments; s++) {
      float bri = brightness[i][s];

      g.fill(255 * (bri / 100.0));  

      // 第一顆球中心在 groundY 上方半個 segment
      float y = stageBottom - segmentHeight/2 - s * segmentHeight;

      g.pushMatrix();
      g.translate(x, y, 0);
      g.sphere(dotRadius);
      g.popMatrix();
    }
  }
}

// 240° 直立圓弧燈條（按 2）
void drawLightsArc(PGraphics g) {
  g.pushMatrix();
  g.noStroke();

  float stageLeft   = stageMargin;
  float stageRight  = g.width - stageMargin;

  float segmentHeight = lightHeight / numSegments;

  // 地板上的圓（XZ 平面）
  float centerX = (stageLeft + stageRight) / 2.0;
  float centerZ = 0;

  float maxRadiusX = (stageRight - stageLeft) / 2.0;
  float radius = maxRadiusX * 0.9;

  float dotRadius = min(lightWidth, segmentHeight) * 0.4;

  // 只有 240° 有燈，留 120° 缺口
  float span = radians(240);          // 有燈的角度範圍
  float startAngle = -span/2.0;       // 對稱展開
  float ringRotation = 0;

  for (int i = 0; i < numLights; i++) {
    float angle = map(i, 0, numLights-1, startAngle, startAngle + span) + ringRotation;

    float baseX = centerX + cos(angle) * radius;
    float baseZ =           sin(angle) * radius;

    for (int s = 0; s < numSegments; s++) {
      float bri = brightness[i][s];
      g.fill(255 * (bri / 100.0));

      float y = groundY - (s + 0.5) * segmentHeight;

      g.pushMatrix();
      g.translate(baseX, y, baseZ);
      g.sphere(dotRadius);
      g.popMatrix();
    }
  }

  g.popMatrix();
}

// 240° 45° 外傾圓弧燈條（按 3）
void drawLightsArcTilt(PGraphics g) {
  g.pushMatrix();
  g.noStroke();

  float stageLeft   = stageMargin;
  float stageRight  = g.width - stageMargin;
  float stageBottom = groundY;   // 燈條底部高度（地板 Y）

  float segmentHeight = lightHeight / numSegments;

  // 地板上的圓心（在 XZ 平面）
  float centerX = (stageLeft + stageRight) / 2.0;
  float centerZ = 0;

  float maxRadiusX = (stageRight - stageLeft) / 2.0;
  float radius = maxRadiusX * 0.9;   // 稍微縮一點避免貼邊

  // 每顆 pixel 的球半徑
  float dotRadius = min(lightWidth, segmentHeight) * 0.4;

  // 傾斜角度：45 度
  float tiltAngle = radians(45);
  float sinTilt = sin(tiltAngle);
  float cosTilt = cos(tiltAngle);

  // 只用 240°，留 120° 的缺口
  float span = radians(240);       // 有燈的弧長
  float startAngle = -span/2.0;    // 讓 240° 對稱展開，缺口在相反那一側
  float ringRotation = 0;          // 如果想整圈一起旋轉，可以改這裡

  for (int i = 0; i < numLights; i++) {
    float t = (numLights == 1) ? 0.0 : i / (float)(numLights - 1);
    float angle = startAngle + t * span + ringRotation;

    float baseX = centerX + cos(angle) * radius;
    float baseZ =           sin(angle) * radius;

    float dirX = cos(angle) * sinTilt;   // X：朝圓心外側
    float dirY = -cosTilt;               // Y：往上（畫面往上是負）
    float dirZ = sin(angle) * sinTilt;   // Z：朝圓心外側

    for (int s = 0; s < numSegments; s++) {
      float bri = brightness[i][s];
      g.fill(255 * (bri / 100.0));   // 白光，亮度依 bri

      float dist = (s + 0.5) * segmentHeight;

      float px = baseX + dirX * dist;
      float py = stageBottom + dirY * dist;
      float pz = baseZ + dirZ * dist;

      g.pushMatrix();
      g.translate(px, py, pz);
      g.sphere(dotRadius);
      g.popMatrix();
    }
  }

  g.popMatrix();
}

// 240° 括號形貝茲弧線燈條（按 4）
void drawLightsArcCurve(PGraphics g) {
  g.pushMatrix();
  g.noStroke();

  float stageLeft   = stageMargin;
  float stageRight  = g.width - stageMargin;
  float stageBottom = groundY;   // 燈條底部高度（地板 Y）

  float segmentHeight = lightHeight / numSegments;

  // 地板上的圓心（在 XZ 平面）
  float centerX = (stageLeft + stageRight) / 2.0;
  float centerZ = 0;

  float maxRadiusX = (stageRight - stageLeft) / 2.0;
  float radius = maxRadiusX * 0.9;   // 稍微縮一點避免貼邊

  // 每顆 pixel 的球半徑
  float dotRadius = min(lightWidth, segmentHeight) * 0.4;

  // 彎曲程度
  float curveBase = lightHeight * 0.5;

  // 只用 240° 的圓弧，留一個 120° 的開口
  float span = radians(240);          // 有燈的弧長
  float startAngle = -span/2.0;       // 讓 240° 對稱展開，剩下 120° 是缺口

  // 開口方向在 XZ 平面「從 +X 轉 90°」
  // openAngle = 0     -> 開口朝 +X
  // openAngle = PI/2  -> 開口朝 +Z
  // openAngle = -PI/2 -> 開口朝 -Z
  float openAngle = HALF_PI;          // 現在改成橫轉 90°
  float openDirX = cos(openAngle);
  float openDirZ = sin(openAngle);

  for (int i = 0; i < numLights; i++) {

    // 把 0~(numLights-1) 均勻映射到 240° 弧形
    float angle = map(i, 0, numLights-1, startAngle, startAngle + span);

    // 這根燈條「腳」在地板上的位置（沿弧線一圈）
    float baseX = centerX + cos(angle) * radius;
    float baseZ =           sin(angle) * radius;

    // 直線燈條的下端 / 上端（高度跟原本一樣）
    float x0 = baseX;
    float y0 = stageBottom - segmentHeight/2.0;          // 下端
    float z0 = baseZ;

    float x1 = baseX;
    float y1 = y0 - (numSegments - 1) * segmentHeight;   // 上端
    float z1 = baseZ;

    // 控制點：以上下中點為基準，沿著 openDir 方向推 curveBase
    float mx = (x0 + x1) * 0.5;
    float my = (y0 + y1) * 0.5;
    float mz = baseZ;

    float cx = mx + openDirX * curveBase;
    float cy = my;
    float cz = mz + openDirZ * curveBase;

    for (int s = 0; s < numSegments; s++) {
      float bri = brightness[i][s];
      if (bri <= 0) continue;

      g.fill(255 * (bri / 100.0));   // 白光

      float t = (numSegments == 1) ? 0.0 : s / (float)(numSegments - 1);
      float invT = 1.0 - t;

      // 三維二次貝茲曲線
      float px = invT*invT*x0 + 2*invT*t*cx + t*t*x1;
      float py = invT*invT*y0 + 2*invT*t*cy + t*t*y1;
      float pz = invT*invT*z0 + 2*invT*t*cz + t*t*z1;

      g.pushMatrix();
      g.translate(px, py, pz);
      g.sphere(dotRadius);
      g.popMatrix();
    }
  }

  g.popMatrix();
}

// 240° 括號形貝茲弧線燈條（沿半徑外開，按 5）
void drawLightsArcCurveRadial(PGraphics g) {
  g.pushMatrix();
  g.noStroke();

  float stageLeft   = stageMargin;
  float stageRight  = g.width - stageMargin;
  float stageBottom = groundY;   // 燈條底部高度（地板 Y）

  float segmentHeight = lightHeight / numSegments;

  // ---- 地板上的圓心（在 XZ 平面）----
  float centerX = (stageLeft + stageRight) / 2.0;
  float centerZ = 0;

  float maxRadiusX = (stageRight - stageLeft) / 2.0;
  float radius = maxRadiusX * 0.9;   // 稍微縮一點避免貼邊

  // 每顆 pixel 的球半徑
  float dotRadius = min(lightWidth, segmentHeight) * 0.4;

  // 彎曲程度，跟 2D 版一樣從 lightHeight 推出來
  float curveBase = lightHeight * 0.5;

  // ===== 只用 240°，留 120° 的缺口 =====
  float span = radians(240);        // 有燈的角度範圍
  float startAngle = -span/2.0;     // 讓 240° 對稱展開，缺口在對側
  float ringRotation = 0;           // 想整圈轉向可以改這個（例如 HALF_PI）

  for (int i = 0; i < numLights; i++) {

    // 把 0 ~ numLights-1 均勻分配到 240° 的弧形上
    float t = (numLights == 1) ? 0.0 : i / (float)(numLights - 1);
    float angle = startAngle + t * span + ringRotation;

    // 這根燈條「腳」在地板上的位置（沿弧線）
    float baseX = centerX + cos(angle) * radius;
    float baseZ =           sin(angle) * radius;

    // 直立時，底端 / 頂端位置
    float x0 = baseX;
    float y0 = stageBottom - segmentHeight/2.0;          // 下端
    float z0 = baseZ;

    float x1 = baseX;
    float y1 = y0 - (numSegments - 1) * segmentHeight;   // 上端
    float z1 = baseZ;

    // 往外的「半徑方向」（單位向量）
    float rx = cos(angle);
    float rz = sin(angle);

    // 控制點：取上下中點再沿半徑方向推出去 curveBase
    float mx = (x0 + x1) * 0.5;
    float my = (y0 + y1) * 0.5;
    float mz = (z0 + z1) * 0.5;

    float cx = mx - rx * curveBase;   // 往外開口
    float cy = my;
    float cz = mz - rz * curveBase;

    for (int s = 0; s < numSegments; s++) {
      float bri = brightness[i][s];
      if (bri <= 0) continue;

      g.fill(255 * (bri / 100.0));   // HSB 白光，亮度 = bri

      // tSeg: 0 ~ 1 代表從下到上的位置
      float tSeg = (numSegments == 1) ? 0.0 : s / (float)(numSegments - 1);
      float invT = 1.0 - tSeg;

      // 二次貝茲曲線
      float px = invT*invT*x0 + 2*invT*tSeg*cx + tSeg*tSeg*x1;
      float py = invT*invT*y0 + 2*invT*tSeg*cy + tSeg*tSeg*y1;
      float pz = invT*invT*z0 + 2*invT*tSeg*cz + tSeg*tSeg*z1;

      g.pushMatrix();
      g.translate(px, py, pz);
      g.sphere(dotRadius);
      g.popMatrix();
    }
  }

  g.popMatrix();
}

// 240° 括號形貝茲弧線燈條（沿半徑外開 +rx/+rz，按 6）
void drawLightsArcCurveRadial2(PGraphics g) {
  g.pushMatrix();
  g.noStroke();

  float stageLeft   = stageMargin;
  float stageRight  = g.width - stageMargin;
  float stageBottom = groundY;   // 燈條底部高度（地板 Y）

  float segmentHeight = lightHeight / numSegments;

  // ---- 地板上的圓心（在 XZ 平面）----
  float centerX = (stageLeft + stageRight) / 2.0;
  float centerZ = 0;

  float maxRadiusX = (stageRight - stageLeft) / 2.0;
  float radius = maxRadiusX * 0.9;   // 稍微縮一點避免貼邊

  // 每顆 pixel 的球半徑
  float dotRadius = min(lightWidth, segmentHeight) * 0.4;

  // 彎曲程度，跟 2D 版一樣從 lightHeight 推出來
  float curveBase = lightHeight * 0.5;

  // ===== 只用 240°，留 120° 的缺口 =====
  float span = radians(240);        // 有燈的角度範圍
  float startAngle = -span/2.0;     // 讓 240° 對稱展開，缺口在對側
  float ringRotation = 0;           // 想整圈轉向可以改這個（例如 HALF_PI）

  for (int i = 0; i < numLights; i++) {

    // ⭐ 把 0 ~ numLights-1 均勻分配到 240° 的弧形上
    float t = (numLights == 1) ? 0.0 : i / (float)(numLights - 1);
    float angle = startAngle + t * span + ringRotation;

    // 這根燈條「腳」在地板上的位置（沿弧線）
    float baseX = centerX + cos(angle) * radius;
    float baseZ =           sin(angle) * radius;

    // 直立時，底端 / 頂端位置
    float x0 = baseX;
    float y0 = stageBottom - segmentHeight/2.0;          // 下端
    float z0 = baseZ;

    float x1 = baseX;
    float y1 = y0 - (numSegments - 1) * segmentHeight;   // 上端
    float z1 = baseZ;

    // 往外的「半徑方向」（單位向量）
    float rx = cos(angle);
    float rz = sin(angle);

    // 控制點：取上下中點再沿半徑方向推出去 curveBase
    float mx = (x0 + x1) * 0.5;
    float my = (y0 + y1) * 0.5;
    float mz = (z0 + z1) * 0.5;

    float cx = mx + rx * curveBase;   // ⭐ 這版是 +rx / +rz
    float cy = my;
    float cz = mz + rz * curveBase;

    for (int s = 0; s < numSegments; s++) {
      float bri = brightness[i][s];
      if (bri <= 0) continue;

      g.fill(255 * (bri / 100.0));   // HSB 白光，亮度 = bri

      // tSeg: 0 ~ 1 代表從下到上的位置
      float tSeg = (numSegments == 1) ? 0.0 : s / (float)(numSegments - 1);
      float invT = 1.0 - tSeg;

      // 二次貝茲曲線
      float px = invT*invT*x0 + 2*invT*tSeg*cx + tSeg*tSeg*x1;
      float py = invT*invT*y0 + 2*invT*tSeg*cy + tSeg*tSeg*y1;
      float pz = invT*invT*z0 + 2*invT*tSeg*cz + tSeg*tSeg*z1;

      g.pushMatrix();
      g.translate(px, py, pz);
      g.sphere(dotRadius);
      g.popMatrix();
    }
  }

  g.popMatrix();
}

// 240°：每根燈在自己平面繞一整圈（按 7）
void drawLightsArcRing(PGraphics g) {
  g.pushMatrix();
  g.noStroke();

  float stageLeft   = stageMargin;
  float stageRight  = g.width - stageMargin;
  float stageBottom = groundY;              // 燈條底部高度（地板 Y）

  float segmentHeight = lightHeight / numSegments;

  // ---- 地板上的圓心（在 XZ 平面）----
  float centerX = (stageLeft + stageRight) / 2.0;
  float centerZ = 0;

  float maxRadiusX = (stageRight - stageLeft) / 2.0;
  float radius = maxRadiusX * 0.9;         // 稍微縮一點避免貼邊

  float groundYLocal = stageBottom;        // 燈條腳底 Y

  // 每顆 pixel 的球半徑
  float dotRadius = min(lightWidth, segmentHeight) * 0.4;

  // 這一根燈條自己的圓半徑：取 lightHeight/2 → 垂直高度大約 lightHeight
  float ringR = lightHeight * 0.5;

  // ===== 只用 240°，留 120° 的缺口 =====
  float span = radians(240);         // 有燈的總角度
  float startAngle = -span / 2.0;    // 讓 240° 對稱展開，缺口在對側
  float ringRotation = 0;            // 想讓整個弧形轉向可以改這個（例如 HALF_PI）

  for (int i = 0; i < numLights; i++) {

    // 把 0 ~ (numLights-1) 均勻分配到 240° 的弧形上
    float tRing  = (numLights == 1) ? 0.0 : i / (float)(numLights - 1);
    float angle  = startAngle + tRing * span + ringRotation;

    // 這根燈條「腳」在地板上的位置（沿 240° 弧線）
    float baseX = centerX + cos(angle) * radius;
    float baseZ =           sin(angle) * radius;

    // 垂直向上單位向量
    float vyx = 0;
    float vyy = -1;
    float vyz = 0;

    // 往外的「半徑方向」單位向量（在 XZ 平面）
    float vrx = cos(angle);
    float vrz = sin(angle);

    // 這根燈條的圓心：從腳往上半徑的距離
    float cx = baseX + vyx * ringR;           // vyx = 0，其實就是 baseX
    float cy = groundYLocal + vyy * ringR;    // groundY - ringR
    float cz = baseZ + vyz * ringR;           // vyz = 0，其實就是 baseZ

    for (int s = 0; s < numSegments; s++) {
      float bri = brightness[i][s];
      if (bri <= 0) continue;

      g.fill(255 * (bri / 100.0));   // 白光，亮度 = bri

      // t: 0~1，從「圓的底部」開始繞一整圈回到底部
      float t = (numSegments == 1) ? 0.0 : s / (float)(numSegments - 1);
      float localAngle = -HALF_PI + t * TWO_PI;  // -90° 起點在正下方

      float cosA = cos(localAngle);
      float sinA = sin(localAngle);

      // 圓所在的平面：由「往外 vr」和「往上 vy」張成
      // P = C + vr * (cosθ * r) + vy * (sinθ * r)
      float px = cx + vrx * (cosA * ringR) + vyx * (sinA * ringR);
      float py = cy + vyy * (sinA * ringR);
      float pz = cz + vrz * (cosA * ringR) + vyz * (sinA * ringR);

      g.pushMatrix();
      g.translate(px, py, pz);
      g.sphere(dotRadius);
      g.popMatrix();
    }
  }

  g.popMatrix();
}

// 3D 地板（矩形）──依照排列方式改尺寸
void drawFloor(PGraphics g, float y) {
  g.pushMatrix();
  g.noStroke();
  g.fill(40);

  float w, h;
  if (layoutMode == 0) {
    // 一字排：原本的版本
    w = g.width * 2.5;
    h = g.height * 2.0;
  } else {
    // layout 1, 2, 3：圓弧類型
    w = g.width * 1.0;
    h = g.height * 4.0;
  }

  g.translate(g.width/2, y, 0);
  g.rotateX(PI/2);
  g.rectMode(CENTER);
  g.rect(0, 0, w, h);
  g.popMatrix();
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

  String layoutName = "Parallel";
  if (layoutMode == 1) layoutName = "Ring";
  else if (layoutMode == 2) layoutName = "Radiation";
  else if (layoutMode == 3) layoutName = "Same_side";
  else if (layoutMode == 4) layoutName = "Center";
  else if (layoutMode == 5) layoutName = "Outward";
  else if (layoutMode == 6) layoutName = "Vertical_circle";
  text("Layout  > " + layoutName, 20, 60);
}

// ====================== 文字輸入 → 燈光字典 ======================
void keyPressed() {
  if (key == ENTER || key == RETURN) {
    String word = inputText.trim();
    applyKeyword(word);
    inputText = "";
  } 
  else if (key == BACKSPACE) {
    if (inputText.length() > 0) {
      inputText = inputText.substring(0, inputText.length()-1);
    }
  } 
  else if (key == CODED) {
    if (keyCode == LEFT)  camRotY -= 0.05;
    if (keyCode == RIGHT) camRotY += 0.05;
    if (keyCode == UP)    camRotX -= 0.05;
    if (keyCode == DOWN)  camRotX += 0.05;
  }
  // 排列方式切換：1 = 一字排，2 = 直立圓弧，3 = 45° 傾斜圓弧，4 = 括號形貝茲弧線，5 = 貝茲曲線，6 = 貝茲曲線，7 = 圓環
  else if (key == '1') {
    layoutMode = 0;
  }
  else if (key == '2') {
    layoutMode = 1;
  }
  else if (key == '3') {
    layoutMode = 2;
  }
  else if (key == '4') {
    layoutMode = 3;
  }
  else if (key == '5') {
  layoutMode = 4;
  }
  else if (key == '6') {
  layoutMode = 5;   
  }
  else if (key == '7') {        
  layoutMode = 6;
  }
  else {
    inputText += key;
  }
}

// ====================== 滑鼠相機控制 ======================
void mousePressed() {
  isDragging = true;
  lastMouseX = mouseX;
  lastMouseY = mouseY;
}

void mouseReleased() {
  isDragging = false;
}

void mouseDragged() {
  if (isDragging) {
    float dx = mouseX - lastMouseX;
    float dy = mouseY - lastMouseY;

    camRotY += dx * 0.01;
    camRotX += dy * 0.01;

    lastMouseX = mouseX;
    lastMouseY = mouseY;
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();  // 滾輪方向

  camZoom *= 1.0 + e * 0.05;
  camZoom = constrain(camZoom, 0.3, 3.0);
}

// ====================== 關鍵字對應 ======================
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
