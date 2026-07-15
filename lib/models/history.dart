class History {
  final String testId;
  final String questId;
  String answerDate;
  int answeredTime;
  List<dynamic> choice;
  bool judgment;
  String testDate;
  int scoring = 0;
  String answerNote;

  History(this.testId, this.questId)
    : answerDate = '',
      answeredTime = 0,
      choice = [],
      judgment = false,
      testDate = '',
      answerNote = '';

  History.fromMap(Map<String, dynamic> data)
    : testId = data['test_id'],
      questId = data['quest_id'],
      answerDate = data['answer_date'],
      answeredTime = data['answered_time'],
      choice = data['choice'],
      judgment = data['judgment'],
      testDate = data['test_date'],
      scoring = data.containsKey('scoring') ? data['scoring'] : 0,
      answerNote = data.containsKey('answer_note') ? data['answer_note'] : "";

  static List<History> fromData(List<dynamic> data) {
    return data.map((history) => History.fromMap(history)).toList();
  }
}
