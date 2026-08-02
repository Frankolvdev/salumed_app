import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class FadeAnimation extends StatelessWidget {

 

  final double delay;
  final Widget child;
  final AxisAnimation axis;
  final bool negative;

  FadeAnimation(this.delay, this.child,{ this.axis=AxisAnimation.y, this.negative=false});

  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("opacity").add(Duration(milliseconds: 500), Tween(begin: 0.0, end: 1.0)),
      Track((axis==AxisAnimation.x)?"translateX":"translateY").add(
        Duration(milliseconds: 500),(negative)?Tween(begin: 30.0, end:0.0) :Tween(begin: -30.0, end: 0.0),
        curve: Curves.easeOut)
    ]);

    return ControlledAnimation(
      delay: Duration(milliseconds: (500 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builderWithChild: (context, child, animation) => Opacity(
        opacity: (animation as dynamic)["opacity"],
        child: Transform.translate(
          offset:(axis==AxisAnimation.x)? Offset((animation as dynamic)["translateX"], 0):Offset(0,(animation as dynamic)["translateY"]), 
          child: child
        ),
      ),
    );
  }
}

 enum AxisAnimation {
  x,
  y,
}