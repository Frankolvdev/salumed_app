import 'dart:async';

import 'package:flutter/material.dart';

class FadeAnimation extends StatefulWidget {
  final double delay;
  final Widget child;
  final AxisAnimation axis;
  final bool negative;

  const FadeAnimation(
    this.delay,
    this.child, {
    super.key,
    this.axis = AxisAnimation.y,
    this.negative = false,
  });

  @override
  State<FadeAnimation> createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _offset;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);

    _offset = Tween<double>(
      begin: widget.negative ? 30 : -30,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    final delay = Duration(
      milliseconds: (500 * widget.delay).round(),
    );

    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      _delayTimer = Timer(delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final offset = widget.axis == AxisAnimation.x
            ? Offset(_offset.value, 0)
            : Offset(0, _offset.value);

        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: offset,
            child: child,
          ),
        );
      },
    );
  }
}

enum AxisAnimation {
  x,
  y,
}
