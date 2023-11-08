import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // For iOS style icons
import 'add_edit_todo_page.dart';
import 'models/todo_item.dart';
import 'services/database.dart';
import 'app_bar.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Future<List<TodoItem>> _todoListFuture;
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

  Future<void> _deleteTodoItem(int id) async {
    await DatabaseService.instance.deleteTodoItem(id);
    _loadTodoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search Tasks',
            border: InputBorder.none,
            suffixIcon: Icon(Icons.search),
          ),
        ),
        centerTitle: false,
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
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddEditTodoPage()),
          );
          _loadTodoList();
        },
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
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                // Delete the item
                await DatabaseService.instance.deleteTodoItem(todoItem.id!);
                _loadTodoList(); // Make sure todoItem.id is an int
              },
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
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => AddEditTodoPage(todoItem: todoItem)),
          );
          _loadTodoList();
        },
      ),
    );
  }
}
