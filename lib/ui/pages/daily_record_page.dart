import 'dart:math' as math;

import 'package:aws_quiz_app/main.dart';
import 'package:aws_quiz_app/models/daily_record.dart';
import 'package:aws_quiz_app/models/question.dart';
import 'package:aws_quiz_app/resources/api_provider.dart';
import 'package:aws_quiz_app/ui/pages/quiz_page.dart';
import 'package:aws_quiz_app/ui/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:provider/src/provider.dart';

// ignore: must_be_immutable
class DailyRecordPage extends StatefulWidget {
  final List<Question> questions;
  final DailyRecord record;

  DailyRecordPage({Key? key, required this.questions, required this.record})
    : super(key: key) {}

  @override
  _DailyRecordPageState createState() => _DailyRecordPageState();
}

class _DailyRecordPageState extends State<DailyRecordPage>
    with WidgetsBindingObserver {
  final List<Question> _selected = [];
  List<Question> _questions = [];
  Color _cardBgcolor = Colors.grey.shade600;
  Color _baseFontColor = Colors.white;
  bool _onlyIncorrect = false;
  String _token = "";

  @override
  void initState() {
    super.initState();
    _questions = widget.questions;
  }

  @override
  Widget build(BuildContext context) {
    _token = context.select((UserState userState) => userState.token);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.record.answerDate),
        elevation: 0,
        actions: <Widget>[
          Switch(
            value: _onlyIncorrect,
            activeThumbColor: Colors.blue,
            activeTrackColor: Colors.green,
            inactiveThumbColor: Colors.orange,
            inactiveTrackColor: Colors.red,
            onChanged: _changeSwitch,
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          ClipPath(
            clipper: WaveClipperTwo(),
            child: Container(
              decoration: BoxDecoration(color: BACK_COLOR),
              height: 150,
            ),
          ),
          CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: _buildRecordPart(),
          ),
        ],
      ),
    );
  }

  _changeSwitch(bool e) async {
    setState(() {
      _onlyIncorrect = e;
      if (_onlyIncorrect) {
        _questions = widget.questions
            .where((question) => !question.judgment)
            .toList();
      } else {
        _questions = widget.questions;
      }
    });
  }

  List<Widget> _buildRecordPart() {
    return <Widget>[
      SliverPersistentHeader(
        pinned: true,
        floating: true,
        delegate: _SliverAppBarDelegate(
          minHeight: 70.0,
          maxHeight: 70.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 8.0,
            ),
            child: Card(
              color: Colors.grey.shade800,
              shadowColor: Colors.indigo,
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: _buildScorePart(),
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 18.0),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1.0,
            crossAxisSpacing: 5.0,
            mainAxisSpacing: 5.0,
          ),
          delegate: SliverChildBuilderDelegate(
            _buildDayRecordItem,
            childCount: _questions.length,
          ),
        ),
      ),
    ];
  }

  Widget _buildScorePart() {
    return Row(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            // width: 90.0,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 4.0,
                  left: 30.0,
                  right: 40.0,
                ),
                child: Text(
                  "${widget.record.correctCount}／${widget.record.executeCount}",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w800,
                    color: _baseFontColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Align(
        //     alignment: Alignment.bottomLeft,
        //     child: Padding(
        //       padding: const EdgeInsets.only(left: 100.0, bottom: 10.0),
        //       child: Text(
        //           "point  (${widget.record.correctCount}/${widget.record.executeCount})",
        //           style: TextStyle(
        //             fontSize: 14.0,
        //             fontWeight: FontWeight.w800,
        //             color: _baseFontColor,
        //           )),
        //     )),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
            child: Text(
              "実行時間：${formatTime(widget.record.executedTime)}",
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: _baseFontColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayRecordItem(BuildContext context, int index) {
    Question question = _questions[index];
    return Card(
      shadowColor: Colors.indigo,
      elevation: 8.0,
      color: _selected.contains(question.questId)
          ? Colors.blue[100]
          : _cardBgcolor,
      child: TextButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          minimumSize: WidgetStateProperty.all(Size.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () async {
          setState(() {
            if (!_selected.contains(question)) {
              _selected.clear();
              // _selected_exam.clear();
              _selected.add(question);
            }
          });
          showLoading(context);
          question = await getQuestion(question, this._token);
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizPage(
                testId: question.testId,
                questions: _questions,
                question: question,
                readOnly: true,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 2.0),
                alignment: Alignment.topCenter,
                // width: 80.0,
                child: Text(
                  "${question.examId}",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 600
                        ? 14.0
                        : 9.0,
                    fontWeight: FontWeight.bold,
                    color: _baseFontColor,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(0.0),
                alignment: Alignment.topCenter,
                // width: 80.0,
                child: Text(
                  "No ${question.examNo}",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 600
                        ? 14.0
                        : 9.0,
                    fontWeight: FontWeight.bold,
                    color: _baseFontColor,
                  ),
                ),
              ),
              Container(
                child: (question.judgment)
                    ? Text(
                        "正解",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width > 600
                              ? 16.0
                              : 11.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        Icons.close,
                        size: MediaQuery.of(context).size.width > 600
                            ? 24.0
                            : 18.0,
                        color: Colors.red,
                      ),
              ),
              Container(
                padding: EdgeInsets.all(0.0),
                alignment: Alignment.bottomCenter,
                // width: 40.0,
                child: Text(
                  "${formatTime(question.answeredTime)}",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 600
                        ? 14.0
                        : 8.0,
                    color: _baseFontColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
