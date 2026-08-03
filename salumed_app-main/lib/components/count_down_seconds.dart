import 'dart:async';

import 'package:flutter/material.dart';

class CountDownSeconds extends StatefulWidget {
  int seconds;
  TextStyle textStyle;
  Widget? customWidget;
  final CountDownSecondsController controller;
  CountDownSeconds(this.seconds, this.textStyle,
      {required this.controller, this.customWidget, Key? key})
      : super(key: key);

  @override
  State<CountDownSeconds> createState() => _CountDownSecondsState();
}

class _CountDownSecondsState extends State<CountDownSeconds> {
  late Timer timer;
  Duration duration = Duration();

  @override
  void initState() {
    widget.controller.addListener(() {
      setState(() {});
    });
    super.initState();
    widget.controller.startF = startTimer;
  }

  @override
  void dispose() {
    super.dispose();
    try {
      timer.cancel();
      widget.controller.dispose();
    } catch (e) {}
  }

  setDuration(Duration duration) {}
  resetTimer() {
    setState(() => duration = Duration(seconds: widget.seconds));
  }

  startTimer() {
    resetTimer();
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  stopTimer({bool resets = true}) {
    if (resets) {
      resetTimer();
    }
    setState(() => timer.cancel());
  }

  void addTime() {
    final addSeconds = -1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;

      if (seconds < 1) {
        try {
          widget.controller.callbackEnd();
        } catch (e) {}
      }
      if (seconds < 0) {
        timer.cancel();
      } else {
        widget.controller.callbackStep();
        duration = Duration(seconds: seconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return displayTimer();
  }

  Widget displayTimer() {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final hours = strDigits(duration.inHours);
    final minutes = strDigits(duration.inMinutes.remainder(60));
    final seconds = duration.inSeconds.remainder(60).toString();
    if (widget.customWidget == null) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [displayTimerUI(time: seconds)]);
    } else {
      return widget.customWidget ?? Container();
    }
  }

  Widget displayTimerUI({required String time}) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(2),
            child: Text(time, style: widget.textStyle),
          ),
        ],
      );
}

class CountDownSecondsController extends ChangeNotifier {
  Function startF = () {};

  Function callbackEnd = () {};
  Function callbackStep = () {};
  start() {
    startF();
    notifyListeners();
    print("entre a start");
  }

  reset() {
    notifyListeners();
  }

  stop() {
    notifyListeners();
  }
}
