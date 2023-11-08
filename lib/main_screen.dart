import 'package:flutter/material.dart';
import 'add_edit_todo_page.dart';
import 'models/todo_item.dart';
import 'services/database.dart';

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
        title: Text('TODO List'),
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
              return ListTile(
                title: Text(todoItem.title),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: todoItem.isDone,
                      onChanged: (bool? value) async {
                        // Update isDone status
                        await DatabaseService.instance.updateTodoItem(
                          todoItem.copyWith(isDone: value ?? false),
                        );
                        _refreshTodoList();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        // Delete the item
                        await DatabaseService.instance
                            .deleteTodoItem(todoItem.id!);
                        _refreshTodoList();
                      },
                    ),
                  ],
                ),
                onTap: () async {
                  // Navigate to the edit page
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) =>
                            AddEditTodoPage(todoItem: todoItem)),
                  );
                  _refreshTodoList();
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to add page
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddEditTodoPage()),
          );
          _refreshTodoList();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
