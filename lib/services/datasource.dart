import 'package:todo_app_24/models/todo.dart';

//Interface for all datasource
abstract class DataSource {
  Future<List<Todo>> browse();
  Future<Todo> read(String id);
  Future<bool> edit(Todo todo);
  Future<bool> add(Map<String, dynamic> map);
  Future<bool> delete(Todo todo);
}
