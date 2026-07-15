// ignore_for_file: implementation_imports

import 'dart:async';

import 'package:aws_quiz_app/main.dart';
import 'package:aws_quiz_app/models/daily_record.dart';
import 'package:aws_quiz_app/models/exam.dart';
import 'package:aws_quiz_app/models/history.dart';
import 'package:aws_quiz_app/models/menu_icon.dart';
import 'package:aws_quiz_app/models/option.dart';
import 'package:aws_quiz_app/models/question.dart';
import 'package:aws_quiz_app/models/report.dart';
import 'package:aws_quiz_app/models/word.dart';
import 'package:aws_quiz_app/resources/api_provider.dart';
import 'package:aws_quiz_app/ui/pages/daily_record_page.dart';
import 'package:aws_quiz_app/ui/util.dart';
import 'package:aws_quiz_app/ui/widgets/book_dialog.dart';
import 'package:aws_quiz_app/ui/widgets/menu_fabs.dart';
import 'package:aws_quiz_app/ui/widgets/note_bug.dart';
import 'package:aws_quiz_app/ui/widgets/note_learning.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_appbar.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_book.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_bottom_sheet.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_dashboard.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_explanation.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_image.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_quest_card.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_quest_head.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_scoring.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_tags.dart';
import 'package:aws_quiz_app/ui/widgets/words_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:provider/src/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class QuizPage extends StatefulWidget {
  final List<Question> questions;
  final Question question;
  final String testId;
  final bool readOnly;
  final bool training;
  final bool shuffle;

  const QuizPage({
    Key? key,
    required this.questions,
    required this.question,
    required this.testId,
    this.readOnly = false,
    this.training = false,
    this.shuffle = false,
  }) : super(key: key);

  @override
  QuizPageState createState() => QuizPageState(question);
}

enum Step { INIT, READY, START, ANSWER, CHECK, END, NEXT }

class QuizPageState extends State<QuizPage> with WidgetsBindingObserver {
  QuizPageState(this._question);

  final TextStyle _quizStyle = TextStyle(
    fontSize: 15.0,
    height: 1.5,
    fontWeight: FontWeight.bold,
    color: CARD_TEXT_COLOR,
  );

  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  final _itemScrollController = ItemScrollController();
  final _itemPositionsListener = ItemPositionsListener.create();
  final _backgroudColors = [Colors.grey.shade400, Colors.grey.shade600];
  final List<Question> _questions = [];
  Question _question;
  List<Option> _options = [];
  int _currentIndex = 0;
  bool _processing = false;
  final Stopwatch _watch = new Stopwatch();
  int _point = 0;
  int _correct = 0;
  int _executed = 0;
  Step _step = Step.INIT;
  Timer? _timer;
  bool _visibleDashboad = false;
  final icons = [
    MenuIcon(Icons.app_registration),
    MenuIcon(Icons.important_devices),
    MenuIcon(Icons.arrow_back_ios),
    MenuIcon(Icons.arrow_forward_ios),
    MenuIcon(Icons.content_paste),
    MenuIcon(Icons.bug_report),
  ];
  Color fabsColor = Colors.lightBlue.shade700;
  Icon fabsIcon = Icon(Icons.menu);
  String _token = "";
  int _estimatedTime = 0;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isSpeechPaused = false;
  String? _activeSpeechText;
  double _speechRate = 0.5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _watch.start();
    unawaited(_configureTts());
  }

  @override
  void dispose() {
    _offTimer();
    _watch.stop();
    _flutterTts.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      print('inactive');
      _flutterTts.stop();
      _offTimer();
      _watch.stop();
    } else if (state == AppLifecycleState.resumed) {
      print('resumed');
      _watch.start();
    } else if (state == AppLifecycleState.paused) {
      print('paused');
      _flutterTts.stop();
      _offTimer();
      _watch.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    _token = context.select((UserState userState) => userState.token);
    _setEstimatedTime();
    _readyQuiz();
    return WillPopScope(
      onWillPop: (widget.readOnly) ? null : _onWillPop,
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          backgroundColor: BACK_COLOR,
          title: QuizAppBar(
            _question.questId,
            _estimatedTime,
            _currentIndex,
            widget.questions.length,
            widget.readOnly,
            _isAnswered(),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: _buildFab(),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _backgroudColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(5.0),
          child: ScrollablePositionedList.builder(
            itemCount: 13,
            itemBuilder: (context, index) => _buildQuizPage(index),
            itemScrollController: _itemScrollController,
            itemPositionsListener: _itemPositionsListener,
          ),
        ),
      ),
    );
  }

  Widget _buildQuizPage(int i) {
    if (_step.index < Step.NEXT.index)
      switch (i) {
        case 0:
          return QuizQuestHead(_question);
        case 1:
          return QuizQuestCard(
            _question,
            onToggleSpeech: _toggleSpeech,
            onStopSpeech: _stopSpeech,
            isSpeaking:
                _isSpeaking &&
                _activeSpeechText ==
                    _normalizeSpeechText(_question.toString()),
            isSpeechPaused: _isSpeechPaused,
          );
        case 2:
          return SizedBox(height: 5.0);
        case 3:
          return (_step.index >= Step.START.index)
              ? _buildOptionsPart()
              : SizedBox(height: 0.0);
        case 4:
          return (!widget.readOnly && _isAnswered())
              ? QuizScoring(question: _question, parent: this)
              : const SizedBox.shrink();
        case 5:
          return QuizBook(_question, widget.readOnly, _isAnswered());
        case 6:
          // return (_step.index >= Step.CHECK.index)
          //     ? _buildTagsPart()
          //     : SizedBox(height: 0.0);
          return SizedBox(height: 0.0);
        case 7:
          return _isAnswered()
              ? QuizExplanation(
                  _question,
                  speechRate: _speechRate,
                )
              : SizedBox(height: 0.0);
        case 8:
          return (widget.readOnly)
              ? SizedBox(height: 0.0)
              : SizedBox(height: 15.0);
        case 9:
          if (widget.readOnly || !_isAnswered() || (_isAnswered()))
            return Container(
              alignment: Alignment.bottomCenter,
              child: _processing
                  ? CircularProgressIndicator()
                  : _buildElevatedButton(),
            );
          break;
        case 10:
          return SizedBox(height: 40.0);
        case 11:
          if (_visibleDashboad) return Dashboard(_question.exam);
          break;
        case 12:
          return SizedBox(height: 50.0);
      }
    return const SizedBox.shrink();
  }

  bool _isAnswered() {
    return _step.index == Step.END.index;
  }

  Widget _buildOptionsPart() {
    return Card(
      color: CARD_COLOR,
      margin: const EdgeInsets.all(5.0),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(right: 5.0, top: 20.0, bottom: 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ..._options.asMap().entries.map(
                (option) => _buildOptionInk(option.value, option.key),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionInk(Option option, int index) {
    if (option.type == "option") {
      return Ink(
        color: _step.index >= Step.CHECK.index ? option.bgColor : CARD_COLOR,
        child: _buildOption(option, index),
      );
    } else {
      return ExpansionTile(
        title: Text(option.text),
        textColor: CARD_TEXT_COLOR,
        onExpansionChanged: (bool changed) {
          setState(() {});
        },
        children: <Widget>[
          ...option.selectOptions.map(
            (selectOption) => Ink(
              color: _step.index >= Step.CHECK.index
                  ? selectOption.bgColor
                  : Colors.white,
              child: _buildSelectOption(selectOption, option),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildOption(Option option, int index) {
    if (_question.correctAnswer.length == 1) {
      String selectedCode = _question.selectCode();
      bool selected = option.code == selectedCode;
      return RadioListTile(
        title: _buildOptionTitle(option),
        tileColor: _step.index >= Step.CHECK.index
            ? option.bgColor
            : CARD_COLOR,
        dense: false,
        contentPadding: EdgeInsets.all(0.0),
        horizontalTitleGap: 4.0,
        activeColor: CARD_TEXT_COLOR,
        selected: selected,
        groupValue: selectedCode,
        value: option.code,
        toggleable: false,
        onChanged: _step.index < Step.CHECK.index
            ? (value) => _answer(option)
            : null,
      );
    } else {
      return CheckboxListTile(
        tileColor: _step.index >= Step.CHECK.index
            ? option.bgColor
            : CARD_COLOR,
        dense: false,
        contentPadding: EdgeInsets.all(0.0),
        horizontalTitleGap: 4.0,
        activeColor: CARD_TEXT_COLOR,
        value: _question.choice.contains(option.code),
        title: _buildOptionTitle(option),
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: _step.index < Step.CHECK.index
            ? (value) => _answer(option)
            : null,
      );
    }
  }

  Widget _buildSelectOption(SelectOption selectOption, Option option) {
    return RadioListTile(
      title: _buildTextWithSpeakButton(
        _buildOptionText(selectOption.label),
        selectOption.label,
      ),
      horizontalTitleGap: 4.0,
      selected: selectOption.isSelected,
      groupValue: option.selectValue(),
      value: selectOption.value,
      toggleable: false,
      onChanged: _step.index < Step.CHECK.index
          ? (value) => _answer2(selectOption)
          : null,
    );
  }

  Future<void> _configureTts() async {
    _flutterTts.setCompletionHandler(_speechFinished);
    _flutterTts.setCancelHandler(_speechFinished);
    _flutterTts.setErrorHandler((_) => _speechFinished());
    await _flutterTts.setLanguage('ja-JP');
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _toggleSpeech(String text) async {
    final speechText = _normalizeSpeechText(text);
    if (speechText.isEmpty) return;

    if (_isSpeaking && _activeSpeechText == speechText) {
      if (_isSpeechPaused) {
        final result = await _flutterTts.speak(speechText);
        if (result == 1 && mounted) {
          setState(() => _isSpeechPaused = false);
        } else if (result != 1) {
          _speechFinished();
        }
      } else {
        final result = await _flutterTts.pause();
        if (result == 1 && mounted) {
          setState(() => _isSpeechPaused = true);
        }
      }
      return;
    }

    if (_isSpeaking) await _stopSpeech();
    if (mounted) {
      setState(() {
        _isSpeaking = true;
        _isSpeechPaused = false;
        _activeSpeechText = speechText;
      });
    }
    final result = await _flutterTts.speak(speechText);
    if (result != 1) _speechFinished();
  }

  Future<void> _stopSpeech() async {
    await _flutterTts.stop();
    _speechFinished();
  }

  void _speechFinished() {
    if (!mounted || !_isSpeaking) return;
    setState(() {
      _isSpeaking = false;
      _isSpeechPaused = false;
      _activeSpeechText = null;
    });
  }

  String _normalizeSpeechText(String text) {
    return HtmlUnescape()
        .convert(text)
        .replaceAllMapped(
          RegExp(r'\[([^\]]+)\]\([^)]+\)'),
          (match) => match.group(1) ?? '',
        )
        .replaceAll(RegExp(r'[`*_>#~-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Widget _buildSpeakButton(String text, {required String tooltip}) {
    final isActive = _activeSpeechText == _normalizeSpeechText(text);
    return IconButton(
      tooltip: isActive && _isSpeaking
          ? (_isSpeechPaused ? '読み上げを再開する' : '読み上げを一時停止する')
          : tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 20.0, height: 20.0),
      iconSize: 20.0,
      visualDensity: VisualDensity.compact,
      icon: Icon(
        isActive && _isSpeaking
            ? (_isSpeechPaused ? Icons.play_arrow : Icons.pause)
            : Icons.volume_up,
      ),
      onPressed: () => _toggleSpeech(text),
    );
  }

  Widget _buildSpeechControls(String text, {required String tooltip}) {
    final isActive =
        _isSpeaking && _activeSpeechText == _normalizeSpeechText(text);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSpeakButton(text, tooltip: tooltip),
        if (isActive)
          IconButton(
            tooltip: '読み上げを停止する',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(
              width: 20.0,
              height: 20.0,
            ),
            iconSize: 20.0,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.stop),
            onPressed: _stopSpeech,
          ),
      ],
    );
  }

  void _changeSpeechRate(double value) {
    setState(() => _speechRate = value);
    _flutterTts.setSpeechRate(value);
  }

  Widget _buildTextWithSpeakButton(Widget content, String text) {
    return Column(
      spacing: 0,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        content,
        SizedBox(
          height: 20.0,
          child: Align(
            alignment: Alignment.topRight,
            child: _buildSpeechControls(text, tooltip: '選択肢を読み上げる'),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTitle(Option option) {
    late final Widget content;
    if (option.imagePath == "") {
      content = _buildOptionText(option.text);
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildOptionText(option.text),
          QuizImage(option.imagePath),
        ],
      );
    }
    return _buildTextWithSpeakButton(content, option.text);
  }

  Widget _buildOptionText(String text) {
    if (_step.index >= Step.CHECK.index) {
      return SelectableText(
        HtmlUnescape().convert(text),
        style: MediaQuery.of(context).size.width > 800
            ? TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)
            : _quizStyle,
      );
    } else {
      return Text(
        HtmlUnescape().convert(text),
        style: MediaQuery.of(context).size.width > 800
            ? TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)
            : _quizStyle,
      );
    }
  }

  Widget buildTagsPart() {
    return QuizTags(this);
  }

  Widget _buildElevatedButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          width: 98.0,
          height: 98.0,
          child: ElevatedButton(
            child: Text(
              (_step.index <= Step.READY.index)
                  ? "Start"
                  : (_step == Step.START)
                  ? "Skip"
                  : (_step == Step.ANSWER)
                  ? "Answer"
                  : "Next",
              style: MediaQuery.of(context).size.width > 800
                  ? TextStyle(fontSize: 38.0, color: Colors.white)
                  : TextStyle(fontSize: 19.0, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: CircleBorder(
                side: BorderSide(
                  color: Colors.red,
                  // width: 0.0,
                  style: BorderStyle.solid,
                ),
              ),
            ),
            onPressed: _submit,
          ),
        ),
      ],
    );
  }

  Widget _buildFab() {
    return MenuFabs(
      icons: icons,
      color: fabsColor,
      icon: fabsIcon,
      speechRate: _speechRate,
      onSpeechRateChanged: _changeSpeechRate,
      onIconTapped: (index) async {
        switch (index) {
          case 0:
            _openWordNote();
            break;
          case 1:
            _openBook();
            break;
          case 2:
            _back();
            break;
          case 3:
            _next();
            break;
          case 4:
            _openLearningNote();
            break;
          case 5:
            _openBugNote(context);
            setState(() => _question.isBug = _question.bugPoints.isNotEmpty);
            break;
        }
      },
    );
  }

  Future<void> _openWordNote() async {
    showLoading(context);
    List<Word> words = await getWords(_question.questId);
    Navigator.pop(context);
    WordsDialog wordsDialog = WordsDialog(words);
    await showDialog<bool>(
      context: context,
      builder: (_) {
        return wordsDialog;
      },
    );
  }

  Future<void> _openBook() async {
    showLoading(context);
    Navigator.pop(context);
    BookDialog bookDialog = BookDialog(_question.histories);
    await showDialog<bool>(
      context: context,
      builder: (_) {
        return bookDialog;
      },
    );
  }

  void _openLearningNote() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) =>
          QuizBottomSheet(LearningNoteDialog(_question, this)),
    );
  }

  void _openBugNote(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) =>
          QuizBottomSheet(BugNoteDialog(_question, this)),
    );
  }

  void _readyQuiz() {
    if (_step == Step.INIT) {
      _question.testId = widget.testId;
      _options = [];
      _options.addAll(_question.options);
      if (widget.readOnly || _question.choice.length > 0) {
        _options.forEach((_option) => _option.onAnswer(_question));
        _step = Step.END;
      } else {
        if (widget.shuffle) _options.shuffle();
        // _actionOnMistake();
        if (_question.choice.length == 0) {
          // _showToast("始め！！");
          _question.watch = new Stopwatch();
          _question.watch.start();
          _timer = Timer.periodic(
            // 定期実行する間隔の設定.
            Duration(seconds: 60),
            // 定期実行関数.
            _onTimer,
          );
        }
        _step = Step.READY;
      }
    }
    _setupFab();
  }

  void _setupFab() {
    icons[4].setupColor(_question.learningNote.length > 0);
    // icons[3].setupColor(_visibleDashboad);
    icons[5].setupColor(_question.isBug);
    if (_question.isBug) {
      fabsColor = Colors.pink;
    } else if (_question.isDifficult) {
      fabsColor = Colors.yellowAccent;
    } else if (_question.moreStudy) {
      fabsColor = Colors.deepPurpleAccent;
    } else {
      fabsColor = Colors.lightBlue.shade700;
    }
    if (_question.learningNote != "") {
      fabsIcon = Icon(Icons.help_outline_rounded);
    } else {
      fabsIcon = Icon(Icons.menu);
    }
  }

  void _showToast(String text, [Color color = Colors.pink]) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 2,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _onTimer(Timer timer) {
    switch (_question.watch.elapsed.inMinutes) {
      case 1:
        _showToast("1 分 経過 ", Colors.lightBlue);
        break;
      case 2:
        _showToast("2 分 経過 ", Colors.deepPurpleAccent);
        break;
      default:
        _showToast(_question.watch.elapsed.inMinutes.toString() + " 分 経過 ");
    }
  }

  void _offTimer() {
    if (_question.watch.isRunning) _question.watch.stop();
    _question.watch.reset();
    _timer?.cancel();
  }

  void _submit() {
    if (_step == Step.READY) {
      _start();
    } else if (_step == Step.ANSWER) {
      _checkAnswer();
    } else {
      _next();
    }
  }

  void _start() {
    _question.wrapTime();
    setState(() => _step = Step.START);
  }

  void _answer(Option option) {
    if (_question.correctAnswer.length == 1) {
      _question.choice = [option.code];
    } else {
      if (_question.choice.contains(option.code)) {
        _question.choice.remove(option.code);
      } else {
        _question.choice.add(option.code);
      }
    }
    _options.forEach((_option) => _option.onAnswer(_question));
    setState(
      () => _step = (_question.choice.length > 0) ? Step.ANSWER : Step.START,
    );
  }

  void _answer2(SelectOption option) {
    if (_question.choice.length == 0) {
      _question.choice = List.filled(_options.length, "");
    }
    _question.choice[option.index] = option.value;
    _options.forEach(
      (_option) => _option.selectOptions.forEach(
        (__option) => __option.onAnswer(_question),
      ),
    );
    setState(
      () => _step =
          (_question.choice.where((choice) => choice != "").toList().length > 0)
          ? Step.ANSWER
          : Step.START,
    );
  }

  Future<void> _checkAnswer() async {
    setState(() => _processing = true);
    _question.recordWatch();

    _score();
    _showResultToast();

    setState(() {
      _step = Step.CHECK;
    });
    if (!widget.training) {
      _question.setupMaturity();

      var result = await recordResult(_question, this._token);
      if (result['histories'] != null) {
        _question.histories = History.fromData(result['histories']);
        _question.answerDate = _question.histories[0].answerDate;
      }
      _question.exam = Exam.fromMap(result);
      _questions.add(_question);
      if (result['levelup']) _showLevelUp(result['level']);
    }

    setState(() {
      _processing = false;
      _step = Step.END;
    });
  }

  void _score() {
    _question.setupResult();
    if (_question.judgment) {
      if (_question.correctCount < 4) _point++;
      _correct++;
      _question.correctCount++;
    }
    if (_question.choice.length > 0) _executed++;
  }

  void _showResultToast() {
    _showToast((_question.judgment) ? "よくできました💮" : "アホ〜〜");
  }

  Future<void> _next() async {
    if (_currentIndex < (widget.questions.length - 1)) {
      _offTimer();
      // setState(() => _processing = true);
      showLoading(context);
      _step = Step.NEXT;
      _question = await getQuestion(
        widget.questions[++_currentIndex],
        this._token,
      );
      Navigator.pop(context);
      setState(() {
        _step = Step.INIT;
        _processing = false;
        _setEstimatedTime();
        _itemScrollController.jumpTo(index: 0);
      });
    } else {
      _finish();
    }
  }

  void _setEstimatedTime() {
    if (!widget.readOnly) {
      _estimatedTime = 0;
      for (
        int i = _currentIndex + (_isAnswered() ? 1 : 0);
        i < widget.questions.length;
        i++
      ) {
        if (widget.questions[i].answeredAvgTime > 0) {
          _estimatedTime += widget.questions[i].answeredAvgTime;
        } else {
          _estimatedTime += 600;
        }
      }
    }
  }

  Future<void> _back() async {
    if (_currentIndex > 0) {
      _offTimer();
      setState(() => _processing = true);
      _question = await getQuestion(
        widget.questions[--_currentIndex],
        this._token,
      );

      setState(() {
        _step = Step.INIT;
        _processing = false;
        _itemScrollController.jumpTo(index: 0);
      });
    }
  }

  void _finish() {
    _offTimer();
    _watch.stop();
    int executedTime = _watch.elapsed.inSeconds;
    String answerDate = widget.testId.substring(0, 10);
    if (!widget.training) finishQuiz(answerDate, executedTime);
    DailyRecord record = DailyRecord(
      answerDate,
      _executed,
      _correct,
      _point,
      executedTime,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DailyRecordPage(questions: _questions, record: record),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return await showDialog<bool>(
          context: context,
          builder: (_) {
            return AlertDialog(
              content: Text("Do you want to quit ？"),
              title: Text("Confirm!"),
              actions: <Widget>[
                TextButton(
                  child: Text("Yes"),
                  onPressed: () {
                    Navigator.pop(context, true);
                    _finish();
                  },
                ),
                TextButton(
                  child: Text("No"),
                  onPressed: () => Navigator.pop(context, false),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<bool> _showLevelUp(int level) async {
    final imagePath = levelupImagePaths[level];
    if (imagePath == null) return false;
    return await showDialog<bool>(
          context: context,
          builder: (_) {
            return SimpleDialog(
              backgroundColor: Colors.transparent,
              children: <Widget>[
                Container(
                  height: 400.0,
                  width: 100.0,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
              contentPadding: EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 16.0),
            );
          },
        ) ??
        false;
  }

  // _actionOnMistake() {
  //   if (_step == Step.CHECK) {
  //     if (!_question.judgment) {
  //       final player = AudioCache();
  //       player.play("sounds/gomenne.mp3");
  //       _key.currentState.showSnackBar(SnackBar(
  //           backgroundColor: Colors.white,
  //           duration: Duration(milliseconds: 2500),
  //           content: Image.asset("images/gomenne.png"),
  //           shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(500))));
  //       _question.incorrectAlert = true;
  //     }
  //     _step = Step.END;
  //   }
  // }

  // _showKeywords(List<Word> keywords) async {
  //   await showDialog<bool>(
  //       context: context,
  //       builder: (_) {
  //         return WordsDialog(keywords);
  //       });
  //
  //   setState(() {
  //     _question.keywords = [];
  //     keywords.forEach((keyword) {
  //       if (keyword.checkOn) _question.keywords.add(keyword.word);
  //     });
  //   });
  // }
  //
  // _show() {
  //   showGeneralDialog(
  //       context: context,
  //       barrierDismissible: true,
  //       barrierLabel:
  //           MaterialLocalizations.of(context).modalBarrierDismissLabel,
  //       barrierColor: Colors.black45,
  //       transitionDuration: const Duration(milliseconds: 200),
  //       pageBuilder: (BuildContext buildContext, Animation animation,
  //           Animation secondaryAnimation) {
  //         return Center(
  //           child: Container(
  //             width: MediaQuery.of(context).size.width - 10,
  //             height: MediaQuery.of(context).size.height - 80,
  //             padding: EdgeInsets.all(20),
  //             color: Colors.white,
  //             child: Column(
  //               children: [
  //                 _buildDraggableTagsPart(),
  //                 RaisedButton(
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                   },
  //                   child: Text(
  //                     "Save",
  //                     style: TextStyle(color: Colors.white),
  //                   ),
  //                   color: const Color(0xFF1BC0C5),
  //                 )
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  // }
  //
  // // Widget _buildDraggableTagsPart() {
  //   return Wrap(children: _buildDraggableTags());
  // }
  //
  // List<Widget> _buildDraggableTags() {
  //   List<Widget> tempList = [];
  //   _question.tags.forEach(
  //       (tag) => tempList.add(_buildDraggableTag(tag, Colors.lightBlue)));
  //   _question.keywords.forEach((keyword) =>
  //       tempList.add(_buildDraggableTag(keyword, Colors.indigoAccent[200])));
  //   return tempList;
  // }
  //
  // Widget _buildDraggableTag(dynamic tag, Color color) {
  //   var chip = Chip(
  //     label: Text(tag.tagName),
  //     labelStyle: TextStyle(
  //       fontSize: 12.0,
  //       color: Colors.white,
  //       fontWeight: FontWeight.w600,
  //     ),
  //     backgroundColor: color,
  //   );
  //   return Draggable(
  //     feedback: Material(child: chip),
  //     childWhenDragging: Container(),
  //     child: Material(child: chip),
  //   );
  // }
}
