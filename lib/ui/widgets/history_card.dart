import 'package:aws_quiz_app/models/history.dart';
import 'package:aws_quiz_app/ui/widgets/note_answer.dart';
import 'package:flutter/material.dart';

import '../util.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_bottom_sheet.dart';

class HistoryCard extends StatelessWidget {
  final History history;
  BuildContext _context;
  HistoryCard(this.history, this._context);

  @override
  Widget build(BuildContext context) {
    DateTime answerDate =
        DateTime.parse(history.answerDate.toString().substring(0, 10));
    var answerDaysAgo = DateTime.now().difference(answerDate).inDays;
    return Card(
        shadowColor: Colors.indigo,
        elevation: 4.0,
        color: historyColor[history.scoring],
        // color: (_question.answerDate == history['answer_date'].toString())
        //     ? Colors.pink[50]
        //     : Colors.white,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
            child: ElevatedButton(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.all(0.0),
                        alignment: Alignment.topCenter,
                        // width: 60.0,
                        child: Text(
                            (answerDaysAgo == 0) ? "今日" : "$answerDaysAgo日前",
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width > 600
                                    ? 12.0
                                    : 9.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black))),
                    Container(
                      // height: 22.0,
                      child: Padding(
                        padding: EdgeInsets.all(0.0),
                        child: Text((history.judgment) ? "○" : "×",
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width > 600
                                    ? 20.0
                                    : 14.0,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor)),
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.all(0.0),
                        alignment: Alignment.topCenter,
                        // width: 40.0,
                        child: Text(
                            (history.answeredTime == null)
                                ? "-"
                                : "${formatTime(history.answeredTime)}",
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width > 600
                                    ? 14.0
                                    : 8.0,
                                color: Colors.black))),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(0.0), backgroundColor: historyColor[history.scoring]),
                onPressed: _openAnswerNote)));
  }

  void _openAnswerNote() {
    showModalBottomSheet(
      context: _context,
      isScrollControlled: true,
      builder: (sheetContext) => QuizBottomSheet(AnswerNoteDialog(history)),
    );
  }
}
