bool checkCollision(player, block) {
  final hitbox = player.hitbox;
  final playerx = player.position.x + hitbox.offsetX;
  final playery = player.position.y + hitbox.offsetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  final fixedX = player.scale.x < 0
      ? playerx - (hitbox.offsetX * 2 + playerWidth)
      : playerx;
  final fixedY = block.isPlatform ? playery + playerHeight : playery;

  return (fixedY < blockY + blockHeight &&
      playery + playerHeight > blockY &&
      fixedX < blockX + blockWidth &&
      fixedX + playerWidth > blockX);
}

bool checkCollisionFruit(player, fruit) {
  final hitbox = player.hitbox;
  final playerx = player.position.x + hitbox.offsetX;
  final playery = player.position.y + hitbox.offsetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final fruitHitbox = fruit.hitbox;
  final fruitX = fruit.x + fruitHitbox.offsetX;
  final fruitY = fruit.y + fruitHitbox.offsetY;
  final fruitWidth = fruitHitbox.width;
  final fruitHeight = fruitHitbox.height;

  final fixedX = player.scale.x < 0
      ? playerx - (hitbox.offsetX * 2 + playerWidth)
      : playerx;
  final fixedY = playery;

  return (fixedY < fruitY + fruitHeight &&
      playery + playerHeight > fruitY &&
      fixedX < fruitX + fruitWidth &&
      fixedX + playerWidth > fruitX);
}

bool checkCollisionBox(box, block) {
  if (box.isRemoved) return false;
  final hitbox = box.hitbox;
  final boxx = box.position.x + hitbox.offsetX;
  final boxy = box.position.y + hitbox.offsetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  final fixedX =
      box.scale.x < 0 ? boxx - (hitbox.offsetX * 2 + playerWidth) : boxx;
  final fixedY = boxy;

  return (fixedY < blockY + blockHeight &&
      boxy + playerHeight > blockY &&
      fixedX < blockX + blockWidth &&
      fixedX + playerWidth > blockX &&
      !box.isRemoved);
}

bool checkCollisionRaw(box, block) {
  final hitbox = box.hitbox;
  final boxx = box.position.x + hitbox.offsetX;
  final boxy = box.position.y + hitbox.offsetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  final fixedX =
      box.scale.x < 0 ? boxx - (hitbox.offsetX * 2 + playerWidth) : boxx;
  final fixedY = boxy;

  return (fixedY < blockY + blockHeight &&
      boxy + playerHeight > blockY &&
      fixedX < blockX + blockWidth &&
      fixedX + playerWidth > blockX);
}

bool checkCollisionFan(player, fan) {
  final hitbox = player.hitbox;
  final playerx = player.position.x + hitbox.offsetX;
  final playery = player.position.y + hitbox.offsetY;
  final playerHeight = hitbox.height;
  final playerWidth = hitbox.width;

  final blockX = fan.x;
  final blockY = fan.y;
  final blockHeight = fan.height;
  final blockWidth = fan.width;
  const maxHeight = 100;

  final fixedX = player.scale.x < 0
      ? playerx - (hitbox.offsetX * 2 + playerWidth)
      : playerx;
  // ignore: unused_local_variable
  final fixedY = playery;

  return (playery < blockY + blockHeight &&
      playery + playerHeight < blockY &&
      playery + playerHeight > blockY - maxHeight &&
      fixedX > blockX &&
      fixedX < blockX + blockWidth);
}
