import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Task Manager',
      debugShowCheckedModeBanner: false,
      // --- TASK 1: CUSTOM FIGMA PALETTE & GOOGLE FONTS ---
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF090B0F), // Dark background from your portfolio style
        primaryColor: const Color(0xFF4F46E5), // Your premium purple accent
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
        ),
      ),
      home: const TodoHomeScreen(),
    );
  }
}

// Simple Task Model to handle data cleanly
class Task {
  String title;
  String category; // Work, Personal, Study
  bool isDone;

  Task({required this.title, required this.category, this.isDone = false});

  // Convert Task to Map for saving to SharedPreferences
  Map<String, dynamic> toMap() => {
    'title': title,
    'category': category,
    'isDone': isDone,
  };

  // Create Task from Map when reading storage
  factory Task.fromMap(Map<String, dynamic> map) => Task(
    title: map['title'],
    category: map['category'],
    isDone: map['isDone'],
  );
}

class TodoHomeScreen extends StatefulWidget {
  const TodoHomeScreen({super.key});

  @override
  State<TodoHomeScreen> createState() => _TodoHomeScreenState();
}

class _TodoHomeScreenState extends State<TodoHomeScreen> {
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();
  String _selectedCategory = 'Personal'; // Default choice for dropdown

  @override
  void initState() {
    super.initState();
    _loadTasksFromStorage();
    _searchController.addListener(_filterTasks);
  }

  // --- TASK 3: LOAD FROM DEVICE STORAGE ---
// --- TASK 3: LOAD FROM DEVICE STORAGE ---
  Future<void> _loadTasksFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('saved_user_tasks');
    
    if (tasksJson != null) {
      final List<dynamic> decodedList = jsonDecode(tasksJson);
      setState(() {
        _allTasks = decodedList.map((item) => Task.fromMap(item)).toList();
        _filteredTasks = _allTasks;
      });
    }
  }

  // --- TASK 3: SAVE TO DEVICE STORAGE ---
  Future<void> _saveTasksToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_allTasks.map((t) => t.toMap()).toList());
    await prefs.setString('saved_user_tasks', encodedData);
  }

  // --- TASK 3: REAL-TIME SEARCH FILTERING ---
  void _filterTasks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredTasks = _allTasks;
      } else {
        _filteredTasks = _allTasks.where((task) {
          return task.title.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  // Helper helper to color code categories dynamically (Task 2)
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work': return const Color(0xFFEF4444); // Red
      case 'Study': return const Color(0xFF10B981); // Emerald Green
      default: return const Color(0xFF3B82F6); // Personal -> Blue
    }
  }

  // Add Dialog Popup with Dropdown (Task 2)
  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Allows dropdown state updates inside a popup dialog
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF131720),
              title: const Text('Add New Task', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _taskController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'What needs to be done?',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // --- TASK 2: CATEGORY DROPDOWN DIALOG ---
                  DropdownButton<String>(
                    value: _selectedCategory,
                    dropdownColor: const Color(0xFF131720),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white),
                    items: ['Personal', 'Work', 'Study'].map((String val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setDialogState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
                  onPressed: () {
                    if (_taskController.text.isNotEmpty) {
                      setState(() {
                        _allTasks.add(Task(
                          title: _taskController.text,
                          category: _selectedCategory,
                        ));
                        _taskController.clear();
                        _filterTasks(); // Refresh list layout
                      });
                      _saveTasksToStorage();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workspace Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF131720),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- TASK 3: SEARCH BAR UI ---
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF131720),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Task List Display View Track
            Expanded(
              child: _filteredTasks.isEmpty
                  ? const Center(child: Text('No tasks found.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = _filteredTasks[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF131720),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              activeColor: const Color(0xFF4F46E5),
                              value: task.isDone,
                              onChanged: (bool? checked) {
                                setState(() {
                                  task.isDone = checked!;
                                });
                                _saveTasksToStorage();
                              },
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                color: Colors.white,
                                decoration: task.isDone ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            // --- TASK 2: COLOR CODED CHIPS ---
                            trailing: Chip(
                              backgroundColor: _getCategoryColor(task.category).withOpacity(0.15),
                              side: BorderSide(color: _getCategoryColor(task.category)),
                              label: Text(
                                task.category,
                                style: TextStyle(
                                  color: _getCategoryColor(task.category),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4F46E5),
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}