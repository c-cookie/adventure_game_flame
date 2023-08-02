class PlayerHitbox {
  double offsetX;
  double offsetY;
  double width;
  double height;

  PlayerHitbox({
    required this.offsetX,
    required this.offsetY,
    required this.width,
    required this.height,
  });

  void reset() {
    offsetX = 0;
    offsetY = 0;
    width = 0;
    height = 0;
  }
}
