import 'dart:io';

import 'package:aws_quiz_app/main.dart';
import 'package:aws_quiz_app/models/question.dart';
import 'package:aws_quiz_app/models/scoring.dart';
import 'package:aws_quiz_app/resources/api_provider.dart';
import 'package:aws_quiz_app/ui/pages/error.dart';
import 'package:aws_quiz_app/ui/pages/quiz_page.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_chip.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_scoring_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import '../util.dart';

class QuizConditionsDialog extends StatefulWidget {
  final List<String> selectedExam;
  final List<ScoringTableItem> table;
  QuizConditionsDialog({
    Key? key,
    required this.selectedExam,
    required this.table,
  }) : super(key: key);

  @override
  _QuizConditionsDialogState createState() => _QuizConditionsDialogState();
}

class _QuizConditionsDialogState extends State<QuizConditionsDialog> {
  final _openness = ["公開中のみ", "準備中含む"];
  final _timesOption = ["すべて", "正解", "実行", "間違え"];
  final _targetOption = ["対象外", "間違え"];
  List<int> _selectedCategory = [];
  int _noOfQuestions = -1;
  int _selectTimesOption = 0;
  int _selectTargetOption = 0;
  List<int> _times = [];
  List<int> _otherOptions = [5];
  int _order = 2;
  int _retention = 100;
  List<int> _maturities = [-1];
  List<int> _priorities = [1, 2, 3];
  List<int> _scorings = [];
  List<int> _targetDaysAgos = [];
  List<int> _exclusives = [0];
  bool _processing = false;
  bool _readOnly = false;
  bool _training = false;
  bool _shuffle = false;
  bool _exceptNotReady = true;
  final PageController _pageController = PageController(initialPage: 1);
  String _token = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _token = context.select((UserState userState) => userState.token);

    return Stack(
      children: <Widget>[
        Container(
          child: PageView(
            reverse: false,
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            children: [_buildPage0(), _buildPage(), _buildPage2()],
          ),
        ),
        Container(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 30.0, bottom: 54.0),
            child: QuizChip(
              "read only",
              0,
              _isOnReadonlyOption,
              _selectReadonlyOption,
            ),
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 48.0),
            child: _processing
                ? CircularProgressIndicator()
                : ElevatedButton(
                    child: Text("Start Quiz",style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white),),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                    onPressed: _startQuiz,
                  ),
          ),
        ),
        Container(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(right: 30.0, bottom: 54.0),
            child: QuizChip(
              " training ",
              0,
              _isOnTrainingOption,
              _selectTrainingOption,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage0() {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 4.0,
                left: 4.0,
                right: 4.0,
                bottom: 80,
              ),
              child: Container(
                color: Colors.blueGrey[900],
                child: QuizScoringTable(_selectedCategory, widget.table),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage() {
    return Column(
      children: <Widget>[
        SizedBox(height: 20.0),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            runSpacing: 10.0,
            spacing: 2.0,
            children: <Widget>[
              SizedBox(width: 0.0),
              ActionChip(
                label: Text(_otherOptions.contains(-2) ? "対象外" : "すべて"),
                labelPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                labelStyle: TextStyle(color: Colors.white),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const StadiumBorder(),
                backgroundColor: _otherOptions.contains(-1)
                    ? Colors.indigo
                    : (_otherOptions.contains(-2))
                    ? Colors.pink
                    : Colors.grey.shade600,
                onPressed: () => _selectOtherOptionSwitch(),
              ),
              QuizChip("復習", 0, _isOnOtherOption, _selectOtherOption),
              QuizChip("難問", 1, _isOnOtherOption, _selectOtherOption),
              QuizChip("弱点", 2, _isOnOtherOption, _selectOtherOption),
              // QuizChip("必須", 3, _isOnOtherOption, _selectOtherOption),
              QuizChip("バグ", 4, _isOnOtherOption, _selectOtherOption),
              SizedBox(width: 3.0),
            ],
          ),
        ),
        _buildSectionTitle("定着度"),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            runSpacing: 1.0,
            spacing: 2.0,
            children: <Widget>[
              SizedBox(width: 0.0),
              QuizChip("すべて", -1, _isOnRetention, _selectRetention),
              QuizChip("０", 0, _isOnRetention, _selectRetention),
              QuizChip("< 40", 40, _isOnRetention, _selectRetention),
              QuizChip("< 60", 60, _isOnRetention, _selectRetention),
              QuizChip("< 80", 80, _isOnRetention, _selectRetention),
              QuizChip("< 100", 100, _isOnRetention, _selectRetention),
              ActionChip(
                label: Text("忘却"),
                labelPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                labelStyle: TextStyle(color: Colors.white),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const StadiumBorder(),
                backgroundColor: _otherOptions.contains(5)
                    ? Colors.pink
                    : Colors.grey.shade600,
                onPressed: () => _selectOtherOption(5),
              ),
              SizedBox(width: 5.0),
            ],
          ),
        ),
        // SizedBox(height: 5.0),
        _buildSectionTitle("実行回数／間違え回数／正解回数"),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: 2.0,
            children: <Widget>[
              SizedBox(width: 0.0),
              ActionChip(
                label: Text(_timesOption[_selectTimesOption]),
                labelPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                labelStyle: TextStyle(color: Colors.white),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const StadiumBorder(),
                backgroundColor: _selectTimesOption == 0
                    ? Colors.indigo
                    : Colors.pink,
                onPressed: () => _selectTimesOptionSwitch(),
              ),
              QuizChip("０", 0, _isOnTime, _selectTimeChip),
              QuizChip("１", 1, _isOnTime, _selectTimeChip),
              QuizChip("２", 2, _isOnTime, _selectTimeChip),
              QuizChip("３", 3, _isOnTime, _selectTimeChip),
              QuizChip("４", 4, _isOnTime, _selectTimeChip),
              QuizChip("５以上", 5, _isOnTime, _selectTimeChip),
              SizedBox(width: 5.0),
            ],
          ),
        ),
        // Text("間違え回数"),
        // SizedBox(
        //   width: double.infinity,
        //   child: Wrap(
        //     alignment: WrapAlignment.center,
        //     runAlignment: WrapAlignment.center,
        //     runSpacing: 5.0,
        //     spacing: 5.0,
        //     children: <Widget>[
        //       SizedBox(width: 0.0),
        //       QuizChip("すべて", -1, _isOnMistakeTime, _selectMistakeTime),
        //       QuizChip("０", 0, _isOnMistakeTime, _selectMistakeTime),
        //       QuizChip("１", 1, _isOnMistakeTime, _selectMistakeTime),
        //       QuizChip("２", 2, _isOnMistakeTime, _selectMistakeTime),
        //       QuizChip("３", 3, _isOnMistakeTime, _selectMistakeTime),
        //       QuizChip("４", 4, _isOnMistakeTime, _selectMistakeTime),
        //       QuizChip("５以上", 5, _isOnMistakeTime, _selectMistakeTime),
        //       SizedBox(width: 5.0),
        //     ],
        //   ),
        // ),
        // Text("正解回数"),
        // SizedBox(
        //   width: double.infinity,
        //   child: Wrap(
        //     alignment: WrapAlignment.center,
        //     runAlignment: WrapAlignment.center,
        //     runSpacing: 5.0,
        //     spacing: 5.0,
        //     children: <Widget>[
        //       SizedBox(width: 0.0),
        //       QuizChip("すべて", -1, _isOnCorrectTime, _selectCorrectTime),
        //       QuizChip("０", 0, _isOnCorrectTime, _selectCorrectTime),
        //       QuizChip("１", 1, _isOnCorrectTime, _selectCorrectTime),
        //       QuizChip("２", 2, _isOnCorrectTime, _selectCorrectTime),
        //       QuizChip("３", 3, _isOnCorrectTime, _selectCorrectTime),
        //       QuizChip("４", 4, _isOnCorrectTime, _selectCorrectTime),
        //       QuizChip("５以上", 5, _isOnCorrectTime, _selectCorrectTime),
        //       SizedBox(width: 5.0),
        //     ],
        //   ),
        // ),
        _buildSectionTitle("対象外／間違え"),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            runSpacing: 0.0,
            spacing: 2.0,
            children: <Widget>[
              SizedBox(width: 0.0),
              ActionChip(
                label: Text(_targetOption[_selectTargetOption]),
                labelPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                labelStyle: TextStyle(color: Colors.white),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const StadiumBorder(),
                backgroundColor: Colors.pink,
                onPressed: () => _selectTargetOptionSwitch(),
              ),
              _targetChip(["今日", "今日"], [0, 0]),
              _targetChip(["昨日", "昨日"], [1, 1]),
              _targetChip(["2日前", "2日前"], [2, 2]),
              _targetChip(["3日前", "3日前"], [3, 3]),
              _targetChip(["4日前", "4日前"], [4, 4]),
              _targetChip(["1週分", "5日前"], [7, 5]),
              _targetChip(["2週分", "6日前"], [14, 6]),
              _targetChip(["1月分", "7日前"], [30, 7]),
              SizedBox(width: 3.0),
            ],
          ),
        ),
        SizedBox(height: 4.0),
      ],
    );
  }

  QuizChip _targetChip(labels, values) {
    Function _isOn = _isOnExclusive;
    Function _f = _selectExclusive;
    if (_selectTargetOption == 0) {
      if (values[_selectTargetOption] > 4) {
        _f = _selectExclusive2;
      }
    } else {
      _isOn = _isOnMistakeDay;
      _f = _selectMistakeDay;
    }
    return QuizChip(
      labels[_selectTargetOption],
      values[_selectTargetOption],
      _isOn,
      _f,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
      child: SizedBox(
        width: double.infinity,
        child: Text(title, textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildPage2() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 80.0),
      children: <Widget>[
        SizedBox(height: 20.0),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            runSpacing: 10.0,
            spacing: 6.0,
            children: <Widget>[
              QuizChip("ランダム", 2, _isOnOrder, _selectOrder),
              QuizChip("昇順", 0, _isOnOrder, _selectOrder),
              QuizChip("降順", 1, _isOnOrder, _selectOrder),
              QuizChip("シャッフル", 3, _isShuffle, _selectShuffle),
              ActionChip(
                label: Text(_openness[_exceptNotReady ? 0 : 1]),
                labelPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                labelStyle: TextStyle(color: Colors.white),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const StadiumBorder(),
                backgroundColor: Colors.indigo,
                onPressed: () => _selectOpennessSwitch(),
              ),
            ],
          ),
        ),
        _buildSectionTitle("問題数"),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            runSpacing: 1.0,
            spacing: 1.0,
            children: <Widget>[
              SizedBox(width: 0.0),
              QuizChip("すべて", -1, _isOnNoOfQuestions, _selectNoOfQuestions),
              QuizChip("10", 10, _isOnNoOfQuestions, _selectNoOfQuestions),
              QuizChip("20", 20, _isOnNoOfQuestions, _selectNoOfQuestions),
              QuizChip("30", 30, _isOnNoOfQuestions, _selectNoOfQuestions),
              QuizChip("40", 40, _isOnNoOfQuestions, _selectNoOfQuestions),
              QuizChip("50", 50, _isOnNoOfQuestions, _selectNoOfQuestions),
              QuizChip("65", 65, _isOnNoOfQuestions, _selectNoOfQuestions),
              QuizChip("75", 75, _isOnNoOfQuestions, _selectNoOfQuestions),
              SizedBox(width: 5.0),
            ],
          ),
        ),
        _buildSectionTitle("優先度"),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            runSpacing: 10.0,
            spacing: 12.0,
            children: <Widget>[
              SizedBox(width: 0.0),
              QuizChip("捨て問", 0, _isOnPriority, _selectPriority),
              QuizChip("後回し", 1, _isOnPriority, _selectPriority),
              QuizChip("普通", 2, _isOnPriority, _selectPriority),
              QuizChip("必須", 3, _isOnPriority, _selectPriority),
              SizedBox(width: 3.0),
            ],
          ),
        ),
        _buildSectionTitle("自信レベル"),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            runSpacing: 0.0,
            spacing: 2.0,
            children: <Widget>[
              SizedBox(width: 0.0),
              QuizChip("無印", 0, _isOnScoring, _selectScoring),
              QuizChip(scoringName[10], 10, _isOnScoring, _selectScoring),
              QuizChip(scoringName[9], 9, _isOnScoring, _selectScoring),
              QuizChip(scoringName[8], 8, _isOnScoring, _selectScoring),
              QuizChip(scoringName[7], 7, _isOnScoring, _selectScoring),
              QuizChip(scoringName[6], 6, _isOnScoring, _selectScoring),
              QuizChip(scoringName[5], 5, _isOnScoring, _selectScoring),
              QuizChip(scoringName[4], 4, _isOnScoring, _selectScoring),
              QuizChip(scoringName[3], 3, _isOnScoring, _selectScoring),
              QuizChip(scoringName[2], 2, _isOnScoring, _selectScoring),
              QuizChip(scoringName[1], 1, _isOnScoring, _selectScoring),
              QuizChip("昨日", 1, _isScoringDaysAgo, _selectScoringDaysAgo),
              QuizChip("2日前", 2, _isScoringDaysAgo, _selectScoringDaysAgo),
              QuizChip("3日前", 3, _isScoringDaysAgo, _selectScoringDaysAgo),
              QuizChip("4日前", 4, _isScoringDaysAgo, _selectScoringDaysAgo),
              QuizChip("5日前", 5, _isScoringDaysAgo, _selectScoringDaysAgo),
              SizedBox(width: 0.0),
            ],
          ),
        ),
      ],
    );
  }

  _isOnNoOfQuestions(int i) {
    return i == _noOfQuestions;
  }

  _selectNoOfQuestions(int i) {
    setState(() => _noOfQuestions = i);
  }

  _selectOpennessSwitch() {
    setState(() => _exceptNotReady = !_exceptNotReady);
  }

  _selectTimesOptionSwitch() {
    setState(() => _selectTimesOption = (_selectTimesOption + 1) % 4);
    if (_selectTimesOption == 0) {
      _times = [];
    }
  }

  _selectTargetOptionSwitch() {
    if (_selectTargetOption == 0) {
      _exclusives = [];
    } else {
      _exclusives = [0];
      _targetDaysAgos = [];
    }
    setState(() {
      _selectTargetOption = (_selectTargetOption + 1) % _targetOption.length;
      _readyChip();
    });
  }

  _isOnTime(int i) {
    if (_selectTimesOption == 0) {
      return false;
    } else {
      return _times.contains(i);
    }
  }

  _selectTimeChip(int i) {
    if (_selectTimesOption != 0) {
      setState(() => _times = _selectTime(_times, i));
    }
  }

  List<int> _toggleChip(List<int> times, int i) {
    if (times.contains(i)) {
      times.remove(i);
    } else {
      times.add(i);
    }
    return times;
  }

  List<int> _selectTime(List<int> times, int i) {
    if (i == -1) {
      times = [-1];
    } else {
      times = _toggleTimes(times, i);
      if (times.length == 0) {
        times = [i];
      }
    }
    return times;
  }

  List<int> _selectTime2(List<int> times, int i) {
    if (i == -1) {
      times = [-1];
    } else {
      times = _toggleTimes(times, i);
    }
    return times;
  }

  List<int> _toggleTimes(List<int> times, int i) {
    if (times.contains(-1)) {
      times = [i];
    } else if (times.contains(i)) {
      times.remove(i);
    } else {
      times.add(i);
    }
    return times;
  }

  _isOnOrder(int i) {
    return i == _order;
  }

  _selectOrder(int i) {
    setState(() => _order = i);
  }

  _selectOtherOptionSwitch() {
    if (!_otherOptions.contains(-1)) {
      if (_otherOptions.contains(5)) _retention = -1;
      _otherOptions = [-1];
    } else {
      _otherOptions.remove(-1);
      _otherOptions.add(-2);
    }
    setState(() => {});
  }

  _isOnOtherOption(int i) {
    return _otherOptions.contains(i);
  }

  _selectOtherOption(int i) {
    setState(() {
      if (_otherOptions.contains(i)) {
        _otherOptions.remove(i);
        if (_otherOptions.isEmpty) {
          _otherOptions.add(-1);
          _retention = -1;
        }
        if (i == 5) _retention = -1;
      } else {
        // if (i == 5) {
        //   _otherOptions.clear();
        //   _otherOptions.add(i);
        // } else {
        _otherOptions.add(i);
        if (_otherOptions.contains(-1)) _otherOptions.remove(-1);
        if (i == 5) _retention = 100;
        // if (_otherOptions.contains(5)) _otherOptions.remove(5);
        // }
      }
    });
  }

  _isOnRetention(int i) {
    return i == _retention;
  }

  _selectRetention(int i) {
    setState(() => _retention = i);
  }

  isOnMaturity(int i) {
    return _maturities.contains(i);
  }

  selectMaturity(int i) {
    setState(() => _maturities = _selectTime(_maturities, i));
  }

  _isOnPriority(int i) {
    return _priorities.contains(i);
  }

  _selectPriority(int i) {
    setState(() => _priorities = _selectTime(_priorities, i));
  }

  _isOnScoring(int i) {
    return _scorings.contains(i);
  }

  _selectScoring(int i) {
    if (_selectTargetOption == 0) {
      setState(() {
        _scorings = _toggleChip(_scorings, i);
        if (_scorings.length == 0) {
          _targetDaysAgos = [];
        }
      });
    }
  }

  _isScoringDaysAgo(int i) {
    return _scorings.length > 0 && _targetDaysAgos.contains(i);
  }

  _selectScoringDaysAgo(int i) {
    if (_selectTargetOption == 0 &&
        _exclusives.length == 1 &&
        _exclusives[0] == 0) {
      if (_scorings.length > 0) {
        setState(() => _targetDaysAgos = _toggleChip(_targetDaysAgos, i));
      }
    }
  }

  _isOnExclusive(int i) {
    return _exclusives.contains(i);
  }

  _selectExclusive(int i) {
    setState(() {
      _exclusives = _selectTime2(
        _exclusives.where((n) => ![7, 14, 30].contains(n)).toList(),
        i,
      );
      _readyChip();
    });
  }

  _selectExclusive2(int i) {
    setState(() {
      _exclusives = [i];
      _readyChip();
    });
  }

  _isOnMistakeDay(int i) {
    return _targetDaysAgos.contains(i);
  }

  _selectMistakeDay(int i) {
    setState(() => _targetDaysAgos = _toggleChip(_targetDaysAgos, i));
  }

  _readyChip() {
    if (_selectTargetOption == 1) {
      _scorings = [];
      _targetDaysAgos = [];
    } else {
      if (!(_exclusives == 1 && _exclusives[0] == 0)) {
        _targetDaysAgos = [];
      }
    }
  }

  _isOnReadonlyOption(int i) {
    return _readOnly;
  }

  _selectReadonlyOption(int i) {
    setState(() => _readOnly = !_readOnly);
  }

  _isOnTrainingOption(int i) {
    return _training;
  }

  _selectTrainingOption(int i) {
    setState(() => _training = !_training);
  }

  bool _isShuffle(int i) {
    return _shuffle;
  }

  void _selectShuffle(int i) {
    setState(() => _shuffle = !_shuffle);
  }

  void _startQuiz() async {
    setState(() => _processing = true);
    try {
      initializeDateFormatting('ja');
      String testId = DateTime.now().toIso8601String();
      List<Question> questions = await getQuestions(
        widget.selectedExam,
        _selectedCategory,
        _selectTimesOption == 2 ? _times : [],
        _selectTimesOption == 3 ? _times : [],
        _selectTimesOption == 1 ? _times : [],
        // _executeTimes.contains(-1) ? [] : _executeTimes,
        // _mistakeTimes.contains(-1) ? [] : _mistakeTimes,
        // _correctTimes.contains(-1) ? [] : _correctTimes,
        _noOfQuestions,
        _otherOptions.contains(-1) ? [] : _otherOptions,
        _priorities,
        _exclusives.contains(-1) ? [] : _exclusives,
        _selectTargetOption == 1 ? [1, 2, 3, 4, 5] : _scorings,
        _targetDaysAgos,
        _retention,
        _order,
        _exceptNotReady,
        this._token,
      );

      if (questions.length < 1) {
        showAlertDialog(context, "対象はありませんでした");
      } else {
        Question question = await getQuestion(questions[0], this._token);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizPage(
              testId: testId,
              questions: questions,
              question: question,
              readOnly: _readOnly,
              training: _training,
              shuffle: _shuffle,
            ),
          ),
        );
      }
    } on SocketException catch (_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ErrorPage(
            message:
                "Can't reach the servers, \n Please check your internet connection.",
          ),
        ),
      );
    } catch (e) {
      print(e);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ErrorPage(
            message: "Unexpected error trying to connect to the API",
          ),
        ),
      );
    }
    setState(() => _processing = false);
  }

  showAlertDialog(BuildContext context, String message) {
    // Create button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () => Navigator.of(context).pop(),
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("エラー"),
      content: Text(message),
      actions: [okButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
