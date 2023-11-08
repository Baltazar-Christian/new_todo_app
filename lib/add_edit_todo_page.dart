import 'package:flutter/material.dart';
import 'models/todo_item.dart';
import 'services/database.dart';

class AddEditTodoPage extends StatefulWidget {
  final TodoItem? todoItem;

  AddEditTodoPage({this.todoItem});

  @override
  _AddEditTodoPageState createState() => _AddEditTodoPageState();
}

class _AddEditTodoPageState extends State<AddEditTodoPage> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.todoItem?.title ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todoItem == null ? 'Add Todo' : 'Edit Todo'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: _saveTodoItem,
              child: Text(widget.todoItem == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTodoItem() async {
    final String title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    if (widget.todoItem == null) {
      TodoItem newItem = TodoItem(title: title);
      await DatabaseService.instance.createTodoItem(newItem);
    } else {
      TodoItem updatedItem = widget.todoItem!.copyWith(title: title);
      await DatabaseService.instance.updateTodoItem(updatedItem);
    }

    Navigator.of(context).pop(); // Close the screen after saving
  }
}
