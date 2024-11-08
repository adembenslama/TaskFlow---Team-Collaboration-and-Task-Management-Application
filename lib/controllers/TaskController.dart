import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:manager/controllers/AuthController.dart';
import 'package:manager/controllers/WorkspaceController.dart';
import 'package:manager/model/task.dart';

class TaskController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();
  final WorkSpaceController _workspaceController = Get.find<WorkSpaceController>();

  final RxList<Task> tasks = <Task>[].obs;
  final RxBool isLoading = false.obs;
  StreamSubscription? _taskSubscription;

  @override
  void onInit() {
    super.onInit();
    // Listen to workspace changes
    ever(_workspaceController.selectedWorkSpace, (_) {
      _resetTaskListener();
    });
    // Initial fetch
    _resetTaskListener();
  }

  void _resetTaskListener() {
    // Cancel existing subscription if any
    _taskSubscription?.cancel();
    
    // Clear existing tasks
    tasks.clear();
    
    // Start new listener if we have a selected workspace
    if (_workspaceController.selectedWorkSpace.value.uid.isNotEmpty) {
      _setupTaskListener();
    }
  }

  void _setupTaskListener() {
    final workspaceId = _workspaceController.selectedWorkSpace.value.uid;
    
    _taskSubscription = _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('tasks')
        .snapshots()
        .listen(
      (snapshot) {
        tasks.value = snapshot.docs
            .map((doc) => Task.fromJson(doc))
            .toList();
      },
      onError: (error) {
        print('Error listening to tasks: $error');
        Get.snackbar('Error', 'Failed to load tasks');
      },
    );
  }

  Future<void> fetchTasks() async {
    try {
      isLoading(true);
      final workspaceId = _workspaceController.selectedWorkSpace.value.uid;
      
      if (workspaceId.isEmpty) {
        tasks.clear();
        return;
      }

      final snapshots = await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('tasks')
          .get();

      tasks.value = snapshots.docs
          .map((doc) => Task.fromJson(doc))
          .toList();
    } catch (e) {
      print('Error fetching tasks: $e');
      Get.snackbar('Error', 'Failed to fetch tasks');
    } finally {
      isLoading(false);
    }
  }

  bool _validateTask({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required bool isRepeat,
    required String repeatType,
    required List<int> repeatDays,
  }) {
    if (title.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a title');
      return false;
    }

    if (startTime.isAfter(endTime)) {
      Get.snackbar('Error', 'Start time must be before end time');
      return false;
    }

    if (isRepeat) {
      if (repeatType == 'Weekly' && repeatDays.isEmpty) {
        Get.snackbar('Error', 'Please select at least one day for weekly repeat');
        return false;
      }
    }

    return true;
  }

  Future<void> addTask({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required String color,
    required List<String> assignedTo,
    bool isRepeat = false,
    String repeatType = '',
    List<int> repeatDays = const [],
    DateTime? repeatUntil,
  }) async {
    // Validate task
    if (!_validateTask(
      title: title,
      startTime: startTime,
      endTime: endTime,
      isRepeat: isRepeat,
      repeatType: repeatType,
      repeatDays: repeatDays,
    )) {
      return;
    }

    try {
      isLoading(true);
      final workspaceId = _workspaceController.selectedWorkSpace.value.uid;
      
      final taskRef = _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('tasks')
          .doc();

      final task = Task(
        id: taskRef.id,
        title: title,
        description: description,
        workspaceId: workspaceId,
        createdBy: _authController.userData.value.uid,
        assignedTo: assignedTo,
        startTime: startTime,
        endTime: endTime,
        color: color,
        isRepeat: isRepeat,
        repeatType: repeatType,
        repeatDays: repeatDays,
        repeatUntil: repeatUntil,
        createdAt: DateTime.now(),
      );

      await taskRef.set(task.toJson());
      await fetchTasks();
      Get.back();
      Get.snackbar('Success', 'Task added successfully');
    } catch (e) {
      print('Error adding task: $e');
      Get.snackbar('Error', 'Failed to add task');
    } finally {
      isLoading(false);
    }
  }

  List<Task> getTasksForDay(DateTime date) {
    return tasks.where((task) {
      if (task.isRepeat) {
        if (task.repeatUntil != null && date.isAfter(task.repeatUntil!)) {
          return false;
        }

        switch (task.repeatType) {
          case 'Daily':
            return true;
          case 'Weekly':
            return task.repeatDays.contains(date.weekday);
          case 'Monthly':
            return task.startTime.day == date.day;
          default:
            return false;
        }
      } else {
        return isSameDay(task.startTime, date);
      }
    }).toList();
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> deleteTask(String taskId) async {
    try {
      isLoading(true);
      final workspaceId = _workspaceController.selectedWorkSpace.value.uid;
      
      await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('tasks')
          .doc(taskId)
          .delete();

      await fetchTasks();
      Get.snackbar('Success', 'Task deleted successfully');
    } catch (e) {
      print('Error deleting task: $e');
      Get.snackbar('Error', 'Failed to delete task');
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateTask(Task task) async {
    // Validate task
    if (!_validateTask(
      title: task.title,
      startTime: task.startTime,
      endTime: task.endTime,
      isRepeat: task.isRepeat,
      repeatType: task.repeatType,
      repeatDays: task.repeatDays,
    )) {
      return;
    }

    try {
      isLoading(true);
      final workspaceId = _workspaceController.selectedWorkSpace.value.uid;
      
      await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('tasks')
          .doc(task.id)
          .update(task.toJson());

      await fetchTasks();
      Get.back();
      Get.snackbar('Success', 'Task updated successfully');
    } catch (e) {
      print('Error updating task: $e');
      Get.snackbar('Error', 'Failed to update task');
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    _taskSubscription?.cancel();
    super.onClose();
  }
} 