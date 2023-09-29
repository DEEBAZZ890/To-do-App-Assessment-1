import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:todo_app_24/models/todo.dart';
import 'package:todo_app_24/services/datasource.dart';

class TodoList extends ChangeNotifier {
  List<Todo> _todos = [];

  TodoList() {
    browse();
  }

  //protected copy of the list
  UnmodifiableListView<Todo> get todos => UnmodifiableListView(_todos);

  int get todoCount => _todos.length;
  int get completedTodos {
    return _todos.where((element) => element.completed == true).length;
  }

  Future<void> browse() async {
    _todos = await GetIt.I<DataSource>().browse();
    notifyListeners();
  }

  Future<void> add(Map<String, dynamic> todoMap) async {
    GetIt.I<DataSource>().add(todoMap);
    await browse();
    notifyListeners();
  }

  void removeAll() {
    _todos.clear();
    notifyListeners();
  }

  void remove(Todo todo) {
    _todos.remove(todo);
    notifyListeners();
  }

  void update(Todo todo) {
    Todo listTodo = _todos.firstWhere((t) => t.name == todo.name);
    listTodo = todo;
    notifyListeners();
  }
}
