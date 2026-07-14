import 'package:aws_quiz_app/models/scoring.dart';
import 'package:aws_quiz_app/ui/widgets/scoring_table.dart';
import 'package:flutter/material.dart';

class QuizScoringTable extends ScoringTable {
  final List<int> selectedCategory;

  QuizScoringTable(
      this.selectedCategory, List<ScoringTableItem> scoringTableItems)
      : super(scoringTableItems);

  @override
  Color bgcolor(ScoringTableItem item) {
    return (selectedCategory.contains(item.tag.tagNo))
        ? Colors.indigo
        : Colors.grey[800];
  }

  @override
  onPressed(BuildContext context, ScoringTableItem item) {
    selectedCategory.contains(item.tag.tagNo)
        ? selectedCategory.remove(item.tag.tagNo)
        : selectedCategory.add(item.tag.tagNo);
  }
}
