import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Explicit Animation')),
        body: ExplicitAnimationDemo(),
      ),
    );
  }
}

class ExplicitAnimationDemo extends StatefulWidget {

  const ExplicitAnimationDemo({super.key});
  
  @override
  _ExplicitAnimationDemoState createState() => _ExplicitAnimationDemoState();
}

class _ExplicitAnimationDemoState extends State<ExplicitAnimationDemo>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _rotationController;
  late AnimationController _verticalController;

  late Animation<double> _sizeanimation;
  late Animation<double> _rotationAnimation;

  late Animation<Color?> _colorAnimation;
  late Color _currentColor = Colors.blue;
  late Color _nextColor = _getRandomColor();

  late Animation<double> _verticalAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _verticalController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _sizeanimation = Tween<double>(begin: 150, end: 0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.linear,
      ),
    );

    _colorAnimation = ColorTween(begin: _currentColor, end: _nextColor).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.easeInOut,
      ),
    );

    _verticalAnimation =
        Tween<double>(begin: -1, end: 1).animate(CurvedAnimation(
      parent: _verticalController,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
    _rotationController.repeat(reverse: true);

    Timer.periodic(const Duration(seconds: 2), (timer) {
      _changeColorWithFade();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _rotationController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  Color _getRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }

  void _changeColorWithFade() {
    setState(() {
      _currentColor = _nextColor;
      _nextColor = _getRandomColor();
      _colorAnimation =
          ColorTween(begin: _currentColor, end: _nextColor).animate(
        CurvedAnimation(
          parent: _rotationController,
          curve: Curves.easeInOut,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _verticalAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            _verticalAnimation.value *
                (MediaQuery.of(context).size.height / 2 - 150),
          ),
          child: Center(
            child: RotationTransition(
              turns: _rotationAnimation,
              child: Container(
                width: _sizeanimation.value,
                height: _sizeanimation.value,
                decoration: BoxDecoration(
                  color: _colorAnimation.value,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
