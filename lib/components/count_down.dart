import 'dart:async';

import 'package:flutter/material.dart';

class CountDown extends StatefulWidget {
  Duration duration;
  final CountDownController controller;
  CountDown(this.duration, {required this.controller, Key? key})
      : super(key: key);

  @override
  State<CountDown> createState() => _CountDownState();
}

class _CountDownState extends State<CountDown> {
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
    setState(() => duration = widget.duration);
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
      if (seconds < 0) {
        timer.cancel();
      } else {
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
    final seconds = strDigits(duration.inSeconds.remainder(60));
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      displayTimerUI(time: minutes),
      Text(":",
          style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black,
              fontSize: 20)),
      displayTimerUI(time: seconds)
    ]);
  }

  Widget displayTimerUI({required String time}) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(2),
            child: Text(time,
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontSize: 20)),
          ),
        ],
      );
}

class CountDownController extends ChangeNotifier {
  Function startF = () {};

  start() {
    startF();
    notifyListeners();
  }

  reset() {
    notifyListeners();
  }

  stop() {
    notifyListeners();
  }
}
