class Word {
  final String questId;
  final String word;
  final int count;
  bool checkOn = false;

  Word.fromMap(String questId, Map<String, dynamic> data)
    : questId = questId,
      word = data["word"],
      count = data["count"],
      checkOn = data["check_on"];

  static List<Word> fromData(String questId, List<Map<String, dynamic>> data) {
    return data.map((word) => Word.fromMap(questId, word)).toList();
  }
}
