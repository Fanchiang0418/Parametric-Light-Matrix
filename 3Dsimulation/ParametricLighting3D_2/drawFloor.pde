void drawFloor() {
  float stageTop    = 80;
  float stageBottom = height - 180;
  float groundY = stageBottom;

  pushMatrix();
  noStroke();
  fill(40);  // 深灰色

  float w = width * 1.0;
  float h = height * 4.0;

  translate(width/2, groundY, 0);
  rotateX(PI/2);

  rectMode(CENTER);
  rect(0, 0, w, h);

  popMatrix();
}
