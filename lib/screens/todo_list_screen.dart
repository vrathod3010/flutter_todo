import 'package:flutter/material.dart';
import 'package:flutter_todo/helpers/database_helper.dart';
import 'package:flutter_todo/models/task_model.dart';
import 'package:flutter_todo/screens/add_task_screen.dart';
import 'package:intl/intl.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  Future<List<Task>> _taskList;
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _taskList = DatabaseHelper.instance.getTaskList();
    });
  }

  Widget _buildTask(Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          ListTile(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AddTaskScreen(
                          task: task,
                          updateTaskList: _updateTaskList,
                        ))),
            title: Text(task.title,
                style: TextStyle(
                    fontSize: 15.0, decoration: task.status == 0 ? TextDecoration.none : TextDecoration.lineThrough)),
            subtitle: Text('${_dateFormatter.format(task.date)} + ${task.priority}'),
            trailing: Container(
              child: Checkbox(
                onChanged: (value) {
                  task.status = value ? 1 : 0;
                  DatabaseHelper.instance.updateTask(task);
                  _updateTaskList();
                },
                activeColor: Theme.of(context).primaryColor,
                value: task.status == 1 ? true : false,
              ),
            ),
          ),
          Divider()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _taskList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final int completedTaskCount = snapshot.data.where((Task task) => task.status == 1).toList().length;

          return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 80.0),
              itemCount: 1 + snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('My Tasks', style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10.0),
                        Text(
                          '$completedTaskCount of ${snapshot.data.length}',
                          style: TextStyle(color: Colors.grey, fontSize: 20.0, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }
                return _buildTask(snapshot.data[index - 1]);
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddTaskScreen(
                      updateTaskList: _updateTaskList,
                    ))),
        child: Icon(Icons.add),
      ),
    );
  }
}
