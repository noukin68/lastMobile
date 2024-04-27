import 'package:flutter/material.dart';

class NumberPicker extends StatefulWidget {
  final String title;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  const NumberPicker({
    required this.title,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  _NumberPickerState createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
  int value = 0;

  void increment() {
    setState(() {
      value = (value + 1) % (widget.maxValue + 1);
      if (value < widget.minValue) {
        value = widget.minValue;
      }
      widget.onChanged(value);
    });
  }

  void decrement() {
    setState(() {
      value = (value - 1) % (widget.maxValue + 1);
      if (value < widget.minValue) {
        value = widget.maxValue;
      }
      widget.onChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.title,
            style: const TextStyle(
              fontSize: 16,
              color: Color.fromRGBO(119, 75, 36, 1),
            )),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromRGBO(119, 75, 36, 1),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(119, 75, 36, 1),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.only(right: 2),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(40, 40),
                    padding: EdgeInsets.all(4),
                    textStyle: TextStyle(fontSize: 12),
                    backgroundColor: Color.fromRGBO(119, 75, 36, 1),
                    foregroundColor: Color.fromRGBO(239, 206, 173, 1),
                  ),
                  onPressed: increment,
                  child: Text('+'),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 2),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(40, 40),
                    padding: EdgeInsets.all(4),
                    textStyle: TextStyle(fontSize: 12),
                    backgroundColor: Color.fromRGBO(119, 75, 36, 1),
                    foregroundColor: Color.fromRGBO(239, 206, 173, 1),
                  ),
                  onPressed: decrement,
                  child: Text('-'),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
