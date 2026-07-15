import 'package:aws_quiz_app/models/exam.dart';

class CloudProvider {
  final String name;
  final String displayName;
  List<Exam> exams;
  // List<Tag> tags;

  CloudProvider(this.name, this.displayName, this.exams);

  CloudProvider.fromMap(Map<String, dynamic> data)
    : name = data['name'],
      displayName = data['display_name'],
      exams = Exam.fromData(data['exams']);

  static List<CloudProvider> fromData(List<Map<String, dynamic>> data) {
    return data.map((question) => CloudProvider.fromMap(question)).toList();
  }
}
