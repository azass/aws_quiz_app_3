import 'package:aws_quiz_app/models/question.dart';
import 'package:aws_quiz_app/resources/api_provider.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_chip.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../util.dart';

class QuizScoring extends StatefulWidget {
  final Question question;
  final State parent;
  const QuizScoring({Key key, this.question, this.parent}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QuizScoringState();
}

class _QuizScoringState extends State<QuizScoring> {
  final Map<String, String> _correctScoringLabel = {
    "10": scoringName[10],
    "9": scoringName[9],
    "8": scoringName[8],
    "7": scoringName[7],
    "6": scoringName[6],
  };
  final Map<String, String> _mistakeScoringLabel = {
    "1": scoringName[1],
    "2": scoringName[2],
    "3": scoringName[3],
    "4": scoringName[4],
    "5": scoringName[5],
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: this._buildScoringOptions(),
    );
  }

  List<Widget> _buildScoringOptions() {
    List<Widget> tempList = [];
    this.getScoringLabel().forEach((key, label) {
      tempList.add(Padding(
          padding: EdgeInsets.all(0.0),
          child: Container(
            child: QuizChip(label, key, _isCheck, _onChanged),
          )));
    });
    return tempList;
  }

  Map<String, String> getScoringLabel() {
    if (widget.question.judgment) {
      return _correctScoringLabel;
    } else {
      return _mistakeScoringLabel;
    }
  }

  bool _isCheck(String key) {
    return widget.question.newScoring == int.parse(key);
  }

  Future<void> _onChanged(String key) async {
    showLoading(context);
    int newScoring = int.parse(key);
    widget.question.newScoring = newScoring;
    updateScoring(widget.question.questId, newScoring);
    Map<String, dynamic> result = await updateHistoryScoring(widget.question);
    widget.question.scoring = newScoring;
    widget.question.histories[0].scoring = newScoring;
    // Map<String, dynamic> result = await updateRetention(widget.question.questId);
    widget.question.retention = result["retention"];
    widget.question.halving_time = result["halving_time"];
    widget.question.halving_date = result["halving_date"];
    // widget.question.last_point = result["last_point"];
    // widget.question.last_addPoint = 0.0 + result["last_addPoint"];
    _analyze();
    if (key == "1") {
      _moreStudy();
    }
    Navigator.pop(context);
    setState(() {widget.parent.setState(() => {});});
  }

  void _moreStudy() {
    widget.question.bugPoints["more_study"] = true;
    widget.question.isBug = widget.question.bugPoints.isNotEmpty;
    updateBugReport(widget.question.questId, widget.question.isBug,
        widget.question.bugPoints);
  }

  void _analyze() {
    if (!widget.question.histories[0].judgment) {
      if (widget.question.histories.length > 1) {
        if (!widget.question.histories[1].judgment) {
          DateTime now = DateTime.now();
          DateFormat dateFormat = DateFormat('yyyy-MM-dd');
          DateTime weekBefore = now.subtract(Duration(days: 7));
          String previousAnswerDate =
              widget.question.histories[1].answerDate.substring(10);
          if (previousAnswerDate.compareTo(dateFormat.format(weekBefore)) ==
              1) {
            widget.question.isWeak = true;
            updateIsWeak(widget.question.questId, true);
          }
        }
      }
    } else {
      if (widget.question.isWeak) {
        if (widget.question.histories.length > 3) {
          if (widget.question.histories[0].scoring > 8 &&
              widget.question.histories[1].scoring > 8 &&
              widget.question.histories[2].scoring > 8) {
            widget.question.isWeak = false;
            updateIsWeak(widget.question.questId, false);
          }
        }
      }
    }
  }
}
