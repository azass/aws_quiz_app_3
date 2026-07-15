import 'package:aws_quiz_app/models/term.dart';
import 'package:aws_quiz_app/models/tag.dart';
import 'package:aws_quiz_app/resources/api_provider.dart';
import 'package:aws_quiz_app/ui/util.dart';
import 'package:aws_quiz_app/ui/widgets/term_view.dart';
import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

class TagView extends StatefulWidget {
  final Tag tag;
  TagView(this.tag);
  @override
  TagViewState createState() => TagViewState();
}

class TagViewState extends State<TagView> {
  List<Term> terms = [];
  List<Widget> termWidgets = [];

  @override
  void initState() {
    super.initState();
    terms = widget.tag.terms;
  }

  @override
  Widget build(BuildContext context) {
    termWidgets = [];
    terms.asMap().forEach(
      (int index, Term term) => termWidgets.add(_buildTag(index)),
    );
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
                      widget.tag.tagName,
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
        Expanded(child: SingleChildScrollView(child: _buildTile())),
      ],
    );
  }

  Color getColor(Term term) {
    return termColors[term.level - 1]["color"];
  }

  Widget _buildTag(int index) {
    Term term = terms[index];
    return Container(
      height: 36 - 3.0 * term.level,
      child: ElevatedButton(
        child: Text(term.word),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(getColor(term)),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.orange, fontSize: 12),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9.0 + 3.0 * term.level),
            ),
          ),
        ),
        onPressed: () {
          showTermView(context, widget.tag.tagName, term);
        },
      ),
    );
  }

  Widget _buildTile() {
    void _onReorder(int oldIndex, int newIndex) {}

    var wrap = ReorderableWrap(
      spacing: 2.0,
      runSpacing: 4.0,
      padding: const EdgeInsets.all(8),
      children: termWidgets,
      onReorder: _onReorder,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Material(child: wrap),
        SizedBox(height: 20.0),
      ],
    );
  }
}

showTagView(BuildContext context, Tag tag) async {
  showLoading(context);
  tag.terms = await getTerms(tag);
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
              child: TagView(tag),
            ),
          );
        },
  );
}
