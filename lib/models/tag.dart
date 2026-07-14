import 'package:aws_quiz_app/models/term.dart';

class Tag {
  final int tagNo;
  final String tagName;
  final String provider;
  List<Term> terms;
  int questionCount;

  Tag(this.tagNo, this.tagName, this.provider);

  Tag.fromMap(Map<String, dynamic> data)
      : tagNo = data["tag_no"],
        tagName = data["tag_name"],
        provider = data["provider"],
        questionCount =
            data.containsKey("question_count") ? data["question_count"] : 0;

  static List<Tag> fromData(List<dynamic> data) {
    return data.map((question) => Tag.fromMap(question)).toList();
  }
}
