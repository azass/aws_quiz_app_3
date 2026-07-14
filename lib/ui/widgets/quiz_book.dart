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
    double h = MediaQuery.of(context).size.width > 650 ? 100.0 : 60.0;
    return Container(
        // color: Colors.grey[500],
        margin: const EdgeInsets.all(5.0),
        child: Column(children: <Widget>[
          if (widget.readOnly ||
              (widget.isAnswered))
            Container(
                height: h,
                child: GridView.count(
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 7, // 1行に表示する数
                    mainAxisSpacing: 0.0, // 横スペース
                    children: _buildHistoryPart(context))),
          Container(padding: EdgeInsets.all(2.0), child: _buildRetentionPart()),
          _buildTimePart(),
          _buildLarningPart(),
        ]));
  }

  Widget _buildRetentionPart() {
    return Text(
      "定着度: ${widget.question.retention}    " +
          "半忘期: ${widget.question.halving_time} 日 " +
          "半忘日: ${widget.question.halving_date}",
      style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.0),
    );
  }

  Widget _buildTimePart() {
    String label = "";
    String label2 = "";
    label = "平均解答時間: ${formatTime(widget.question.answeredAvgTime)}  ";
    if (!widget.readOnly && widget.isAnswered) {
      label2 = "READ: ${formatTime(widget.question.readTime)}  " +
          "ANSWER: ${formatTime(widget.question.answerTime)}  " +
          "TOTAL: ${formatTime(widget.question.answeredTime)}";
      if (widget.question.answeredTime <
          widget.question.answeredAvgTime - 15) {
        label2 += " ⤴️";
      } else if (widget.question.answeredTime >
          widget.question.answeredAvgTime + 15) {
        label2 += " ⤵️";
      } else {
        label2 += " ➡️";
      }
    }
    return Column(children: [
      Text(
        label,
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14.0),
      ),
      if (label2 != "")
        Text(
          label2,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14.0),
        )
    ]);
  }

  List<Widget> _buildHistoryPart(BuildContext context) {
    List<Widget> tempList = [];
    widget.question.histories
        .sublist(
            0,
            widget.question.histories.length < 7
                ? widget.question.histories.length
                : 7)
        .forEach((history) => tempList.add(HistoryCard(history, context)));
    return tempList;
  }

  Widget _buildLarningPart() {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(
          alignment: Alignment.centerLeft,
          child: Row(children: [
            _buildPrioritySlider(),
            _buildLabel(
                priority[widget.question.priority.toInt()], Colors.indigo),
          ])),
      Container(alignment: Alignment.centerRight, child: _buildLarningLabel()),
    ]);
  }

  Widget _buildLarningLabel() {
    return Row(children: [
      if (widget.question.isEasy) _buildLabel("簡単", Colors.lightBlueAccent),
      if (widget.question.isDifficult) _buildLabel("難問", Colors.orangeAccent),
      if (widget.question.isWeak) _buildLabel("弱点", Colors.pinkAccent),
      // if (widget.question.isMandatory) _buildLabel("必須"),
    ]);
  }

  Widget _buildLabel(String text, Color color) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0),
        child: Chip(
          label: Text(text),
          labelStyle: TextStyle(
            fontSize: 10.0,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: color,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity(horizontal: 0.0, vertical: -4),
          // labelPadding: EdgeInsets.symmetric(horizontal: 1),
        ));
  }

  Widget _buildMaturitySlider() {
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
          )),
    );
  }

  Widget _buildPrioritySlider() {
    return Container(
      width: 150.0,
      padding: EdgeInsets.only(top: 2.0),
      child: SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.green,
            showValueIndicator: ShowValueIndicator.never,
            minThumbSeparation: 0,
          ),
          child: Slider(
            value: widget.question.priority,
            min: 0,
            max: 3,
            divisions: 3,
            onChanged: (double value) {
              updatePriority(widget.question.questId, value);
              setState(() => widget.question.priority = value.roundToDouble());
            },
          )),
    );
  }
}
