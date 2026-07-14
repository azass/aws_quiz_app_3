import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import '../util.dart';

class QuizMarkdown extends StatelessWidget {
  final String body;
  QuizMarkdown(this.body);

  @override
  Widget build(BuildContext context) {
    String _s = md.markdownToHtml(body);
    Widget _w = Html(data: _s, style: {
      "p": Style(
          fontSize: FontSize(24.0),
          color: CARD_TEXT_COLOR,
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
          margin: EdgeInsets.all(0),
          lineHeight: LineHeight(1.6),
          whiteSpace: WhiteSpace.PRE),
      // "ul": Style(
      //     padding: EdgeInsets.all(2.0),
      //     margin: EdgeInsets.all(2.0),
      //     lineHeight: LineHeight(1.6)),
      "li": Style(
          fontSize: FontSize(14.0),
          padding: EdgeInsets.symmetric(vertical: 2.0),
          margin: EdgeInsets.all(2.0),
          lineHeight: LineHeight(1.6),
          whiteSpace: WhiteSpace.PRE),
      "strong": Style(
          fontSize: FontSize(15.0),
          fontWeight: FontWeight.bold,
          color: Colors.redAccent)
    }
        // selectable: true,
        // data:md.markdownToHtml(explanation["text"]),
        //   styleSheet: MarkdownStyleSheet.fromTheme(ThemeData(
        //       textTheme: TextTheme(
        //           bodyText2: _quizStyle))),
        // style: _quizStyle,
        );
    String _body = body.replaceAll('\n', '\n\n');
    return MarkdownBody(
      data: _body,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
          p: TextStyle(
              fontSize: 15.0,
              color: CARD_TEXT_COLOR,
              fontWeight: FontWeight.bold)),
      styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
    );
  }
}
