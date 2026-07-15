import 'package:aws_quiz_app/models/menu_icon.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MenuFabs extends StatefulWidget {
  final List<MenuIcon> icons;
  final Color color;
  final Icon icon;
  ValueChanged<int> onIconTapped;

  MenuFabs({
    required this.icons,
    required this.color,
    required this.icon,
    required this.onIconTapped,
  });

  @override
  State createState() => MenuFabsState();
}

class MenuFabsState extends State<MenuFabs> with TickerProviderStateMixin {
  AnimationController? _controllerValue;

  AnimationController get _controller {
    final value = _controllerValue;
    if (value == null) {
      throw StateError('Animation controller has not been initialized.');
    }
    return value;
  }

  @override
  void initState() {
    super.initState();
    _controllerValue = AnimationController(
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
      }).toList()..add(_buildFabMenu()),
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
          curve: Interval(
            0.0,
            1.0 - index / widget.icons.length / 2.0,
            curve: Curves.easeOut,
          ),
        ),
        child: FloatingActionButton(
          backgroundColor: backgroundColor,
          mini: true,
          heroTag: "hero$index",
          child: Icon(
            widget.icons[index].icon,
            color: Colors.indigo,
          ),
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
        shape: const CircleBorder(),
        mini: true,
        heroTag: "heroFabMenu",
        child: Icon(
          widget.icon.icon,
          color: Colors.white,
          size: widget.icon.size,
          semanticLabel: widget.icon.semanticLabel,
          textDirection: widget.icon.textDirection,
        ),
        elevation: 2.0,
        backgroundColor: widget.color,
      ),
    );
  }

  void _onTapped(int index) {
    _controller.reverse();
    widget.onIconTapped(index);
  }
}
