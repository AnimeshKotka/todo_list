import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import './firebasea/auth.dart';
import './firebasea/auth_provider.dart';
import './models/todo.dart';
import './views/new_todo.dart';

class HomePage extends StatefulWidget {
  const HomePage({this.userId, this.onSignedOut});
  final VoidCallback onSignedOut;
  final userId;

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> _todoList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  Query _todoQuery;

  @override
  void initState() {
    super.initState();

    //_checkEmailVerification();

    _todoList = new List();
    _todoQuery = _database
        .reference()
        .child("todo")
        .orderByChild("userId")
        .equalTo(widget.userId);
    _onTodoAddedSubscription = _todoQuery.onChildAdded.listen(onEntryAdded);
    _onTodoChangedSubscription =
        _todoQuery.onChildChanged.listen(onEntryChanged);
  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
  }

  onEntryChanged(Event event) {
    var oldEntry = _todoList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _todoList[_todoList.indexOf(oldEntry)] =
          Todo.fromSnapshot(event.snapshot);
    });
  }

  onEntryAdded(Event event) {
    setState(() {
      _todoList.add(Todo.fromSnapshot(event.snapshot));
    });
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final BaseAuth auth = AuthProvider.of(context).auth;
      await auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  addNewTodo(String todoItem) {
    if (todoItem.length > 0) {
      Todo todo = new Todo(todoItem.toString(), widget.userId, false);
      _database.reference().child("todo").push().set(todo.toJson());
    }
  }

  updateTodo(Todo todo) {
    //Toggle completed
    todo.completed = !todo.completed;
    if (todo != null) {
      _database.reference().child("todo").child(todo.key).set(todo.toJson());
    }
  }

  deleteTodo(String todoId, int index) {
    _database.reference().child("todo").child(todoId).remove().then((_) {
      print("Delete $todoId successful");
      setState(() {
        _todoList.removeAt(index);
      });
    });
  }

  showAddTodoDialog(BuildContext context) async {
    _textEditingController.clear();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Row(
              children: <Widget>[
                new Expanded(
                    child: new TextField(
                  controller: _textEditingController,
                  autofocus: true,
                  decoration: new InputDecoration(
                    labelText: 'Add new todo',
                  ),
                ))
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Save'),
                  onPressed: () {
                    addNewTodo(_textEditingController.text.toString());
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  Widget showTodoList() {
    if (_todoList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _todoList.length,
          itemBuilder: (BuildContext context, int index) {
            String todoId = _todoList[index].key;
            String subject = _todoList[index].subject;
            bool completed = _todoList[index].completed;
            String userId = _todoList[index].userId;
            return userId != null
                ? Dismissible(
                    key: Key(todoId),
                    background: Container(color: Colors.red),
                    onDismissed: (direction) async {
                      deleteTodo(todoId, index);
                    },
                    child: ListTile(
                      title: Text(
                        subject,
                        style: TextStyle(fontSize: 20.0),
                      ),
                      leading: Checkbox(
                        value: completed,
                        onChanged: (_) => updateTodo(_todoList[index]),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: ()=> deleteTodo(todoId, index),
                      ),
                      // trailing: IconButton(
                      //     icon: (completed)
                      //         ? Icon(
                      //             Icons.done_outline,
                      //             color: Colors.green,
                      //             size: 20.0,
                      //           )
                      //         : Icon(Icons.done, color: Colors.grey, size: 20.0),
                      //     onPressed: () {
                      //       updateTodo(_todoList[index]);
                      //     }),
                    ),
                  )
                : _signOut(context); //Todo
          });
    } else {
      return Center(
          child: Text(
        "Welcome! ${widget.userId}.\nYour list is empty",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),
      ));
    }
  }

  void _showAddTodoVM(BuildContext cxt) {
    showBottomSheet(
        context: cxt,
        builder: (_) {
          return GestureDetector(
            child: NewTodoStart(addNewTodo),
            onTap: () {},
            behavior: HitTestBehavior.opaque,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Welcome'),
          actions: <Widget>[
            FlatButton(
              child: Text('Logout',
                  style: TextStyle(fontSize: 17.0, color: Colors.white)),
              onPressed: () => _signOut(context),
            )
          ],
        ),
        body: showTodoList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showAddTodoDialog(context);
            //  _showAddTodoVM(context);
          },
          tooltip: 'Add Todos',
          child: Icon(Icons.add),
        ));
  }
}
