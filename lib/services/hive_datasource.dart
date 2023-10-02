import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app_24/models/todo.dart';
import 'package:todo_app_24/services/datasource.dart';

class HiveDatasource implements DataSource {
  late Future init;

  HiveDatasource() {
    init = initalise();
  }

  Future<void> initalise() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TodoAdapter());
    await Hive.openBox<Todo>('todos');
    //Used to delete the hive box from disk
    //Hive.deleteBoxFromDisk('todos');
  }

  @override
  Future<List<Todo>> browse() async {
    await init;
    Box<Todo> box = Hive.box<Todo>('todos');
    return box.values.toList();
  }

  @override
  Future<Todo> read(String id) async {
    await init;
    Box<Todo> box = Hive.box<Todo>('todos');
    Todo? todo = box.get(id);

    if (todo != null) {
      return todo;
    }
    throw Exception('Todo not found');
  }

  @override
  Future<bool> edit(Todo todo) async {
    await init;
    Box<Todo> box = Hive.box<Todo>('todos');

    if (box.containsKey(todo.key)) {
      box.put(todo.key, todo);
      return true;
    }

    return false;
  }

  @override
  Future<bool> add(Map<String, dynamic> map) async {
    await init;
    Box<Todo> box = Hive.box<Todo>('todos');
    Todo t = Todo.fromMap(map);
    await box.add(t);
    return true;
  }

  @override
  Future<bool> delete(Todo todo) async {
    await init;
    Box<Todo> box = Hive.box<Todo>('todos');
    if (box.containsKey(todo.key)) {
      box.delete(todo.key);
      return true;
    }
    return false;
  }
}
