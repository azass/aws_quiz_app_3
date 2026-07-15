import 'package:aws_quiz_app/models/term.dart';
import 'package:aws_quiz_app/ui/util.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_image.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_link.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_markdown.dart';
import 'package:flutter/material.dart';

class TermView extends StatefulWidget {
  final String tagName;
  // final String word;
  // final String explain;
  // final int level;
  // final List<dynamic> description;
  final Term term;
  TermView(this.tagName, this.term);

  @override
  TermViewState createState() => TermViewState();
}

class TermViewState extends State<TermView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(color: Colors.black),
        Material(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 0.0,
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 15.0,
                      right: 10.0,
                      bottom: 0.0,
                      left: 10.0,
                    ),
                    child: Text(
                      widget.tagName,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    iconSize: 20,
                    icon: Icon(Icons.close),
                    padding: const EdgeInsets.all(0.0),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(color: Colors.black),
        Expanded(child: SingleChildScrollView(child: _buildDocument())),
      ],
    );
  }

  Widget _buildDocument() {
    List<Widget> documents = [];

    documents.add(
      Container(
        padding: const EdgeInsets.only(top: 2.0),
        alignment: Alignment.centerLeft,
        child: Column(children: _buildTag()),
      ),
    );
    widget.term.description.forEach((explanation) {
      documents.add(_buildExplanation(explanation));
    });
    return Card(
      color: CARD_COLOR,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10.0,
          right: 10.0,
          top: 4,
          bottom: 10.0,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: documents),
      ),
    );
  }

  List<Widget> _buildTag() {
    List<Widget> tag = [];
    tag.add(
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.all(2.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9.5, vertical: 2.0),
            height: 20,
            decoration: BoxDecoration(
              color: termColors[widget.term.level - 1]['color'],
              border: Border.all(
                color: termColors[widget.term.level - 1]['color'],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FittedBox(
              child: Text(
                widget.term.word,
                style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (widget.term.explain.toString().isNotEmpty) {
      tag.add(
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            alignment: Alignment.bottomLeft,
            padding: EdgeInsets.only(left: 5.0, top: 0.5),
            child: Wrap(
              // alignment: Alignment.bottomLeft,
              children: [
                SizedBox(height: 5.0),
                Text(
                  widget.term.explain.toString(),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return tag;
  }

  Widget _buildExplanation(Map<String, dynamic> explanation) {
    if (explanation.containsKey("link")) {
      return Padding(
        padding: const EdgeInsets.only(
          left: 8.0,
          right: 8.0,
          top: 2.0,
          bottom: 4.0,
        ),
        child: QuizLink(
          explanation["link"].toString(),
          explanation["url"].toString(),
        ),
      );
    } else if (explanation.containsKey("image_path")) {
      return Padding(
        padding: EdgeInsets.only(top: 15.0),
        child: QuizImage(explanation["image_path"]),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: QuizMarkdown(explanation["text"]),
        ),
      );
    }
  }
}

showTermView(BuildContext context, String tagName, Term term) async {
  showLoading(context);
  Navigator.pop(context);
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder:
        (
          BuildContext buildContext,
          Animation animation,
          Animation secondaryAnimation,
        ) {
          return Center(
            child: Container(
              width: MediaQuery.of(context).size.width - 10,
              height: MediaQuery.of(context).size.height - 20,
              padding: EdgeInsets.all(2),
              color: Colors.white,
              child: TermView(tagName, term),
            ),
          );
        },
  );
}
