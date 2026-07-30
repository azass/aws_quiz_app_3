import 'package:aws_quiz_app/models/question.dart';
import 'package:aws_quiz_app/resources/api_provider.dart';
import 'package:aws_quiz_app/ui/widgets/history_card.dart';
import 'package:flutter/material.dart';

import '../util.dart';

class QuizBook extends StatefulWidget {
  final Question question;
  final bool readOnly;
  final bool isAnswered;

  QuizBook(this.question, this.readOnly, this.isAnswered);

  @override
  QuizBookState createState() => QuizBookState();
}

class QuizBookState extends State<QuizBook> {
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.width > 650 ? 120.0 : 60.0;
    return Container(
      // color: Colors.grey[500],
      margin: const EdgeInsets.all(5.0),
      child: Column(
        children: <Widget>[
          if (widget.readOnly || widget.isAnswered)
            Container(
              height: h,
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 7, // 1行に表示する数
                mainAxisSpacing: 0.0, // 横スペース
                children: _buildHistoryPart(context),
              ),
            ),
          Container(padding: EdgeInsets.all(2.0), child: _buildRetentionPart()),
          _buildTimePart(),
        ],
      ),
    );
  }

  Widget _buildRetentionPart() {
    return Text(
      "定着度: ${widget.question.retention}    " +
          "半忘期: ${widget.question.halving_time} 日 " +
          "半忘日: ${widget.question.halving_date}",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 14.0,
      ),
    );
  }

  Widget _buildTimePart() {
    String label = "";
    String label2 = "";
    label = "平均解答時間: ${formatTime(widget.question.answeredAvgTime)}  ";
    if (!widget.readOnly && widget.isAnswered) {
      label2 =
          "READ: ${formatTime(widget.question.readTime)}  " +
          "ANSWER: ${formatTime(widget.question.answerTime)}  " +
          "TOTAL: ${formatTime(widget.question.answeredTime)}";
      if (widget.question.answeredTime < widget.question.answeredAvgTime - 15) {
        label2 += " ⤴️";
      } else if (widget.question.answeredTime >
          widget.question.answeredAvgTime + 15) {
        label2 += " ⤵️";
      } else {
        label2 += " ➡️";
      }
    }
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14.0,
          ),
        ),
        if (label2 != "")
          Text(
            label2,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14.0,
            ),
          ),
      ],
    );
  }

  List<Widget> _buildHistoryPart(BuildContext context) {
    List<Widget> tempList = [];
    widget.question.histories
        .sublist(
          0,
          widget.question.histories.length < 7
              ? widget.question.histories.length
              : 7,
        )
        .forEach((history) => tempList.add(HistoryCard(history, context)));
    return tempList;
  }

  Widget buildMaturitySlider() {
    return Container(
      width: 140.0,
      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
      child: SliderTheme(
        data: SliderThemeData(
          activeTrackColor: Colors.green,
          showValueIndicator: ShowValueIndicator.never,
          minThumbSeparation: 0,
        ),
        child: Slider(
          value: widget.question.maturity,
          min: 0,
          max: 5,
          divisions: 5,
          onChanged: (double value) {
            updateMaturity(widget.question.questId, value);
            setState(() => widget.question.maturity = value.roundToDouble());
          },
        ),
      ),
    );
  }

}
