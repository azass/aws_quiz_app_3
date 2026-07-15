import 'package:aws_quiz_app/models/question.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class QuizQuestHead extends StatelessWidget {
  final Question question;
  QuizQuestHead(this.question);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 10.0),
            child: Text(
              "Q ${question.examNo}",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w800,
                color: Colors.blueGrey[800],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 100.0),
            child: RatingBarIndicator(
              rating: question.correctCount.toDouble(),
              itemCount: 10,
              itemSize: 20.0,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, _) =>
                  Icon(Icons.star, color: Colors.yellow[400]),
            ),
          ),
        ),
        // Align(
        //     alignment: Alignment.centerRight,
        //     child: Wrap(children: _buildLarningLabel())),
      ],
    );
  }
}
