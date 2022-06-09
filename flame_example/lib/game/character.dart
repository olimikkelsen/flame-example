import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

class Character extends SpriteAnimationComponent with CollisionCallbacks {
  double velocity = 0.0;
  bool eaten = false;
  List<Vector2> movementPath = [];
  Vector2 destination = Vector2(0, 0);
  bool _destinationReached = false;
  int score = 0;
  bool isPlayer = false;

  Character();

  void initCharacter(Image spriteSheet, Vector2 size, double x, double y,
      double velocity, bool isPlayer, Vector2 spriteSlice) {
    this.size = size;
    this.x = x;
    this.y = y;
    this.velocity = velocity;
    this.isPlayer = isPlayer;
    add(RectangleHitbox());
    debugMode = true;

    SpriteAnimationData spriteAnimationData = SpriteAnimationData.sequenced(
        amount: 6, stepTime: 0.3, textureSize: spriteSlice);
    SpriteAnimation spriteAnimation =
        SpriteAnimation.fromFrameData(spriteSheet, spriteAnimationData);

    animation = spriteAnimation;

    if (!isPlayer) {
      _initMovementPath();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (!isPlayer) {
      eaten = true;
    }

    //increment score
    score = isPlayer && !eaten ? score + 1 : score;
  }

  void _initMovementPath() {
    //sample movement path
    movementPath.add(Vector2(x + 100.0, y + 100.0));
    movementPath.add(Vector2(x + 200.0, y));
    movementPath.add(Vector2(x + 100.0, y - 100.0));
    movementPath.add(Vector2(x, y));
    movementPath.add(Vector2(x - 100.0, y + 100.0));
    movementPath.add(Vector2(x - 200.0, y));
    movementPath.add(Vector2(x - 100.0, y - 100.0));
    destination = movementPath[0];
  }

  void updateCurrentDestination() {
    Vector2 currentDestination = movementPath[0];
    if (_shouldChangeDestination(position, currentDestination)) {
      destination = movementPath[1];
      movementPath.remove(currentDestination);
      movementPath.add(currentDestination);
    }
  }

  bool _shouldChangeDestination(Vector2 dest1, Vector2 dest2) {
    if ((dest1.x - dest2.x).abs() < 2.0 &&
        (dest1.x - dest2.x).abs() < 2.0 &&
        !_destinationReached) {
      _destinationReached = true;
      return true;
    }
    _destinationReached = false;
    return false;
  }

  Vector2 getDirection() {
    int dx = destination.x - x > 0 ? 1 : -1;
    int dy = destination.y - y > 0 ? 1 : -1;
    return Vector2(dx * velocity, dy * velocity);
  }
}
