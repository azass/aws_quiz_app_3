import 'package:aws_quiz_app/models/term.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'keyword_dialog.dart';

class KeywordEditor extends StatefulWidget {
  final int index;
  final KeywordDialogState keywordDialogState;
  KeywordEditor(this.index, this.keywordDialogState);

  @override
  State<StatefulWidget> createState() =>
      _KeywordEditorState(keywordDialogState.getKeyword(index));
}

class _KeywordEditorState extends State<KeywordEditor> {
  _KeywordEditorState(this._keyword)
    : _inputText = _keyword.word,
      _inputLevel = _keyword.level;

  bool _isUpdate = false;
  Term _keyword;
  String _inputText;
  int _inputLevel;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomLeft,
                child: IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.pink,
                  iconSize: 36.0,
                  onPressed: _delete,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: Icon(Icons.integration_instructions),
                  color: _isUpdate ? Colors.pink : Colors.grey,
                  iconSize: 36.0,
                  onPressed: _update,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.0),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          child: Row(
            children: [
              Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(0.0),
                  width: 370,
                  child: TextFormField(
                    initialValue: _keyword.word,
                    decoration: InputDecoration(
                      labelText: 'KEYWORD',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Pease Enter some text.";
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) => _notify(),
                    onSaved: (value) => _inputText = value ?? '',
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(5.0),
                  child: CupertinoPicker(
                    backgroundColor: Colors.white,
                    itemExtent: 50,
                    scrollController: FixedExtentScrollController(
                      initialItem: _keyword.level - 1,
                    ),
                    children: buildPickerOptions(),
                    onSelectedItemChanged: (value) {
                      setState(() {
                        _inputLevel = value + 1;
                        _notify();
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _notify() {
    setState(() {
      final formState = _formKey.currentState;
      if (formState != null && formState.validate()) {
        formState.save();
      } else {
        _isUpdate = false;
      }
      if (_inputText != _keyword.word || _inputLevel != _keyword.level) {
        _isUpdate = true;
      } else {
        _isUpdate = false;
      }
    });
  }

  void _update() {
    if (_isUpdate) {
      final formState = _formKey.currentState;
      if (formState != null && formState.validate()) {
        formState.save();
        _keyword.word = _inputText;
        _keyword.level = _inputLevel;
        _keyword.changed = "update";
        widget.keywordDialogState.notifyTagKeywords();
        widget.keywordDialogState.notifyQuestKeywords();
        Navigator.of(context).pop();
      }
    }
  }

  void _delete() {
    Widget cancelButton = TextButton(
      child: Text("キャンセル"),
      onPressed: () => Navigator.of(context).pop(),
    );
    Widget continueButton = TextButton(
      child: Text("削除"),
      onPressed: () {
        widget.keywordDialogState.removeKeyword(widget.index);
        Navigator.of(context).pop();
        widget.keywordDialogState.setState(() {
          widget.keywordDialogState.notifyTagKeywords();
          Navigator.of(context).pop();
        });
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("キーワード削除"),
      content: Text("キーワードを削除しますか？"),
      actions: [cancelButton, continueButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
