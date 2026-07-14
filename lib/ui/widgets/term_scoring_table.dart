import 'package:aws_quiz_app/models/scoring.dart';
import 'package:aws_quiz_app/models/tag.dart';
import 'package:aws_quiz_app/ui/widgets/scoring_table.dart';
import 'package:aws_quiz_app/ui/widgets/term_view.dart';
import 'package:flutter/cupertino.dart';

class TermScoringTable extends ScoringTable {
  final Tag tag;
  TermScoringTable(this.tag, List<ScoringTableItem> scoringTableItems)
      : super(scoringTableItems);

  @override
  double tagWidth(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.42;
  }

  @override
  onPressed(BuildContext context, ScoringTableItem item) {
    showTermView(context, tag.tagName, item.term);
  }
}