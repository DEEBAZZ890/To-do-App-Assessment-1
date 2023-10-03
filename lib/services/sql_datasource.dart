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
    int id = await database.insert('todos', map);
    map['internalID'] = id.toString(); // Set the returned ID
    return true;
  }

  @override
  Future<List<Todo>> browse() async {
    await init;
    List<Map<String, dynamic>> maps = await database.query('todos');
    return List.generate(
      maps.length,
      (index) => Todo(
        internalID: maps[index]['id'].toString(),
        name: maps[index]['name'],
        description: maps[index]['description'],
        completed: maps[index]['completed'] == 1 ? true : false,
      ),
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
    await init;
    int id =
        todo.internalID != null ? int.tryParse(todo.internalID!) ?? -1 : -1;

    if (id == -1) {
      print('SQL - Invalid ID provided.');
      return false;
    }

    int updatedRows = await database.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return updatedRows > 0;
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
