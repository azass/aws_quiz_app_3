import 'package:aws_quiz_app/models/scoring.dart';
import 'package:flutter/material.dart';

/// 問題別の分析値テーブル（分析タブ用）。
/// mastery 昇順（弱い問題が先頭）が初期表示。各列でソート可能。
/// mastery セルは習熟度ヒートカラーで表示する。
class QuestionStatsTable extends StatefulWidget {
  final List<QuestionStat> stats;
  const QuestionStatsTable(this.stats);

  @override
  _QuestionStatsTableState createState() => _QuestionStatsTableState();
}

class _QuestionStatsTableState extends State<QuestionStatsTable> {
  int _sortColumn = 1; // mastery
  bool _ascending = true;

  static const TextStyle _headStyle = TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white70);
  static const TextStyle _cellStyle =
      TextStyle(fontSize: 14.0, color: Colors.white70);

  @override
  Widget build(BuildContext context) {
    if (widget.stats.isEmpty) {
      return SizedBox(height: 0.0);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 4.0),
          child: Text("問題別の分析値（${widget.stats.length}問）",
              style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70))),
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            sortColumnIndex: _sortColumn,
            sortAscending: _ascending,
            headingRowColor: WidgetStateProperty.all(Colors.blueGrey[800]),
            headingRowHeight: 30,
            dataRowHeight: 28,
            columnSpacing: 14.0,
            horizontalMargin: 8.0,
            columns: [
              _col("問題", (s) => s.questId),
              _col("M", (s) => s.mastery),
              _col("定着", (s) => s.retention),
              _col("S", (s) => s.stability),
              _col("D", (s) => s.difficulty),
              _col("復習日", (s) => s.halvingDate),
            ],
            rows: widget.stats.map((s) => _row(s)).toList(),
          )),
    ]);
  }

  DataColumn _col(String label, Comparable Function(QuestionStat) key) {
    return DataColumn(
        label: Text(label, style: _headStyle),
        onSort: (index, asc) {
          setState(() {
            _sortColumn = index;
            _ascending = asc;
            widget.stats.sort((a, b) =>
                asc ? key(a).compareTo(key(b)) : key(b).compareTo(key(a)));
          });
        });
  }

  DataRow _row(QuestionStat s) {
    return DataRow(cells: [
      DataCell(Text(_shortId(s.questId), style: _cellStyle)),
      DataCell(Container(
          padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
          decoration: BoxDecoration(
              color: _masteryColor(s.mastery).withValues(alpha: 0.3),
              border: Border.all(color: _masteryColor(s.mastery), width: 1.0),
              borderRadius: BorderRadius.circular(8.0)),
          child: Text(s.mastery.toStringAsFixed(0),
              style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)))),
      DataCell(Text(s.retention.toStringAsFixed(0), style: _cellStyle)),
      DataCell(Text(s.stability.toStringAsFixed(1), style: _cellStyle)),
      DataCell(Text(s.difficulty.toStringAsFixed(1), style: _cellStyle)),
      DataCell(Text(s.halvingDate, style: _cellStyle)),
    ]);
  }

  /// "AIP-C01-0001" → "0001" のように末尾だけ表示して幅を節約する。
  String _shortId(String questId) {
    final parts = questId.split('-');
    return parts.isNotEmpty ? parts.last : questId;
  }

  Color _masteryColor(double mastery) {
    if (mastery < 20) return Color(0xFFE57373);
    if (mastery < 40) return Color(0xFFFF8A65);
    if (mastery < 60) return Color(0xFFFFB74D);
    if (mastery < 80) return Color(0xFFFFD54F);
    if (mastery < 100) return Color(0xFFAED581);
    if (mastery < 120) return Color(0xFF81C784);
    return Color(0xFF4DB6AC);
  }
}
