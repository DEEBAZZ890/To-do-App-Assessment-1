import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'models/todo.dart';
import 'package:todo_app_24/models/todo_list.dart';
import 'package:todo_app_24/services/datasource.dart';
import 'package:todo_app_24/services/api_datasource.dart';
import 'package:todo_app_24/services/sql_datasource.dart';
import 'package:todo_app_24/services/hive_datasource.dart';
import 'package:todo_app_24/widgets/todo_widget.dart';

import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // GetIt.I.registerSingleton<DataSource>(HiveDatasource()); // For Hive
  // GetIt.I.registerSingleton<DataSource>(ApiDatasource()); // For the API
  GetIt.I.registerSingleton<DataSource>(SQLDatasource());

  runApp(ChangeNotifierProvider(
    create: (context) => TodoList(),
    child: const TodoApp(),
  ));
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerDescription = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          Consumer<TodoList>(
            builder: (context, stateModel, child) {
              return Text(
                  "Completed: ${stateModel.completedTodos} / ${stateModel.todoCount}");
            },
          )
        ],
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Consumer<TodoList>(
        builder: (context, stateModel, child) {
          return RefreshIndicator(
            onRefresh: stateModel.browse,
            child: ListView.builder(
              itemCount: stateModel.todoCount,
              itemBuilder: (context, index) {
                print(
                    "Rendering TodoWidget with Todo ID: ${stateModel.todos[index].id}"); // Add this line
                return TodoWidget(
                  todo: stateModel.todos[index],
                  toggleCompletion: () => _toggleCompletion(stateModel, index),
                  editTodo: () => _editTodo(stateModel.todos[index]),
                );
              },
            ),
          );
        },
      ),
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Use this to add a todo',
        onPressed: _addTodo,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addTodo() {
    _controllerDescription.text = '';
    _controllerName.text = '';
    showDialog(
        context: context,
        builder: (builder) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Name'),
                TextFormField(
                  controller: _controllerName,
                ),
                const Text('Description'),
                TextFormField(
                  controller: _controllerDescription,
                ),
                ElevatedButton(
                  onPressed: () => {
                    //functionality of the save button
                    setState(() {
                      Provider.of<TodoList>(context, listen: false).add({
                        'name': _controllerName.text,
                        'description': _controllerDescription.text
                      });
                      Navigator.pop(context);
                    })
                  },
                  child: const Text('Save'),
                )
              ],
            ),
          );
        });
  }

  void _toggleCompletion(TodoList stateModel, int index) {
    setState(() {
      stateModel.todos[index].completed = !stateModel.todos[index].completed;
      stateModel.update(stateModel.todos[index]);
    });
  }

  void _editTodo(Todo currentTodo) {
    print("Editing Todo with ID: ${currentTodo.id}"); // Add this line

    _controllerName.text = currentTodo.name;
    _controllerDescription.text = currentTodo.description;

    showDialog(
        context: context,
        builder: (builder) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Name'),
                TextFormField(
                  controller: _controllerName,
                ),
                const Text('Description'),
                TextFormField(
                  controller: _controllerDescription,
                ),
                ElevatedButton(
                  onPressed: () {
                    // Create a new Todo with updated values
                    Todo updatedTodo = Todo(
                      name: _controllerName.text,
                      description: _controllerDescription.text,
                      completed: currentTodo.completed,
                      internalID:
                          currentTodo.internalID, // <-- Retain the original id
                    );
                    print("Todo ID: ${updatedTodo.id}");

                    // Update the data source
                    Provider.of<TodoList>(context, listen: false)
                        .update(updatedTodo);

                    // Close the dialog
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                )
              ],
            ),
          );
        });
  }
}
