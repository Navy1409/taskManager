import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_management/models/color.dart';
import 'add_task_screen.dart';
import 'auth_screen.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String _selectedPriority = "No Filter";
  String _selectedStatus = "No Filter";

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  void _logout() {
    _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Manager", style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: _logout),
        ],
        backgroundColor: AppColors.bgColor1,
      ),
      backgroundColor: AppColors.bgColor2,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text("Filter by Priority"),
                    DropdownButton<String>(
                      value: _selectedPriority,
                      items: ["No Filter", "Low", "Medium", "High"]
                          .map((priority) => DropdownMenuItem(value: priority, child: Text(priority)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPriority = value!;
                        });
                      },
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text("Filter By Completion"),
                    DropdownButton<String>(
                      value: _selectedStatus,
                      items: ["No Filter", "Completed", "Incomplete"]
                          .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tasks')
                  .where('userId', isEqualTo: _user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

                // Apply filters
                List<QueryDocumentSnapshot> filteredDocs = docs.where((doc) {
                  var task = doc.data() as Map<String, dynamic>;
                  bool matchesPriority = _selectedPriority == "No Filter" || task['priority'] == _selectedPriority;
                  bool matchesStatus = _selectedStatus == "No Filter" ||
                      (_selectedStatus == "Completed" && task['isCompleted'] == true) ||
                      (_selectedStatus == "Incomplete" && task['isCompleted'] == false);
                  return matchesPriority && matchesStatus;
                }).toList();

                // Sort by due date (earliest first)
                filteredDocs.sort((a, b) {
                  DateTime dateA = DateTime.parse((a.data() as Map<String, dynamic>)['dueDate']);
                  DateTime dateB = DateTime.parse((b.data() as Map<String, dynamic>)['dueDate']);
                  return dateA.compareTo(dateB);
                });

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var task = filteredDocs[index].data() as Map<String, dynamic>;
                    return Card(
                      color: AppColors.bgColor3,
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          task['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            decoration: task['isCompleted'] ? TextDecoration.lineThrough : TextDecoration.none,
                            color: task['isCompleted'] ? Colors.grey : Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${task['description']}", style: TextStyle( fontWeight: FontWeight.w600),),
                            Text("Due Date:", style: TextStyle(fontWeight: FontWeight.w400),),
                            Text("${task['dueDate'].toString().split('T')[0]}", style: TextStyle(fontWeight: FontWeight.w300),),
                            Text("Priority:", style: TextStyle(fontWeight: FontWeight.w400),),
                            Text("${task['priority']}", style: TextStyle(fontWeight: FontWeight.w300),),
                            if (task['isCompleted'])
                              Text("Completed", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.black),
                                      onPressed: () => _editTask(filteredDocs[index].id, task),
                                    ),
                                    Text("Edit", style: TextStyle(fontWeight: FontWeight.w200),)
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.black),
                                      onPressed: () => _deleteTask(filteredDocs[index].id),
                                    ),
                                    Text("Delete", style: TextStyle(fontWeight: FontWeight.w200),)
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                        trailing: Checkbox(
                          value: task['isCompleted'] ?? false,
                          onChanged: (value) {
                            FirebaseFirestore.instance.collection('tasks').doc(filteredDocs[index].id).update({
                              'isCompleted': value ?? false,
                            });
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.bgColor1,
        child: Icon(Icons.add, color: Colors.white,),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddTaskScreen()));
        },
      ),
    );
  }

  void _deleteTask(String taskId) {
    FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
  }

  void _editTask(String taskId, Map<String, dynamic> taskData) {
    TextEditingController titleController = TextEditingController(text: taskData['title']);
    TextEditingController descriptionController = TextEditingController(text: taskData['description']);
    DateTime selectedDate = DateTime.parse(taskData['dueDate']);
    String selectedPriority = taskData['priority'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: 'Title')),
            TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description')),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              child: Text("Pick Due Date"),
            ),
            Text("Selected Due Date: ${selectedDate.toLocal()}".split(' ')[0]),
            DropdownButton<String>(
              value: selectedPriority,
              items: ["Low", "Medium", "High"]
                  .map((priority) => DropdownMenuItem(value: priority, child: Text(priority)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedPriority = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
                'title': titleController.text,
                'description': descriptionController.text,
                'dueDate': selectedDate.toIso8601String(),
                'priority': selectedPriority,
              });
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }
}
