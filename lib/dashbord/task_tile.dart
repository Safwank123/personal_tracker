import 'package:flutter/material.dart';
import 'package:personal_tracker/dashbord/task_model.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;
  final ValueChanged<bool?>? onToggleCompleted;
  final VoidCallback? onEdit;

  const TaskTile({
    super.key,
    required this.task,
    required this.onDelete,
    this.onToggleCompleted,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart, // Swipe to delete
      onDismissed: (direction) {
        onDelete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted')),
        );
      },
      background: Container(
        color: Colors.red, // Red background when swiping
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30, // Make the delete icon more prominent
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (onToggleCompleted != null) {
              onToggleCompleted!(!task.isCompleted);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              children: [
                Checkbox(
                 
                  value: task.isCompleted,
                  onChanged: onToggleCompleted,
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                      ),
                      if (task.description != null && task.description!.isNotEmpty)
                        Text(
                          task.description!,
                          style: const TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}