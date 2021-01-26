import 'package:flutter/material.dart';

class TestUI extends StatefulWidget {
  TestUI(this.x, this.y);

  final double x;
  final double y;

  @override
  _TestUIState createState() => _TestUIState();
}

class _TestUIState extends State<TestUI> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 0),
      alignment: Alignment(widget.x, widget.y),
      child: ElevatedButton(
        child: Icon(Icons.account_tree),
        onPressed: () => null,
      ),
    );
  }
}
