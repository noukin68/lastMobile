import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final int seconds;
  final VoidCallback onFinish;

  const CountdownTimer({required this.seconds, required this.onFinish});

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.seconds;
    startCountdown();
  }

  void startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer.cancel();
          widget.onFinish();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final int hours = _remainingSeconds ~/ 3600;
    final int minutes = (_remainingSeconds % 3600) ~/ 60;
    final int seconds = _remainingSeconds % 60;

    return Text(
      '$hours : ${minutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')}',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color.fromRGBO(119, 75, 36, 1),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
