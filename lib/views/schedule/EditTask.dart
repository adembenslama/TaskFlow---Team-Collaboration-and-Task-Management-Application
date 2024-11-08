import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:manager/controllers/TaskController.dart';
import 'package:manager/theme.dart';
import 'package:intl/intl.dart';
import 'package:manager/views/widgets/MembersWidget.dart';
import 'package:manager/views/widgets/MyInputfield.dart';
import 'package:manager/model/task.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;
  const EditTaskPage({Key? key, required this.task}) : super(key: key);

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final TaskController _taskController = Get.find<TaskController>();
  late DateTime _selectedDate;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late List<bool> _selectedDays;
  late List<String> _selectedMembers;
  late bool _isRepeat;
  late String _endTime;
  late String _startTime;
  late int _colorIndex;
  late String _selectedOption;

  final List<String> _days = ["M", "T", "W", "T", "F", "S", "S"];
  final List<String> _options = ["Daily", "Weekly", "Monthly"];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _selectedDate = widget.task.startTime;
    _startTime = DateFormat("HH:mm").format(widget.task.startTime);
    _endTime = DateFormat("HH:mm").format(widget.task.endTime);
    _isRepeat = widget.task.isRepeat;
    _selectedOption = widget.task.repeatType.isEmpty ? "Weekly" : widget.task.repeatType;
    _colorIndex = widget.task.color == 'blue' ? 1 : widget.task.color == 'yellow' ? 2 : 3;
    _selectedMembers = List.from(widget.task.assignedTo);
    _selectedDays = List.generate(7, (index) => 
      widget.task.repeatDays.contains(index + 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const BackButton(),
        title: Row(
          children: [
            const Spacer(),
            ElevatedButton(
              onPressed: _updateTask,
              child: Text("Update", style: buttonText),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyInputField(
                title: "Title",
                hint: "Enter title",
                controller: _titleController,
              ),
              const SizedBox(height: 12),
              MyInputField(
                title: "Description",
                hint: "Enter description",
                controller: _descriptionController,
              ),
              const SizedBox(height: 12),
              MyInputField(
                title: "Date",
                hint: DateFormat('yyyy-MM-dd').format(_selectedDate),
                widget: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: () => _getDateFromUser(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: MyInputField(
                      title: "Start Time",
                      hint: _startTime,
                      widget: IconButton(
                        icon: const Icon(Icons.access_time_rounded),
                        onPressed: () => _getTimeFromUser(true),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MyInputField(
                      title: "End Time",
                      hint: _endTime,
                      widget: IconButton(
                        icon: const Icon(Icons.access_time_rounded),
                        onPressed: () => _getTimeFromUser(false),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
             
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Repeat", style: addStyle),
                      Switch(
                        value: _isRepeat,
                        onChanged: (value) {
                          setState(() => _isRepeat = value);
                        },
                      ),
                    ],
                  ),
                  if (_isRepeat) ...[
                    DropdownButton<String>(
                      value: _selectedOption,
                      items: _options.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() => _selectedOption = newValue);
                        }
                      },
                    ),
                  ],
                ],
              ),
              if (_isRepeat && _selectedOption == "Weekly")
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Select Days", style: addStyle),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(
                          7,
                          (index) => GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDays[index] = !_selectedDays[index];
                              });
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: _selectedDays[index]
                                    ? Colors.blue
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _selectedDays[index]
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  _days[index],
                                  style: TextStyle(
                                    color: _selectedDays[index]
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Text("Color", style: addStyle),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _colorIndex = 1),
                    child: ColorCircle(
                      color: Colors.blue,
                      isSelected: _colorIndex == 1,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _colorIndex = 2),
                    child: ColorCircle(
                      color: Colors.yellow,
                      isSelected: _colorIndex == 2,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _colorIndex = 3),
                    child: ColorCircle(
                      color: Colors.red,
                      isSelected: _colorIndex == 3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateTask() {
    if (_titleController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a title');
      return;
    }

    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      int.parse(_startTime.split(':')[0]),
      int.parse(_startTime.split(':')[1].trim()),
    );

    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      int.parse(_endTime.split(':')[0]),
      int.parse(_endTime.split(':')[1].trim()),
    );

    final updatedTask = Task(
      id: widget.task.id,
      title: _titleController.text,
      description: _descriptionController.text,
      workspaceId: widget.task.workspaceId,
      createdBy: widget.task.createdBy,
      startTime: startDateTime,
      endTime: endDateTime,
      color: ['blue', 'yellow', 'red'][_colorIndex - 1],
      assignedTo: _selectedMembers,
      isRepeat: _isRepeat,
      repeatType: _isRepeat ? _selectedOption : '',
      repeatDays: _isRepeat && _selectedOption == 'Weekly'
          ? _selectedDays
              .asMap()
              .entries
              .where((e) => e.value)
              .map((e) => e.key + 1)
              .toList()
          : [],
      repeatUntil: _isRepeat ? _selectedDate.add(const Duration(days: 365)) : null,
      createdAt: widget.task.createdAt,
    );

    _taskController.updateTask(updatedTask);
  }

  _getDateFromUser() async {
    DateTime? pickerDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );
    if (pickerDate != null) {
      setState(() => _selectedDate = pickerDate);
    }
  }

  _getTimeFromUser(bool isStartTime) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(isStartTime ? _startTime.split(':')[0] : _endTime.split(':')[0]),
        minute: int.parse(isStartTime ? _startTime.split(':')[1].trim() : _endTime.split(':')[1].trim()),
      ),
    );

    if (pickedTime != null) {
      String formattedTime = pickedTime.format(context);
      setState(() {
        if (isStartTime) {
          _startTime = formattedTime;
        } else {
          _endTime = formattedTime;
        }
      });
    }
  }
}

class ColorCircle extends StatelessWidget {
  final Color color;
  final bool isSelected;

  const ColorCircle({
    Key? key,
    required this.color,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        radius: 14,
        backgroundColor: color,
        child: isSelected
            ? const Icon(Icons.done, color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}