import 'package:flutter/material.dart';

class QuizBottomSheet extends StatelessWidget {
  final Widget widget;
  const QuizBottomSheet(this.widget);

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 100),
      child: SizedBox(height: 200, child: widget),
    );
  }
}
