import 'package:aws_quiz_app/models/question.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_image.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_markdown.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

import '../util.dart';

class QuizQuestCard extends StatelessWidget {
  final Question question;
  QuizQuestCard(this.question);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: CARD_COLOR,
      margin: const EdgeInsets.all(5.0),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 10.0,
          right: 5.0,
          bottom: 20.0,
          left: 12.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ...question.questionElems.map(
              (questionElem) => _buildQuestionElem(questionElem),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionElem(Map<String, dynamic> questionElem) {
    if (questionElem.containsKey("image_path")) {
      return QuizImage(questionElem["image_path"]);
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        // child: SelectableText(
        //   HtmlUnescape().convert(questionElem["text"]),
        //   textAlign: TextAlign.left,
        //   style: MediaQuery.of(context).size.width > 800
        //       ? _quizStyle.copyWith(fontSize: 30.0)
        //       : _quizStyle,
        child: QuizMarkdown(HtmlUnescape().convert(questionElem["text"])),
      );
    }
  }
}
