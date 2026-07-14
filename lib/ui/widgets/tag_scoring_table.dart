import 'package:aws_quiz_app/models/exam.dart';
import 'package:aws_quiz_app/models/report.dart';
import 'package:aws_quiz_app/models/scoring.dart';
import 'package:aws_quiz_app/models/tag.dart';
import 'package:aws_quiz_app/resources/api_provider.dart';
import 'package:aws_quiz_app/ui/widgets/scoring_table.dart';
import 'package:aws_quiz_app/ui/widgets/tag_scoring_view.dart';
import 'package:flutter/material.dart';

class TagScoringTable extends ScoringTable {
  final Exam exam;
  TagScoringTable(this.exam, List<ScoringTableItem> scoringTableItems)
      : super(scoringTableItems);

  @override
  double tagWidth(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.42;
  }

  @override
  onPressed(BuildContext context, ScoringTableItem item) {
    _showTagScoring(context, item.tag);
  }

  _showTagScoring(BuildContext context, Tag tag) async {
    Report reportByTag = await getReportByTag(exam, tag);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => TagScoringView(reportByTag)));
  }
}
