import 'package:uuid/uuid.dart';

class Term {
  String termId;
  String word;
  int level;
  int sort;
  List<dynamic> description;
  String explain = "";
  bool selected = false;
  String changed = "";
  Term({
    required this.termId,
    required this.word,
    required this.level,
    this.sort = 0,
    this.description = const [],
    this.explain = '',
    this.selected = false,
    this.changed = '',
  });

  Term.fromMap(Map<String, dynamic> data)
    : termId = data['term_id'],
      word = data['word'],
      level = data['level'],
      sort = data['sort'],
      description = data['description'],
      explain = data['explain'];

  static newTermId() {
    return "trm-" + Uuid().v4().substring(0, 6);
  }

  static List<Term> fromData(List<Map<String, dynamic>> data) {
    return data
        .map(
          (keyword) => Term(
            termId: keyword['term_id'],
            word: keyword['word'],
            level: keyword['level'],
            sort: keyword['sort'],
            description: keyword['description'],
            explain: keyword['explain'],
          ),
        )
        .toList();
  }
}
