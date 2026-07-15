import 'package:flutter/material.dart';

import '../util.dart';

class QuizAppBar extends StatelessWidget {
  final String questId;
  final int estimatedTime;
  final int currentIndex;
  final int questionsLength;
  final bool readOnly;
  final bool isAnswered;
  QuizAppBar(
    this.questId,
    this.estimatedTime,
    this.currentIndex,
    this.questionsLength,
    this.readOnly,
    this.isAnswered,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          questId,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        _buildPointText(),
      ],
    );
  }

  Widget _buildPointText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!readOnly)
          Padding(
            padding: EdgeInsets.only(bottom: 5.0, right: 0.0),
            child: Text(
              "想定時間: ${formatTime(estimatedTime)}( ${_avgEstimatedTime()} )",
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        RichText(
          text: TextSpan(
            children: [
              if (!readOnly)
                TextSpan(
                  text: "残り： ",
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              if (!readOnly)
                TextSpan(
                  text:
                      '${questionsLength - currentIndex - (isAnswered ? 1 : 0)} ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              TextSpan(
                text: " (${(currentIndex + 1)}/${questionsLength})",
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _avgEstimatedTime() {
    int n = questionsLength - currentIndex - (isAnswered ? 1 : 0);
    if (n > 0)
      return formatTime((estimatedTime / n).toInt());
    else
      return formatTime(0);
  }
}
