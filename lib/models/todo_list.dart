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
    await GetIt.I<DataSource>().add(todoMap);
    todoMap['internalID'] = todoMap['id'];
    await browse();
    notifyListeners();
  }

  Future<void> removeAll() async {
    for (var todo in _todos) {
      await GetIt.I<DataSource>().delete(todo);
    }
    await browse();
    notifyListeners();
  }

  Future<void> remove(Todo todo) async {
    await GetIt.I<DataSource>().delete(todo);
    await browse();
    notifyListeners();
  }

  Future<void> update(Todo updatedTodo) async {
    int index =
        _todos.indexWhere((todo) => todo.internalID == updatedTodo.internalID);
    if (index != -1) {
      _todos[index] = updatedTodo;
      await GetIt.I<DataSource>().edit(updatedTodo);
      notifyListeners();
    }
  }
}
