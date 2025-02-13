import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_management/models/color.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDate; // ✅ Now required
  String selectedPriority = "Medium";

  void _saveTask() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in!")),
      );
      return;
    }

    // ✅ Check if all fields are filled
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required!")),
      );
      return;
    }

    FirebaseFirestore.instance.collection('tasks').add({
      'title': titleController.text,
      'description': descriptionController.text,
      'dueDate': selectedDate!.toIso8601String(),
      'priority': selectedPriority,
      'isCompleted': false,
      'userId': user.uid,
    });

    Navigator.pop(context);
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Task", style: TextStyle(color: Colors.white),),
      backgroundColor: AppColors.bgColor1,),
      backgroundColor: AppColors.bgColor2,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title',
                floatingLabelStyle: TextStyle(color: Colors.black),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Bottom line black when focused
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // Bottom line grey when not focused
                ),
              ),
              cursorColor: Colors.black,
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description',
                floatingLabelStyle: TextStyle(color: Colors.black),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Bottom line black when focused
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // Bottom line grey when not focused
                ),
              ),
              cursorColor: Colors.black,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickDate,
              child: Text("Pick Due Date", style: TextStyle(color: Colors.black),),
              style:ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppColors.bgColor3),
              ),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedPriority,
              items: ["Low", "Medium", "High"]
                  .map((priority) => DropdownMenuItem(value: priority, child: Text(priority)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedPriority = value!;
                },);
              },
              dropdownColor: AppColors.bgColor3, // Dropdown menu background color
              style: TextStyle(color: Colors.black), // Text style of dropdown items
              iconEnabledColor: Colors.black,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTask,
              child: Text('Save Task', style: TextStyle(color: Colors.black),),
              style:ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppColors.bgColor3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
