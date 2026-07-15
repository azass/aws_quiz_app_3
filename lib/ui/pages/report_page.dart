import 'package:aws_quiz_app/models/knowhow_note.dart';
import 'package:aws_quiz_app/models/report.dart';
import 'package:aws_quiz_app/ui/pages/knowhow_notes_page.dart';
import 'package:aws_quiz_app/resources/api_provider.dart';
import 'package:aws_quiz_app/ui/widgets/fsrs_dashboard.dart';
import 'package:aws_quiz_app/ui/widgets/question_stats_table.dart';
import 'package:aws_quiz_app/ui/widgets/keyword_dialog.dart';
import 'package:aws_quiz_app/ui/widgets/scoring_board.dart';
import 'package:aws_quiz_app/ui/widgets/tag_scoring_table.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ReportPage extends StatefulWidget {
  final Report report;
  ReportPage({Key? key, required this.report}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int _currentSortColumn = 0;
  Future<List<KnowhowNote>>? _knowhowFuture;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    widget.report.scoringTableItems.sort(
      (b, a) => a.questionCount.compareTo(b.questionCount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Report'),
          elevation: 0,
          bottom: TabBar(
            labelStyle: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'レポート'),
              Tab(text: '分析'),
              Tab(text: 'つまずき集'),
            ],
          ),
        ),
        body: Container(
          color: Colors.blueGrey[900],
          height: double.infinity,
          width: double.infinity,
          child: TabBarView(
            children: <Widget>[
              _buildReportTab(),
              _buildAnalysisTab(),
              _buildKnowhowTab(),
            ],
          ),
        ),
      ),
    );
  }

  // タブ1: 従来のレポート（成績ボード＋タグ別テーブル）
  Widget _buildReportTab() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: Text(
              widget.report.exam.examName,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white60,
              ),
            ),
          ),
          SizedBox(height: 10.0),
          ScoringBoard(widget.report.scoring),
          SizedBox(height: 6),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: TagScoringTable(
                  widget.report.exam,
                  widget.report.scoringTableItems,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  // タブ2: FSRS 分析ダッシュボード
  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FsrsDashboard(widget.report.scoring),
          SizedBox(height: 10.0),
          QuestionStatsTable(widget.report.scoring.questionStats),
        ],
      ),
    );
  }

  // タブ3: つまずきノウハウ集（初回表示時に取得）
  Widget _buildKnowhowTab() {
    _knowhowFuture ??= getKnowhowNotes(widget.report.exam.examId);
    return FutureBuilder<List<KnowhowNote>>(
      future: _knowhowFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'ノウハウの取得に失敗しました',
              style: TextStyle(fontSize: 12.0, color: Colors.white54),
            ),
          );
        }
        return KnowhowNotesView(
          examName: widget.report.exam.examName,
          notes: snapshot.data ?? const [],
        );
      },
    );
  }

  Widget buildDataTable() {
    return DataTable(
      sortColumnIndex: _currentSortColumn,
      sortAscending: _isAscending,
      headingRowColor: WidgetStateProperty.all(Colors.blueGrey[900]),
      dataRowHeight: 22,
      headingRowHeight: 22,
      horizontalMargin: 1,
      columnSpacing: MediaQuery.of(context).size.width > 600 ? 30 : 1,
      columns: [
        const DataColumn(
          label: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Text(''),
          ),
        ),
        DataColumn(
          label: const Text(
            '数',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Sorting function
          onSort: (columnIndex, _) {
            setState(() {
              _currentSortColumn = columnIndex;
              if (_isAscending == true) {
                _isAscending = false;
                // sort the product list in Ascending, order by Price
                widget.report.scoringTableItems.sort(
                  (itemA, itemB) =>
                      itemB.questionCount.compareTo(itemA.questionCount),
                );
              } else {
                _isAscending = true;
                // sort the product list in Descending, order by Price
                widget.report.scoringTableItems.sort(
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
                widget.report.scoringTableItems.sort(
                  (itemA, itemB) => itemB.correctAnswerRate.compareTo(
                    itemA.correctAnswerRate,
                  ),
                );
              } else {
                _isAscending = true;
                // sort the product list in Descending, order by Price
                widget.report.scoringTableItems.sort(
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
                widget.report.scoringTableItems.sort(
                  (itemA, itemB) =>
                      itemB.avgRetention.compareTo(itemA.avgRetention),
                );
              } else {
                _isAscending = true;
                // sort the product list in Descending, order by Price
                widget.report.scoringTableItems.sort(
                  (itemA, itemB) =>
                      itemA.avgRetention.compareTo(itemB.avgRetention),
                );
              }
            });
          },
        ),
      ],
      rows: widget.report.scoringTableItems.map((item) {
        return DataRow(
          cells: [
            DataCell(_buildTag(context, item.tag)),
            DataCell(
              Text(
                item.questionCount.toString(),
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            DataCell(
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: LinearPercentIndicator(
                      width: 50.0,
                      lineHeight: 8.0,
                      percent: item.correctAnswerRate,
                      progressColor: Colors.red,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Container(
                      width: 32,
                      child: Text(
                        item.toRatePercentage(item.correctAnswerRate),
                        style: TextStyle(
                          fontSize: 12.0,
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
                    child: LinearPercentIndicator(
                      width: 50.0,
                      lineHeight: 8.0,
                      percent: item.avgRetention / 100 < 1
                          ? item.avgRetention / 100
                          : 1,
                      progressColor: Colors.red,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Container(
                      width: 32,
                      child: Text(
                        item.avgRetention.toString(),
                        style: TextStyle(
                          fontSize: 12.0,
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

  // List<Widget> _buildRowList(BuildContext context) {
  //   List<Widget> rowList = [];
  //   widget.report.rates
  //       .sort((b, a) => a.questionCount.compareTo(b.questionCount));
  //   widget.report.rates
  //       .forEach((item) => rowList.add(_buildServiceUnitRow(context, item)));
  //   return rowList;
  // }

  Widget buildServiceUnitRow(BuildContext context, ReportItem item) {
    return Row(
      children: [
        _buildTag(context, item.tag),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0),
          child: SizedBox(
            height: 18,
            width: 20,
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
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: LinearPercentIndicator(
            width: 50.0,
            lineHeight: 8.0,
            percent: item.correctAnswerRate,
            progressColor: Colors.red,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Container(
            width: 32,
            child: Text(
              item.toRatePercentage(item.correctAnswerRate),
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: LinearPercentIndicator(
            width: 50.0,
            lineHeight: 8.0,
            percent: item.completionRate,
            progressColor: Colors.red,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: SizedBox(
            width: 30,
            child: Text(
              item.toRatePercentage(item.completionRate),
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(BuildContext context, dynamic tag) {
    return Container(
      height: 20,
      width: 190,
      child: ElevatedButton(
        child: Text(tag.tagName),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          textStyle: TextStyle(fontSize: 10.0, color: Colors.white),
          backgroundColor: Colors.grey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.centerLeft,
        ),
        onPressed: () {
          showKeywordDialog(context, tag, null, null);
        },
      ),
    );
  }
}
