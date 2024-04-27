import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_application_1/circle_progress_painter.dart';
import 'package:flutter_application_1/countdown_timer.dart';
import 'package:flutter_application_1/login_page.dart';
import 'package:flutter_application_1/number_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/process_info.dart';
import 'package:flutter_application_1/process_screen.dart';
import 'package:flutter_application_1/request_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'main.dart';

class TimerScreen extends StatefulWidget {
  final IO.Socket socket;
  final String uid;

  TimerScreen({required this.socket, required this.uid});
  static List<ProcessInfo> processInfoList = [];

  static ReceivePort? receivePort;

  static Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort('Notification action port in main isolate')
      ..listen(
          (silentData) => onActionReceivedImplementationMethod(silentData));

    IsolateNameServer.registerPortWithName(
        receivePort!.sendPort, 'notification_action_port');
  }

  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      // ...
    } else {
      if (receivePort == null) {
        SendPort? sendPort =
            IsolateNameServer.lookupPortByName('notification_action_port');

        if (sendPort != null) {
          sendPort.send(receivedAction);
          return;
        }
      }

      return onActionReceivedImplementationMethod(receivedAction);
    }
  }

  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.Default) {
      Navigator.push(
        MyApp.navigatorKey.currentState!.context,
        MaterialPageRoute(
          builder: (context) => ProcessInfoScreen(TimerScreen.processInfoList),
        ),
      );
    }
  }

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  int hours = 0;
  int minutes = 0;
  int seconds = 0;
  bool isCountingDown = false;
  bool isTimerRunning = false;
  bool isSocketConnected = true;
  List<ProcessInfo> processInfoList = [];

  String selectedSubject = 'История';
  int selectedClass = 5;

  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();

    Permission.notification.request();

    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Канал для базовых уведомлений',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
          playSound: true,
          onlyAlertOnce: true,
          enableLights: true,
          enableVibration: true,
        ),
      ],
    );

    widget.socket.on('process-data', (data) {
      setState(() {
        if (data != null && data['processes'] != null && data['uid'] != null) {
          var processes = data['processes'];
          if (processes is List) {
            TimerScreen.processInfoList = List<ProcessInfo>.from(
              processes.map((item) {
                if (item is Map<String, dynamic>) {
                  return ProcessInfo.fromJson(item);
                }
              }),
            );
            processInfoList = List<ProcessInfo>.from(
              processes.map((item) {
                if (item is Map<String, dynamic>) {
                  return ProcessInfo.fromJson(item);
                }
              }),
            );
          } else {
            TimerScreen.processInfoList = [];
            processInfoList = [];
          }
          // Теперь вы можете использовать uid по вашему усмотрению.
        } else {
          TimerScreen.processInfoList = [];
          processInfoList = [];
        }
      });

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: -1,
          channelKey: 'basic_channel',
          title: 'Отчет готов!',
          body: 'Просмотрите ежедневный отчет.',
          bigPicture:
              'https://stop-ugroza.ru/wp-content/uploads/2022/10/roditelskij-kontrol-980x642.jpg',
          largeIcon: 'https://cdn-icons-png.flaticon.com/512/9621/9621072.png',
          notificationLayout: NotificationLayout.BigPicture,
          payload: {'notificationId': '1234567890'},
        ),
        actionButtons: [
          NotificationActionButton(key: 'REDIRECT', label: 'Просмотреть'),
          NotificationActionButton(
            key: 'DISMISS',
            label: 'Закрыть',
            actionType: ActionType.DismissAction,
            isDangerousOption: true,
          ),
        ],
      );
    });

    widget.socket.on('connection-status', (data) {
      setState(() {
        isSocketConnected = data['connected'];
      });
    });

    widget.socket.on('restart-time', (data) => restartTime(data));

    widget.socket.on(
      'test-completed',
      (data) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: const Color.fromRGBO(119, 75, 36, 1),
              title: Text(
                "Уведомление",
                style: TextStyle(
                  color: const Color.fromRGBO(239, 206, 173, 1),
                ),
              ),
              content: Text(
                "Тест завершен",
                style: TextStyle(
                  color: const Color.fromRGBO(239, 206, 173, 1),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: onContinuePressed,
                  child: Text(
                    'Продолжить работу',
                    style: TextStyle(
                      color: const Color(0xFFEFCEAD),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onFinishPressed,
                  child: Text(
                    'Завершить работу',
                    style: TextStyle(
                      color: const Color(0xFFEFCEAD),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @pragma("vm:entry-point")
  static Future<void> navigateToProcessInfoScreen(
      BuildContext context, List<ProcessInfo> processInfoList) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProcessInfoScreen(processInfoList),
      ),
    );
  }

  void restartTime(data) {
    try {
      final jsonData = json.decode(data);
      final List<RequestResponse> restart = (jsonData as List)
          .map((item) => RequestResponse.fromJson(item))
          .toList();

      if (restart.isNotEmpty) {
        final uid = restart[0].uid;

        if (uid == widget.uid) {
          setState(() {
            sendTimeToServer();
          });
        } else {
          print('UID не соответствует');
        }
      } else {
        print('Ошибка десериализации ответа');
      }
    } catch (e) {
      print('Ошибка при обработке данных перезапуска: $e');
    }
  }

  Future<void> sendSubjectAndClassToServer(
      String selectedSubject, int selectedClass) async {
    widget.socket.emit('subject-and-class', {
      'uid': widget.uid,
      'subject': selectedSubject,
      'grade': selectedClass
    });
  }

  Future<String?> showSubjectSelectionDialog() async {
    final selectedSubject = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromRGBO(156, 138, 114, 1),
          title: Text(
            'Выберите предмет',
            style: TextStyle(
              color: Color.fromRGBO(119, 75, 36, 1),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(
                  'История',
                  style: TextStyle(
                    color: Color.fromRGBO(239, 206, 173, 1),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context, 'История');
                },
              ),
              // Добавьте другие варианты предметов здесь при необходимости.
            ],
          ),
        );
      },
    );

    if (selectedSubject == null) {
      return null;
    }

    return selectedSubject;
  }

  Future<int?> showClassSelectionDialog() async {
    final selectedClass = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Color.fromRGBO(156, 138, 114, 1),
          title: Text(
            'Выберите класс',
            style: TextStyle(
              color: Color.fromRGBO(119, 75, 36, 1),
            ),
          ),
          children: <Widget>[
            for (int i = 5; i <= 11; i++)
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, i);
                },
                child: Text(
                  '$i класс',
                  style: TextStyle(
                    color: Color.fromRGBO(239, 206, 173, 1),
                  ),
                ),
              ),
          ],
        );
      },
    );
    if (selectedClass == null) {
      return null;
    }
    return selectedClass;
  }

  Future<void> onContinuePressed() async {
    widget.socket.emit('continue-work', {
      'uid': widget.uid,
    });
    Navigator.pop(context);
  }

  void onFinishPressed() {
    widget.socket.emit('finish-work', {
      'uid': widget.uid,
    });
    Navigator.pop(context);
  }

  void startCountdown() {
    final totalSeconds = hours * 3600 + minutes * 60 + seconds;

    setState(() {
      isCountingDown = true;
      isTimerRunning = true;
    });

    Future.delayed(Duration(seconds: totalSeconds), () {
      setState(() {
        isCountingDown = false;
        isTimerRunning = false;
        hours = 0;
        minutes = 0;
        seconds = 0;
      });
    });
  }

  void stopCountdown() {
    setState(() {
      isCountingDown = false;
      isTimerRunning = false;
    });

    final totalSeconds = calculateRemainingSeconds();
    print('Stopping timer and sending time: $totalSeconds');
    widget.socket.emit('stop-timer', {
      'uid': widget.uid,
      'totalSeconds': totalSeconds,
    });
  }

  void sendTimeToServer() {
    final totalSeconds = hours * 3600 + minutes * 60 + seconds;

    print('Sending time: $hours:$minutes:$seconds');
    widget.socket.emit('time-received', {
      'uid': widget.uid,
      'timeInSeconds': totalSeconds,
    });

    startCountdown();
  }

  int calculateRemainingSeconds() {
    final totalSeconds = hours * 3600 + minutes * 60 + seconds;
    return totalSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Лимит времени'),
        backgroundColor: const Color.fromRGBO(119, 75, 36, 1),
        foregroundColor: const Color.fromRGBO(239, 206, 173, 1),
        actions: [
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: const Color.fromRGBO(239, 206, 173, 1),
            ),
            onPressed: () => logout(),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFEFCEAD),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: CircleProgressPainter(
                      remainingSeconds: calculateRemainingSeconds()),
                  child: Center(
                    child: isCountingDown
                        ? CountdownTimer(
                            seconds: calculateRemainingSeconds(),
                            onFinish: () {
                              setState(() {
                                isCountingDown = false;
                              });
                            },
                          )
                        : Text(
                            formatTime(calculateRemainingSeconds()),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(119, 75, 36, 1),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NumberPicker(
                    title: 'Часы',
                    minValue: 0,
                    maxValue: 23,
                    onChanged: (value) {
                      setState(() {
                        hours = value;
                      });
                    },
                  ),
                  NumberPicker(
                    title: 'Минуты',
                    minValue: 0,
                    maxValue: 59,
                    onChanged: (value) {
                      setState(() {
                        minutes = value;
                      });
                    },
                  ),
                  NumberPicker(
                    title: 'Секунды',
                    minValue: 0,
                    maxValue: 59,
                    onChanged: (value) {
                      setState(() {
                        seconds = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _buttonScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _buttonScaleAnimation.value,
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTapDown: (_) {
                    _buttonAnimationController.forward();
                  },
                  onTapUp: (_) async {
                    _buttonAnimationController.reverse();
                    final subjectSelected = await showSubjectSelectionDialog();
                    if (subjectSelected == null) {
                      return;
                    }
                    final classSelected = await showClassSelectionDialog();
                    if (classSelected == null) {
                      return;
                    }
                    sendSubjectAndClassToServer(subjectSelected, classSelected);
                    sendTimeToServer();
                  },
                  onTapCancel: () {
                    _buttonAnimationController.reverse();
                  },
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: const Color.fromRGBO(119, 75, 36, 1),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            color: Color.fromRGBO(239, 206, 173, 1),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Установить таймер',
                            style: TextStyle(
                              color: Color.fromRGBO(239, 206, 173, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _buttonScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _buttonScaleAnimation.value,
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTapDown: (_) {
                    _buttonAnimationController.forward();
                  },
                  onTapUp: (_) {
                    _buttonAnimationController.reverse();
                    stopCountdown();
                  },
                  onTapCancel: () {
                    _buttonAnimationController.reverse();
                  },
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: const Color.fromRGBO(119, 75, 36, 1),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.stop,
                            color: Color.fromRGBO(239, 206, 173, 1),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Остановить таймер',
                            style: TextStyle(
                              color: Color.fromRGBO(239, 206, 173, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _buttonScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _buttonScaleAnimation.value,
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTapDown: (_) {
                    _buttonAnimationController.forward();
                  },
                  onTapUp: (_) {
                    _buttonAnimationController.reverse();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProcessInfoScreen(processInfoList),
                      ),
                    );
                  },
                  onTapCancel: () {
                    _buttonAnimationController.reverse();
                  },
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: const Color.fromRGBO(119, 75, 36, 1),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color.fromRGBO(239, 206, 173, 1),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Отчёт',
                            style: TextStyle(
                              color: Color.fromRGBO(239, 206, 173, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Статус подключения: ${isSocketConnected ? 'Сопряжено' : 'Не сопряжено'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(119, 75, 36, 1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  String formatTime(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')} : ${minutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')}';
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
