import 'package:aws_quiz_app/models/exam.dart';
import 'package:aws_quiz_app/models/report.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class Dashboard extends StatelessWidget {
  final Exam exam;
  final Color lineColor = Colors.white60;

  Dashboard(this.exam) : super();

  final TextStyle _headerStyle = TextStyle(
      fontSize: 9.0, fontWeight: FontWeight.w500, color: Colors.white);

  @override
  Widget build(BuildContext context) {
    return
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Card(
          color: Colors.blueGrey[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(5.0),
          child: Padding(
            padding: const EdgeInsets.only(
                top: 5.0, right: 10.0, bottom: 5.0, left: 10.0),
            child: Container(
              width: 118,
              height: 154,
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                SizedBox(
                    width: double.infinity,
                    child: Text(
                      "POINT",
                      textAlign: TextAlign.left,
                      style: _headerStyle,
                    )),
                Container(
                    alignment: Alignment.bottomRight,
                    child: Text(exam.point.toString(),
                        style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white))),
                SizedBox(height: 1.0),
                SizedBox(
                    width: double.infinity,
                    child: Text(
                      "LEVEL",
                      textAlign: TextAlign.left,
                      style: _headerStyle,
                    )),
                CircularPercentIndicator(
                  radius: 78.0,
                  lineWidth: 10.0,
                  percent: exam.progressRate(),
                  center: Container(
                    width: 50.0,
                    height: 50.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.contain,
                            image: AssetImage(_getLevelImagePaths()))),
                  ),
                  backgroundColor: Colors.grey,
                  progressColor: Colors.blue,
                ),
                SizedBox(height: 2.0),
                SizedBox(
                    width: double.infinity,
                    child: Text(
                      "REMINING",
                      textAlign: TextAlign.left,
                      style: _headerStyle,
                    )),
                Container(
                    alignment: Alignment.topRight,
                    child: Text(exam.remaining().toString(),
                        style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white))),
              ]),
            ),
          ),
        ),
        SizedBox(width: 8.0),
        Expanded(child: _buildAcquiredImage(9)),
        Expanded(child: _buildAcquiredImage(8)),
        Expanded(child: _buildAcquiredImage(7)),
        Expanded(child: _buildAcquiredImage(6)),
        Expanded(child: _buildAcquiredImage(5)),
        Expanded(child: _buildAcquiredImage(4)),
        Expanded(child: _buildAcquiredImage(3)),
        Expanded(child: _buildAcquiredImage(2)),
        Expanded(child: _buildAcquiredImage(1)),
        SizedBox(width: 5.0),
      ]
      );
  }

  Widget _buildAcquiredImage(int level) {
    String img = "images/none.png";
    if (level < exam.level) {
      img = hashiraImagePaths[level];
    }
    return Container(
        decoration: BoxDecoration(border: Border.all(color: lineColor)),
        child: Image.asset(img));
  }

  String _getLevelImagePaths() {
    if (exam.level > 9) {
      return levelImagePaths[0];
    } else {
      return levelImagePaths[exam.level];
    }
  }
}