import 'package:flutter/material.dart';

class QuizBottomSheet extends StatelessWidget {
  final Widget widget;
  const QuizBottomSheet(this.widget);

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      builder: (_) => AnimatedPadding(
          padding: EdgeInsets.only(
              bottom:
              MediaQuery.of(context).viewInsets.bottom),
          duration: const Duration(milliseconds: 100),
          child: Container(
              height: 200,
              child: widget)),
      onClosing: () {},
    );
  }
}