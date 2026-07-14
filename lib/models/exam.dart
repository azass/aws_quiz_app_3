import 'package:aws_quiz_app/models/tag.dart';

class Exam {
  final String examId;
  final String examName;
  String provider;
  String iconPath;
  int examCount;
  int level;
  int point;
  int div;
  List<Tag> tags;
  Exam(this.examId, this.examName, this.iconPath);

  Exam.fromMap(Map<String, dynamic> data)
      : examId = data["exam_id"],
        examName = data["exam_name"],
        provider = data["provider"],
        examCount = data["exam_count"],
        iconPath = data["icon_path"],
        level = data["level"],
        point = data["point"],
        div = data["exam_count"] ~/ 3,
        tags = data.containsKey("tags") ? Tag.fromData(data['tags']) : [];

  static List<Exam> fromData(List<dynamic> data) {
    return data.map((exam) => Exam.fromMap(exam)).toList();
  }

  double progressRate() {
    int mod1 = point % examCount;
    int mod2 = mod1 % div;
    double rate = mod2 / div;
    return rate;
  }

  int remaining() {
    int mod1 = point % examCount;
    int mod2 = mod1 % div;
    return div - mod2;
  }
}

final List<Exam> _exams = [
  Exam("SAP-C01", "Solusions Architect Professional",
      'images/architect_professional.png'),
  Exam("DOP-C01", "DevOps Engineer Professional",
      'images/devops_professional.png'),
  Exam("SCS-C01", "Security Specialty", 'images/security_specialty.png'),
  Exam("ANS-C00", "Advanced Networking Specialty",
      'images/network_specialty.png'),
  Exam("SAA-C02", "Solusions Architect Associate",
      'images/architect_associate.png'),
  Exam("DAV-C01", "Developer Associate", 'images/developer_associate.png'),
  Exam("SOA-C01", "SysOps Administrator Associate",
      'images/sysops_associate.png'),
  Exam("DBS-C01", "Database Specialty", 'images/database_specialty.png'),
  Exam("DAS-C01", "Data Analytics Specialty", 'images/analytics_specialty.png'),
  Exam("MLS-C01", "Machine Learning Specialty", 'images/ml_specialty.png'),
  Exam("CLF-C01", "Cloud Practitioner", 'images/practitioner.png'),
  Exam("AZ-104", "Azure Administrator Associate", 'images/az104.png'),
];
