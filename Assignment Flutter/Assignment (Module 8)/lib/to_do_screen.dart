import 'package:flutter/material.dart';
import 'database/db_helper.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);
  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Map<String, dynamic>> _todos = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshTodos();
  }

  void _refreshTodos() async {
    final data = await DatabaseHelper.instance.getTodos();
    setState(() => _todos = data);
  }

  void _addTodo() async {
    if (_taskController.text.isEmpty) return;
    await DatabaseHelper.instance.insertTodo({'title': _taskController.text, 'isDone': 0});
    _taskController.clear();
    _refreshTodos();
  }

  void _toggleTodo(int id, int isDone, String title) async {
    await DatabaseHelper.instance.updateTodo({'id': id, 'title': title, 'isDone': isDone == 0 ? 1 : 0});
    _refreshTodos();
  }

  void _deleteTodo(int id) async {
    await DatabaseHelper.instance.deleteTodo(id);
    _refreshTodos();
  }

  void _showEditDialog(int id, String currentTitle, int isDone) {
    TextEditingController editController = TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Task"),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(hintText: "Update your task"),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")
          ),
          ElevatedButton(
            onPressed: () async {
              if (editController.text.isNotEmpty) {
                await DatabaseHelper.instance.updateTodo({
                  'id': id,
                  'title': editController.text,
                  'isDone': isDone,
                });
                _refreshTodos();
                Navigator.pop(context);
              }
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    hintText: "Add a new task...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FloatingActionButton(
                onPressed: _addTodo,
                child: const Icon(Icons.add),
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _todos.length,
            itemBuilder: (context, index) {
              final todo = _todos[index];
              bool isDone = todo['isDone'] == 1;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: ListTile(
                  leading: Checkbox(
                    value: isDone,
                    onChanged: (val) => _toggleTodo(todo['id'], todo['isDone'], todo['title']),
                  ),
                  title: Text(
                    todo['title'],
                    style: TextStyle(decoration: isDone ? TextDecoration.lineThrough : null),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditDialog(todo['id'], todo['title'], todo['isDone']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTodo(todo['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}