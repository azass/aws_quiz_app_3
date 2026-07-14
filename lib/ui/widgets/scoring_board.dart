import 'package:aws_quiz_app/models/scoring.dart';
import 'package:aws_quiz_app/ui/util.dart';
// import 'package:d_chart/d_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ScoringBoard extends StatelessWidget {
  final Scoring scoring;
  final Color lineColor = Colors.white60;
  ScoringBoard(this.scoring) : super();
  final TextStyle _headerStyle = TextStyle(
      fontSize: 9.0, fontWeight: FontWeight.w500, color: Colors.white);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double circleSize = size.width * 0.36;
    return Card(
        color: Colors.blueGrey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.only(
            top: 10.0, left: 5.0, bottom: 10.0, right: 5.0),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // _buildScoring(),
                // SizedBox(width: 4.0),
                Container(
                  width: size.width / 2 - 20,
                  child: _buildScoringPieChart(circleSize),
                ),
                // SizedBox(width: 4.0),
                Container(
                    width: size.width / 2 - 20,
                    child: _buildRetentionPieChart(circleSize))
              ]),
        ));
  }

  Widget _buildScoring() {
    return Container(
        width: 60,
        alignment: Alignment.topLeft,
        // height: 126,
        child: Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 15.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "SCORING",
                    textAlign: TextAlign.left,
                    style: _headerStyle,
                  )),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                  alignment: Alignment.topCenter,
                  child: Text(scoring.avg_scoring.toString(),
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white))),
              SizedBox(height: 80.0),
            ])));
  }

  // Widget _buildScoringPieChart2() {
  //   return Container(
  //     decoration: BoxDecoration(color: Colors.blueGrey[600]),
  //     padding: EdgeInsets.only(top: 0, bottom: 0),
  //     width: 115.0,
  //     height: 115.0,
  //     child: AspectRatio(
  //       aspectRatio: 16 / 9,
  //       child: Stack(
  //         children: [
  //           DChartPie(
  //               data: scoring.scoringCounts
  //                   .map((scoringCount) => {
  //                         'domain': scoringName[scoringCount.scoring],
  //                         'measure': scoringCount.count
  //                       })
  //                   .toList(),
  //               fillColor: (pieData, index) => historyColor[index])
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildScoringPieChart(double circleSize) {
    final List<PieChartData> chartData = scoring.scoringCounts
        .map((scoringCount) => PieChartData(scoringName[scoringCount.scoring],
            scoringCount.count, historyColor[scoringCount.scoring]))
        .toList();

    return Container(
        decoration: BoxDecoration(color: Colors.blueGrey[900]),
        padding: EdgeInsets.only(top: 0, bottom: 0),
        width: circleSize,
        height: circleSize,
        child: Stack(children: [
          SfCircularChart(
              margin: EdgeInsets.only(top: 0.0, bottom: 0.0),
              series: <CircularSeries>[
                DoughnutSeries<PieChartData, String>(
                    dataSource: chartData,
                    pointColorMapper: (PieChartData data, _) => data.color,
                    xValueMapper: (PieChartData data, _) => data.x,
                    yValueMapper: (PieChartData data, _) => data.y,
                    dataLabelMapper: (PieChartData data, _) =>
                        data.x.toString(),
                    dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        textStyle: TextStyle(
                          fontSize: 6.0,
                        )),
                    // Radius of pie
                    radius: '95%')
              ]),
          Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Text(
              "平均自信度",
              style: _headerStyle,
            ),
            Text(scoring.avg_scoring.toString(),
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white))
          ]))
        ]));
  }

  Widget _buildAreaChart() {
    final List<ChartData> chartData = scoring.dailyScorings
        .map((dailyScoring) => ChartData(
            DateFormat('yyyy-MM-dd').parse(dailyScoring.answerDate),
            dailyScoring.average))
        .toList();

    final List<Color> color = <Color>[];
    color.add(Colors.blue[500]);
    color.add(Colors.blue[400]);
    color.add(Colors.blue[300]);
    color.add(Colors.blue[200]);
    color.add(Colors.blue[100]);

    final List<double> stops = <double>[];
    stops.add(0.0);
    stops.add(0.25);
    stops.add(0.5);
    stops.add(0.75);
    stops.add(1.0);

    final LinearGradient gradientColors = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: color,
        stops: stops);

    return Container(
        decoration: BoxDecoration(color: Colors.blueGrey[600]),
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        height: 120.0,
        width: 180.0,
        child: SfCartesianChart(
            primaryXAxis: DateTimeAxis(
                opposedPosition: true,
                intervalType: DateTimeIntervalType.days,
                rangePadding: ChartRangePadding.none,
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                labelStyle: TextStyle(
                  color: Colors.white,
                )),
            primaryYAxis: NumericAxis(
                isVisible: true,
                opposedPosition: true,
                minimum: 0,
                maximum: 100,
                // edgeLabelPlacement: EdgeLabelPlacement.shift,
                labelStyle: TextStyle(
                  color: Colors.white,
                )),
            margin:
                EdgeInsets.only(top: 5.0, left: 25.0, bottom: 15.0, right: 7.0),
            series: <ChartSeries>[
              AreaSeries<ChartData, DateTime>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y * data.y,
                gradient: gradientColors,
                borderColor: Colors.teal,
                borderWidth: 2,
              )
            ]));
  }

  Widget _buildRetentionPieChart(double circleSize) {
    final List<PieChartData> chartData = scoring.retentionCounts
        .asMap()
        .entries
        .map((retentionCount) => PieChartData(retentionCount.value.label,
            retentionCount.value.count, historyColor[retentionCount.key]))
        .toList();

    return Container(
        decoration: BoxDecoration(color: Colors.blueGrey[900]),
        padding: EdgeInsets.only(top: 0, bottom: 0),
        width: circleSize,
        height: circleSize,
        child: Stack(children: [
          SfCircularChart(
              margin: EdgeInsets.only(top: 0.0, bottom: 0.0),
              series: <CircularSeries>[
                DoughnutSeries<PieChartData, String>(
                    dataSource: chartData,
                    pointColorMapper: (PieChartData data, _) => data.color,
                    xValueMapper: (PieChartData data, _) => data.x,
                    yValueMapper: (PieChartData data, _) => data.y,
                    dataLabelMapper: (PieChartData data, _) =>
                        data.x.toString(),
                    dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        textStyle: TextStyle(
                          fontSize: 6.0,
                        )),
                    // Radius of pie
                    radius: '95%')
              ]),
          Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Text(
              "平均定着度",
              style: _headerStyle,
            ),
            Text(scoring.avg_retention.toString(),
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white))
          ]))
        ]));
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final DateTime x;
  final double y;
}

class PieChartData {
  PieChartData(this.x, this.y, this.color);
  final String x;
  final int y;
  final Color color;
}
