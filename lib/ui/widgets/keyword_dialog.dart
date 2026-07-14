import 'dart:convert';

import 'package:aws_quiz_app/models/term.dart';
import 'package:aws_quiz_app/models/question.dart';
import 'package:aws_quiz_app/models/tag.dart';
import 'package:aws_quiz_app/models/word.dart';
import 'package:aws_quiz_app/resources/api_provider.dart';
import 'package:aws_quiz_app/ui/pages/quiz_page.dart';
import 'package:aws_quiz_app/ui/util.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_bottom_sheet.dart';
import 'package:aws_quiz_app/ui/widgets/words_dialog.dart';
import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

import 'keyword_editor.dart';

class KeywordDialog extends StatefulWidget {
  final Tag tag;
  QuizPageState quizPage = null;
  Question question = null;
  KeywordDialog(this.tag, this.quizPage, this.question);

  @override
  KeywordDialogState createState() => KeywordDialogState();
}

class KeywordDialogState extends State<KeywordDialog> {
  static List keywordColors = [
    {"color": Colors.indigoAccent[200], "text": "1"},
    {"color": Colors.blue[600], "text": "2"},
    {"color": Colors.indigo[300], "text": "3"},
    {"color": Colors.blue[300], "text": "4"},
    {"color": Colors.teal[300], "text": "5"},
    {"color": Colors.green[300], "text": "6"},
  ];
  final List questColors = [
    Colors.pink,
    Colors.redAccent[200],
    Colors.pink[200],
    Colors.deepOrange[300]
  ];
  List<Widget> keywordWidgets = [];
  List<Term> keywords = [];
  bool _isUpdateTagKeywords = false;
  bool _isUpdateQuestKeywords = false;
  Question _question = null;
  bool _edit = true;

  void addKeyword(Term keyword) {
    keywords.add(keyword);
  }

  Term getKeyword(int index) {
    return keywords[index];
  }

  void removeKeyword(int index) {
    keywords.removeAt(index);
  }

  @override
  void initState() {
    super.initState();
    List select = [];
    if (forQuestion()) {
      _edit = false;
      _question = widget.question;
      if (_question.tagKeywords.containsKey(widget.tag.tagName)) {
        select = _question.tagKeywords[widget.tag.tagName]
            .map((keyword) => keyword["term_id"])
            .toList();
      }
    }
    keywords = widget.tag.terms;
  }

  Color getColor(Term keyword) {
    if (keyword.selected) {
      return questColors[keyword.level - 1];
    } else {
      return keywordColors[keyword.level - 1]["color"];
    }
  }

  Color getFontColor(Term keyword) {}

  @override
  Widget build(BuildContext context) {
    keywordWidgets = [];
    keywords.asMap().forEach(
        (int index, Term keyword) => keywordWidgets.add(_buildTag(index)));
    return Column(children: [
      Divider(color: Colors.black),
      Material(
          child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
              child: Stack(children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                        padding: const EdgeInsets.only(
                            top: 15.0, right: 10.0, bottom: 0.0, left: 10.0),
                        child: Text(
                          widget.tag.tagName,
                          style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ))),
                Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      iconSize: 50,
                      icon: Icon(Icons.assignment_rounded),
                      color: (_isUpdateTagKeywords || _isUpdateQuestKeywords)
                          ? Colors.deepOrange
                          : Colors.indigo,
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () {
                        if (_isUpdateTagKeywords || _isUpdateQuestKeywords) {
                          setState(() {
                            _updateKeywords();
                          });
                        } else {
                          Navigator.pop(context, true);
                          if (forQuestion()) {
                            setState(
                                () {widget.quizPage.setState(() => {});});
                          }
                        }
                      },
                    ))
              ]))),
      Divider(color: Colors.black),
      Container(height: 580, child: SingleChildScrollView(child: _buildTile())),
    ]);
  }

  Widget _buildTag(int index) {
    Term keyword = keywords[index];
    return Container(
      height: 36 - 3.0 * keyword.level,
      child: ElevatedButton(
        child: Text(keyword.word),
        style: ButtonStyle(
          // foregroundColor: MaterialStateProperty.all(Colors.orange),
          backgroundColor: WidgetStateProperty.all(getColor(keyword)),
          padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0)),
          textStyle: WidgetStateProperty.all(
              const TextStyle(color: Colors.orange, fontSize: 12)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9.0 + 3.0 * keyword.level),
          )),
        ),
        onPressed: () {
          if (_edit) {
            _openKeywordEditor(context, index);
          } else {
            keywords[index].selected = !keywords[index].selected;
            if (forQuestion()) {
              _isUpdateQuestKeywords = true;
            }
          }
          setState(() {});
        },
      ),
    );
  }

  Widget _buildTile() {
    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        Term keyword = keywords.removeAt(oldIndex);
        keywords.insert(newIndex, keyword);
        notifyTagKeywords();
      });
    }

    var wrap = ReorderableWrap(
      spacing: 2.0,
      runSpacing: 4.0,
      padding: const EdgeInsets.all(8),
      children: keywordWidgets,
      onReorder: _onReorder,
    );

    var newButton = IconButton(
      iconSize: 50,
      icon: Icon(Icons.add_circle),
      color: Colors.teal,
      padding: const EdgeInsets.all(0.0),
      onPressed: () {
        setState(() {
          int newIndex = keywords.length;
          keywords.add(Term(
              termId: Term.newTermId(),
              word: "",
              level: 1,
              selected: false,
              changed: "new"));
          keywordWidgets.add(_buildTag(newIndex));
          _openKeywordEditor(context, newIndex);
          _isUpdateTagKeywords = true;
        });
      },
    );

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Material(child: wrap),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            children: <Widget>[
              if (forQuestion())
                Material(
                    child: Switch(
                  value: _edit,
                  activeThumbColor: Colors.blue,
                  activeTrackColor: Colors.green,
                  inactiveThumbColor: Colors.orange,
                  inactiveTrackColor: Colors.red,
                  onChanged: (value) => setState(() => _edit = value),
                )),
              if (forQuestion()) Material(child: _buildAddButton()),
              Material(child: newButton),
            ],
          ),
          SizedBox(height: 20.0),
        ]);
  }

  Widget _buildAddButton() {
    return IconButton(
      iconSize: 50,
      icon: Icon(Icons.add_circle),
      color: Colors.deepOrange,
      padding: const EdgeInsets.all(0.0),
      onPressed: () async {
        showLoading(context);
        List<Word> words = await getWords(_question.questId);
        Navigator.pop(context);
        WordsDialog wordsDialog = WordsDialog(words);

        await showDialog<bool>(
            context: context,
            builder: (_) {
              return wordsDialog;
            });
        setState(() {
          if (wordsDialog.selectedWord != "") {
            keywords.add(Term(
                termId: Term.newTermId(),
                word: wordsDialog.selectedWord,
                level: wordsDialog.selectedLevel,
                selected: wordsDialog.selected,
                changed: "new"));
            _isUpdateTagKeywords = true;
          }
        });
      },
    );
  }

  void _openKeywordEditor(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => QuizBottomSheet(KeywordEditor(index, this)),
    );
  }

  void notifyTagKeywords() {
    setState(() {
      _isUpdateTagKeywords = true;
    });
  }

  void notifyQuestKeywords() {
    if (forQuestion()) {
      setState(() {
        _isUpdateQuestKeywords = true;
      });
    }
  }

  void _updateKeywords() {
    String _tagNo = "";
    String _tagKeywords = "";
    String _questId = "";
    String _questKeywords = "";
    _tagNo = widget.tag.tagNo.toString();
    // keywords.asMap().forEach((i, keyword)=> keyword.sort = i + 1);
    if (_isUpdateTagKeywords) {
      List<Map<dynamic, dynamic>> elems = [];
      keywords.asMap().forEach((i, keyword) {
        var elem = {};
        elem["term_id"] = keyword.termId;
        elem["word"] = keyword.word;
        elem["level"] = keyword.level;
        if (keyword.changed != "new") {
          if (keyword.sort != i + 1) elem["changed"] = "update";
          if (keyword.changed != "") elem["changed"] = keyword.changed;
        }
        keyword.sort = i + 1;
        elem["sort"] = keyword.sort;
        elems.add(elem);
      });
      _tagKeywords = jsonEncode(elems);
      debugPrint(_tagKeywords);
    }
    if (_isUpdateQuestKeywords) {
      _questId = _question.questId;
      List elems = keywords.where((keyword) => keyword.selected).map((keyword) {
        var elem = {};
        elem["term_id"] = keyword.termId;
        elem["word"] = keyword.word;
        elem["level"] = keyword.level;
        elem["sort"] = keyword.sort;
        return elem;
      }).toList();
      _question.tagKeywords[widget.tag.tagName] = elems;
      _questKeywords = jsonEncode(_question.tagKeywords);
      debugPrint(_questKeywords);
    }

    updateKeywords(
        widget.tag.provider, _tagNo, _tagKeywords, _questId, _questKeywords);
    _isUpdateTagKeywords = false;
    _isUpdateQuestKeywords = false;
    setState(() {});
  }

  bool forQuestion() {
    return widget.quizPage != null;
  }
}

showKeywordDialog(BuildContext context, Tag tag, QuizPageState quizPage,
    Question question) async {
  showLoading(context);
  tag.terms = await getTerms(tag);
  Navigator.pop(context);
  showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return Center(
            child: Container(
                width: MediaQuery.of(context).size.width - 10,
                height: MediaQuery.of(context).size.height - 20,
                padding: EdgeInsets.all(2),
                color: Colors.white,
                child: KeywordDialog(tag, quizPage, question)));
      });
}

List<Widget> buildPickerOptions() {
  return KeywordDialogState.keywordColors.map((picker) {
    return Container(
      alignment: Alignment.center,
      color: picker["color"],
      child: Text(
        picker["text"],
        style: TextStyle(
          fontSize: 30.0,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      width: 40,
    );
  }).toList();
}
