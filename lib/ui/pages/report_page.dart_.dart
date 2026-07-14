import 'package:aws_quiz_app/models/report.dart';
import 'package:aws_quiz_app/ui/widgets/fsrs_dashboard.dart';
import 'package:aws_quiz_app/ui/widgets/keyword_dialog.dart';
import 'package:aws_quiz_app/ui/widgets/scoring_board.dart';
import 'package:aws_quiz_app/ui/widgets/tag_scoring_table.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ReportPage extends StatefulWidget {
  final Report report;
  ReportPage({Key key, this.report}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int _currentSortColumn = 0;
  bool _isAscending = true;

  @override
  Future<void> initState() {
    widget.report.scoringTableItems
        .sort((b, a) => a.questionCount.compareTo(b.questionCount));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report'),
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
                    widget.report.exam.examName,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white60),
                  )),
              SizedBox(height: 10.0),
              Column(children: <Widget>[
                ScoringBoard(widget.report.scoring),
                // Dashboard(report.exam)
              ]),
              SizedBox(height: 6),
              Expanded(
                // height: double.infinity,
                child: SingleChildScrollView(
                    child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(children: <Widget>[
                    FsrsDashboard(widget.report.scoring),
                    SizedBox(height: 8.0),
                    TagScoringTable(
                        widget.report.exam, widget.report.scoringTableItems),
                  ]),
                )
                    // child: Column(
                    //   children: _buildRowList(context),
                    // ),
                    ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    Size size = MediaQuery.of(context).size;
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
                  padding: const EdgeInsets.only(left: 15.0), child: Text(''))),
          DataColumn(
              label: const Text(
                '数',
                style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              // Sorting function
              onSort: (columnIndex, _) {
                setState(() {
                  _currentSortColumn = columnIndex;
                  if (_isAscending == true) {
                    _isAscending = false;
                    // sort the product list in Ascending, order by Price
                    widget.report.scoringTableItems.sort((itemA, itemB) =>
                        itemB.questionCount.compareTo(itemA.questionCount));
                  } else {
                    _isAscending = true;
                    // sort the product list in Descending, order by Price
                    widget.report.scoringTableItems.sort((itemA, itemB) =>
                        itemA.questionCount.compareTo(itemB.questionCount));
                  }
                });
              }),
          DataColumn(
              label: const Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    '正解率',
                    style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  )),
              // Sorting function
              onSort: (columnIndex, _) {
                setState(() {
                  _currentSortColumn = columnIndex;
                  if (_isAscending == true) {
                    _isAscending = false;
                    // sort the product list in Ascending, order by Price
                    widget.report.scoringTableItems.sort((itemA, itemB) => itemB
                        .correctAnswerRate
                        .compareTo(itemA.correctAnswerRate));
                  } else {
                    _isAscending = true;
                    // sort the product list in Descending, order by Price
                    widget.report.scoringTableItems.sort((itemA, itemB) => itemA
                        .correctAnswerRate
                        .compareTo(itemB.correctAnswerRate));
                  }
                });
              }),
          DataColumn(
              label: const Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    '平均定着度',
                    style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  )),
              // Sorting function
              onSort: (columnIndex, _) {
                setState(() {
                  _currentSortColumn = columnIndex;
                  if (_isAscending == true) {
                    _isAscending = false;
                    // sort the product list in Ascending, order by Price
                    widget.report.scoringTableItems.sort((itemA, itemB) =>
                        itemB.avgRetention.compareTo(itemA.avgRetention));
                  } else {
                    _isAscending = true;
                    // sort the product list in Descending, order by Price
                    widget.report.scoringTableItems.sort((itemA, itemB) =>
                        itemA.avgRetention.compareTo(itemB.avgRetention));
                  }
                });
              }),
        ],
        rows: widget.report.scoringTableItems.map((item) {
          return DataRow(cells: [
            DataCell(_buildTag(context, item.tag)),
            DataCell(Text(
              item.questionCount.toString(),
              style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            )),
            DataCell(Row(children: [
              Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: LinearPercentIndicator(
                    width: 50.0,
                    lineHeight: 8.0,
                    percent: item.correctAnswerRate,
                    progressColor: Colors.red,
                  )),
              Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Container(
                      width: 32,
                      child: Text(
                        item.toRatePercentage(item.correctAnswerRate),
                        style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ))),
            ])),
            DataCell(Row(children: [
              Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: LinearPercentIndicator(
                    width: 50.0,
                    lineHeight: 8.0,
                    percent: item.avgRetention / 100 < 1
                        ? item.avgRetention / 100
                        : 1,
                    progressColor: Colors.red,
                  )),
              Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Container(
                      width: 32,
                      child: Text(
                        item.avgRetention.toString(),
                        style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ))),
            ])),
          ]);
        }).toList());
  }

  // List<Widget> _buildRowList(BuildContext context) {
  //   List<Widget> rowList = [];
  //   widget.report.rates
  //       .sort((b, a) => a.questionCount.compareTo(b.questionCount));
  //   widget.report.rates
  //       .forEach((item) => rowList.add(_buildServiceUnitRow(context, item)));
  //   return rowList;
  // }

  Widget _buildServiceUnitRow(BuildContext context, ReportItem item) {
    return Row(children: [
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
                    color: Colors.white),
              ))),
      Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: LinearPercentIndicator(
            width: 50.0,
            lineHeight: 8.0,
            percent: item.correctAnswerRate,
            progressColor: Colors.red,
          )),
      Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Container(
              width: 32,
              child: Text(
                item.toRatePercentage(item.correctAnswerRate),
                style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ))),
      Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: LinearPercentIndicator(
            width: 50.0,
            lineHeight: 8.0,
            percent: item.completionRate,
            progressColor: Colors.red,
          )),
      Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: SizedBox(
              width: 30,
              child: Text(
                item.toRatePercentage(item.completionRate),
                style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ))),
    ]);
  }

  Widget _buildTag(BuildContext context, dynamic tag) {
    return Container(
      height: 20,
      width: 190,
      child: ElevatedButton(
        child: Text(tag.tagName),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, textStyle: TextStyle(fontSize: 10.0, color: Colors.white), backgroundColor: Colors.grey[800],
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
