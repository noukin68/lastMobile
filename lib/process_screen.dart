import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/process_info.dart';

class ProcessInfoScreen extends StatelessWidget {
  final List<ProcessInfo> processInfoList;

  ProcessInfoScreen(this.processInfoList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Информация о процессах'),
        backgroundColor: Color.fromRGBO(119, 75, 36, 1),
      ),
      body: ListView.builder(
        itemCount: processInfoList.length,
        itemBuilder: (context, index) {
          final processInfo = processInfoList[index];

          final startTimeFormatted = formatDateTime(processInfo.startTime);
          final elapsedTimeFormatted = formatDuration(processInfo.elapsedTime);

          return ListTile(
            title: Text(processInfo.processName),
            subtitle: Text(
              'Дата и время запуска: $startTimeFormatted\nПрошедшее время: $elapsedTimeFormatted',
            ),
          );
        },
      ),
    );
  }

  String formatDateTime(String dateTimeString) {
    final parsedDateTime = DateTime.parse(dateTimeString);
    final formattedDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedDateTime);
    return formattedDateTime;
  }

  String formatDuration(String durationString) {
    final parts = durationString.split('.');
    final formattedDuration = parts[0];
    return formattedDuration;
  }
}
