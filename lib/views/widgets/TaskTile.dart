import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:manager/model/task.dart';
import 'package:manager/theme.dart';
import 'package:manager/views/schedule/EditTask.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;

  const TaskTile({
    Key? key,
    required this.task,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Time indicator
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: task.color == 'blue'
                    ? Colors.blue.withOpacity(0.1)
                    : task.color == 'yellow'
                        ? Colors.yellow.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('HH:mm').format(task.startTime),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: task.color == 'blue'
                          ? Colors.blue
                          : task.color == 'yellow'
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                  const Icon(Icons.arrow_downward, size: 16),
                  Text(
                    DateFormat('HH:mm').format(task.endTime),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: task.color == 'blue'
                          ? Colors.blue
                          : task.color == 'yellow'
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            // Vertical divider
            Container(
              width: 4,
              color: task.color == 'blue'
                  ? Colors.blue
                  : task.color == 'yellow'
                      ? Colors.yellow
                      : Colors.red,
            ),
            // Task details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (task.isRepeat)
                          const Icon(Icons.repeat, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: royalBlue),
                          onPressed: () => Get.to(() => EditTaskPage(task: task)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteDialog(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
} 