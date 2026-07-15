import 'package:aws_quiz_app/models/question.dart';
import 'package:aws_quiz_app/resources/api_provider.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_chip.dart';
import 'package:flutter/material.dart';

class MistakeNoteDialog extends StatefulWidget {
  final Question question;
  const MistakeNoteDialog(Question question) : question = question;

  @override
  _MistakeNoteDialogState createState() => _MistakeNoteDialogState();
}

class _MistakeNoteDialogState extends State<MistakeNoteDialog> {
  final noteTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    noteTextController.text = widget.question.learningNote;
  }

  @override
  void dispose() {
    super.dispose();
    widget.question.learningNote = noteTextController.text;
    noteTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    noteTextController.selection = TextSelection.fromPosition(
      TextPosition(offset: noteTextController.text.length),
    );
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              width: 50.0,
              padding: EdgeInsets.only(left: 8.0, top: 8.0),
              child: Icon(Icons.assignment_ind),
            ),
            Container(
              padding: EdgeInsets.only(top: 8.0),
              child: Container(
                height: 30.0,
                width: 68.0,
                child: QuizChip("復習", "", _isMoreStudy, _onChangedMoreStudy),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 8.0),
              child: Container(
                height: 30.0,
                width: 68.0,
                child: QuizChip("難問", "", _isDifficult, _onChangedIsDifficult),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 8.0),
              child: Container(
                height: 30.0,
                width: 68.0,
                child: QuizChip("弱点", "", _isWeak, _onChangedIsWeak),
              ),
            ),
            // Container(
            //     padding: EdgeInsets.only(top: 8.0),
            //     child: Container(
            //       height: 30.0,
            //       width: 68.0,
            //       child: QuizChip("必須", "", _isMandatory, _onChangedIsMandatory),
            //     )),
            Container(
              alignment: Alignment.bottomCenter,
              height: 30.0,
              padding: const EdgeInsets.all(0.0),
              child: IconButton(
                icon: Icon(Icons.send),
                color: widget.question.updateNote ? Colors.pink : Colors.grey,
                iconSize: 24,
                onPressed: () {
                  updateLearningNote(
                    widget.question.questId,
                    widget.question.learningNote,
                  );
                  setState(() => widget.question.updateNote = false);
                },
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "note",
            ),
            maxLines: 7,
            style: TextStyle(fontSize: 12.0),
            controller: noteTextController,
            onChanged: (text) {
              widget.question.learningNote = text;
              if (!widget.question.updateNote)
                setState(() => widget.question.updateNote = true);
            },
          ),
        ),
      ],
    );
  }

  bool _isMoreStudy(String key) {
    return widget.question.moreStudy;
  }

  void _onChangedMoreStudy(String key) {
    widget.question.moreStudy = !widget.question.moreStudy;
    updateMoreStudy(widget.question.questId, widget.question.moreStudy);
    setState(() => {});
  }

  bool _isDifficult(String key) {
    return widget.question.isDifficult;
  }

  void _onChangedIsDifficult(String key) {
    widget.question.isDifficult = !widget.question.isDifficult;
    updateMoreStudy(widget.question.questId, widget.question.isDifficult);
    setState(() => {});
  }

  bool _isWeak(String key) {
    return widget.question.isWeak;
  }

  void _onChangedIsWeak(String key) {
    widget.question.isWeak = !widget.question.isWeak;
    updateIsWeak(widget.question.questId, widget.question.isWeak);
    setState(() => {});
  }
}
