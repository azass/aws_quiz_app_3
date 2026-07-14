import 'package:aws_quiz_app/models/report.dart';
import 'package:aws_quiz_app/ui/widgets/scoring_board.dart';
import 'package:aws_quiz_app/ui/widgets/term_scoring_table.dart';
import 'package:flutter/material.dart';

class TagScoringView extends StatelessWidget {
  final Report report;
  const TagScoringView(this.report);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(report.exam.examName),
          elevation: 0,
        ),
        body: Container(
          color: Colors.blueGrey[900],
          height: double.infinity,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                    width: double.infinity,
                    child: Text(
                      report.tag.tagName,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white60),
                    )),
                SizedBox(height: 10.0),
                Column(children: <Widget>[
                  ScoringBoard(report.scoring),
                  // Dashboard(report.exam)
                ]),
                SizedBox(height: 6),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(4.0),
                    child:
                        TermScoringTable(report.tag, report.scoringTableItems),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ));
  }
}
