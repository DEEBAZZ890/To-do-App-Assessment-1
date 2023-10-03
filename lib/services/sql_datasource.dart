import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app_24/models/todo.dart';
import 'package:todo_app_24/services/datasource.dart';

class SQLDatasource implements DataSource {
  late Database database;
  late Future init;

  SQLDatasource() {
    init = initialise();
  }

  Future initialise() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'todo_data.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE IF NOT EXISTS todos (id INTEGER PRIMARY KEY, name TEXT, description TEXT, completed INTEGER)');
      },
    );
  }

  @override
  Future<bool> add(Map<String, dynamic> map) async {
    await init;
    map.remove('id');
    await database.insert('todos', map,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return true;
  }

  @override
  Future<List<Todo>> browse() async {
    await init; //wait for init completion before attempting to fetch data.

    List<Map<String, dynamic>> maps = await database.query('todos');
    return List.generate(
      maps.length,
      (index) => Todo.fromMap({
        'internalID': maps[index]['id'].toString(),
        'name': maps[index]['name'],
        'description': maps[index]['description'],
        'completed': maps[index]['completed'] == 1 ? true : false,
      }),
    );
  }

  @override
  Future<bool> delete(Todo todo) async {
    await init;
    await database.delete('todos', where: 'id = ?', whereArgs: [todo.id]);
    return true;
  }

  @override
  Future<bool> edit(Todo todo) async {
    print("SQL - Attempting to update Todo: ${todo.name}, ${todo.description}");

    await init;
    final db = await database;

    // Debugging print statements
    print("SQL - ID of Todo being updated: ${todo.id}");
    Map<String, dynamic> map = todo.toMap();
    print("SQL - Map for updating: $map");

    var existingTodo =
        await db.query('todos', where: 'id = ?', whereArgs: [todo.id]);
    print("SQL - Todo with the given ID in the database: $existingTodo");

    // Actual update logic
    int result =
        await db.update('todos', map, where: 'id = ?', whereArgs: [todo.id]);

    if (result > 0) {
      print(
          "SQL - Successfully updated Todo: ${todo.name}, ${todo.description}");
      return true;
    } else {
      print("SQL - Failed to update Todo: ${todo.name}");
      return false;
    }
  }

  // Uncomment this if the below read function doesnt work:
  @override
  Future<Todo> read(String id) async {
    await init;
    List<Map<String, dynamic>> maps = await database.query('todos');
    await database.query('todos', where: 'id = ?', whereArgs: [id]);
    return Todo(name: 'name', description: 'description');
  }
}
