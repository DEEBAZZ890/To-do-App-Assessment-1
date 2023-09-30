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
  Future<bool> add(Map<String, dynamic> map) async {
    await init;
    Box<Todo> box = Hive.box<Todo>('todos');
    Todo t = Todo.fromMap(map);
    await box.add(t);
    return true;
  }

  @override
  Future<List<Todo>> browse() async {
    await init;
    Box<Todo> box = Hive.box<Todo>('todos');
    return box.values.toList();
  }

  @override
  Future<bool> delete(Todo todo) async {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<bool> edit(Todo todo) async {
    // TODO: implement read
    throw UnimplementedError();
  }

  @override
  Future<Todo> read(String id) async {
    // TODO: implement read
    throw UnimplementedError();
  }
}
