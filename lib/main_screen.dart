import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

enum SnakePosition {
  UP,
  DOWN,
  RIGHT,
  LEFT,
}

class _MainScreenState extends State<MainScreen> {
  SnakePosition snakePosition = SnakePosition.RIGHT;

  List<int> snakeBodyParts = [
    0,
    1,
    2,
  ];

  int food = Random().nextInt(100);

  int score = 0;

  int block = 3;

  bool isActiveButton = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            myScore(),
            snakeGrounds(),
            buttonBar(context),
          ],
        ),
      ),
    );
  }

  Text myScore() {
    return Text(
      "Score: $score",
      style: const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w500,
        color: Colors.limeAccent,
      ),
    );
  }

  GestureDetector snakeGrounds() {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(
              () {
            if (details.delta.dx > 0 && snakePosition != SnakePosition.LEFT) {
              // Right
              snakePosition = SnakePosition.RIGHT;
            } else if (details.delta.dx < 0 &&
                snakePosition != SnakePosition.RIGHT) {
              // Left
              snakePosition = SnakePosition.LEFT;
            }
          },
        );
      },
      onVerticalDragUpdate: (details) {
        setState(
              () {
            if (details.delta.dy > 0 && snakePosition != SnakePosition.UP) {
              // Down
              snakePosition = SnakePosition.DOWN;
            } else if (details.delta.dy < 0 &&
                snakePosition != SnakePosition.DOWN) {
              // Up
              snakePosition = SnakePosition.UP;
            }
          },
        );
      },
      child: SizedBox(
        height: 400,
        width: double.infinity,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 10,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: 100,
          itemBuilder: (context, index) {
            if (snakeBodyParts.contains(index)) {
              return snakeBlock(
                color: Colors.lightGreenAccent,
                index: index,
              );
            } else if (index == food) {
              return snakeBlock(
                color: Colors.yellowAccent,
                index: index,
              );
            } else {
              return snakeBlock(
                color: Theme
                    .of(context)
                    .primaryColor,
                index: index,
              );
            }
          },
        ),
      ),
    );
  }

  Row buttonBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        playButton(),
        resetButton(context),
      ],
    );
  }

  MaterialButton playButton() {
    return MaterialButton(
      onPressed: isActiveButton ? onPlayButton : doNothing,
      color: Colors.lightGreenAccent,
      child: const Text("Play"),
    );
  }

  MaterialButton resetButton(BuildContext context) {
    return MaterialButton(
      onPressed: onResetButton,
      color: Colors.limeAccent,
      child: const Text("Reset"),
    );
  }

  Container snakeBlock({required Color color, required int index}) {
    return Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: null);
  }

  bool isSnakeItSelf() {
    for (int i = 0; i < snakeBodyParts.length - 1; i++) {
      if (snakeBodyParts[i] == snakeBodyParts.last) {
        return true;
      }
    }
    return false;
  }

  void moveSnake() {
    switch (snakePosition) {
      case SnakePosition.RIGHT:
        {
          if (snakeBodyParts.last % 10 == 9) {
            snakeBodyParts.add(snakeBodyParts.last - 9);
          } else {
            snakeBodyParts.add(snakeBodyParts.last + 1);
          }
        }
        break;
      case SnakePosition.LEFT:
        {
          if (snakeBodyParts.last % 10 == 0) {
            snakeBodyParts.add(snakeBodyParts.last + 9);
          } else {
            snakeBodyParts.add(snakeBodyParts.last - 1);
          }
        }
        break;
      case SnakePosition.UP:
        {
          if (snakeBodyParts.last ~/ 10 == 0) {
            snakeBodyParts.add(snakeBodyParts.last + 90);
          } else {
            snakeBodyParts.add(snakeBodyParts.last - 10);
          }
        }
        break;
      case SnakePosition.DOWN:
        {
          if (snakeBodyParts.last ~/ 10 == 9) {
            snakeBodyParts.add(snakeBodyParts.last - 90);
          } else {
            snakeBodyParts.add(snakeBodyParts.last + 10);
          }
        }
        break;
    }

    if (snakeBodyParts.contains(food)) {
      newFoodLoc();
    } else {
      snakeBodyParts.removeAt(0);
    }
  }

  void newFoodLoc() {
    food = Random().nextInt(100);
    score += 10;
    block++;
  }

  void onPlayButton() {
    Vibration.vibrate(amplitude: 50, duration: 100);
    Timer.periodic(
      const Duration(milliseconds: 200),
          (timer) {
        setState(
              () {
            isActiveButton = false;
            if (isSnakeItSelf()) {
              Vibration.vibrate(
                pattern: [0, 500, 300, 500],
                amplitude: 128,
              );
              timer.cancel();
              showDialog(
                context: context,
                builder: (context) =>
                    AlertDialog(
                      title: const Text("Game Over!!"),
                      titleTextStyle: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w500,
                        color: Colors.redAccent,
                      ),
                      content: Text("Score: $score"),
                      contentTextStyle: const TextStyle(
                        fontSize: 28,
                        color: Colors.limeAccent,
                      ),
                      backgroundColor: Theme
                          .of(context)
                          .primaryColor,
                    ),
              );
            } else {
              moveSnake();
            }
          },
        );
      },
    );
  }

  void onResetButton() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainScreen(),
      ),
    );
  }

  void doNothing() {}
}
