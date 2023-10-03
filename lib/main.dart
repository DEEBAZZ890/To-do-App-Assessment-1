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
  GetIt.I.registerSingleton<DataSource>(ApiDatasource()); // For the API
  // GetIt.I.registerSingleton<DataSource>(SQLDatasource());

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
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<TodoList>(
            builder: (context, stateModel, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 10.0), // Adjust as needed
                child: Text(
                  "Completed: ${stateModel.completedTodos} / ${stateModel.todoCount}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
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
                return InkWell(
                  onTap: () => _toggleCompletion(stateModel, index),
                  child: TodoWidget(
                    todo: stateModel.todos[index],
                    toggleCompletion: () =>
                        _toggleCompletion(stateModel, index),
                    editTodo: () => _editTodo(stateModel.todos[index]),
                    deleteTodo: () => _deleteTodo(stateModel.todos[index]),
                  ),
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
                  onPressed: () {
                    setState(() {
                      Provider.of<TodoList>(context, listen: false).add({
                        'name': _controllerName.text,
                        'description': _controllerDescription.text
                      });
                      Navigator.pop(context);
                    });
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
                    Todo updatedTodo = Todo(
                      name: _controllerName.text,
                      description: _controllerDescription.text,
                      completed: currentTodo.completed,
                      internalID: currentTodo.internalID,
                    );

                    Provider.of<TodoList>(context, listen: false)
                        .update(updatedTodo);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                )
              ],
            ),
          );
        });
  }

  void _deleteTodo(Todo currentTodo) {
    showDialog(
      context: context,
      builder: (builder) {
        return AlertDialog(
          title: const Text(
            'Delete Todo',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                  currentTodo.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(currentTodo.description),
                const SizedBox(height: 20), // Some spacing before the buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Provider.of<TodoList>(context, listen: false)
                            .remove(currentTodo);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        backgroundColor: Colors.red[100],
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
