import 'package:flutter/material.dart';

class CustomPageRouteAnimator extends PageRouteBuilder {
  final Widget child;
  final String direction;

  CustomPageRouteAnimator({required this.child, required this.direction})
      : super(
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation) =>
    child, // The page to display when the animation is complete
  );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) =>
      SlideTransition(
        position: Tween<Offset>(
          begin: directionOffset(direction), // Begin offset
          end: Offset.zero, // End offset (Offset.zero is shorthand for Offset(0,0))
        ).animate(animation),
        child: child,
      );


  Offset directionOffset(String direction){
    switch(direction){
      case 'fromTop':
        return Offset(0, -1);
      case 'fromBottom':
        return Offset(0, 1);
      case 'fromRight':
        return Offset(1, 0);
      default:
        return Offset(0, 1);
    }
  }
}


