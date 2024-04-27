import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_page.dart';
import 'package:flutter_application_1/registration_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage();

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  int userId = 0;

  void showErrorMessage(BuildContext context, String message) {
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

  Future<void> checkLicenseStatus(int userId) async {
    try {
      var response = await http.get(
        Uri.parse('http://62.217.182.138:3000/licenseStatus/${userId}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        var licenseStatus = json.decode(response.body);
        if (licenseStatus['active'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(userId)),
          );
        }
      } else {
        showErrorMessage(context, 'Ошибка при проверке статуса лицензии');
      }
    } catch (e) {
      showErrorMessage(context, 'Ошибка при проверке статуса лицензии: $e');
    }
  }

  Future<void> loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showErrorMessage(context, 'Введите email и пароль');
      return;
    }

    try {
      var requestBody = jsonEncode({
        'email': email,
        'password': password,
      });

      var response = await http.post(
        Uri.parse('http://62.217.182.138:3000/userlogin'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('email', email);

        var responseData = json.decode(response.body);
        userId = responseData['userId'];

        await checkLicenseStatus(userId);
      } else {
        showErrorMessage(context, 'Неверный email или пароль');
      }
    } catch (e) {
      showErrorMessage(context, 'Ошибка аутентификации: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFCEAD),
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > 600) {
            return _buildDesktopLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Авторизация',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(119, 75, 36, 1),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: Color.fromRGBO(119, 75, 36, 1),
              ),
              decoration: InputDecoration(
                hintText: 'Email',
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
            TextField(
              controller: passwordController,
              obscureText: true,
              style: TextStyle(
                color: Color.fromRGBO(119, 75, 36, 1),
              ),
              decoration: InputDecoration(
                hintText: 'Пароль',
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
                loginUser();
              },
              child: Text('Войти'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Color.fromRGBO(239, 206, 173, 1),
                backgroundColor: Color.fromRGBO(119, 75, 36, 1),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()),
                );
              },
              child: Text(
                'Нет аккаунта?',
                style: TextStyle(
                  color: Color.fromRGBO(119, 75, 36, 1),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 20),
          Text(
            'Авторизация',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(119, 75, 36, 1),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Color.fromRGBO(119, 75, 36, 1),
            ),
            decoration: InputDecoration(
              hintText: 'Email',
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
          TextField(
            controller: passwordController,
            obscureText: true,
            style: TextStyle(
              color: Color.fromRGBO(119, 75, 36, 1),
            ),
            decoration: InputDecoration(
              hintText: 'Пароль',
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
              loginUser();
            },
            child: Text('Войти'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Color.fromRGBO(239, 206, 173, 1),
              backgroundColor: Color.fromRGBO(119, 75, 36, 1),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          SizedBox(height: 20),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => RegistrationPage()),
              );
            },
            child: Text(
              'Нет аккаунта?',
              style: TextStyle(
                color: Color.fromRGBO(119, 75, 36, 1),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
