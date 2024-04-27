import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ReportScreen extends StatefulWidget {
  final IO.Socket socket;

  ReportScreen(this.socket);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int totalQuestions = 0;
  List<int> correctAnswerIndices = [];

  @override
  void initState() {
    super.initState();

    widget.socket.on(
      'questionnaire-data',
      (data) {
        setState(() {
          totalQuestions = data['totalQuestions'];
          correctAnswerIndices = List<int>.from(data['correctAnswerIndices']);
        });
      },
    );
    widget.socket.emit('request-questionnaire-data');
  }

  double calculateAccuracyPercentage() {
    int correctAnswers = 0;
    correctAnswerIndices.forEach((index) {
      if (index >= 0 && index < 4) {
        correctAnswers++;
      }
    });
    return totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
  }

  @override
  Widget build(BuildContext context) {
    double accuracyPercentage = calculateAccuracyPercentage();

    return Scaffold(
      appBar: AppBar(title: Text('Daily Report')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Correct Answers: ${correctAnswerIndices.length}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Total Questions: $totalQuestions',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Accuracy: ${accuracyPercentage.toStringAsFixed(2)}%',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
