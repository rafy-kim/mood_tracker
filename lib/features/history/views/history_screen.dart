import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_tracker/constants/gaps.dart';
import 'package:mood_tracker/features/history/view_models/history_view_model.dart';
import 'package:mood_tracker/features/history/views/emotion_detail_screen.dart';
import 'package:mood_tracker/features/history/views/setting_screen.dart';
import 'package:mood_tracker/features/posts/view_models/timeline_view_model.dart';
import 'package:mood_tracker/features/posts/views/widgets/emotion_ball.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  // TODO: 상단에 감정 통계

  // TODO: 특정 ball 선택시 modal 로 보여주기
  bool isInit = false;
  late int cntSum;
  late var cntEmotion;

  @override
  void initState() {
    super.initState();
    _resetCount();
  }

  void _resetCount() {
    cntSum = 0;
    cntEmotion = {
      "joy": 0,
      "sadness": 0,
      "disgust": 0,
      "fear": 0,
      "anger": 0,
    };
  }

  void _initCount(posts) {
    // if (isInit) return;
    _resetCount();

    cntSum = posts.length;
    for (var post in posts) {
      if (cntEmotion.containsKey(post.emotionName)) {
        cntEmotion[post.emotionName] = cntEmotion[post.emotionName]! + 1;
      }
    }
    setState(() {});
    // isInit = true;
  }

  void _onTapEmotion(post) {
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => EmotionDetailScreen(post: post),
    //     ));
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EmotionDetailScreen(post: post),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
            reverseCurve: Curves.easeInCirc,
          );
          // final opacityAnimation = Tween(
          //   begin: 0.0,
          //   end: 1.0,
          // ).animate(curvedAnimation);
          // final offsetAnimtaion = Tween(
          //   begin: const Offset(0, -1),
          //   end: Offset.zero,
          // ).animate(curvedAnimation);
          // // Push transition
          // if (animation.status == AnimationStatus.forward) {
          //   return SlideTransition(
          //     position: offsetAnimtaion,
          //     child: FadeTransition(
          //       opacity: opacityAnimation,
          //       child: child,
          //     ),
          //   );
          // } else {
          //   // Pop transition: Fade
          return FadeTransition(
            opacity: curvedAnimation,
            child: child,
          );
          // }
        },
        transitionDuration: const Duration(milliseconds: 1500),
        reverseTransitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  void _onTapSetting() {
    context.push(SettingsScreen.routeURL);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("History"),
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: _onTapSetting,
              child: const FaIcon(FontAwesomeIcons.gear),
            ),
            Gaps.h10,
          ],
        ),
        body: ref.watch(historyProvider).when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Text(
                  "could not load posts: $error",
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              data: (posts) {
                _initCount(posts);
                // posts.shuffle(Random());
                return Column(
                  children: [
                    Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: cntSum > 0
                          ? CustomPaint(
                              size: Size(size.width - 40, 40),
                              painter: EmotionBar(
                                cntEmotion: cntEmotion,
                                cntSum: posts.length,
                                // progressValue: _progressController.value,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("joy: ${cntEmotion["joy"]}  "),
                        Text("sadness: ${cntEmotion["sadness"]}  "),
                        Text("disgust: ${cntEmotion["disgust"]}  "),
                        Text("fear: ${cntEmotion["fear"]}  "),
                        Text("anger: ${cntEmotion["anger"]}"),
                      ],
                    ),
                    const Divider(
                      height: 20,
                      thickness: 2,
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(
                          bottom: 20,
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          verticalDirection: VerticalDirection.up,
                          // runAlignment: WrapAlignment.center,
                          children: List.generate(
                            posts.length,
                            (index) {
                              return GestureDetector(
                                onTap: () => _onTapEmotion(posts[index]),
                                child: Hero(
                                  tag: posts[index].id,
                                  child: EmotionBall(
                                    name: posts[index].emotionName,
                                    isCore: posts[index].imgs!.isNotEmpty
                                        ? true
                                        : false,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
      ),
    );
  }
}

class EmotionBar extends CustomPainter {
  final Map<String, int> cntEmotion;
  final int cntSum;

  EmotionBar({
    super.repaint,
    required this.cntEmotion,
    required this.cntSum,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // final progress = size.width * progressValue;
    // track
    final trackPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;
    final trackRect = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height,
    );
    canvas.drawRect(trackRect, trackPaint);

    // joy
    final joyPaint = Paint()
      ..color = Colors.yellow.shade300
      ..style = PaintingStyle.fill;
    final joyRect = Rect.fromLTWH(
      0,
      0,
      (cntEmotion["joy"]! / cntSum) * size.width,
      size.height,
    );
    canvas.drawRect(joyRect, joyPaint);

    // sadness
    final sadnessPaint = Paint()
      ..color = Colors.blue.shade200
      ..style = PaintingStyle.fill;
    final sadnessRect = Rect.fromLTWH(
      (cntEmotion["joy"]! / cntSum) * size.width,
      0,
      (cntEmotion["sadness"]! / cntSum) * size.width,
      size.height,
    );
    canvas.drawRect(sadnessRect, sadnessPaint);

    // disgust
    final disgustPaint = Paint()
      ..color = Colors.green.shade200
      ..style = PaintingStyle.fill;
    final disgustRect = Rect.fromLTWH(
      (cntEmotion["joy"]! / cntSum) * size.width +
          (cntEmotion["sadness"]! / cntSum) * size.width,
      0,
      (cntEmotion["disgust"]! / cntSum) * size.width,
      size.height,
    );
    canvas.drawRect(disgustRect, disgustPaint);

    // fear
    final fearPaint = Paint()
      ..color = Colors.purple.shade200
      ..style = PaintingStyle.fill;
    final fearRect = Rect.fromLTWH(
      (cntEmotion["joy"]! / cntSum) * size.width +
          (cntEmotion["sadness"]! / cntSum) * size.width +
          (cntEmotion["disgust"]! / cntSum) * size.width,
      0,
      (cntEmotion["fear"]! / cntSum) * size.width,
      size.height,
    );
    canvas.drawRect(fearRect, fearPaint);

    // anger
    final angerPaint = Paint()
      ..color = Colors.red.shade200
      ..style = PaintingStyle.fill;
    final angerRect = Rect.fromLTWH(
      (cntEmotion["joy"]! / cntSum) * size.width +
          (cntEmotion["sadness"]! / cntSum) * size.width +
          (cntEmotion["disgust"]! / cntSum) * size.width +
          (cntEmotion["fear"]! / cntSum) * size.width,
      0,
      (cntEmotion["anger"]! / cntSum) * size.width,
      size.height,
    );
    canvas.drawRect(angerRect, angerPaint);
  }

  @override
  bool shouldRepaint(covariant EmotionBar oldDelegate) {
    return false;
    // return oldDelegate.progressValue != progressValue;
  }
}
