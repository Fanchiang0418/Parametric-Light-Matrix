void drawAxes3D() {
  // 跟 drawLights3D 用同一組舞台計算，確保軸放在「地板圓心」附近
  float stageLeft   = stageMargin;
  float stageRight  = width - stageMargin;
  float stageBottom = height - 180;

  float centerX = (stageLeft + stageRight) / 2.0;
  float centerZ = 0;
  float groundY = stageBottom;

  // 軸的長度（你可以自己調）
  float L = 80;

  pushMatrix();
  // 軸的原點：放在地板圓心稍微上方（避免埋進地板）
  translate(centerX, groundY - 2, centerZ);

  strokeWeight(3);

  // X 軸（+X 往右）
  stroke(0, 100, 100);    // HSB：紅
  line(0, 0, 0,  L, 0, 0);

  // Y 軸（+Y 往上：注意 Processing 螢幕座標 Y 往下，所以「往上」是 -Y）
  stroke(120, 100, 100);  // 綠
  line(0, 0, 0,  0, -L, 0);

  // Z 軸（+Z 往前/往後：P3D 右手系，視覺上你會看到往外/往內）
  stroke(240, 100, 100);  // 藍
  line(0, 0, 0,  0, 0, L);

  // ----- 文字標籤（永遠面向鏡頭）-----
  // 用跟你 index label 一樣的 billboard 技巧
  noStroke();
  fill(0, 0, 100);
  textSize(14);
  textAlign(LEFT, CENTER);

  // X label
  pushMatrix();
  translate(L + 6, 0, 0);
  rotateY(-camRotY);
  rotateX(-camRotX);
  text("X", 0, 0);
  popMatrix();

  // Y label
  pushMatrix();
  translate(0, -L - 6, 0);
  rotateY(-camRotY);
  rotateX(-camRotX);
  text("Y", 0, 0);
  popMatrix();

  // Z label
  pushMatrix();
  translate(0, 0, L + 6);
  rotateY(-camRotY);
  rotateX(-camRotX);
  text("Z", 0, 0);
  popMatrix();

  popMatrix();
}
