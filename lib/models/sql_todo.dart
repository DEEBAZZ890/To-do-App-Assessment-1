import 'package:todo_app_24/models/itodo.dart';

class SQLTodo implements ITodo {
  final String _id;
  @override
  String get id => _id;

  @override
  final String name;

  @override
  String description;

  @override
  bool completed;

  SQLTodo(
      {required id,
      required this.name,
      required this.description,
      this.completed = false})
      : _id = id;

  @override
  Map<String, dynamic> toMap() {
    throw UnimplementedError();
  }
}
