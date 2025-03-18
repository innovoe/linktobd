import 'package:flutter/material.dart';

enum SwipeDirection { left, right }

class GestureDetectorDrag extends StatefulWidget {
  final Widget child;
  final double dragThreshold;
  final VoidCallback? onSwipeComplete;
  final SwipeDirection swipeTo;

  const GestureDetectorDrag({
    Key? key,
    required this.child,
    this.dragThreshold = 100.0,
    this.onSwipeComplete,
    this.swipeTo = SwipeDirection.left, // Default swipe direction
  }) : super(key: key);

  @override
  _GestureDetectorDragState createState() => _GestureDetectorDragState();
}

class _GestureDetectorDragState extends State<GestureDetectorDrag> {
  double _dragDistance = 0.0;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child, // Underlying content

        // Positioned arrow based on swipe direction
        Positioned(
          left: widget.swipeTo == SwipeDirection.left ? 20 : null,
          right: widget.swipeTo == SwipeDirection.right ? 20 : null,
          top: MediaQuery.of(context).size.height / 2 - 25, // Center vertically
          child: Opacity(
            opacity: _getArrowOpacity(), // Opacity based on drag distance
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, // White background for the circle
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: EdgeInsets.all(10),
              child: Icon(
                widget.swipeTo == SwipeDirection.left
                    ? Icons.arrow_back_ios_new_rounded // Left arrow
                    : Icons.arrow_forward_ios_rounded, // Right arrow
                size: 30, // Icon size
                color: Colors.black, // Black color for the arrow
              ),
            ),
          ),
        ),

        // Gesture detector for swipe handling
        GestureDetector(
          onHorizontalDragStart: (_) {
            setState(() {
              _dragging = true;
            });
          },
          onHorizontalDragUpdate: (details) {
            setState(() {
              if (widget.swipeTo == SwipeDirection.left && details.primaryDelta! > 0) {
                _dragDistance += details.primaryDelta!;
              } else if (widget.swipeTo == SwipeDirection.right && details.primaryDelta! < 0) {
                _dragDistance += details.primaryDelta!;
              }
            });
          },
          onHorizontalDragEnd: (details) {
            setState(() {
              _dragging = false;
            });

            // Check if drag distance exceeds the threshold
            if (_dragDistance.abs() > widget.dragThreshold) {
              // Trigger callback or pop the page
              widget.onSwipeComplete != null
                  ? widget.onSwipeComplete!()
                  : Navigator.pop(context);
            } else {
              // Reset drag distance if threshold is not met
              setState(() {
                _dragDistance = 0.0;
              });
            }
          },
        ),
      ],
    );
  }

  // Calculate opacity for arrow based on drag distance
  double _getArrowOpacity() {
    double opacity = _dragDistance.abs() / widget.dragThreshold;
    if (opacity > 1.0) opacity = 1.0; // Maximum opacity
    if (opacity < 0.0) opacity = 0.0; // Start fully invisible
    return opacity;
  }
}
