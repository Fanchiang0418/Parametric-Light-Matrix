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
