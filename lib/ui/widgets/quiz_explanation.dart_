import 'package:aws_quiz_app/models/question.dart';
import 'package:aws_quiz_app/models/tag.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_image.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_link.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_markdown.dart';
import 'package:aws_quiz_app/ui/widgets/tag_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../util.dart';
import 'keyword_dialog.dart';

class QuizExplanation extends StatelessWidget {
  final Question _question;
  const QuizExplanation(this._question);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _getExplanations(context),
    );
  }

  List _getExplanations(BuildContext context) {
    List<Widget> explanations = <Widget>[];
    if (_question.explanation.length > 0) {
      explanations.add(_buildMemo());
    }
    _question.tagKeywords.forEach((tagKeywordsKey, terms) {
      Tag tag = _question.getTag(tagKeywordsKey);
      explanations.add(Align(
          alignment: Alignment.centerLeft,
          child: Padding(
              padding: EdgeInsets.only(left: 2.0, top: 4.0),
              child: _buildKeyword(context, tag, Colors.lightBlue))));
      if (terms.isNotEmpty) {
        explanations.add(_buildDocument(context, terms));
      }
    });
    return explanations;
  }

  Widget _buildDocument(BuildContext context, List<dynamic> terms) {
    List<Widget> documents = [];
    List<dynamic> _terms = [];
    terms.asMap().forEach((index, term) {
      _terms = _terms.where((t) => (t["level"] < term["level"])).toList();
      _terms.add(term);
      if (term['description'] != null) {
        List<dynamic> description = term['description']
            .where((explanation) => (explanation.containsKey('quest_ids') &&
                explanation['quest_ids'].contains(_question.questId)))
            .toList();
        if (description.length > 0 ||
            index == terms.length - 1 ||
            (index < terms.length - 1 &&
                term["level"] >= terms[index + 1]["level"])) {
          // explanations.add(SizedBox(height: 8.0));
          final _tags = getTagsInExplanation(_terms);
          documents.add(Container(
              padding: const EdgeInsets.only(top: 2.0),
              alignment: Alignment.centerLeft,
              child: Column(children: _tags)));
        }
        description.forEach((explanation) {
          if (explanation.containsKey('quest_ids') &&
              explanation['quest_ids'].contains(_question.questId)) {
            documents.add(_buildExplanation(explanation));
          }
        });
      }
    });
    return Card(
        color: CARD_COLOR,
        child: Padding(
            padding: const EdgeInsets.only(
                left: 10.0, right: 10.0, top: 4, bottom: 10.0),
            child:
                Column(mainAxisSize: MainAxisSize.min, children: documents)));
  }

  List<Widget> getTagsInExplanation(List<dynamic> terms) {
    String breadcrumbs = "";
    final List<Widget> _tags = [];
    terms.asMap().forEach((index, term) {
      if (term["word"] != "is ?") {
        if (index < terms.length - 1) {
          breadcrumbs = breadcrumbs + term["word"] + " > ";
        } else {
          if (breadcrumbs.isNotEmpty) {
            _tags.add(Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Text(
                      breadcrumbs,
                      style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.pink,
                          fontWeight: FontWeight.w600),
                    ))));
          }
          _tags.add(Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: EdgeInsets.all(2.0),
                  child: _buildKeyword3(
                      term['word'],
                      KeywordDialogState.keywordColors[term["level"] - 1]
                          ['color']))));
          if (term.containsKey('explain') &&
              term['explain'].toString().isNotEmpty) {
            _tags.add(Align(
              alignment: Alignment.centerLeft,
              child: Container(
                  alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.only(
                    left: 5.0,
                    top: 0.5,
                  ),
                  child: Wrap(
                      // alignment: Alignment.bottomLeft,
                      children: [
                        SizedBox(height: 5.0),
                        Text(term['explain'],
                            style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.pinkAccent))
                      ])),
            ));
          }
        }
      }
    });
    return _tags;
  }

  Widget _buildKeyword(BuildContext context, Tag tag, Color color) {
    return Container(
      height: 30,
      margin: EdgeInsets.only(left: 2),
      // child: Chip(
      //   label: Text(text),
      //   labelStyle: TextStyle(
      //     fontSize: 11.0,
      //     color: Colors.white,
      //     fontWeight: FontWeight.w600,
      //   ),
      //   backgroundColor: color,
      // ),
      child: ElevatedButton(
        child: Text(tag.tagName),
        style: ElevatedButton.styleFrom(
          primary: color,
          onPrimary: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () => showTagView(context, tag),
      ),
    );
  }

  Widget _buildKeyword2(String text, Color color) {
    return Container(
      height: 28,
      margin: EdgeInsets.symmetric(
        vertical: 0.0,
        horizontal: 0.0,
      ),
      padding: EdgeInsets.only(
        bottom: 0.8,
      ),
      child: Chip(
        label: Text(
          text,
          style: TextStyle(
            fontSize: 9.0,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        // padding: EdgeInsets.symmetric(
        //   vertical: 0.0,
        //   horizontal: 0.0,
        // ),
        // labelStyle: TextStyle(
        //   fontSize: 9.0,
        //   color: Colors.white,
        //   fontWeight: FontWeight.w600,
        // ),
        backgroundColor: color,
      ),
    );
  }

  Widget _buildKeyword4(String text, Color color) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: Colors.blueGrey[900],
        color: color,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
            child: Container(
                padding: EdgeInsets.all(4.0),
                alignment: Alignment.centerLeft,
                child: Text(text,
                    style: TextStyle(
                        fontSize: 9.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)))));
  }

  Widget _buildKeyword3(String text, Color color) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9.5, vertical: 1.0),
        height: 20,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(10),
        ),
        child: FittedBox(
          child: Text(text,
              style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ));
  }

  Widget _buildMemo() {
    return Card(
        color: CARD_COLOR,
        child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              ..._question.explanation
                  .map((explanation) => _buildExplanation(explanation))
            ])));
  }

  Widget _buildExplanation(Map<String, dynamic> explanation) {
    if (explanation.containsKey("link")) {
      return Padding(
          padding: const EdgeInsets.only(
              left: 8.0, right: 8.0, top: 2.0, bottom: 4.0),
          child: QuizLink(
              explanation["link"].toString(), explanation["url"].toString()));
    } else if (explanation.containsKey("image_path")) {
      return Padding(
          padding: EdgeInsets.only(top: 15.0),
          child: QuizImage(explanation["image_path"]));
    } else {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: QuizMarkdown(explanation["text"])));
    }
  }
}
