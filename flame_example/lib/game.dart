import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'dart:math';
import 'game/character.dart';
//import 'package:flame_audio/flame_audio.dart';

class SlimeGame extends FlameGame with TapDetector, HasCollisionDetection {
  Character player = Character();

  Vector2 goalPosition = Vector2(0, 0);
  double baseVelocity = 5.0;
  //map fra path string til spritesheet
  Map<String, Image> enemySpriteSheets = {};
  List<Character> enemies = [];
  SpriteAnimationComponent spriteAnimation = SpriteAnimationComponent();

  TextPaint scoreTextPaint = TextPaint();

  List<String> paths = ['slime.png'];

  int i = 0;

  @override
  Color backgroundColor() => const Color(0x0090ee90);

  @override
  Future<void> onLoad() async {
    var spriteSheet = await images.load('player.png');
    //await FlameAudio.audioCache.load('pop.mp3');

    player.initCharacter(spriteSheet, Vector2(100.0, 100.0), 150.0, 50.0,
        baseVelocity, true, Vector2(19, 27));

    add(player);

    enemySpriteSheets = await enemySpriteMap();
  }

  @override
  update(double dt) {
    super.update(dt);
    /** SAMPLE START - adding slime every 100 frames */
    i++;
    double enemySize = 45;

    if (i == 100) {
      insertEnemy(Vector2(enemySize, enemySize), 1.0);
      i = 0;
    }
    /* SAMPLE END */

    List enemiesToRemove = [];

    for (var enemy in enemies) {
      if (enemy.eaten) {
        enemiesToRemove.add(enemy);
      }
    }

    for (var glooby in enemiesToRemove) {
      remove(glooby);
      //FlameAudio.play('pop.mp3');
      enemies.remove(glooby);
    }

    movePlayer();
    moveEnemies();
  }

  void movePlayer() {
    double directionX = goalPosition.x - player.x;
    double directionY = goalPosition.y - player.y;

    //do not move if within 5 of goal position
    if (directionX.abs() < 5.0 && directionY.abs() < 5.0) {
      return;
    }

    double directionLength =
        sqrt(directionX * directionX + directionY * directionY);
    directionX = directionX / directionLength;
    directionY = directionY / directionLength;

    player.x += directionX * player.velocity;
    player.y += directionY * player.velocity;
  }

  @override
  void onTapDown(TapDownInfo info) {
    goalPosition.x = info.eventPosition.game.x;
    goalPosition.y = info.eventPosition.game.y;
  }

  //Return map from asset path to enemy Sprite
  Future<Map<String, Image>> enemySpriteMap() async {
    Map<String, Image> enemySprites = {};

    for (int i = 0; i < paths.length; i++) {
      String currentPath = paths[i];
      var spriteSheet = await images.load(currentPath);

      enemySprites[currentPath] = spriteSheet;
    }

    return enemySprites;
  }

  bool withinBounds(double x1, double y1, double x2, double y2) {
    double size = 100; //should maybe be passed as argument
    return (x1 - x2).abs() < size && (y1 - y2).abs() < size;
  }

  void insertEnemy(Vector2 size, double velocity) {
    Random rand = Random();

    String randomSpritePath = paths[rand.nextInt(paths.length)];

    //TODO: determine based on screen size
    int maxX = 250;
    int maxY = 700;

    //random start position
    double x = rand.nextDouble() * maxX;
    double y = rand.nextDouble() * maxY;

    spawnEnemy(randomSpritePath, size, x, y, velocity);
  }

  void spawnEnemy(
      String path, Vector2 size, double x, double y, double velocity) {
    Character newSlime = Character();
    Image? newSpriteSheet = enemySpriteSheets[path];
    if (newSpriteSheet == null) {
      print("Could not find sprite: " + path);
      return;
    }
    newSlime.initCharacter(
        newSpriteSheet, size, x, y, velocity, false, Vector2(22, 20));
    enemies.add(newSlime);
    add(newSlime);
  }

  void moveEnemies() {
    enemies.forEach((enemy) {
      enemy.updateCurrentDestination();
      Vector2 currentDirection = enemy.getDirection();
      enemy.x = enemy.x + currentDirection.x;
      enemy.y = enemy.y + currentDirection.y;
    });
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    scoreTextPaint.render(canvas, "score: ${player.score}", Vector2(10, 10));
  }

  void updateGameStage() {}
}
