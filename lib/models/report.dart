import 'package:aws_quiz_app/models/exam.dart';
import 'package:aws_quiz_app/models/scoring.dart';
import 'package:aws_quiz_app/models/tag.dart';

class Report {
  final Exam exam;
  Tag tag;
  Scoring scoring;
  List<ScoringTableItem> scoringTableItems;

  Report.fromMap(Map<String, dynamic> data)
      : exam = Exam.fromMap(data),
        scoring = Scoring.fromMap(data),
        scoringTableItems = data['items']
            .map<ScoringTableItem>((item) => ScoringTableItem.fromReport(item))
            .toList();

  Report.from(this.exam, this.tag, Map<String, dynamic> data)
      : scoringTableItems = data['items']
            .map<ScoringTableItem>(
                (item) => ScoringTableItem.fromTagReport(item))
            .toList(),
        scoring = Scoring.fromMap(data);

  static List<ScoringTableItem> toScoringTableItems(List<dynamic> items) {
    List<ScoringTableItem> scoringTableItems = [];
    items.forEach((item) {
      scoringTableItems.add(ScoringTableItem.fromReport(item));
    });
    return scoringTableItems;
  }
}

class ReportItem {
  final Tag tag;
  final int questionCount;
  final double correctAnswerRate;
  final double completionRate;
  final double avgRetention;

  ReportItem.fromMap(Map<String, dynamic> data)
      : tag = Tag.fromMap(data),
        questionCount = data['question_count'],
        correctAnswerRate = data['execute_count'] == 0
            ? 0.0
            : (data['correct_count'] > data['execute_count'])
                ? 1.0
                : data['correct_count'] / data['execute_count'],
        completionRate = (data['complete_count'] > data['total_count'])
            ? 1.0
            : data['complete_count'] / data['total_count'],
        avgRetention = data['tag_avg_retention'].toDouble();

  String toRatePercentage(double rate) {
    int percatege = (rate * 100.0).round();
    return percatege.toString() + "%";
  }
}

final Map<int, String> hashiraImagePaths = {
  0: "images/none.png",
  1: "images/oto.png",
  2: "images/musi.png",
  3: "images/mizu.png",
  4: "images/en.png",
  5: "images/koi.png",
  6: "images/hebi.png",
  7: "images/kasumi.png",
  8: "images/kaze.png",
  9: "images/iwa.png"
};

final Map<int, String> levelImagePaths = {
  0: "images/none.png",
  1: "images/oto_s.png",
  2: "images/musi_s.png",
  3: "images/mizu_s.png",
  4: "images/en_s.png",
  5: "images/koi_s.png",
  6: "images/hebi_s.png",
  7: "images/kasumi_s.png",
  8: "images/kaze_s.png",
  9: "images/iwa_s.png"
};

final Map<int, String> levelupImagePaths = {
  0: "images/none.png",
  1: "images/oto_m.png",
  2: "images/musi_m.png",
  3: "images/mizu_m.png",
  4: "images/en_m.png",
  5: "images/koi_m.png",
  6: "images/hebi_m.png",
  7: "images/kasumi_m.png",
  8: "images/kaze_m.png",
  9: "images/iwa_m.png"
};
