import 'package:firebase_database/firebase_database.dart';
import 'package:todo_app_24/firebase_options.dart';
import 'package:todo_app_24/models/todo.dart';
import 'package:todo_app_24/services/datasource.dart';
import 'package:firebase_core/firebase_core.dart';

class ApiDatasource implements DataSource {
  late FirebaseDatabase database;
  late Future init;

  ApiDatasource() {
    init = initialise();
  }

  Future<void> initialise() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    database = FirebaseDatabase.instance;
  }

  @override
  Future<List<Todo>> browse() async {
    await init;
    DataSnapshot snapshot = await database.ref().child('todos').get();
    List<Todo> todos = <Todo>[];
    if (snapshot.exists) {
      Map<dynamic, dynamic> snapshotValue = snapshot.value as Map;
      if (snapshotValue.isNotEmpty) {
        snapshotValue.forEach((key, value) {
          value['id'] = key;
          todos.add(Todo.fromMap(Map<String, dynamic>.from(value)));
        });
      }
    }
    return todos;
  }

  @override
  Future<Todo> read(String id) async {
    await init;
    DataSnapshot snapshot = await database.ref().child('todos').child(id).get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> snapshotValue = snapshot.value as Map;
      snapshotValue['id'] = id;
      return Todo.fromMap(Map<String, dynamic>.from(snapshotValue));
    } else {
      throw Exception("An error occurred - Todo not found!");
    }
  }

  @override
  Future<bool> add(Map<String, dynamic> map) async {
    map['completed'] = false;
    var ref = database.ref('todos').push();
    map['id'] = ref.key;
    await ref.set(map);
    return true;
  }

  @override
  Future<bool> edit(Todo todo) async {
    await init;
    await database.ref().child('todos').child(todo.id).update(todo.toMap());
    return true;
  }

  @override
  Future<bool> delete(Todo todo) async {
    await init;
    await database.ref().child('todos').child(todo.id).remove();
    return true;
  }
}
