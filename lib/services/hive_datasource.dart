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

    int keyAsInt = int.tryParse(todo.id) ?? -1;
    if (keyAsInt != -1 && box.containsKey(keyAsInt)) {
      // Use int key
      box.put(keyAsInt, todo); // Use int key
      return true;
    }

    return false;
  }

  @override
  Future<bool> add(Map<String, dynamic> map) async {
    await init;
    Box<Todo> box = Hive.box<Todo>('todos');
    Todo t = Todo.fromMap(map);
    int key = await box.add(t);

    // Create a new Todo with the internalID set
    Todo newTodo = Todo(
      name: t.name,
      description: t.description,
      completed: t.completed,
      internalID: key.toString(),
    );

    // Now, we should replace the original todo with the newTodo in the box
    await box.put(key, newTodo);

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
