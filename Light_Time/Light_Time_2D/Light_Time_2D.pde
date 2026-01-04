String textToDisplay = "TIME"; // 你要顯示的字
PFont font;

int scanX = 0;        // 掃描柱目前位置
int columnWidth = 12; // LED 柱寬度（越小光軌越精細）
int dotSize = 8;      // LED 點大小
int spacing = 10;     // 掃描的取樣距離

PGraphics pg;         // 用來產生字形點陣

void setup() {
  size(800, 300);
  font = createFont("Arial Black", 200);
  
  pg = createGraphics(width, height);
  pg.beginDraw();
  pg.background(0);
  pg.fill(255);
  pg.textFont(font);
  pg.textAlign(CENTER, CENTER);
  pg.text(textToDisplay, width/2, height/2);
  pg.endDraw();
  
  pg.loadPixels();
}

void draw() {
  background(0);
  noStroke();
  
  // 掃描柱：只顯示一小條的LED像素
  for (int y = 0; y < height; y += spacing) {
    int idx = y * width + scanX;
    
    if (idx >= 0 && idx < pg.pixels.length) {
      float b = brightness(pg.pixels[idx]);
      if (b > 50) {
        fill(200, 200, 255); // LED 顏色
        ellipse(scanX, y, dotSize, dotSize);
      }
    }
  }
  
  // 掃描位置向右移動
  scanX += 2; // 速度（可調）
  if (scanX > width) scanX = 0;
  
  // 提示
  fill(255);
  textSize(16);
}
