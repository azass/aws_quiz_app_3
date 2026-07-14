import 'package:aws_quiz_app/models/question.dart';
import 'package:aws_quiz_app/ui/util.dart';
import 'package:flutter/material.dart';

class Option {
  String code;
  final String type;
  final String text;
  String imagePath;
  double imageHeight;
  List<SelectOption> selectOptions = [];
  String correctValue;
  bool isCorrect = false;
  bool isSelected = false;
  Color bgColor = CARD_COLOR;

  Option(this.code, this.type, this.text, this.imagePath, this.imageHeight,
      this.isCorrect) {
    if (isCorrect) {
      bgColor = Colors.lightBlueAccent[100];
    }
  }

  Option.fromSelectOptions(int index, Map<String, dynamic> data)
      : type = data["type"],
        // code = data["correctValue"],
        text = data["text"],
        selectOptions = SelectOption.fromSelectOptions(
            index, data["selectOptions"], data["correctValue"]),
        correctValue = data["correctValue"];

  static Option fromMap(
      int index, Map<String, dynamic> data, List<dynamic> correctAnswer) {
    if (data["type"] == "select") {
      return Option.fromSelectOptions(index, data);
    } else {
      String _code = (data.containsKey("text") && data["text"].length > 0)
          ? data["text"].substring(0, 1)
          : "";
      return Option(
          _code,
          "option",
          getTextFrom(data),
          (data.containsKey("image_path")) ? data['image_path'] : "",
          (data.containsKey("image_height"))
              ? double.parse(data["image_height"])
              : 0.0,
          correctAnswer.contains(_code));
    }
  }

  static String getTextFrom(Map<String, dynamic> data) {
    if (data.containsKey("text") && data["text"].length > 2) {
      String _text = data["text"].substring(2);
      return _text.trimLeft();
    } else {
      return "";
    }
  }

  String selectValue() {
    String selectValue = "";
    selectOptions.forEach((option) {
      if (option.isSelected) {
        selectValue = option.value;
        return;
      }
    });
    return selectValue;
  }

  void onAnswer(Question question) {
    if (question.choice.contains(this.code)) {
      isSelected = true;
    } else {
      isSelected = false;
    }
    if (!isCorrect) {
      if (isSelected) {
        bgColor = Colors.pinkAccent[100];
      } else {
        bgColor = CARD_COLOR;
      }
    }
  }
}

class SelectOption {
  final int index;
  final String label;
  final String value;
  bool isCorrect;
  bool isSelected = false;
  Color bgColor = CARD_COLOR;

  SelectOption(this.index, this.label, this.value, this.isCorrect) {
    if (isCorrect) {
      bgColor = Colors.lightBlueAccent[100];
    }
  }
  static List<SelectOption> fromSelectOptions(
      int index, List<dynamic> data, String correctValue) {
    return data
        .map((option) => SelectOption(index, option["label"], option["value"],
            option["value"] == correctValue))
        .toList();
  }

  void onAnswer(Question question) {
    if (question.choice[index] == value) {
      isSelected = true;
    } else {
      isSelected = false;
    }
    if (!isCorrect) {
      if (isSelected) {
        bgColor = Colors.pinkAccent[100];
      } else {
        bgColor = CARD_COLOR;
      }
    }
  }
}
