import 'dart:async';

import 'package:app/components/count_down.dart';
import 'package:app/components/count_down_seconds.dart';
import 'package:app/components/fade_animation.dart';
import 'package:app/constants/colors.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

import 'package:flutter/material.dart';
import 'package:app/compat/flutter_page_transition.dart';
import 'package:simple_animations/simple_animations/animation_controller_x/animation_controller_mixin.dart';

class Breathing extends StatefulWidget {
  const Breathing({Key? key}) : super(key: key);

  @override
  State<Breathing> createState() => _BreathingState();
}

class _BreathingState extends State<Breathing>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controllerAnimationWaves;
  CountDownController _countDownController = new CountDownController();
  CountDownSecondsController _countDownSecondsController =
      new CountDownSecondsController();

  CountDownSecondsController _countDownStep1 = new CountDownSecondsController();
  CountDownSecondsController _countDownStep2 = new CountDownSecondsController();
  CountDownSecondsController _countDownStep3 = new CountDownSecondsController();
  CountDownSecondsController _countDownStep4 = new CountDownSecondsController();
  CountDownSecondsController _countDownStep5 = new CountDownSecondsController();

  var swatch = Stopwatch();

  int step = 0;
  bool showCounter = false;

  late AnimationController _breathingController;

  var _breather = 0.0;
  var audioPlayer;
  @override
  void initState() {
    super.initState();
    /*_controllerAnimationWaves = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: Duration(seconds: 4),
    )..repeat();*/

    _breathingController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 3000));
    _breathingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _breathingController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _breathingController.forward();
      }
    });
    _breathingController.addListener(() {
      if (mounted) {
        setState(() {
          _breather = _breathingController.value;
        });
      }
    });
    _breathingController.forward();

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      restartBreathing();

      audioPlayer = AssetsAudioPlayer.newPlayer();
      /* (audioPlayer as AssetsAudioPlayer).open(Audio("assets/sound/rain.mp3"),
          autoStart: true, showNotification: false, loopMode: LoopMode.single);*/
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    try {
      (audioPlayer as AssetsAudioPlayer).stop();
    } catch (e) {}
    super.dispose();
  }

  restartBreathing() {
    setState(() {
      step = 0;
    });
    _countDownSecondsController.start();
    _countDownSecondsController.callbackEnd = callbackEndCountDown4seconds;
  }

  bool show4seconds = true;
  bool showStep1 = false;
  bool showStep2 = false;
  bool showStep3 = false;
  bool showStep4 = false;
  bool showStep5 = false;
  bool showInhale = false;
  int globalSteps = 0;
  bool showEnd = false;
  callbackEndCountDown4seconds() {
    setState(() {
      show4seconds = false;
      step = 1;
      showStep1 = true;
    });
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _countDownStep1.start();
      _countDownStep1.callbackEnd = callbackStep1;
    });
  }

  callbackStep1({bool fromEnd = false}) {
    setState(() {
      showStep1 = false;
      showStep2 = true;
      step = 2;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
           if (fromEnd == false) {
       // _countDownController.start();
      }


      _countDownStep2.start();
      _countDownStep2.callbackEnd = callbackStep2;
    });
  }

bool entry=false;
  callbackStep2({bool fromEnd = false}) {
    setState(() {
      showStep3 = true;
      showStep2 = false;
      showCounter = true;
      showInhale = true;
    });
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (entry == false) {
        _countDownController.start();
        setState(() {
          entry=true;
        });
      }

      _countDownStep3.start();
      _countDownStep3.callbackEnd = callbackStep3;
    });
  }

  callbackStep3() {
    setState(() {
      showStep3 = false;
      showStep4 = true;
      showInhale = false;
    });
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _countDownStep4.start();
      _countDownStep4.callbackStep = callbackStepCount1;
      _countDownStep4.callbackEnd = callbackStep4;
    });
  }

  int count = 0;
  callbackStepCount1() {
    setState(() {
      count++;
    });
  }

  callbackStep4() {
    setState(() {
      showStep4 = false;
      showStep5 = true;
    });
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _countDownStep5.start();
      _countDownStep5.callbackEnd = callbackStep5;
    });
  }

  callbackStep5() {
    setState(() {
      _countDownStep1 = new CountDownSecondsController();
      _countDownStep2 = new CountDownSecondsController();
      _countDownStep3 = new CountDownSecondsController();
      _countDownStep4 = new CountDownSecondsController();
      _countDownStep5 = new CountDownSecondsController();
      showStep5 = false;
      count = 0;
      globalSteps++;
      print("global");
      print(globalSteps);
    });

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (globalSteps < 7) {
        callbackStep1(fromEnd: true);
      } else {
        setState(() {
          showEnd = true;
        });
      }
    });
  }

  Widget breathingCircle(double r, double opacity) {
    final size = r - (150 * _breather);
    return Container(
      height: size < 0 ? 0 : size,
      width: size < 0 ? 0 : size,
      child: Material(
        borderRadius: BorderRadius.circular(200.0),
        color: CustomColors.primary.withOpacity(opacity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Stack(alignment: Alignment.center, children: [
            Positioned.fill(
              top: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.white.withAlpha(220),
                child: Align(
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      (true)
                          ? Positioned(
                              child: _buildWave(
                                  300, CustomColors.primary.withOpacity(0.2)))
                          : Container(),
                      /*(step >= 2 && (!showEnd) && !showStep4)
                                ? Positioned(
                                    child: _buildWave(
                                        200 * _controllerAnimationWaves.value,
                                        CustomColors.primary.withOpacity(1 -
                                            _controllerAnimationWaves.value)))
                                : Container(),*/

                      (step >= 2 && (!showEnd) && !showStep4)
                          ? Positioned(
                              child: breathingCircle(290, 0.3),
                            )
                          : Container(),
                      (showStep5 || showStep3 || showStep4 && (!showEnd))
                          ? Positioned(
                              child: _buildWave(
                                  150, CustomColors.primary.withOpacity(0.2)))
                          : Container(),
                      /*(showStep5 || showStep3 && (!showEnd) && !showStep4)
                                ? Positioned(
                                    child: _buildWave(
                                        100 * _controllerAnimationWaves.value,
                                        CustomColors.primary.withOpacity(1 -
                                            _controllerAnimationWaves.value)))
                                : Container(),*/
                      Positioned(
                        child: SizedBox(
                          width: 300,
                          height: 300,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            value: (globalSteps == 0) ? 0 : 0.142857 * globalSteps,
                            semanticsLabel: '',
                          ),
                        ),
                      ),
                      (showStep4)
                          ? Positioned(
                              child: Image.asset('assets/images/pausa.png',
                                  width: 80))
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
            (showCounter && (!showEnd))
                ? Positioned(
                    top: 120,
                    left: 0,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeAnimation(
                          1,
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CountDown(
                                  Duration(minutes: 3, seconds: 3),
                                  controller: _countDownController)),
                        )
                      ],
                    ))
                : Container(),
            (show4seconds)
                ? Positioned(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeAnimation(
                              1,
                              Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CountDownSeconds(
                                      4, TextStyle(fontSize: 60),
                                      controller: _countDownSecondsController)))
                        ],
                      ),
                    ))
                : Container(),
            (showStep1)
                ? Positioned(
                    bottom: MediaQuery.of(context).size.height * .15,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeAnimation(
                            1,
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CountDownSeconds(
                                  4,
                                  TextStyle(fontSize: 60),
                                  controller: _countDownStep1,
                                  customWidget: Text(
                                    "Relajate y toma una postura comoda",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )),
                          )
                        ],
                      ),
                    ))
                : Container(),
            (showStep2)
                ? Positioned(
                    bottom: MediaQuery.of(context).size.height * .15,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeAnimation(
                            1,
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CountDownSeconds(
                                  7,
                                  TextStyle(fontSize: 60),
                                  controller: _countDownStep2,
                                  customWidget: Text(
                                    "Concentrate en tu respiración",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )),
                          )
                        ],
                      ),
                    ))
                : Container(),
            (showStep3)
                ? Positioned(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CountDownSeconds(
                                  7, TextStyle(fontSize: 60),
                                  controller: _countDownStep3))
                        ],
                      ),
                    ))
                : Container(),
            (showInhale)
                ? Positioned(
                    bottom: MediaQuery.of(context).size.height * .15,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeAnimation(
                              1,
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "inhala",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ))
                        ],
                      ),
                    ))
                : Container(),
            (showStep4)
                ? Positioned(
                    bottom: MediaQuery.of(context).size.height * .15,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeAnimation(
                              1,
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CountDownSeconds(
                                  5,
                                  TextStyle(fontSize: 60),
                                  controller: _countDownStep4,
                                  customWidget: Text(
                                    "Sostén",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ))
                        ],
                      ),
                    ))
                : Container(),
            (showStep4)
                ? Positioned(
                    bottom: MediaQuery.of(context).size.height * .10,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          stepCountItem(1),
                          stepCountItem(2),
                          stepCountItem(3),
                          stepCountItem(4),
                          stepCountItem(5),
                    
                        ],
                      ),
                    ))
                : Container(),
            (showStep5)
                ? Positioned(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeAnimation(
                            1,
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CountDownSeconds(
                                  8,
                                  TextStyle(fontSize: 60),
                                  controller: _countDownStep5,
                                )),
                          )
                        ],
                      ),
                    ))
                : Container(),
            (showStep5)
                ? Positioned(
                    width: MediaQuery.of(context).size.width,
                    bottom: MediaQuery.of(context).size.height * .15,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeAnimation(
                            1,
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "exhala",
                                  style: TextStyle(fontSize: 16),
                                )),
                          )
                        ],
                      ),
                    ))
                : Container(),
            (showEnd)
                ? Positioned(
                    width: MediaQuery.of(context).size.width,
                    bottom: MediaQuery.of(context).size.height * .15,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeAnimation(
                              1,
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "bien hecho",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ))
                        ],
                      ),
                    ))
                : Container(),
            AppBar(
                iconTheme: IconThemeData(
                  color: CustomColors.primary, //change your color here
                ),
                title: Text(""),
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                centerTitle: true),
            (show4seconds)
                ? Positioned(
                    width: MediaQuery.of(context).size.width,
                    bottom: MediaQuery.of(context).padding.bottom,
                    left: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeAnimation(
                              1,
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      elevation: 2,
                                      primary: CustomColors.primary,
                                      shape: StadiumBorder()),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 35.0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.stop,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Detener",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ))
                        ],
                      ),
                    ))
                : Container(),
            (showEnd)
                ? Positioned(
                    width: MediaQuery.of(context).size.width,
                    bottom: MediaQuery.of(context).padding.bottom,
                    left: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeAnimation(
                              1,
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      elevation: 2,
                                      primary: CustomColors.primary,
                                      shape: StadiumBorder()),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            child: Breathing(),
                                            type:
                                                PageTransitionType.slideInRight,
                                            duration:
                                                Duration(milliseconds: 250)));
                                  },
                                  child: Container(
                                    height: 35.0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.repeat,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Repetir",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ))
                        ],
                      ),
                    ))
                : Container()
          ]),
        ),
      ),
    );
  }

  Widget stepCountItem(int val) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: Container(
        width: 15,
        height: 5,
        decoration: BoxDecoration(
          color: (count >= val) ? Colors.grey : Colors.white,
          border: Border.all(width: 0.5, color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(0)),
        ),
      ),
    );
  }

  Widget _buildWave(double radius, Color color) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
