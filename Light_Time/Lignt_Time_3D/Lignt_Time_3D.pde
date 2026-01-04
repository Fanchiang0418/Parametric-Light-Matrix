import processing.event.MouseEvent;  // 滾輪用

// ====== 文字掃描（POV）參數 ======
String textToDisplay = "TIME";
PFont font;
PGraphics pg;              // 用來產生字形點陣
int scanI = 0;             // 掃描到第幾根燈（0..numLights-1）
int scanSpeed = 1;         // 每幀掃幾根燈
float threshold = 50;      // 判斷是否亮的亮度門檻（0~100）
float onBri = 100;         // 亮的亮度（0~100）
float offBri = 0;          // 暗的亮度（0~100）
float trail = 0;         // 殘影（0=無殘影；0.85=慢慢衰退）

// ====== 基本參數 ======
int numLights = 20;        // 燈的數量（沿一圈／一排）
float stageMargin = 80;    // 舞台左右預留空間
float lightWidth = 6;      // 每顆 pixel 在射線上的最大直徑
float lightHeight = 100;   // 每根燈柱的長度
int numSegments = 10;      // 每條燈切成幾個 pixel
float[][] brightness;      // brightness[i][s]：第 i 根燈、第 s 格的亮度
float groundY;             // 地板高度 & 燈條腳底高度

// ====== 相機控制 ======
float camRotX = -PI/6.0;
float camRotY = 0;
boolean isDragging = false;
int lastMouseX, lastMouseY;
float camZoom = 1.0;

// ====================== setup / draw ======================
void setup() {
  size(900, 480, P3D);
  colorMode(HSB, 360, 100, 100);
  rectMode(CENTER);
  textAlign(LEFT, TOP);
  textSize(16);

  groundY = height - 180;

  // 初始化亮度
  brightness = new float[numLights][numSegments];
  for (int i = 0; i < numLights; i++) {
    for (int s = 0; s < numSegments; s++) {
      brightness[i][s] = offBri;
    }
  }

  // 產生文字像素地圖 pg
  font = createFont("Arial Black", 260);
  pg = createGraphics(width, height, P2D);
  renderTextToPG();     // 先畫一次
}

void draw() {
  background(0);

  // 每幀更新：把掃描柱效果套到 brightness[][]（核心）
  updateScanFromText();

  // --- 3D 場景 ---
  noLights();
  colorMode(HSB, 360, 100, 100);

  pushMatrix();
  translate(width/2, height*0.65, 0);
  scale(camZoom);
  rotateX(camRotX);
  rotateY(camRotY);
  translate(-width/2, -height/2, 0);

  drawFloor(g, groundY);
  drawLights(g);

  popMatrix();

  // --- UI ---
  hint(DISABLE_DEPTH_TEST);
  fill(0, 0, 100);
  //text("Drag: rotate | Wheel: zoom | POV scan text: " + textToDisplay, 10, 10);
  hint(ENABLE_DEPTH_TEST);
}

// ====================== 文字 → pg ======================
void renderTextToPG() {
  pg.beginDraw();
  pg.background(0);
  pg.fill(255);
  pg.textFont(font);

  pg.textAlign(LEFT, TOP);
  float tw = pg.textWidth(textToDisplay);
  float x = (pg.width - tw) * 0.5;      // ⭐ 真正的水平置中
  float y = 0;
  pg.text(textToDisplay, x, y);
  pg.endDraw();
  pg.loadPixels();
}

// ====================== 掃描柱：pg → brightness[][] ======================
void updateScanFromText() {
  // 殘影（長曝感）
  if (trail > 0) {
    for (int ii = 0; ii < numLights; ii++) {
      for (int s = 0; s < numSegments; s++) {
        brightness[ii][s] *= trail;
      }
    }
  } else {
    // 沒殘影：先全部清暗
    for (int ii = 0; ii < numLights; ii++) {
      for (int s = 0; s < numSegments; s++) {
        brightness[ii][s] = offBri;
      }
    }
  }

  // 掃描到的那一根燈
  int i = scanI;

  // x 對應到 pg
  int xPix = (numLights == 1)
    ? pg.width/2
    : int(map(i, 0, numLights-1, 0, pg.width-1));

  // 只取舞台可視高度對應燈柱
  int yTopPix    = int(map(80, 0, height, 0, pg.height-1));
  int yBottomPix = int(map(groundY, 0, height, 0, pg.height-1));

  // 每個 segment 用「區間取樣」
  for (int s = 0; s < numSegments; s++) {

    int yA = int(map(s, 0, numSegments, yBottomPix, yTopPix));
    int yB = int(map(s+1, 0, numSegments, yBottomPix, yTopPix));

    int yMin = min(yA, yB);
    int yMax = max(yA, yB);

    boolean hit = false;

    // 在該段 y 範圍內掃描（步進 1~3，越小越密）
    for (int yy = yMin; yy <= yMax; yy += 1) {
      int idx = yy * pg.width + xPix;
      if (idx >= 0 && idx < pg.pixels.length) {
        if (brightness(pg.pixels[idx]) > threshold) {
          hit = true;
          break;
        }
      }
    }

    brightness[i][s] = hit ? onBri : offBri;
  }

  // 掃描往前走
  scanI += scanSpeed;
  if (scanI >= numLights) scanI = 0;
}

// ====================== 燈條 + 地板 ======================
void drawLights(PGraphics g) {
  g.noStroke();

  float stageLeft   = stageMargin;
  float stageRight  = g.width - stageMargin;
  float stageBottom = groundY;

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
      float bri = brightness[i][s];  // 0..100

      // 你原本是灰階 fill(255 * (bri/100))，這裡改成白亮度
      g.fill(0, 0, bri);  // HSB: 白色，亮度 bri

      float y = stageBottom - segmentHeight/2 - s * segmentHeight;

      g.pushMatrix();
      g.translate(x, y, 0);
      g.sphere(dotRadius);
      g.popMatrix();
    }
  }
}

// 3D 地板（矩形）
void drawFloor(PGraphics g, float y) {
  g.pushMatrix();
  g.noStroke();
  g.fill(0, 0, 20);
  float w = g.width * 2.5;
  float h = g.height * 2.0;
  g.translate(g.width/2, y, 0);
  g.rotateX(PI/2);
  g.rectMode(CENTER);
  g.rect(0, 0, w, h);
  g.popMatrix();
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
  float e = event.getCount();
  camZoom *= 1.0 + e * 0.05;
  camZoom = constrain(camZoom, 0.3, 3.0);
}
