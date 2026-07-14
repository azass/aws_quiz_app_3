import 'package:aws_quiz_app/models/exam.dart';
import 'package:aws_quiz_app/models/history.dart';
import 'package:aws_quiz_app/models/option.dart';
import 'package:aws_quiz_app/models/tag.dart';
import 'package:aws_quiz_app/utils/DateUtil.dart';

enum Type { multiple, boolean }
enum Difficulty { easy, medium, hard }

class Question {
  final String questId;
  final String examId;
  int examNo;
  String testId;
  List<dynamic> questionElems;
  List<dynamic> correctAnswer;
  List<Option> options;
  List<dynamic> choice = [];
  bool judgment = false;
  String answerDate;
  int readTime;
  int answerTime;
  int answeredTime;
  int answeredAvgTime;
  String imagePath;
  double imageHeight;
  List<dynamic> explanation;
  bool moreStudy = false;
  bool isEasy = false;
  bool isDifficult = false;
  bool isWeak = false;
  bool isMandatory = false;
  bool isBug = false;
  Map<String, dynamic> bugPoints = {};
  int executeCount;
  int correctCount;
  int mistakeCount;
  List<dynamic> tags;
  Map<String, dynamic> tagKeywords = {};
  List<dynamic> keywords;
  List<History> histories;
  bool incorrectAlert = false;
  double maturity = 0.0;
  double priority = 1.0;
  String passDate;
  Stopwatch watch;
  Exam exam;
  String learningNote = "";
  bool updateBugMemo = false;
  bool updateNote = false;
  int scoring;
  int newScoring;
  int retention;
  int halving_time;
  String halving_date;
  int last_point = 0;
  double last_addPoint = 0.0;

  Question.fromRecordMap(Map<String, dynamic> data)
      : questId = data["quest_id"],
        examId = data["exam_id"],
        examNo = data["exam_no"],
        correctCount = data["correct_count"],
        tags = data["tags"],
        answeredAvgTime = data["answered_average_time"] != null
            ? data["answered_average_time"]
            : 0;

  Question.fromHistoryMap(Map<String, dynamic> data)
      : questId = data["quest_id"],
        examId = data["quest_id"].toString().substring(0, 7),
        examNo = int.parse(data["quest_id"].toString().substring(8)),
        testId = data["test_id"],
        choice = data["choice"],
        judgment = data["judgment"] == true,
        answerDate = data['answer_date'],
        answeredTime = data["answered_time"];

  void setup(Map<String, dynamic> data) {
    examNo = data["exam_no"];
    questionElems = data["question_items"];
    correctAnswer = data["correct_answer"];
    if (data.containsKey("options")) {
      options = fromOptionsData(data["options"], data["correct_answer"]);
    } else {
      options = [];
    }
    imagePath = data["image_path"];
    imageHeight =
        data["image_height"] != null ? data["image_height"].toDouble() : 0.0;
    explanation = data["explanation"] != null ? data["explanation"] : [];
    executeCount = data["execute_count"];
    correctCount = data["correct_count"];
    mistakeCount = data["mistake_count"];
    tags = Tag.fromData(data["tags"]);
    tagKeywords = (data["keywords"] == null) ? [] : data["keywords"];
    moreStudy = data["more_study"] == true;
    isDifficult = data["is_difficult"] == true;
    isWeak = data["is_weak"] == true;
    isMandatory = data["is_mandatory"] == true;
    maturity = data["maturity"] != null ? data["maturity"].toDouble() : 1.0;
    priority = data["priority"] != null ? data["priority"].toDouble() : 2.0;
    passDate = data["pass_date"];
    histories = History.fromData(data["histories"]);
    isBug = data["is_bug"] == true;
    bugPoints = (data["bug_points"] == null)
        ? {}
        : (data["bug_points"].length == 0)
            ? {}
            : data["bug_points"];
    learningNote = (data["learning_note"] == null) ? "" : data["learning_note"];
    scoring = data["scoring"] == null ? 0 : data["scoring"];
    retention = data["retention"] != null ? data["retention"] : 0;
    halving_time = data["halving_time"] != null ? data["halving_time"] : 0;
    halving_date = data["halving_date"] != null ? data["halving_date"] : "";
    answeredAvgTime = data["answered_average_time"] != null
        ? data["answered_average_time"]
        : 0;

    exam = Exam.fromMap(data);
  }

  static List<Question> fromRecordData(List<Map<String, dynamic>> data) {
    return data.map((question) => Question.fromRecordMap(question)).toList();
  }

  static List<Question> fromHistoryData(List<Map<String, dynamic>> data) {
    return data.map((question) => Question.fromHistoryMap(question)).toList();
  }

  static List<Option> fromOptionsData(
      List<dynamic> data, List<dynamic> correctAnswer) {
    List<Option> list = [];
    data.asMap().forEach((index, element) {
      list.add(Option.fromMap(index, element, correctAnswer));
    });
    return list;
  }

  void wrapTime() {
    readTime = watch.elapsed.inSeconds;
  }

  void recordWatch() {
    answerTime = watch.elapsed.inSeconds;
    answeredTime = readTime + answerTime;
    // watch.stop();
  }

  void setupResult() {
    this.judgment = true;
    choice.forEach((element) {
      this.judgment = this.judgment && correctAnswer.contains(element);
    });
    correctAnswer.forEach((element) {
      this.judgment = this.judgment && choice.contains(element);
    });
  }

  void setupMaturity() {
    if (judgment) {
      if ((maturity < 5 && passDate.compareTo(DateUtil.today()) <= 0)) {
        maturity++;
      }
    } else {
      if (maturity > 0) {
        maturity--;
      }
    }
  }

  // void setupMaturity() {
  //   if (judgment) {
  //     int consecutive = 1;
  //     for (var history in histories) {
  //       if (history.judgment) {
  //         ++consecutive;
  //       } else {
  //         break;
  //       }
  //     }
  //     if (consecutive >= 5) {
  //       maturity = 3;
  //     } else if (consecutive >= 3) {
  //       if (maturity < 2) maturity = 2;
  //     }
  //   } else {
  //     if (maturity > 1) maturity--;
  //   }
  // }

  String toString() {
    String question = "";
    questionElems.forEach((element) {
      if (element.containsKey("text")) {
        question = question + element["text"] + "\n";
      }
    });
    return question;
  }

  String selectCode() {
    String selectCode = "";
    options.forEach((option) {
      Option _option = option;
      if (_option.isSelected) {
        selectCode = _option.code;
        return;
      }
    });
    return selectCode;
  }

  String transTagName(String tagKeywordsKey) {
    String tagName = "";
    if (int.tryParse(tagKeywordsKey) == null) {
      tagName = tagKeywordsKey;
    } else {
      tags.forEach((tag) {
        Tag _tag = tag;
        if (_tag.tagNo == int.parse(tagKeywordsKey)) {
          tagName = _tag.tagName;
        }
      });
    }
    return tagName;
  }

  Tag getTag(String tagKeywordsKey) {
    Tag tag = null;
    tags.forEach((_tag) {
      if (int.tryParse(tagKeywordsKey) == null) {
        if (_tag.tagName == tagKeywordsKey) {
          tag = _tag;
        }
      } else {
        if (_tag.tagNo == int.parse(tagKeywordsKey)) {
          tag = _tag;
        }
      }
    });
    return tag;
  }
}
