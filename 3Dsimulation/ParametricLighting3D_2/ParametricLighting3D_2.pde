import processing.event.MouseEvent;  // 滾輪用
boolean showAxes = true;
boolean showHSB = true;

// ====== 基本參數 ======
int numLights = 20;        // 燈的數量（沿圓一圈）
float stageMargin = 80;    // 舞台左右預留空間
float lightWidth = 6;      // 每顆 pixel 在射線上的最大直徑
float lightHeight = 100;   // 每根燈柱的長度（沿射線方向）
int numSegments = 10;      // 每條燈切成幾個 pixel
float[][] brightness;      // brightness[i][s]：第 i 根燈、第 s 格的亮度

// ====== 相機控制 ======
float camRotX = -PI/6.0;  // 一開始稍微往後仰
float camRotY = 0;        // 左右旋轉
boolean isDragging = false;
int lastMouseX, lastMouseY;
float camZoom = 1.0;      // 鏡頭縮放倍率（1 = 原始大小）

// ====== 八個共享參數（0~1 或指定範圍）======

/*
// 同步呼吸（Unified Breath）
 float tempo     = 1.0;
 float contrast  = 0.1;
 float density   = 0.5;
 float horizontalPhase    = 0;
 float horizontalDirection = 0;
 float ringTurns = 0;
 float verticalPhase = 0;
 float verticalDirection = 0;
 */

/*
// 順時針 (Cw)
 float tempo     = 1.0;
 float contrast  = 0.1;
 float density   = 0.05; //3支
 float horizontalPhase    = 0;
 float horizontalDirection = 1;
 float ringTurns = 1;
 float verticalPhase = 0;
 float verticalDirection = 0;
 */

/*
// 仰望 (Up)
 float tempo = 1.0;
 float contrast = 0.9;
 float density = 0.1; //0.05 > 2點，0.1 > 3點
 float horizontalPhase = 0;
 float horizontalDirection = 0;
 float ringTurns = 0;
 float verticalPhase = 0.05; //0.5 = 間隔10個點，1 = 間隔5個點
 float verticalDirection = +1; // +1 向上, -1 向下
 */


// 波浪 (Wave)
 float tempo = 0.5;
 float contrast = 0.2;
 float density = 0.4; //0.05 > 2點，0.1 > 3點，0.5 > 9點
 float horizontalPhase = 0.1;
 float horizontalDirection = 1;
 float ringTurns = 0;
 float verticalPhase = 0.05; //0.5 = 間隔10個點，1 = 間隔5個點
 float verticalDirection = 1; // +1 向上, -1 向下
 

// ====== 時間 ======
float globalTime = 0;

// ====================== setup / draw ======================
void setup() {
  size(900, 480, P3D);
  colorMode(HSB, 360, 100, 100);
  rectMode(CENTER);
  textAlign(LEFT, TOP);
  textSize(16);

  brightness = new float[numLights][numSegments];
  for (int i = 0; i < numLights; i++) {
    for (int s = 0; s < numSegments; s++) {
      brightness[i][s] = 40;
    }
  }
}

void draw() {
  background(0);

  globalTime = millis() / 1000.0;
  updateBreathingDrift();  // 每一幀更新 brightness[][]（套效果）

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

  // 把座標系移回去，讓 drawLights3D / drawFloor 用 0~width,0~height 的邏輯
  translate(-width/2, -height/2, 0);

  // 先畫地板，再畫燈
  drawFloor();
  if (showAxes) drawAxes3D();
  drawLights3D();

  popMatrix();

  // UI 疊在最上層
  hint(DISABLE_DEPTH_TEST);
  hint(ENABLE_DEPTH_TEST);
}
