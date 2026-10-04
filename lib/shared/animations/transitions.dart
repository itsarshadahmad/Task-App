import 'package:flutter/material.dart';

class SlideUpTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const SlideUpTransition({
    super.key,
    required this.child,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}

class SlideDownTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const SlideDownTransition({
    super.key,
    required this.child,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}

class SlideLeftTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const SlideLeftTransition({
    super.key,
    required this.child,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}

class SlideRightTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const SlideRightTransition({
    super.key,
    required this.child,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}

class FadeScaleTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const FadeScaleTransition({
    super.key,
    required this.child,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.9,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

class PageTransition extends PageRouteBuilder {
  final Widget child;
  final String type;

  PageTransition({
    required this.child,
    this.type = 'slideUp',
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            switch (type) {
              case 'slideUp':
                return SlideUpTransition(
                  child: child,
                  animation: animation,
                );
              case 'slideDown':
                return SlideDownTransition(
                  child: child,
                  animation: animation,
                );
              case 'slideLeft':
                return SlideLeftTransition(
                  child: child,
                  animation: animation,
                );
              case 'slideRight':
                return SlideRightTransition(
                  child: child,
                  animation: animation,
                );
              case 'fadeScale':
                return FadeScaleTransition(
                  child: child,
                  animation: animation,
                );
              default:
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
            }
          },
        );
}
