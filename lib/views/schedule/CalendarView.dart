import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:manager/controllers/WorkspaceController.dart';
import 'package:manager/model/task.dart';
import 'package:manager/theme.dart';
import 'package:manager/views/schedule/AddTask.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:manager/controllers/TaskController.dart';
import 'package:manager/views/widgets/TaskTile.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDay;
  CalendarFormat format = CalendarFormat.month;
  late DateTime _selectedDay;
  final TaskController _taskController = Get.find<TaskController>();
  final WorkSpaceController
   _workspaceController = Get.find<WorkSpaceController>();
  
  // Add workers to track for disposal
  late List<Worker> _workers;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    
    // Initialize workers
    _workers = [
      ever(_taskController.tasks, (_) {
        if (mounted) setState(() {});
      }),
      ever(_workspaceController.selectedWorkSpace, (_) {
        if (mounted) setState(() {});
      }),
    ];
  }

  @override
  void dispose() {
    // Dispose of workers
    for (var worker in _workers) {
      worker.dispose();
    }
    super.dispose();
  }

  List<Task> _getEventsForDay(DateTime day) {
    return _taskController.getTasksForDay(day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 20,),
            Obx(() => Text(
              _workspaceController.selectedWorkSpace.value.name,
              style: boldTitle,
            )),
            IconButton(
              onPressed: () {
                if (_workspaceController.selectedWorkSpace.value.uid.isEmpty) {
                  Get.snackbar('Error', 'Please select a workspace first');
                  return;
                }
                Get.to(() => const AddTask());
              },
              icon: const Icon(Iconsax.calendar_add, color: royalBlue,)
            )
          ],
        ),
        centerTitle: true,
        backgroundColor: backColor,
        elevation: 0,
        
        scrolledUnderElevation: 0,
      ),
      body: Obx(() {
        if (_workspaceController.selectedWorkSpace.value.uid.isEmpty) {
          return const Center(
            child: Text('Please select a workspace to view tasks'),
          );
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(1, 1),
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                  )
                ]
              ),
              child: Column(
                children: [
                  TableCalendar<Event>(
                    locale: 'en_US',
                    formatAnimationDuration: const Duration(milliseconds: 500),
                    formatAnimationCurve: Curves.fastOutSlowIn,
                    daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: GoogleFonts.lato(
                            textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )),
                        weekendStyle: GoogleFonts.lato(
                            textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ))),
                    headerStyle: const HeaderStyle(
                        titleCentered: true, formatButtonVisible: false),
                    selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                    firstDay: DateTime.utc(2022, 1, 1),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: _focusedDay,
                    calendarFormat: format,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    availableGestures: AvailableGestures.all,
                    eventLoader: (day) {
                      return _getEventsForDay(day).map((task) => Event(task.title)).toList();
                    },
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SimpleGestureDetector(
                    onTap: () {
                      if (format == CalendarFormat.month) {
                        setState(() {
                          format = CalendarFormat.twoWeeks;
                        });
                      } else if (format == CalendarFormat.twoWeeks) {
                        setState(() {
                          format = CalendarFormat.week;
                        });
                      } else {
                        setState(() {
                          format = CalendarFormat.month;
                        });
                      }
                    },
                    child: Container(
                      height: 25,
                      width: 150,
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Container(
                          width: 150,
                          height: 10,
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Obx(() {
                if (_taskController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = _taskController.getTasksForDay(_selectedDay);
                
                if (tasks.isEmpty) {
                  return const Center(
                    child: Text('No tasks for this day'),
                  );
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskTile(
                      task: task,
                      onDelete: () => _taskController.deleteTask(task.id),
                    );
                  },
                );
              }),
            ),
          ],
        );
      }),
    );
  }
}

class Event {
  final String title;
  bool isMultiDay = false;
  final DateTime? end;

  Event(this.title, {this.isMultiDay = false, this.end});

  @override
  String toString() => title;
}
