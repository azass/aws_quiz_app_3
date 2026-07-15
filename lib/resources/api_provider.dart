import 'dart:convert';

import 'package:aws_quiz_app/models/daily_record.dart';
import 'package:aws_quiz_app/models/exam.dart';
import 'package:aws_quiz_app/models/provider.dart';
import 'package:aws_quiz_app/models/question.dart';
import 'package:aws_quiz_app/models/report.dart';
import 'package:aws_quiz_app/models/scoring.dart';
import 'package:aws_quiz_app/models/tag.dart';
import 'package:aws_quiz_app/models/term.dart';
import 'package:aws_quiz_app/models/word.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:aws_quiz_app/models/knowhow_note.dart';

const String baseUrl =
    "https://avnrlm9jw7.execute-api.ap-northeast-1.amazonaws.com/awsquiz/dynamodbctrl";
const String baseApi =
    "https://avnrlm9jw7.execute-api.ap-northeast-1.amazonaws.com/awsquiz/";

Map<String, String> headers(String token) {
  return {"Authorization": token};
}

Future<List<Question>> getQuestions(
  List<String> selectedExam,
  List<int> selectedCategory,
  List<int> executeTimes,
  List<int> mistakeTimes,
  List<int> correctTimes,
  int noOfQuestions,
  List<int> otherOptions,
  List<int> priorities,
  List<int> exclusives,
  List<int> scorings,
  List<int> targetDaysAgos,
  int retention,
  int order,
  bool exceptNotReady,
  String token,
) async {
  Map<String, dynamic> _payload = {"Method": "SEARCH_QUESTIONS"};
  Map<String, dynamic> _args = {};
  _args["exam_ids"] = selectedExam;
  _args["category_ids"] = selectedCategory;
  _args["execute_times"] = executeTimes;
  _args["mistake_times"] = mistakeTimes;
  _args["correct_times"] = correctTimes;
  _args["no_of_questions"] = noOfQuestions;
  _args["other_options"] = otherOptions;
  _args["priorities"] = priorities;
  _args["exclusives"] = exclusives;
  _args["scorings"] = scorings;
  _args["target_days_agos"] = targetDaysAgos;
  _args["retention"] = retention;
  _args["order"] = order;
  _args["except_old"] = true;
  _args["except_not_ready"] = exceptNotReady;
  _payload["Args"] = _args;
  String payload = JsonEncoder().convert(_payload);
  http.Response res = await http.post(
    Uri.parse(baseApi + "questions"),
    body: payload,
    headers: headers(token),
  );
  String jso = res.body;
  List<Map<String, dynamic>> questions = List<Map<String, dynamic>>.from(
    json.decode(jso),
  );
  return Question.fromRecordData(questions);
}

Future<Question> getQuestion(Question question, String token) async {
  try {
    http.Response res = await http.get(
      Uri.parse(baseApi + "question?quest_id=" + question.questId),
      headers: headers(token),
    );
    String jso = res.body;
    Map<String, dynamic> result = json.decode(jso);
    // if (result["Count"] > 0) {
    question.setup(Map<String, dynamic>.from(result['body']));
    return question;
    // } else {
    //   return null;
    // }
  } catch (e) {
    print('quest_id=${question.questId}');
    print('Something really unknown: $e');
    rethrow;
  }
}

Future<List<ScoringTableItem>> getTagScoringTable(
  String provider,
  List<String> examIds,
) async {
  try {
    Map<String, dynamic> _payload = {"Method": "TAG_SCORING_TABLE"};
    Map<String, dynamic> _args = {};
    _args["provider"] = provider;
    _args["exam_ids"] = examIds;
    _payload["Args"] = _args;
    String payload = JsonEncoder().convert(_payload);
    http.Response res = await http.post(Uri.parse(baseUrl), body: payload);
    String jso = res.body;
    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      json.decode(jso),
    );
    for (final item in data) {
      item['provider'] ??= provider;
    }
    return ScoringTableItem.fromDataList(data);
  } catch (e) {
    print(e);
    rethrow;
  }
}

Future<Map<String, dynamic>> recordResult(
  Question question,
  String token,
) async {
  Map<String, dynamic> _payload = {"Method": "RECORD"};
  Map<String, dynamic> _args = {};
  _args["test_id"] = question.testId;
  _args["quest_id"] = question.questId;
  _args["judgment"] = question.judgment;
  _args["choice"] = question.choice;
  _args["answered_time"] = question.answeredTime;
  _args["maturity"] = question.maturity.toInt();
  _payload["Args"] = _args;
  String payload = JsonEncoder().convert(_payload);
  http.Response res = await http.post(
    Uri.parse(baseUrl),
    body: payload,
    headers: headers(token),
  );
  String jso = res.body;
  return json.decode(jso);
}

Future<Map<String, dynamic>> updateHistoryScoring(Question question) async {
  Map<String, dynamic> _payload = {"Method": "UPDATE_HISTORY_SCORING"};
  Map<String, dynamic> _args = {};
  _args["test_id"] = question.testId;
  _args["exam_id"] = question.exam.examId;
  _args["quest_id"] = question.questId;
  _args["scoring"] = question.scoring;
  _args["newScoring"] = question.newScoring;
  _payload["Args"] = _args;
  String payload = JsonEncoder().convert(_payload);
  http.Response res = await http.post(Uri.parse(baseUrl), body: payload);
  String jso = res.body;
  Map<String, dynamic> result = json.decode(jso);
  return result;
}

void finishQuiz(String answerDate, int executedTime) async {
  Map<String, dynamic> _payload = {"Method": "FINISH_QUIZ"};
  Map<String, dynamic> _args = {};
  _args["answer_date"] = answerDate;
  _args["executed_time"] = executedTime;
  _payload["Args"] = _args;
  String payload = JsonEncoder().convert(_payload);
  await http.post(Uri.parse(baseUrl), body: payload);
}

Future<Report> getReport(String examId) async {
  http.Response res = await http.get(
    Uri.parse(baseApi + "report?exam_id=$examId"),
  );
  String jso = utf8.decode(res.bodyBytes);
  print(jso);
  Map<String, dynamic> result = json.decode(jso);
  // List items = result['items'];
  // items.forEach((element) {print(element['sort'].runtimeType);print(element['sort']);});
  // print(result['items']);
  return Report.fromMap(result);
}

Future<Report> getReportByTag(Exam exam, Tag tag) async {
  http.Response res = await http.get(
    Uri.parse(
      baseApi +
          "report?exam_id=${exam.examId}&provider=${tag.provider}&tag_no=${tag.tagNo}",
    ),
  );
  String jso = utf8.decode(res.bodyBytes);
  Map<String, dynamic> result = json.decode(jso);
  return Report.from(exam, tag, result);
}

void updateBugReport(
  String questId,
  bool isBug,
  Map<String, dynamic> bugPoints,
) async {
  Map<String, dynamic> _payload = {"Method": "IS_BUG"};
  Map<String, dynamic> _args = {};
  _args["quest_id"] = questId;
  _args["is_bug"] = isBug;
  _args.addAll(bugPoints);
  _payload["Args"] = _args;
  String payload = JsonEncoder().convert(_payload);
  http.post(Uri.parse(baseUrl), body: payload);
}

void updateScoring(String questId, int scoring) async {
  Map<String, dynamic> _payload = {"quest_id": questId, "scoring": scoring};
  String payload = JsonEncoder().convert(_payload);
  await http.put(Uri.parse(baseApi + "question"), body: payload);
}

void updateMoreStudy(String questId, bool moreStudy) async {
  Map<String, dynamic> _payload = {
    "quest_id": questId,
    "more_study": moreStudy,
  };
  String payload = JsonEncoder().convert(_payload);
  await http.put(Uri.parse(baseApi + "question"), body: payload);
}

void updateLearningNote(String questId, String learningNote) async {
  Map<String, dynamic> _payload = {
    "quest_id": questId,
    "learning_note": learningNote,
  };
  String payload = JsonEncoder().convert(_payload);
  await http.put(Uri.parse(baseApi + "question"), body: payload);
}

void updateIsEasy(String questId, bool isEasy) async {
  Map<String, dynamic> _payload = {"quest_id": questId, "is_easy": isEasy};
  String payload = JsonEncoder().convert(_payload);
  await http.put(Uri.parse(baseApi + "question"), body: payload);
}

void updateIsDifficult(String questId, bool isDifficult) async {
  Map<String, dynamic> _payload = {
    "quest_id": questId,
    "is_difficult": isDifficult,
  };
  String payload = JsonEncoder().convert(_payload);
  await http.put(Uri.parse(baseApi + "question"), body: payload);
}

void updateIsWeak(String questId, bool isWeak) async {
  Map<String, dynamic> _payload = {"quest_id": questId, "is_weak": isWeak};
  String payload = JsonEncoder().convert(_payload);
  await http.put(Uri.parse(baseApi + "question"), body: payload);
}

void updateIsMandatory(String questId, bool isMandatory) async {
  Map<String, dynamic> _payload = {
    "quest_id": questId,
    "is_mandatory": isMandatory,
  };
  String payload = JsonEncoder().convert(_payload);
  await http.put(Uri.parse(baseApi + "question"), body: payload);
}

void updateMaturity(String questId, double maturity) async {
  Map<String, dynamic> _payload = {"quest_id": questId, "maturity": maturity};
  String payload = JsonEncoder().convert(_payload);
  await http.put(Uri.parse(baseApi + "question"), body: payload);
}

void updatePriority(String questId, double priority) async {
  Map<String, dynamic> _payload = {"quest_id": questId, "priority": priority};
  String payload = JsonEncoder().convert(_payload);
  await http.put(Uri.parse(baseApi + "question"), body: payload);
}

Future<List<Word>> getWords(String questId) async {
  http.Response res = await http.get(
    Uri.parse(baseApi + "words?quest_id=$questId"),
  );
  String jso = utf8.decode(res.bodyBytes);
  List<Map<String, dynamic>> words = List<Map<String, dynamic>>.from(
    json.decode(jso),
  );
  return Word.fromData(questId, words);
}

void hideWord(Word word) async {
  Map<String, dynamic> _payload = {"Method": "HIDE_WORD"};
  Map<String, dynamic> _args = {};
  _args["quest_id"] = word.checkOn ? "COM" : word.questId;
  _args["word"] = word.word;
  _payload["Args"] = _args;
  String payload = JsonEncoder().convert(_payload);
  await http.post(Uri.parse(baseUrl), body: payload);
}

Future<Map<String, DailyRecord>> getDailyRecords(
  String fromDate,
  String toDate,
) async {
  Map<String, dynamic> _payload = {"Method": "DAILY_RECORDS"};
  Map<String, dynamic> _args = {};
  _args["from_date"] = fromDate;
  _args["to_date"] = toDate;
  _payload["Args"] = _args;
  String payload = JsonEncoder().convert(_payload);

  http.Response res = await http.post(Uri.parse(baseUrl), body: payload);
  String jso = utf8.decode(res.bodyBytes);
  List<Map<String, dynamic>> records = List<Map<String, dynamic>>.from(
    json.decode(jso),
  );
  return DailyRecord.fromData(records);
}

void putDailyRecord(String today) async {
  Map<String, dynamic> _payload = {"Method": "PUT_DAILY_RECORD"};
  Map<String, dynamic> _args = {};
  _args["today"] = today;
  _payload["Args"] = _args;
  String payload = JsonEncoder().convert(_payload);
  await http.post(Uri.parse(baseUrl), body: payload);
}

Future<List<Question>> searchDayHistory(
  String answerDate,
  BuildContext context,
) async {
  // final UserState userState = Provider.of<UserState>(context);
  Map<String, dynamic> _payload = {"Method": "DAY_HISTORY"};
  Map<String, dynamic> _args = {};
  _args["answer_date"] = answerDate;
  _payload["Args"] = _args;
  String payload = JsonEncoder().convert(_payload);
  http.Response res = await http.post(Uri.parse(baseUrl), body: payload);
  String jso = utf8.decode(res.bodyBytes);
  List<Map<String, dynamic>> questions = List<Map<String, dynamic>>.from(
    json.decode(jso),
  );
  return Question.fromHistoryData(questions);
}

Future<List<Question>> searchAnswerHistories(String questId) async {
  Map<String, dynamic> _payload = {"Method": "ANSWER_HISTORIES"};
  Map<String, dynamic> _args = {};
  _args["quest_id"] = questId;
  _payload["Args"] = _args;
  String payload = JsonEncoder().convert(_payload);
  http.Response res = await http.post(Uri.parse(baseUrl), body: payload);
  String jso = utf8.decode(res.bodyBytes);
  List<Map<String, dynamic>> questions = List<Map<String, dynamic>>.from(
    json.decode(jso),
  );
  return Question.fromHistoryData(questions);
}

Future<List<CloudProvider>> getCloudProviders() async {
  http.Response res = await http.get(Uri.parse(baseApi + "get_providers"));
  String jso = utf8.decode(res.bodyBytes);
  List<Map<String, dynamic>> providers = List<Map<String, dynamic>>.from(
    json.decode(jso),
  );
  return CloudProvider.fromData(providers);
}

Future<List<Term>> getTerms(Tag tag) async {
  http.Response res = await http.get(
    Uri.parse(
      baseApi + "keywords?provider=${tag.provider}&tag_no=${tag.tagNo}",
    ),
  );
  String jso = utf8.decode(res.bodyBytes);
  List<Map<String, dynamic>> terms = List<Map<String, dynamic>>.from(
    json.decode(jso),
  );
  return Term.fromData(terms);
}

void updateKeywords(
  String provider,
  String tagNo,
  String tagKeywords,
  String questId,
  String questKeywords,
) {
  Map<String, dynamic> _payload = {};
  _payload["provider"] = provider;
  _payload["tag_no"] = tagNo;
  _payload["tag_keywords"] = tagKeywords;
  _payload["quest_id"] = questId;
  _payload["quest_keywords"] = questKeywords;
  String payload = JsonEncoder().convert(_payload);
  http.post(Uri.parse(baseApi + "keywords"), body: payload);
}

void launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Future<Map<String, dynamic>> updateRetention(String questId) async {
  Map<String, dynamic> _payload = {
    "Method": "calculate_total",
    "quest_id": questId,
  };
  String payload = JsonEncoder().convert(_payload);
  http.Response res = await http.put(
    Uri.parse(baseApi + "retention"),
    body: payload,
  );
  String jso = utf8.decode(res.bodyBytes);
  Map<String, dynamic> result = json.decode(jso);
  return result;
}

void updateAnswerNote(String testId, String questId, String answerNote) async {
  Map<String, dynamic> _payload = {"Method": "UPDATE_ANSWER_NOTE"};
  Map<String, dynamic> _args = {};
  _args["test_id"] = testId;
  _args["quest_id"] = questId;
  _args["answer_note"] = answerNote;
  _payload["Args"] = _args;
  String payload = JsonEncoder().convert(_payload);
  await http.post(Uri.parse(baseUrl), body: payload);
}

Future<List<KnowhowNote>> getKnowhowNotes(String examId) async {
  http.Response res = await http.get(
    Uri.parse(baseApi + "knowhow?exam_id=$examId"),
  );
  // 日本語を含むため bodyBytes を明示的に UTF-8 デコードする
  String jso = utf8.decode(res.bodyBytes);
  dynamic decoded = json.decode(jso);
  // API Gateway 統合方式により、配列が直接返る場合と
  // {statusCode, body} でラップされて返る場合の両方に対応する。
  List<dynamic> list;
  if (decoded is List) {
    list = decoded;
  } else if (decoded is Map && decoded['body'] != null) {
    dynamic body = decoded['body'];
    // body が JSON 文字列の場合はもう一段デコードする
    list = body is String ? json.decode(body) : body;
  } else {
    list = [];
  }
  return KnowhowNote.fromList(list);
}
