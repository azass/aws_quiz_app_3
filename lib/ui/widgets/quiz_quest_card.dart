import 'package:aws_quiz_app/models/question.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_image.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_markdown.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

import '../util.dart';

class QuizQuestCard extends StatelessWidget {
  final Question question;
  final Future<void> Function(String text) onToggleSpeech;
  final Future<void> Function() onStopSpeech;
  final bool isSpeaking;
  final bool isSpeechPaused;
  QuizQuestCard(
    this.question, {
    required this.onToggleSpeech,
    required this.onStopSpeech,
    required this.isSpeaking,
    required this.isSpeechPaused,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: CARD_COLOR,
      margin: const EdgeInsets.all(5.0),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 5.0,
          right: 5.0,
          bottom: 5.0,
          left: 12.0,
        ),
        child: Column(
          spacing: 0.0,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ...question.questionElems.map(
                  (questionElem) => _buildQuestionElem(questionElem),
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                tooltip: isSpeaking
                    ? (isSpeechPaused ? '読み上げを再開する' : '読み上げを一時停止する')
                    : '問題文を読み上げる',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 20.0,
                    height: 20.0,
                  ),
                  iconSize: 20.0,
                icon: Icon(
                  isSpeaking
                      ? (isSpeechPaused ? Icons.play_arrow : Icons.pause)
                      : Icons.volume_up,
                ),
                  onPressed: () => onToggleSpeech(question.toString()),
                    ),
                    if (isSpeaking)
                      IconButton(
                        tooltip: '読み上げを停止する',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 20.0,
                          height: 20.0,
                        ),
                        iconSize: 20.0,
                        icon: const Icon(Icons.stop),
                        onPressed: onStopSpeech,
                      ),
                  ],
                ),
              ),
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
