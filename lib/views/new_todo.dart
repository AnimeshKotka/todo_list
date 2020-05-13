import 'package:flutter/material.dart';

class NewTodoStart extends StatefulWidget {
  Function addNewTodo;
  NewTodoStart(this.addNewTodo);

  @override
  _NewTodoStartState createState() => _NewTodoStartState();
}

class _NewTodoStartState extends State<NewTodoStart> {
  final _textEditingController = TextEditingController();

  void _onSubmit() {
    _textEditingController.clear();
    String newTodo = _textEditingController.text.toString();
    if (newTodo == null) return;

    widget.addNewTodo(newTodo);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Expanded(
              child: new TextField(
            controller: _textEditingController,
            autofocus: true,
            decoration: new InputDecoration(
              labelText: 'Add new todo',
            ),
          )),
          Row(
            children: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(child: const Text('Save'), onPressed: _onSubmit)
            ],
          )
        ],
      ),
    );
  }
}
