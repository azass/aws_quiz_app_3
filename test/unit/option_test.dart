import 'package:aws_quiz_app/models/option.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> data = {"text": "A.\n test"};
  print(data);
  String _text = Option.getTextFrom(data);
  print(_text);
  test('getTextFromのテスト', () {
    expect(_text, "test");
  });
}