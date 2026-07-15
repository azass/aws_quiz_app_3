import 'package:aws_quiz_app/resources/api_provider.dart';
import 'package:flutter/material.dart';

class QuizLink extends StatelessWidget {
  final String title;
  final String url;
  QuizLink(this.title, this.url);

  @override
  Widget build(BuildContext context) {
    bool isTopic = title.startsWith("TOPIC ") && title.endsWith("DISCUSSION");
    return GestureDetector(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: isTopic ? 9.0 : 14.0,
            fontWeight: FontWeight.w600,
            color: isTopic ? Colors.grey : Colors.blue[600],
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      onTap: () => launchURL(url),
    );
  }
}
