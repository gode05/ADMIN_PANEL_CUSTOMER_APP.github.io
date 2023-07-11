import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  TextWidget({
    Key? key,
    required this.text,
    required this.color,
    this.textSize = 16,
    this.maxLines = 1,
    this.isTitle = false,
  }) : super(key: key);
  final String text;
  final Color color;
  final double textSize;
  bool isTitle;
  int maxLines = 1;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      style: TextStyle(
          fontSize: textSize,
          color: color,
          overflow: TextOverflow.ellipsis,
          fontWeight: isTitle ? FontWeight.w600 : FontWeight.w400),
    );
  }
}
