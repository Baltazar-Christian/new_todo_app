import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // For iOS style icons
import 'add_edit_todo_page.dart';
import 'models/todo_item.dart';
import 'services/database.dart';
import 'app_bar.dart';

// import 'services/database_service.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Future<List<TodoItem>> _todoListFuture;

  @override
  void initState() {
    super.initState();
    _todoListFuture = DatabaseService.instance.readAllTodoItems();
  }

  Future<void> _refreshTodoList() async {
    _todoListFuture = DatabaseService.instance.readAllTodoItems();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.transparent, // Set your desired background color
        title: Text(
          'All Tasks',
          style: TextStyle(
            color: Colors
                .lightBlue, // Choose a color that contrasts well with the background
            fontWeight: FontWeight.bold, // If your design requires bold text
          ),
        ),
        centerTitle: false, // If your title should be centered
        elevation: 0, // Removes the shadow underneath the AppBar
        actions: [
          // If you have any actions, add them here
        ],
      ),
      body: FutureBuilder<List<TodoItem>>(
        future: _todoListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('No TODOs found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (ctx, i) {
              var todoItem = snapshot.data![i];
              return _buildTaskTile(todoItem, i);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddEditTodoPage()),
          );
          _refreshTodoList();
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
        trailing: IconButton(
          icon: todoItem.isDone
              ? Icon(CupertinoIcons.check_mark_circled_solid,
                  color: Colors.green)
              : Icon(CupertinoIcons.circle, color: Colors.grey),
          onPressed: () async {
            todoItem.isDone = !todoItem.isDone;
            await DatabaseService.instance.updateTodoItem(todoItem);
            _refreshTodoList();
          },
        ),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => AddEditTodoPage(todoItem: todoItem)),
          );

          _refreshTodoList();
        },
      ),
    );
  }
}
