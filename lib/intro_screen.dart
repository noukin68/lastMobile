import 'package:flutter/material.dart';
import 'package:flutter_application_1/login_page.dart';
import 'package:flutter_application_1/registration_page.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class IntroScreen extends StatefulWidget {
  const IntroScreen();

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Map<String, String>> _introData = [
    {
      'image': 'assets/image1.png',
    },
    {
      'image': 'assets/image2.png',
    },
    {
      'image': 'assets/image3.png',
    },
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _introData.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFEFCEAD),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      _introData[index]['image']!,
                      fit: BoxFit.fill,
                    ),
                    Container(
                      color: Colors.transparent,
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 40.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageIndicator(),
            ),
          ),
        ],
      ),
      floatingActionButton: _currentPage == _introData.length - 1
          ? FloatingActionButton(
              onPressed: () => _startApp(context),
              child: Icon(Icons.arrow_forward),
              backgroundColor: Color.fromRGBO(119, 75, 36, 1),
              foregroundColor: Color.fromRGBO(239, 206, 173, 1),
            )
          : null,
    );
  }

  void _startApp(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
      (route) => false, // Удаляем все предыдущие страницы из стека
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < _introData.length; i++) {
      indicators.add(
        i == _currentPage ? _indicator(true) : _indicator(false),
      );
    }
    return indicators;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive
            ? Color.fromRGBO(119, 75, 36, 1)
            : Color.fromRGBO(156, 138, 114, 1),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}
