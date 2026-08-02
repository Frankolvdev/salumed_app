import 'package:app/components/fade_animation.dart';
import 'package:flutter/material.dart';

class EmptyStateImage extends StatefulWidget {
  final String subtitle;
  final Widget widget;
  final bool showEmpty;
  EmptyStateImage(this.subtitle, this.widget, this.showEmpty);

  @override
  _EmptyStateImageState createState() => _EmptyStateImageState();
}

class _EmptyStateImageState extends State<EmptyStateImage> {
  @override
  Widget build(BuildContext context) {
    if (widget.showEmpty) {
      return Center(
          child: FadeAnimation(
              1.5,
              Container(
                height: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                        image: AssetImage('assets/images/empty-state.png'),
                        height: 100),
                    Text(widget.subtitle)
                  ],
                ),
              )));
    } else {
      return widget.widget;
    }
  }
}
