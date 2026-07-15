import 'package:flutter/material.dart';

// ignore: must_be_immutable
class QuizChip extends StatelessWidget {
  final String label;
  var value;
  final Function _isOn;
  final Function _f;
  final double? fontSize;

  QuizChip(this.label, this.value, this._isOn, this._f, {this.fontSize});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Transform.translate(
        offset: const Offset(0, -1.0),
        child: Text(label),
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 2.0),
      labelStyle: TextStyle(color: Colors.white, fontSize: fontSize),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: const StadiumBorder(),
      backgroundColor: _bgColor(_isOn(value)),
      onPressed: () => _f(value),
    );
  }

  Color _bgColor(bool isSelected) {
    return isSelected ? Colors.indigo : Colors.grey.shade600;
  }
}
