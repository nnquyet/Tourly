import 'package:flutter/material.dart';

import '../app_constants.dart';

class ThreeDots extends StatefulWidget {
  const ThreeDots({super.key});

  @override
  ThreeDotsState createState() => ThreeDotsState();
}

class ThreeDotsState extends State<ThreeDots> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _currentIndex++;
          if (_currentIndex == 3) {
            _currentIndex = 0;
          }
          _animationController!.reset();
          _animationController!.forward();
        }
      });
    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController!,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/bot.png'),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  Text(
                    'Bot',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              Container(
                width: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppConst.kBotChatColor,
                ),
                margin: const EdgeInsets.only(top: 5),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: List.generate(1, (index) {
                      return Opacity(
                        opacity: index == _currentIndex ? 1.0 : 0.2,
                        child: const Text(
                          '▊',
                          textScaleFactor: 1,
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
