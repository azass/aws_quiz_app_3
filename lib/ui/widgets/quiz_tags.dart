import 'package:aws_quiz_app/ui/pages/quiz_page.dart';
import 'package:flutter/material.dart';

import 'keyword_dialog.dart';

class QuizTags extends StatelessWidget {
  final QuizPageState pageState;
  QuizTags(this.pageState);

  @override
  Widget build(BuildContext context) {
    return Wrap(children: _buildTags(context));
  }

  List<Widget> _buildTags(BuildContext context) {
    List<Widget> tempList = [];
    pageState.widget.question.tags.forEach((tag) {
      tempList.add(_buildTag(context, tag, Colors.lightBlue));
      if (pageState.widget.question.tagKeywords.containsKey(tag.tagName)) {
        pageState.widget.question.tagKeywords[tag.tagName].forEach((keyword) {
          if (keyword["word"] != "is ?") {
            tempList.add(
              _buildKeyword(
                keyword["word"],
                KeywordDialogState.keywordColors[keyword["level"] - 1]['color'],
              ),
            );
          }
        });
      }
    });
    return tempList;
  }

  Widget _buildTag(BuildContext context, dynamic tag, Color color) {
    return Container(
      height: 32,
      child: ElevatedButton(
        child: Text(tag.tagName),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () => showKeywordDialog(
          context,
          tag,
          pageState,
          pageState.widget.question,
        ),
      ),
    );
  }

  Widget _buildKeyword(String text, Color color) {
    return Container(
      height: 30,
      margin: EdgeInsets.only(left: 2),
      child: Chip(
        label: Text(text),
        labelStyle: TextStyle(
          fontSize: 11.0,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: color,
      ),
    );
  }
}
