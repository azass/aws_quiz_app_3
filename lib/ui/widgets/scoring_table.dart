import 'package:aws_quiz_app/models/scoring.dart';
import 'package:flutter/material.dart';

class ScoringTable extends StatefulWidget {
  final List<ScoringTableItem> scoringTableItems;
  ScoringTable(this.scoringTableItems);

  @override
  State<StatefulWidget> createState() => _ScoringTableState();

  double tagWidth(BuildContext context) {
    return double.infinity;
  }

  Color bgcolor(ScoringTableItem item) {
    return Colors.grey.shade800;
  }

  onPressed(BuildContext context, ScoringTableItem item) {}
}

class _ScoringTableState extends State<ScoringTable> {
  int _currentSortColumn = 0;
  bool _isAscending = true;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      sortColumnIndex: _currentSortColumn,
      sortAscending: _isAscending,
      headingRowColor: WidgetStateProperty.all(Colors.blueGrey[900]),
      dataRowHeight: 28,
      headingRowHeight: 28,
      horizontalMargin: 1,
      columnSpacing: 1,
      columns: [
        DataColumn(
          label: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              // 習熟度ヒートカラーの凡例（KnowhowMap と同デザイン）
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _legendChip("未定着", _heatColors[0]),
                    _legendChip("学習中", _heatColors[2]),
                    _legendChip("定着", _heatColors[4]),
                    _legendChip("熟達", _heatColors[6]),
                  ],
                ),
              ),
            ),
          ),
          onSort: (columnIndex, _) {
            setState(() {
              _currentSortColumn = columnIndex;
              if (_isAscending == true) {
                _isAscending = false;
                // sort the product list in Ascending, order by Price
                widget.scoringTableItems.sort(
                  (itemA, itemB) => itemB.sort.compareTo(itemA.sort),
                );
              } else {
                _isAscending = true;
                // sort the product list in Descending, order by Price
                widget.scoringTableItems.sort(
                  (itemA, itemB) => itemA.sort.compareTo(itemB.sort),
                );
              }
            });
          },
        ),
        DataColumn(
          label: Container(
            width: MediaQuery.of(context).size.width * 0.03,
            child: Text(
              '数',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Sorting function
          onSort: (columnIndex, _) {
            setState(() {
              _currentSortColumn = columnIndex;
              if (_isAscending == true) {
                _isAscending = false;
                // sort the product list in Ascending, order by Price
                widget.scoringTableItems.sort(
                  (itemA, itemB) =>
                      itemB.questionCount.compareTo(itemA.questionCount),
                );
              } else {
                _isAscending = true;
                // sort the product list in Descending, order by Price
                widget.scoringTableItems.sort(
                  (itemA, itemB) =>
                      itemA.questionCount.compareTo(itemB.questionCount),
                );
              }
            });
          },
        ),
        DataColumn(
          label: const Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(
              '正解率',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Sorting function
          onSort: (columnIndex, _) {
            setState(() {
              _currentSortColumn = columnIndex;
              if (_isAscending == true) {
                _isAscending = false;
                // sort the product list in Ascending, order by Price
                widget.scoringTableItems.sort(
                  (itemA, itemB) => itemB.correctAnswerRate.compareTo(
                    itemA.correctAnswerRate,
                  ),
                );
              } else {
                _isAscending = true;
                // sort the product list in Descending, order by Price
                widget.scoringTableItems.sort(
                  (itemA, itemB) => itemA.correctAnswerRate.compareTo(
                    itemB.correctAnswerRate,
                  ),
                );
              }
            });
          },
        ),
        DataColumn(
          label: const Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(
              '平均定着度',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Sorting function
          onSort: (columnIndex, _) {
            setState(() {
              _currentSortColumn = columnIndex;
              if (_isAscending == true) {
                _isAscending = false;
                // sort the product list in Ascending, order by Price
                widget.scoringTableItems.sort(
                  (itemA, itemB) =>
                      itemB.avgRetention.compareTo(itemA.avgRetention),
                );
              } else {
                _isAscending = true;
                // sort the product list in Descending, order by Price
                widget.scoringTableItems.sort(
                  (itemA, itemB) =>
                      itemA.avgRetention.compareTo(itemB.avgRetention),
                );
              }
            });
          },
        ),
      ],
      rows: widget.scoringTableItems.map((item) {
        return DataRow(
          cells: [
            DataCell(buildTag(context, item)),
            DataCell(
              Container(
                width: MediaQuery.of(context).size.width * 0.05,
                child: Text(
                  item.questionCount.toString(),
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            DataCell(
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: LinearProgressIndicator(
                          value: item.correctAnswerRate,
                          minHeight: 8.0,
                          color: Colors.red,
                          backgroundColor: const Color(0xFFB8C7CB),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.08,
                      child: Text(
                        item.toRatePercentage(item.correctAnswerRate),
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            DataCell(
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: LinearProgressIndicator(
                          value: item.avgRetention / 100 < 1
                              ? item.avgRetention / 100
                              : 1.0,
                          minHeight: 8.0,
                          color: Colors.red,
                          backgroundColor: const Color(0xFFB8C7CB),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.08,
                      child: Text(
                        item.avgRetention.toString(),
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget buildTag(BuildContext context, ScoringTableItem item) {
    // 習熟度(mastery)ヒートカラーをボタン背景に適用。
    // データが無い(0)場合は従来の色にフォールバック。
    final Color bg = item.avgMastery > 0
        ? _masteryColor(item.avgMastery)
        : widget.bgcolor(item);
    // 明るい背景色では文字を黒にして可読性を確保する。
    final Color fg = bg.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;
    return Container(
      height: 26,
      width: widget.tagWidth(context),
      child: Padding(
        padding: EdgeInsets.only(left: item.indent),
        child: ElevatedButton(
          child: Text(item.label),
          style: ElevatedButton.styleFrom(
            foregroundColor: fg,
            textStyle: TextStyle(fontSize: 11.0),
            backgroundColor: bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.centerLeft,
          ),
          onPressed: () => pressed(context, item),
        ),
      ),
    );
  }

  pressed(BuildContext context, ScoringTableItem item) {
    setState(() => widget.onPressed(context, item));
  }

  /// 凡例チップ（色四角＋ラベル）。KnowhowMap の Legend と同デザイン。
  Widget _legendChip(String label, Color color) => Padding(
    padding: EdgeInsets.only(right: 6.0),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10.0, height: 10.5, color: color),
        SizedBox(width: 3.0),
        Text(label, style: TextStyle(fontSize: 10.0, color: Colors.white)),
      ],
    ),
  );

  /// 習熟度ヒートカラー（低 → 高）。凡例と _masteryColor で共有する。
  static const List<Color> _heatColors = [
    Color(0xFFE57373), // <20  未定着
    Color(0xFFFF8A65), // <40
    Color(0xFFFFB74D), // <60
    Color(0xFFFFD54F), // <80  学習中
    Color(0xFFAED581), // <100
    Color(0xFF81C784), // <120 定着
    Color(0xFF4DB6AC), // 120+ 熟達
  ];

  /// mastery(0〜120+) をヒートカラーに変換する。
  Color _masteryColor(double mastery) {
    if (mastery < 20) return _heatColors[0];
    if (mastery < 40) return _heatColors[1];
    if (mastery < 60) return _heatColors[2];
    if (mastery < 80) return _heatColors[3];
    if (mastery < 100) return _heatColors[4];
    if (mastery < 120) return _heatColors[5];
    return _heatColors[6];
  }
}
