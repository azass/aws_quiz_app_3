import 'package:aws_quiz_app/models/question.dart';
import 'package:aws_quiz_app/models/tag.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_image.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_link.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_markdown.dart';
import 'package:aws_quiz_app/ui/widgets/tag_view.dart';
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
      child: ElevatedButton(
        child: Text(tag.tagName),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: color,
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
    // Question.explanation の各要素を provider ごとにタブ表示する。
    // questId を Key にすることで、問題切替時に State を作り直し、
    // 共通タブが選択された状態で再表示されるようにする。
    return _ProviderTabbedMemo(
      _question.explanation,
      key: ValueKey(_question.questId),
    );
  }

  Widget _buildExplanation(Map<String, dynamic> explanation) {
    return buildExplanationItem(explanation);
  }
}

/// explanation の 1 要素を種類（link / image / text）に応じて描画する共通関数。
/// 要素間に間隔を空けるため、外側に下マージンを付与する。
Widget buildExplanationItem(Map<String, dynamic> explanation) {
  Widget child;
  if (explanation.containsKey("link")) {
    child = Padding(
        padding:
            const EdgeInsets.only(left: 8.0, right: 8.0, top: 2.0, bottom: 4.0),
        child: QuizLink(
            explanation["link"].toString(), explanation["url"].toString()));
  } else if (explanation.containsKey("image_path")) {
    child = Padding(
        padding: EdgeInsets.only(top: 15.0),
        child: QuizImage(explanation["image_path"]));
  } else {
    child = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: QuizMarkdown(explanation["text"])));
  }
  // 要素間の間隔。
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: child,
  );
}

/// Question.explanation の各要素を provider の値ごとにグループ化し、
/// スワイプ＆スクロール可能なタブで表示するメモウィジェット。
class _ProviderTabbedMemo extends StatefulWidget {
  final List<dynamic> explanations;
  const _ProviderTabbedMemo(this.explanations, {Key key}) : super(key: key);

  @override
  State<_ProviderTabbedMemo> createState() => _ProviderTabbedMemoState();
}

class _ProviderTabbedMemoState extends State<_ProviderTabbedMemo>
    with SingleTickerProviderStateMixin {
  // provider 未設定の要素をまとめるためのキー。
  static const String _defaultProviderKey = "__default__";

  // タブの表示順序。共通（未設定）を先頭に固定し、以降この順に並べる。
  // ここに無い provider は末尾に出現順で並べる。
  static const List<String> _providerOrder = [
    _defaultProviderKey,
    "agent",
    "gemini",
    "openai",
    "bedrock",
  ];

  TabController _tabController;
  List<String> _providers;
  Map<String, List<dynamic>> _grouped;

  @override
  void initState() {
    super.initState();
    _groupByProvider();
    // 共通タブ（先頭）を初期表示にする。
    _tabController = TabController(
      length: _providers.length,
      vsync: this,
      initialIndex: 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // provider ごとにグループ化し、_providerOrder の順に並べる。
  void _groupByProvider() {
    final Map<String, List<dynamic>> grouped = {};
    final List<String> seen = [];
    for (final explanation in widget.explanations) {
      String key = _defaultProviderKey;
      if (explanation is Map &&
          explanation["provider"] != null &&
          explanation["provider"].toString().isNotEmpty) {
        key = explanation["provider"].toString();
      }
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
        seen.add(key);
      }
      grouped[key].add(explanation);
    }

    // 指定順序（共通, agent, gemini, openai, bedrock）に並べ替える。
    // 指定外の provider は末尾に出現順で続ける。
    final List<String> order = [];
    for (final p in _providerOrder) {
      if (grouped.containsKey(p)) {
        order.add(p);
      }
    }
    for (final p in seen) {
      if (!order.contains(p)) {
        order.add(p);
      }
    }

    _grouped = grouped;
    _providers = order;
  }

  String _tabLabel(String providerKey) {
    return providerKey == _defaultProviderKey ? "共通" : providerKey;
  }

  @override
  Widget build(BuildContext context) {
    // provider が 1 種類以下なら従来通りタブなしで表示する。
    if (_providers.length <= 1) {
      final key = _providers.isEmpty ? _defaultProviderKey : _providers.first;
      return _buildMemoCard(_grouped[key] ?? widget.explanations);
    }

    return Card(
      color: CARD_COLOR,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // 横スクロール可能・タップで切替できるタブバー。
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.teal[800],
            unselectedLabelColor: Colors.teal[300],
            indicatorColor: Colors.teal[700],
            labelStyle: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.bold,
            ),
            tabs: _providers.map((p) => Tab(text: _tabLabel(p))).toList(),
          ),
          // スワイプで切替可能・各タブ内は縦スクロール可能なタブビュー。
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: _providers.map((p) {
                final items = _grouped[p];
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ...items.map((e) => buildExplanationItem(e))
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // タブなし（provider が 1 種類以下）の場合の従来表示。
  Widget _buildMemoCard(List<dynamic> explanations) {
    return Card(
        color: CARD_COLOR,
        child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              ...explanations.map((e) => buildExplanationItem(e))
            ])));
  }
}
