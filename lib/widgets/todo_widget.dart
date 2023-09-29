import 'package:flutter/material.dart';
import 'package:todo_app_24/models/todo.dart';

class TodoWidget extends StatefulWidget {
  final Todo todo;
  final Color backgroundColor;

  const TodoWidget({
    super.key,
    required this.todo,
    required this.backgroundColor,
  });

  @override
  State<TodoWidget> createState() => _TodoWidgetState();
}

class _TodoWidgetState extends State<TodoWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: widget.backgroundColor,
        padding: const EdgeInsets.fromLTRB(2.5, 10, 2.5, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: Text(widget.todo.name,
                  style: const TextStyle(
                    fontSize: 18,
                  )),
            ),
            Text(widget.todo.description),
          ],
        ));
  }
}
