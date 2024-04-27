import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/timer_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final int userId;

  const HomePage(this.userId);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<HomePage> {
  IO.Socket? socket;
  TextEditingController uidController = TextEditingController();
  List<String> connectedUIDs = [];
  Map<String, IO.Socket> sockets = {};

  @override
  void initState() {
    super.initState();
    initSocket();
  }

  void initSocket() {
    socket = IO.io('http://62.217.182.138:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket?.connect();

    socket?.on('action', (data) {
      String uid = data['uid'];
      String action = data['action'];
      print('Received action: $action for UID: $uid');
    });
  }

  Future<void> saveConnectedUIDs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('connectedUIDs', connectedUIDs);
  }

  void addUID(String uid) async {
    Map<String, dynamic> requestBody = {
      'uid': uid,
      'type': 'flutter', // Добавляем тип подключения
    };

    try {
      var response = await http.post(
        Uri.parse('http://62.217.182.138:3000/check-uid-license'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        socket?.emit('join', requestBody); // Отправляем данные на сервер
        socket?.once('joined', (data) {
          setState(() {
            if (!connectedUIDs.contains(uid)) {
              connectedUIDs.add(uid);
              sockets[uid] = socket!;
            }
          });

          // После успешного добавления UID отправляем событие flutter-connected
          socket?.emit('flutter-connected', {'uid': uid});
        });
      } else {
        var jsonResponse = jsonDecode(response.body);
        showErrorMessage('Ошибка: ${jsonResponse['error']}');
      }
    } catch (error) {
      showErrorMessage('Ошибка: $error');
    }
  }

  void removeUID(String uid) {
    setState(() {
      connectedUIDs.remove(uid);
      sockets.remove(uid);
      socket?.emit('flutter-disconnected',
          {'uid': uid}); // Отправляем на сервер событие об отключении Flutter
    });
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ошибка'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFCEAD),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 20),
            Text(
              'Родительский контроль',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(119, 75, 36, 1),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: uidController,
              style: TextStyle(
                color: Color.fromRGBO(119, 75, 36, 1),
              ),
              decoration: InputDecoration(
                hintText: 'Введите UID',
                hintStyle: TextStyle(
                  color: Color.fromRGBO(119, 75, 36, 1),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(119, 75, 36, 1),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String uid = uidController.text.trim();
                if (uid.isNotEmpty) {
                  // Проверяем, что uid не пустой
                  addUID(uid);
                  uidController.clear(); // Здесь отправляется команда на сервер
                } else {
                  showErrorMessage('Пожалуйста, введите действительный UID');
                }
              },
              child: Text('Добавить соединение'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Color.fromRGBO(239, 206, 173, 1),
                backgroundColor: Color.fromRGBO(119, 75, 36, 1),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: connectedUIDs.isEmpty
                  ? Center(
                      child: Text('У пользователя нет подключений'),
                    )
                  : ListView.builder(
                      itemCount: connectedUIDs.length,
                      itemBuilder: (context, index) {
                        String uid = connectedUIDs[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 4,
                          color: Color.fromRGBO(239, 206, 173, 1),
                          child: ListTile(
                            title: Text(
                              uid,
                              style: TextStyle(
                                color: Color.fromRGBO(119, 75, 36, 1),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  color: Color.fromRGBO(119, 75, 36, 1),
                                  onPressed: () {
                                    removeUID(uid);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.arrow_forward),
                                  color: Color.fromRGBO(119, 75, 36, 1),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TimerScreen(
                                          socket: sockets[
                                              uid]!, // Используйте соответствующий экземпляр сокета для данного UID
                                          uid: uid,
                                        ),
                                      ),
                                    ).then((_) {
                                      // При возврате из TimerScreen ничего не делаем
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 20),
            Text(
              'при поддержке',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(119, 75, 36, 1),
                fontFamily: 'Calibri',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/pixel.png',
                  width: 90,
                  height: 90,
                ),
                SizedBox(
                  width: 10,
                ),
                Image.asset(
                  'assets/faz.png',
                  width: 90,
                  height: 90,
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
