import 'package:flutter/material.dart';
import 'package:flutter_todo/helpers/database_helper.dart';
import 'package:flutter_todo/models/task_model.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  final Task task;
  final Function updateTaskList;

  AddTaskScreen({this.task, this.updateTaskList});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _priority;
  DateTime _date = DateTime.now();
  TextEditingController _dateController = TextEditingController();
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  final List<String> _priorities = ['High', 'Low', 'Medium'];

  void initState() {
    super.initState();

    if (widget.task != null) {
      _title = widget.task.title;
      _priority = widget.task.priority;
      _date = widget.task.date;
    }
    _dateController.text = _dateFormatter.format(_date);
  }

  dispose() {
    _dateController.dispose();
    super.dispose();
  }

  _handleDatePicker() async {
    final DateTime date =
        await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = _dateFormatter.format(date);
    }
  }

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print('$_title $_date $_priority');

      //insert into database
      Task task = Task(title: _title, date: _date, priority: _priority);
      if (widget.task == null) {
        task.status = 0;
        DatabaseHelper.instance.insertTask(task);
      } else {
        task.id = widget.task.id;
        task.status = widget.task.status;
        DatabaseHelper.instance.updateTask(task);
      }
      //update task into database
      widget.updateTaskList();
      Navigator.pop(context);
    }
  }

  _delete() {
    DatabaseHelper.instance.deleteTask(widget.task.id);
    widget.updateTaskList();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_ios, color: Theme.of(context).primaryColor, size: 30.0),
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                widget.task == null ? 'Add Task' : 'Update Task',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40.0, color: Colors.black),
              ),
              SizedBox(
                height: 10.0,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: TextFormField(
                        style: TextStyle(fontSize: 18.0),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.00)),
                            labelText: 'Title',
                            labelStyle: TextStyle(fontSize: 18.0)),
                        validator: (input) => input.trim().isEmpty ? "Please Enter a task title" : null,
                        onSaved: (input) => _title = input,
                        initialValue: _title,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: TextFormField(
                        readOnly: true,
                        style: TextStyle(fontSize: 18.0),
                        onTap: _handleDatePicker,
                        controller: _dateController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.00)),
                            labelText: 'Date',
                            labelStyle: TextStyle(fontSize: 18.0)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: DropdownButtonFormField(
                        icon: Icon(
                          Icons.arrow_drop_down_circle,
                        ),
                        iconSize: 22.0,
                        iconEnabledColor: Theme.of(context).primaryColor,
                        items: _priorities
                            .map((String e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                    style: TextStyle(fontSize: 18.0, color: Colors.black),
                                  ),
                                ))
                            .toList(),
                        style: TextStyle(fontSize: 18.0),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.00)),
                            labelText: 'Priorities',
                            labelStyle: TextStyle(fontSize: 18.0)),
                        validator: (input) => input.trim().isEmpty ? "Please Select a Priority level" : null,
                        onSaved: (input) => _priority = input,
                        onChanged: (value) {
                          setState(() {
                            _priority = value;
                          });
                        },
                        value: _priority,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20.0),
                      height: 60.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(20.0)),
                      child: FlatButton(
                        onPressed: _submit,
                        child: Text(
                          widget.task == null ? 'Add' : 'Update',
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
                      ),
                    ),
                    widget.task != null
                        ? Container(
                            margin: EdgeInsets.symmetric(vertical: 20.0),
                            height: 60.0,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(20.0)),
                            child: FlatButton(
                              onPressed: _delete,
                              child: Text(
                                'Delete',
                                style: TextStyle(color: Colors.white, fontSize: 20.0),
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
