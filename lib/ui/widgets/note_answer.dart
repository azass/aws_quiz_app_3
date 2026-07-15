import 'package:aws_quiz_app/models/history.dart';
import 'package:aws_quiz_app/resources/api_provider.dart';
import 'package:flutter/material.dart';

class AnswerNoteDialog extends StatefulWidget {
  final History history;
  const AnswerNoteDialog(this.history);

  @override
  _AnswerNoteDialogState createState() => _AnswerNoteDialogState();
}

class _AnswerNoteDialogState extends State<AnswerNoteDialog> {
  final noteTextController = TextEditingController();
  bool shouldSave = false;

  @override
  void initState() {
    super.initState();
    noteTextController.text = widget.history.answerNote;
  }

  @override
  void dispose() {
    super.dispose();
    widget.history.answerNote = noteTextController.text;
    noteTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // noteTextController.selection = TextSelection.fromPosition(
    //   TextPosition(offset: noteTextController.text.length),
    // );
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            top: 4.0,
            left: 8.0,
            right: 8.0,
            bottom: 0.0,
          ),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                // alignment: Alignment.centerLeft,
                // width: 50.0,
                // padding: EdgeInsets.only(left: 8.0, top: 8.0),
                child: Icon(Icons.assignment_ind),
              ),
              Spacer(),
              Container(
                // alignment: Alignment.center,
                // padding: EdgeInsets.only(top: 8.0),
                child: Container(
                  // height: 30.0,
                  child: Text(
                    "解答日: ${widget.history.answerDate.substring(0, 10)}",
                  ),
                ),
              ),
              Spacer(),
              Container(
                alignment: Alignment.centerLeft,
                // padding: EdgeInsets.only(top: 8.0),
                child: Container(
                  // height: 30.0,
                  child: Text(
                    "解答: ${(widget.history.judgment) ? "○" : "×"} ${widget.history.choice..sort()}",
                  ),
                ),
              ),
              Spacer(),
              Container(
                // alignment: Alignment.bottomCenter,
                // height: 30.0,
                // padding: const EdgeInsets.all(0.0),
                child: IconButton(
                  icon: Icon(Icons.send),
                  color: shouldSave ? Colors.pink : Colors.grey,
                  iconSize: 24,
                  onPressed: () {
                    updateAnswerNote(
                      widget.history.testId,
                      widget.history.questId,
                      widget.history.answerNote,
                    );
                    setState(() => shouldSave = false);
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 0.0),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "note",
            ),
            maxLines: 6,
            style: TextStyle(fontSize: 12.0),
            controller: noteTextController,
            onChanged: (text) {
              widget.history.answerNote = text;
              if (!shouldSave) setState(() => shouldSave = true);
            },
          ),
        ),
      ],
    );
  }
}
