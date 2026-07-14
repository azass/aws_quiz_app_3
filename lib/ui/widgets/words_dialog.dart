import 'package:aws_quiz_app/models/word.dart';
import 'package:aws_quiz_app/resources/api_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'keyword_dialog.dart';

class WordsDialog extends StatefulWidget {
  final List<Word> words;
  String selectedWord = "";
  int selectedLevel = 1;
  bool selected = false;
  WordsDialog(this.words);

  @override
  _WordsDialogState createState() => _WordsDialogState();
}

class _WordsDialogState extends State<WordsDialog> {
  final _formKey = GlobalKey<FormState>();
  final myController = TextEditingController();
  bool _isUpdate = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: <Widget>[
          SizedBox(height: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: [
                  // Align(
                  //     alignment: Alignment.centerLeft,
                  //     child: IconButton(
                  //       icon: Icon(Icons.power_settings_new),
                  //       color: widget.selected ? Colors.pink : Colors.grey,
                  //       iconSize: 36.0,
                  //       onPressed: () {
                  //         setState(() => widget.selected = !widget.selected);
                  //       },
                  //     )),
                  Row(children: [
                    // Align(
                    //     alignment: Alignment.center,
                    Expanded(
                        child: Container(
                            height: 40.0,
                            width: 50.0,
                            padding: const EdgeInsets.all(5.0),
                            child: CupertinoPicker(
                              backgroundColor: Colors.white,
                              itemExtent: 50,
                              scrollController:
                                  FixedExtentScrollController(initialItem: 0),
                              children: buildPickerOptions(),
                              onSelectedItemChanged: (value) {
                                setState(() {
                                  widget.selectedLevel = value + 1;
                                });
                              },
                            ))),
                    // Align(
                    //     alignment: Alignment.centerRight,
                    IconButton(
                      icon: Icon(Icons.integration_instructions_outlined),
                      color: _isUpdate ? Colors.pink : Colors.grey,
                      iconSize: 30.0,
                      onPressed: () {
                        if (_isUpdate) {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                          }
                        }
                        Navigator.pop(context, true);
                      },
                    ),
                  ])
                ],
              ),
              Divider(color: Colors.black),
              Form(
                  key: _formKey,
                  child: Container(
                      padding: const EdgeInsets.all(5.0),
                      width: 380,
                      child: TextFormField(
                        controller: myController,
                        decoration: InputDecoration(
                          labelText: 'SELECTED WORD',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.pink,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Pease Enter some text.";
                          } else {
                            return null;
                          }
                        },
                        onChanged: (value) {
                          setState(() {
                            _isUpdate = (value.length > 0);
                          });
                        },
                        onSaved: (value) => widget.selectedWord = value,
                      ))),
              SizedBox(height: 15),
            ],
          ),
          Expanded(
            child: ListView.builder(
                itemCount: widget.words.length,
                itemBuilder: (BuildContext context, int index) {
                  final word = widget.words[index];
                  return Dismissible(
                    key: Key(word.word),
                    onDismissed: (direction) {
                      setState(() {
                        hideWord(word);
                        widget.words.removeAt(index);
                      });
                    },
                    background: Container(color: Colors.red),
                    child: ListTile(
                      title: Text(word.word),
                      tileColor:
                          word.checkOn ? Colors.yellow[100] : Colors.white,
                      onTap: () {
                        setState(() {
                          widget.selectedWord = word.word;
                          myController.text = word.word;
                          _isUpdate = true;
                        });
                      },
                      onLongPress: () {
                        setState(() {
                          word.checkOn = !word.checkOn;
                        });
                      },
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
