import 'package:aws_quiz_app/models/history.dart';
import 'package:aws_quiz_app/ui/widgets/history_card.dart';
import 'package:flutter/material.dart';

class BookDialog extends StatefulWidget {
  final List<History> histories;
  BookDialog(this.histories);
  @override
  _BookDialogState createState() => _BookDialogState();
}

class _BookDialogState extends State<BookDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        child: Column(children: [
          Expanded(
              child: ListView.separated(
                  padding: EdgeInsets.all(5),
                  itemCount: widget.histories.length,
                  itemBuilder: (BuildContext context, int index) {
                    final history = widget.histories[index];
                    return Card(
                        color: Colors.lightGreenAccent.withValues(alpha: 0.3),
                        margin: EdgeInsets.all(2.0),
                        child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 1.0),
                            leading: SizedBox(
                              child: HistoryCard(history, null),
                              width: 50,
                            ),
                            title: Text("解答: ${history.choice..sort()}",
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.0)),
                            subtitle: Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(history.answerNote,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.0)))));
                  }, separatorBuilder: (BuildContext context, int index) { return SizedBox(height: 4.0); },))
        ]));
  }
}
