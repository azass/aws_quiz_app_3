import 'package:flutter/material.dart';

// ignore: must_be_immutable
class QuizChip extends StatelessWidget {
  final String label;
  var value;
  final Function _isOn;
  final Function _f;

  QuizChip(this.label, this.value, this._isOn, this._f);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      labelStyle: TextStyle(color: Colors.white),
      backgroundColor: _bgColor(_isOn(value)),
      onPressed: () => _f(value),
    );
  }

  Color _bgColor(bool isSelected) {
    return isSelected ? Colors.indigo : Colors.grey.shade600;
  }
}
