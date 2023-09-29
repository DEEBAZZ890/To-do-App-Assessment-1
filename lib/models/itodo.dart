abstract class ITodo {
  String get id;
  String get name;
  String get description;
  bool get completed;

  set completed(bool value);

  Map<String, dynamic> toMap();
}
