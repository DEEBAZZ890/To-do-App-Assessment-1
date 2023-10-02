import 'package:flutter/material.dart';
import 'package:todo_app_24/models/todo.dart';

class TodoWidget extends StatefulWidget {
  final Todo todo;

  const TodoWidget({
    super.key,
    required this.todo,
  });

  @override
  State<TodoWidget> createState() => _TodoWidgetState();
}

class _TodoWidgetState extends State<TodoWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      margin: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(25, 20, 5, 20),
        child: Row(
          children: [
            // If completed, show green circle with a white tick
            // Otherwise, show an outlined circle.
            widget.todo.completed
                ? const Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: Colors.green, size: 30),
                      Icon(Icons.check, color: Colors.white, size: 20),
                    ],
                  )
                : const Icon(Icons.radio_button_unchecked,
                    color: Colors.black, size: 30),
            const SizedBox(
                width: 15), // Spacing between the circle and the text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      widget.todo.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(widget.todo.description),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Icon(Icons.edit, size: 20.0),
            ),
          ],
        ),
      ),
    );
  }
}
