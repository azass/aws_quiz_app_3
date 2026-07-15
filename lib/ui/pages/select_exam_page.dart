import 'package:aws_quiz_app/models/daily_record.dart';
import 'package:aws_quiz_app/models/exam.dart';
import 'package:aws_quiz_app/models/provider.dart';
import 'package:aws_quiz_app/models/report.dart';
import 'package:aws_quiz_app/models/scoring.dart';
import 'package:aws_quiz_app/models/tag.dart';
import 'package:aws_quiz_app/resources/api_provider.dart';
import 'package:aws_quiz_app/ui/pages/report_page.dart';
import 'package:aws_quiz_app/ui/util.dart';
import 'package:aws_quiz_app/ui/widgets/quiz_conditions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

class SelectExamPage extends StatefulWidget {
  final CloudProvider provider;
  SelectExamPage({Key? key, required this.provider}) : super(key: key);

  @override
  _SelectExamPageState createState() => _SelectExamPageState();
}

class _SelectExamPageState extends State<SelectExamPage> {
  final List<String> _selectedExam = [];
  // final List<int> _selectedCategory = [];
  final List<DailyRecord> _selectedDate = [];
  bool _isReport = false;
  List<DailyRecord> records = [];
  bool _processing = false;
  List<Tag> _selectableTags = [];

  @override
  initState() {
    super.initState();
    _setupSelectableTags();
  }

  _changeSwitch(bool e) async {
    setState(() => _processing = true);
    setState(() {
      _processing = false;
      _isReport = e;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.provider.displayName),
        elevation: 0,
        actions: <Widget>[
          Switch(
            value: _isReport,
            activeThumbColor: Colors.blue,
            activeTrackColor: Colors.green,
            inactiveThumbColor: Colors.orange,
            inactiveTrackColor: Colors.red,
            onChanged: _changeSwitch,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 110.0,
        height: 110.0,
        margin: EdgeInsets.only(bottom: 10.0),
        child: (_processing)
            ? CircularProgressIndicator()
            : FloatingActionButton(
                shape: const CircleBorder(),
                child: Text(
                  _isReport ? " REPORT " : " START ",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                ),
                backgroundColor: _isReport
                    ? Colors.blue[500]
                    : Colors.deepOrange[500],
                onPressed: () async {
                  if (_isReport) {
                    if (_selectedExam.length > 0) {
                      showLoading(context);
                      Report report = await getReport(_selectedExam[0]);
                      Navigator.pop(context);
                      _reportPressed(context, report);
                    }
                  } else {
                    _startPressed(context);
                  }
                },
              ),
      ),
      body: Stack(
        children: <Widget>[
          ClipPath(
            clipper: WaveClipperTwo(),
            child: Container(
              decoration: BoxDecoration(color: BACK_COLOR),
              height: 260,
            ),
          ),
          CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.all(10.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: getCrossAxisCount(),
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 5.0,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    _buildExamItem,
                    childCount: widget.provider.exams.length,
                  ),
                ),
              ),
              // SliverPadding(
              //   padding: const EdgeInsets.all(10.0),
              //   sliver: SliverGrid(
              //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //           crossAxisCount: getCrossAxisCount(),
              //           childAspectRatio: 1.6,
              //           crossAxisSpacing: 5.0,
              //           mainAxisSpacing: 5.0),
              //       delegate: SliverChildBuilderDelegate(
              //         _buildTagButton,
              //         childCount: _selectableTags.length,
              //       )),
              // ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 60.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int getCrossAxisCount() {
    return MediaQuery.of(context).size.width > 1000
        ? 7
        : MediaQuery.of(context).size.width > 600
        ? 5
        : 4;
  }

  Widget _buildExamItem(BuildContext context, int index) {
    Exam exam = widget.provider.exams[index];
    return MaterialButton(
      elevation: 1.0,
      highlightElevation: 1.0,
      padding: EdgeInsets.all(5),
      minWidth: 0,
      onPressed: () {
        setState(() {
          if (_selectedExam.contains(exam.examId)) {
            _selectedExam.remove(exam.examId);
          } else {
            if (_isReport) {
              _selectedExam.clear();
              _selectedDate.clear();
            }
            _selectedExam.add(exam.examId);
          }
          _setupSelectableTags();
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      color: _selectedExam.contains(exam.examId)
          ? Colors.indigoAccent[400]
          : Colors.grey.shade800,
      textColor: Colors.white70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildExamSubItems(exam),
      ),
    );
  }

  List<Widget> _buildExamSubItems(Exam exam) {
    List<Widget> tempList = [];
    if (exam.iconPath != '') {
      tempList.add(Expanded(child: Image.asset(exam.iconPath)));
    }
    tempList.add(
      Text(
        exam.examName,
        style: TextStyle(fontSize: (exam.iconPath != '') ? 8.0 : 12.0),
        textAlign: TextAlign.center,
      ),
    );
    return tempList;
  }

  // Widget _buildTagButton(BuildContext context, int index) {
  //   Tag tag = _selectableTags[index];
  //   return MaterialButton(
  //     padding: EdgeInsets.symmetric(horizontal: 5.0),
  //     elevation: 1.0,
  //     highlightElevation: 1.0,
  //     onPressed: () {
  //       setState(() {
  //         if (_selectedCategory.contains(tag.tagNo)) {
  //           _selectedCategory.remove(tag.tagNo);
  //         } else {
  //           _selectedCategory.add(tag.tagNo);
  //         }
  //       });
  //     },
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(15.0),
  //     ),
  //     color: _selectedCategory.contains(tag.tagNo)
  //         ? Colors.indigoAccent[400]
  //         : Colors.grey.shade600,
  //     textColor: Colors.white70,
  //     child: Padding(
  //       padding: EdgeInsets.zero,
  //       child: AutoSizeText(
  //         tag.tagName,
  //         minFontSize: 8.0,
  //         textAlign: TextAlign.center,
  //         maxLines: 3,
  //         wrapWords: false,
  //       ),
  //     ),
  //   );
  // }

  _setupSelectableTags() {
    _selectableTags = [];

    widget.provider.exams.forEach((exam) {
      if (_containsSelectableTag(exam)) {
        _addSelectableTags(exam.tags);
      }
    });
    _selectableTags.sort((b, a) => a.questionCount.compareTo(b.questionCount));
  }

  bool _containsSelectableTag(Exam exam) {
    if (_selectedExam.length == 0) {
      return true;
    } else {
      for (String examId in _selectedExam) {
        if (examId == exam.examId) {
          return true;
        }
      }
      return false;
    }
  }

  _addSelectableTags(tags) {
    tags.forEach((tag) => _addSelectableTag(tag));
  }

  _addSelectableTag(Tag tag) {
    for (Tag selectableTag in _selectableTags) {
      if (selectableTag.tagNo == tag.tagNo) {
        selectableTag.questionCount += tag.questionCount;
        return;
      }
    }
    Tag _tag = Tag(tag.tagNo, tag.tagName, tag.provider);
    _tag.questionCount = tag.questionCount;
    _selectableTags.add(_tag);
  }

  _startPressed(BuildContext context) async {
    showLoading(context);
    List<ScoringTableItem> table = await getTagScoringTable(
      widget.provider.name,
      _selectedExam,
    );
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => QuizConditionsDialog(
        selectedExam: _selectedExam,
        // selectedCategory: _selectedCategory,
        table: table,
      ),
    );
  }

  _reportPressed(BuildContext context, Report report) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ReportPage(report: report)));
  }
}
