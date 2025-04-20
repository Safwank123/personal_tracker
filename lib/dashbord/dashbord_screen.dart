import 'package:flutter/material.dart';
import 'package:personal_tracker/app/theme.dart';
import 'package:personal_tracker/auth/auth_service.dart';
import 'package:personal_tracker/dashbord/task_model.dart';
import 'package:personal_tracker/dashbord/task_tile.dart';
import 'package:personal_tracker/services/subabase_services.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Task>> _tasksFuture;
  List<Task> _currentTasks = [];
  late final AuthService authService;

  @override
  void initState() {
    super.initState();
    authService = Provider.of<AuthService>(context, listen: false);
    _loadTasks();
  }

  void _loadTasks() {
    _tasksFuture = Provider.of<SupabaseService>(context, listen: false)
        .getTasks()
        .then((tasks) {
      setState(() {
        _currentTasks = tasks;
      });
      return tasks;
    });
  }

  Future<void> _addTask(String title) async {
    final userId =
        Provider.of<AuthService>(context, listen: false).currentUser!.id;
    await Provider.of<SupabaseService>(context, listen: false)
        .addTask(userId, title, title); // No description
    _loadTasks();
  }

  Future<void> _deleteTask(String taskId) async {
    await Provider.of<SupabaseService>(context, listen: false)
        .deleteTask(taskId);
    setState(() {
      _currentTasks.removeWhere((task) => task.id == taskId);
    });
  }

  Future<void> _toggleTaskStatus(String taskId, bool isCompleted) async {
    await Provider.of<SupabaseService>(context, listen: false)
        .updateTask(taskId, isCompleted: isCompleted);
    setState(() {
      final index = _currentTasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        _currentTasks[index] = _currentTasks[index].copyWith(
          isCompleted: isCompleted,
        );
      }
    });
  }

  Future<void> _editTask(Task task) async {
    final _editTitleController = TextEditingController(text: task.title);

    final updated = await showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: _editTitleController,
            decoration: const InputDecoration(labelText: 'Task Title'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop(_editTitleController.text.trim());
              },
            ),
          ],
        );
      },
    );

    if (updated != null && updated != task.title) {
      await Provider.of<SupabaseService>(context, listen: false).updateTask(
        task.id,
        title: updated,
        description: null,
        isCompleted: task.isCompleted,
      );
      setState(() {
        final index = _currentTasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _currentTasks[index] = _currentTasks[index].copyWith(title: updated);
        }
      });
    }
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    final _newTaskController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const Text(
                  'Add New Task',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _newTaskController,
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D2A3A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    final title = _newTaskController.text.trim();
                    if (title.isNotEmpty) {
                      _addTask(title);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Add Task',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(
              authService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              authService.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<List<Task>>(
                future: _tasksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFCD95B),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Error loading tasks",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No tasks found.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: _currentTasks.length,
                    itemBuilder: (context, index) {
                      final task = _currentTasks[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A4B5C),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            task.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: task.isCompleted,
                                activeColor: const Color(0xFFFCD95B),
                                onChanged: (val) =>
                                    _toggleTaskStatus(task.id, val ?? false),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.white70),
                                onPressed: () => _editTask(task),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                onPressed: () => _deleteTask(task.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: SizedBox(
              height: 50,
              width: 160,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFCD95B),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                icon: const Icon(Icons.add),
                label: const Text("Add Task",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => _showAddTaskBottomSheet(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
