import 'package:flutter/material.dart';

class CustomPageRouteAnimator extends PageRouteBuilder {
  final Widget child;
  final String direction;
  final VoidCallback runThis; // Keep it as a final field.

  CustomPageRouteAnimator({
    required this.child,
    required this.direction,
    VoidCallback? runThis, // Make runThis a nullable named parameter.
  }) : runThis = runThis ?? (() {}), // Assign the provided callback or a no-op.
        super(
        transitionDuration: Duration(milliseconds: 300),
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) =>
        child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // You can implement custom transition logic based on 'direction'
          // For simplicity, the example below just fades in the new page.
          return FadeTransition(opacity: animation, child: child);
        },
      );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: directionOffset(direction), // Begin offset
        end: Offset.zero, // End offset (Offset.zero is shorthand for Offset(0,0))
      ).animate(animation),
      child: child,
    );
  }

  Offset directionOffset(String direction) {
    switch(direction) {
      case 'fromTop':
        return Offset(0, -1);
      case 'fromBottom':
        return Offset(0, 1);
      case 'fromRight':
        return Offset(1, 0);
      default:
        return Offset(0, 1); // Assuming default is fromBottom for any other string input.
    }
  }

  @override
  void didComplete(result) {
    super.didComplete(result);
    runThis(); // Execute the callback when the transition is complete
  }
}
