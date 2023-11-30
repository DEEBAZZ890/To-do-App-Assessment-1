import 'package:hive_flutter/hive_flutter.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  final String? internalID;
  String get id {
    if (key != null) return key.toString();
    return internalID ?? "Not Provided";
  }

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  bool completed;

  Todo({
    required this.name,
    required this.description,
    this.internalID = "",
    this.completed = false,
  });

  @override
  String toString() {
    return "$name - ($description)";
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'completed': completed ? 1 : 0,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> mapData) {
    bool completed;
    if (mapData['completed'] is int) {
      completed = mapData['completed'] != 0;
    } else {
      completed = mapData['completed'] ?? false;
    }

    Todo todo = Todo(
      name: mapData['name'],
      description: mapData['description'],
      completed: completed,
      internalID: mapData['id'],
    );
    return todo;
  }
}

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  Todo read(BinaryReader reader) {
    Map<String, dynamic> map = {
      'id': reader.read(),
      'name': reader.read(),
      'description': reader.read(),
      'completed': reader.read(),
    };
    return Todo.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.description);
    writer.write(obj.completed);
  }

  @override
  int get typeId => 0;
}
