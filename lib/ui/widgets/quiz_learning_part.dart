import 'package:aws_quiz_app/models/question.dart';
import 'package:aws_quiz_app/resources/api_provider.dart';
import 'package:flutter/material.dart';

import '../util.dart';

class QuizLearningPart extends StatefulWidget {
  final Question question;

  const QuizLearningPart({
    super.key,
    required this.question,
  });

  @override
  State<QuizLearningPart> createState() => _QuizLearningPartState();
}

class _QuizLearningPartState extends State<QuizLearningPart> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              _buildPrioritySlider(),
              _buildLabel(
                priority[widget.question.priority.toInt()],
                Colors.indigo,
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.centerRight,
          child: _buildLearningLabel(),
        ),
      ],
    );
  }

  Widget _buildLearningLabel() {
    return Row(
      children: [
        if (widget.question.isEasy) _buildLabel("簡単", Colors.lightBlueAccent),
        if (widget.question.isDifficult)
          _buildLabel("難問", Colors.orangeAccent),
        if (widget.question.isWeak) _buildLabel("弱点", Colors.pinkAccent),
      ],
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0),
      child: Chip(
        label: Transform.translate(
          offset: const Offset(0, -1.4),
          child: Text(text),
        ),
        labelStyle: const TextStyle(
          fontSize: 10.0,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: color,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(horizontal: 0.0, vertical: -4),
      ),
    );
  }

  Widget _buildPrioritySlider() {
    return Container(
      width: 150.0,
      padding: const EdgeInsets.only(top: 2.0),
      child: SliderTheme(
        data: const SliderThemeData(
          activeTrackColor: Colors.green,
          showValueIndicator: ShowValueIndicator.never,
          minThumbSeparation: 0,
        ),
        child: Slider(
          value: widget.question.priority,
          min: 0,
          max: 3,
          divisions: 3,
          onChanged: (double value) {
            updatePriority(widget.question.questId, value);
            setState(() => widget.question.priority = value.roundToDouble());
          },
        ),
      ),
    );
  }
}
