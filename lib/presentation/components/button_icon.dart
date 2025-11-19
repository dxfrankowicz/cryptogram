import 'package:flutter/material.dart';

class IconInteractive extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const IconInteractive({Key? key, required this.icon, required this.onTap}) : super(key: key);

  @override
  _IconInteractiveState createState() => _IconInteractiveState();
}

class _IconInteractiveState extends State<IconInteractive> {
  Color color = Colors.white;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6)))),
      ),
      icon: Icon(widget.icon, color: color),
      onPressed: () {
        widget.onTap.call();
      },
      // child: Card(
      //     margin: const EdgeInsets.only(bottom: 6, right: 6),
      //     child: Padding(
      //       padding: const EdgeInsets.all(6.0),
      //       child: Icon(widget.icon, color: color),
      //     )),
    );
  }
}
