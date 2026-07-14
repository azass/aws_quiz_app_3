import 'package:aws_quiz_app/models/menu_icon.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MenuFabs extends StatefulWidget {
  final List<MenuIcon> icons;
  final Color color;
  final Icon icon;
  ValueChanged<int> onIconTapped;

  MenuFabs({this.icons, this.color, this.icon, this.onIconTapped});

  @override
  State createState() => MenuFabsState();
}

class MenuFabsState extends State<MenuFabs> with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.icons.length, (int index) {
        return _buildChild(index);
      }).toList()
        ..add(
          _buildFabMenu(),
        ),
    );
  }

  Widget _buildChild(int index) {
    Color backgroundColor = Theme.of(context).cardColor;
    return Container(
      height: 56.0,
      width: 56.0,
      alignment: FractionalOffset.topCenter,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _controller,
          curve: Interval(0.0, 1.0 - index / widget.icons.length / 2.0,
              curve: Curves.easeOut),
        ),
        child: FloatingActionButton(
          backgroundColor: backgroundColor,
          mini: true,
          heroTag: "hero$index",
          child:
              Icon(widget.icons[index].icon, color: widget.icons[index].color),
          onPressed: () => _onTapped(index),
        ),
      ),
    );
  }

  Widget _buildFabMenu() {
    return Container(
        height: 50.0,
        width: 50.0,
        alignment: FractionalOffset.topCenter,
        child: FloatingActionButton(
          onPressed: () {
            if (_controller.isDismissed) {
              _controller.forward();
            } else {
              _controller.reverse();
            }
          },
          mini: true,
          heroTag: "heroFabMenu",
          child: widget.icon,
          elevation: 2.0,
          backgroundColor: widget.color,
        ));
  }

  void _onTapped(int index) {
    _controller.reverse();
    widget.onIconTapped(index);
  }
}
