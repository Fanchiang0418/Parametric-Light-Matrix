void updateBreathingDrift() {

  // --- 基礎亮度範圍 ---
  float baseLow  = 0;
  float baseHigh = 100;

  // --- contrast -> exponent ---
  float exponent = lerp(1.0, 10.0, constrain(contrast, 0, 1));

  // --- time (tempo as Hz-like) ---
  float t = globalTime * tempo * TWO_PI;

  // --- density gate ---
  float thresh = 1.0 - constrain(density, 0, 1);
  
  // 座標系修正（把你畫面觀察到的方向統一在這裡翻轉）
  float hDir = -horizontalDirection;
  float vDir = -verticalDirection;

  for (int i = 0; i < numLights; i++) {

    // (A) 環向結構：ringTurns 決定一圈幾個週期
    float phiRing = hDir * i * (ringTurns * TWO_PI / numLights);

    // (B) 水平錯位：horizontalPhase 決定相鄰燈條額外相位偏移（0~1 -> 0~2π）
    float phiH = i * horizontalPhase * TWO_PI;

    for (int s = 0; s < numSegments; s++) {

      // (C) 垂直起伏：verticalPhase 決定高度方向相位偏移（0~1 -> 0~2π）
      float phiV = vDir * s * verticalPhase * TWO_PI;

      float wave = sin(t + phiRing + phiH + phiV);
      float w01  = (wave + 1.0) * 0.5;

      float shaped = pow(w01, exponent);
      float mask   = (w01 < thresh) ? 0.0 : 1.0;

      float bri = lerp(baseLow, baseHigh, shaped) * mask;
      brightness[i][s] = constrain(bri, 0, 100);
    }
  }
}
