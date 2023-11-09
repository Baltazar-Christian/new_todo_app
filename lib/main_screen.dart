import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // For iOS style icons
import 'models/todo_item.dart';
import 'services/database.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TextEditingController _searchController = TextEditingController();
  List<TodoItem> _todoList = [];
  List<TodoItem> _filteredTodoList = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadTodoList();
  }

  void _loadTodoList() async {
    _todoList = await DatabaseService.instance.readAllTodoItems();
    _filteredTodoList = _todoList;
    setState(() {});
  }

  void _onSearchChanged() {
    String searchQuery = _searchController.text.toLowerCase();
    setState(() {
      _filteredTodoList = _todoList.where((todoItem) {
        return todoItem.title.toLowerCase().contains(searchQuery);
      }).toList();
    });
  }

  Future<void> _confirmDeleteDialog(int id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.grey),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Icon(Icons.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.red),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTodoItem(id);
              },
              child: Icon(Icons.delete),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTodoItem(int id) async {
    await DatabaseService.instance.deleteTodoItem(id);
    _loadTodoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Center(
          child: Container(
            height: 32,
            width: MediaQuery.of(context).size.width * 0.8,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Tasks',
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide.none,
                ),
                prefixIcon:
                    Icon(Icons.search, color: Theme.of(context).primaryColor),
              ),
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _onSearchChanged();
            },
          ),
        ],
      ),
      body: _filteredTodoList.isEmpty
          ? Center(child: Text('No TODOs found'))
          : ListView.builder(
              itemCount: _filteredTodoList.length,
              itemBuilder: (ctx, i) {
                var todoItem = _filteredTodoList[i];
                return _buildTaskTile(todoItem, i);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditTodoDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.lightBlue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTaskTile(TodoItem todoItem, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        title: Text(todoItem.title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showAddEditTodoDialog(todoItem: todoItem),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDeleteDialog(todoItem.id!),
            ),
            IconButton(
              icon: todoItem.isDone
                  ? Icon(CupertinoIcons.check_mark_circled_solid,
                      color: Color.fromARGB(255, 142, 246, 146))
                  : Icon(CupertinoIcons.circle, color: Colors.grey),
              onPressed: () async {
                todoItem.isDone = !todoItem.isDone;
                await DatabaseService.instance.updateTodoItem(todoItem);
                _loadTodoList();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddEditTodoDialog({TodoItem? todoItem}) async {
    final _titleController = TextEditingController(text: todoItem?.title ?? '');
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(todoItem == null ? 'Add Task' : 'Edit Task'),
          content: TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Task Name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.grey),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Icon(Icons.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.green),
              onPressed: () async {
                final String title = _titleController.text;
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Title cannot be empty')),
                  );
                  return;
                }
                if (todoItem == null) {
                  await DatabaseService.instance
                      .createTodoItem(TodoItem(title: title));
                } else {
                  await DatabaseService.instance
                      .updateTodoItem(todoItem.copyWith(title: title));
                }
                Navigator.of(context).pop();
                _loadTodoList();
              },
              child: Icon(Icons.check),
            ),
          ],
        );
      },
    );
  }
}
