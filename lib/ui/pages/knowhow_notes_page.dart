import 'package:aws_quiz_app/models/knowhow_note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class KnowhowNotesPage extends StatelessWidget {
  final String examName;
  final List<KnowhowNote> notes;
  const KnowhowNotesPage({Key key, this.examName, this.notes})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('つまずきノウハウ集'), elevation: 0),
        body: Container(
            color: Colors.blueGrey[900],
            height: double.infinity,
            child: KnowhowNotesView(examName: examName, notes: notes)));
  }
}

/// タブ等に埋め込むための本体ビュー（Scaffold なし）。
class KnowhowNotesView extends StatelessWidget {
  final String examName;
  final List<KnowhowNote> notes;
  const KnowhowNotesView({Key key, this.examName, this.notes})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return notes.isEmpty
        ? Center(
            child: Text(
                "まだノウハウがありません。\n問題を解いて間違えると、翌日ここに蓄積されます。",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.0, color: Colors.white54)))
        : ListView(
            padding: EdgeInsets.all(10.0),
            children: <Widget>[
              if (examName.isNotEmpty)
                Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(examName,
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white60))),
              ...notes.map((note) => _buildNoteCard(context, note)),
            ]);
  }

  Widget _buildNoteCard(BuildContext context, KnowhowNote note) {
    return Card(
        color: Colors.blueGrey[800],
        margin: EdgeInsets.only(bottom: 8.0),
        child: ExpansionTile(
            iconColor: Colors.tealAccent,
            collapsedIconColor: Colors.white54,
            title: Text(note.tagName,
                style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            subtitle: Text(
                "直近の誤答 ${note.sourceCount}問から生成  更新: ${note.updateDate}",
                style: TextStyle(fontSize: 9.5, color: Colors.white54)),
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(
                      left: 14.0, right: 14.0, bottom: 12.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: MarkdownBody(
                          data: note.content,
                          styleSheet: _darkMarkdownStyle(context))))
            ]));
  }

  /// ダーク背景に合わせた Markdown スタイル。
  MarkdownStyleSheet _darkMarkdownStyle(BuildContext context) {
    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: TextStyle(fontSize: 12.0, height: 1.6, color: Colors.white70),
      listBullet:
          TextStyle(fontSize: 12.0, height: 1.6, color: Colors.white70),
      strong: TextStyle(
          fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
      h1: TextStyle(
          fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.tealAccent),
      h2: TextStyle(
          fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.tealAccent),
      h3: TextStyle(
          fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.tealAccent),
      code: TextStyle(
          fontSize: 11.0,
          color: Colors.orangeAccent,
          backgroundColor: Colors.black26),
    );
  }
}
