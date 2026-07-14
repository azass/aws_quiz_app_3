import 'package:aws_quiz_app/models/question.dart';
import 'package:aws_quiz_app/resources/api_provider.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_chip.dart';
import 'package:flutter/material.dart';

class BugNoteDialog extends StatefulWidget {
  final Question question;
  final State parent;
  const BugNoteDialog(this.question, this.parent);

  @override
  _BugNoteDialogState createState() => _BugNoteDialogState();
}

class _BugNoteDialogState extends State<BugNoteDialog> {
  final Map<String, String> _bugCheckboxLabel = {
    "more_study": "要復習",
    "in_question": "問題",
    "in_option": "選択肢",
    "in_tag": "タグ",
    "in_explanation": "解説",
  };
  final memoTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    memoTextController.text = widget.question.bugPoints['memo'];
  }

  @override
  void dispose() {
    super.dispose();
    if (memoTextController.text != "")
      widget.question.bugPoints['memo'] = memoTextController.text;

    memoTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    memoTextController.selection = TextSelection.fromPosition(
      TextPosition(offset: memoTextController.text.length),
    );
    return Column(children: <Widget>[
      Row(
        children: this._buildBugCheckboxesAndButton(),
      ),
      Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
                border: OutlineInputBorder(), labelText: "memo"),
            maxLines: 4,
            controller: memoTextController,
            onChanged: (text) {
              if (!widget.question.updateBugMemo)
                setState(() => widget.question.updateBugMemo = true);
            },
          )),
    ]);
  }

  List<Widget> _buildBugCheckboxesAndButton() {
    List<Widget> tempList = [
      Container(
          width: 40.0,
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
              child: IconButton(
                icon: Icon(Icons.flare),
                color: widget.question.bugPoints.isEmpty
                    ? Colors.lightBlueAccent
                    : Colors.pink,
                iconSize: 24,
                onPressed: () {
                  if (widget.question.bugPoints.isNotEmpty) {
                    widget.question.bugPoints.clear();
                    updateBugReport(
                        widget.question.questId,
                        widget.question.bugPoints.isNotEmpty,
                        widget.question.bugPoints);
                    setState(() => widget.question.updateBugMemo = false);
                  }
                },
              )))
    ];
    // tempList.add(Padding(
    //     padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
    //     child: Container(
    //       width: 68.0,
    //       child: QuizChip("要復習", "", _isMoreStudy, _onChangedMoreStudy),
    //     )));
    this._bugCheckboxLabel.forEach((key, label) {
      tempList.add(Container(
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
              child: Container(
                width: 66.0,
                child: QuizChip(label, key, _isCheck, _onChanged),
              ))));
    });
    tempList.add(Container(
        width: 40.0,
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
            child: IconButton(
              icon: Icon(Icons.send),
              color: widget.question.updateBugMemo ? Colors.pink : Colors.grey,
              iconSize: 24,
              onPressed: () {
                if (memoTextController.text == "") {
                  widget.question.bugPoints.remove("memo");
                } else {
                  widget.question.bugPoints["memo"] = memoTextController.text;
                }
                updateBugReport(
                    widget.question.questId,
                    widget.question.bugPoints.isNotEmpty,
                    widget.question.bugPoints);
                setState(() => widget.question.updateBugMemo = false);
              },
            ))));
    return tempList;
  }

  bool _isCheck(String key) {
    return widget.question.bugPoints[key] == true;
  }

  void _onChanged(String key) {
    if (!_isCheck(key)) {
      widget.question.bugPoints[key] = true;
    } else {
      widget.question.bugPoints.remove(key);
    }
    widget.question.isBug = widget.question.bugPoints.isNotEmpty;
    updateBugReport(widget.question.questId, widget.question.isBug,
        widget.question.bugPoints);
    setState(() {widget.parent.setState(() => {});});
  }

  bool _isMoreStudy(String key) {
    return widget.question.moreStudy;
  }

  void _onChangedMoreStudy(String key) {
    widget.question.moreStudy = !widget.question.moreStudy;
    updateMoreStudy(widget.question.questId, widget.question.moreStudy);
    setState(() => {});
  }
}
