// 一圈在地板上的正圓 + 直立燈條
void drawLights3D() {
  pushMatrix();
  noStroke();

  float stageLeft   = stageMargin;
  float stageRight  = width - stageMargin;
  float stageBottom = height - 180;  // 燈條底部高度，可調

  float segmentHeight = lightHeight / numSegments;

  // 地板上的圓（XZ 平面）
  float centerX = (stageLeft + stageRight) / 2.0;
  float centerZ = 0;

  float maxRadiusX = (stageRight - stageLeft) / 2.0;
  float radius = maxRadiusX * 0.9;

  float groundY = stageBottom;

  float dotRadius = min(lightWidth, segmentHeight) * 0.4;

  // 只有 240° 有燈，留 120° 缺口
  float span = radians(240);
  float startAngle = -span/2.0;

  for (int i = 0; i < numLights; i++) {
    float angle = map(i, 0, numLights-1, startAngle, startAngle + span);

    float baseX = centerX + cos(angle) * radius;
    float baseZ =           sin(angle) * radius;

    for (int s = 0; s < numSegments; s++) {
      float bri = brightness[i][s];

      float y = groundY - (s + 0.5) * segmentHeight;

      // 每顆球自己的座標層
      pushMatrix();
      translate(baseX, y, baseZ);

      // 球
      fill(0, 0, bri);
      sphere(dotRadius);

      // 共同 offset
      float labelOffset = dotRadius * 3.0;

      // --- index label ---
      pushMatrix();
      rotateY(-camRotY);
      rotateX(-camRotX);
      translate(labelOffset, -dotRadius * 0.8, 0);

      textSize(10);
      textAlign(LEFT, CENTER);

      String idx = i + "," + s;

      fill(0, 0, 0);
      text(idx, 1, 1);
      fill(0, 0, 30);
      text(idx, 0, 0);

      popMatrix();

      // --- HSB label ---
      if (showHSB) {
        String hsbText = nf(bri, 1, 1); // 前面加兩個空白當間距

        pushMatrix();
        rotateY(-camRotY);
        rotateX(-camRotX);

        // X 往右推「index 字串寬度 + 間距」
        float indexWidth = textWidth(idx);
        translate(labelOffset + indexWidth + 6, -dotRadius * 0.8, 0);

        textSize(9);
        textAlign(LEFT, CENTER);

        // shadow
        fill(0, 0, 0);
        text(hsbText, 1, 1);
        // text
        fill(0, 0, 30);
        text(hsbText, 0, 0);

        popMatrix();
      }

      popMatrix(); // 結束每顆球自己的座標層
    }
  }

  popMatrix(); // 對應 drawLights3D() 最上面的 pushMatrix()
}
