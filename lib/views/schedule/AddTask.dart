import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:manager/controllers/AuthController.dart';
import 'package:manager/theme.dart';
import 'package:intl/intl.dart';
import 'package:manager/views/widgets/MembersWidget.dart';
import 'package:manager/views/widgets/MyInputfield.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<bool> _selectedDays = List.generate(7, (index) => false);

  // List of abbreviated day names
  final List<String> _days = [ "M", "T", "W", "T", "F", "S","S",];
  final List<String> _selectedMembers = [];
  bool _isRepeat = false;
  String _endTime = "12:00";
  String _startTime = DateFormat("HH:mm ").format(DateTime.now()).toString();
  int _colorIndex = 1;
  String _selectedOption = "Weekly"; // Default selected value

  int _iconIndex = 1;
  final List<String> _options = ["Daily", "Weekly", "Monthly"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: const BackButton(),
          title: Row(
            children: [
              const Spacer(),
              ElevatedButton(
                  onPressed: () {}, child: Text("Save", style: buttonText))
            ],
          )),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(88, 0, 140, 255),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                            child: Icon(
                              Iconsax.building,
                              size: 40,
                              color: royalBlue,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 70, left: 60),
                          child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15)),
                              child: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Iconsax.edit_2,
                                    color: Colors.grey,
                                    size: 15,
                                  ))),
                        )
                      ],
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: MyInputField(
                        title: "Title",
                        hint: "enter the title",
                        controller: _titleController,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
               MyInputField(
                        title: "Description",
                        hint: "enter the title",
                        controller: _descriptionController,
                      ),
                       const SizedBox(
                height: 15,
              ),
//////////////////////////////////////////////////////////////////////////
              // Text(
              //   "Team Members",
              //   style: addStyle,
              // ),
              // const SizedBox(height: 10,),
              // MembersWidget(
              //   users: [
              //     AuthController.instance.userData.value,
              //     AuthController.instance.userData.value,
              //     AuthController.instance.userData.value,
              //     AuthController.instance.userData.value,
              //     AuthController.instance.userData.value,
              //     AuthController.instance.userData.value,
              //     AuthController.instance.userData.value,
              //     AuthController.instance.userData.value,
              //     AuthController.instance.userData.value,
              //     AuthController.instance.userData.value,
              //     AuthController.instance.userData.value,
              //     AuthController.instance.userData.value,
              //     AuthController.instance.userData.value,
              //   ],
              //   stacked: false,
              //   canAdd: false,
              // ),
              //               const SizedBox(height: 10,),

               Row(
                children: [
                  Text(
                    "Repeat",
                    style: addStyle,
                  ),
                  const Spacer(),
                _isRepeat ?  DropdownButton<String>(
                      value: _selectedOption,
                      icon: const Icon(Icons.arrow_drop_down_rounded),
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      underline: Container(
                        height: 2,
                        color: royalBlue,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedOption = newValue!;
                        });
                      },
                      items: _options
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList()) : const SizedBox(),
                      const SizedBox(width: 10,) ,
                  Switch(
                      activeColor: royalBlue,
                      value: _isRepeat,
                      onChanged: (value) {
                        setState(() {
                          _isRepeat = value;
                        });
                      })
                ],
              ),

               (!_isRepeat || _selectedOption=="Monthly") ? MyInputField(
            
                readOnly: true,
                title: "Date",
                hint: DateFormat.yMd().format(_selectedDate),
                widget: IconButton(
                  icon: const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    _getDateFromUser();
                  },
                ),
              ) : SizedBox(),
            
              const SizedBox(
                height: 10,
              ),
             
              const SizedBox(height: 16),
              (_isRepeat && _selectedOption == "Weekly")
                  ? Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                "Days",
                style: addStyle,
              ),
              const SizedBox(height: 15,),
                      Center(
                          child: ToggleButtons(
                            isSelected: _selectedDays,
                            onPressed: (int index) {
                              setState(() {
                                _selectedDays[index] = !_selectedDays[index];
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            selectedColor: Colors.white,
                            fillColor: royalBlue,
                            color: Colors.grey,
                            selectedBorderColor: royalBlue,
                            borderColor: Colors.grey,
                            children: _days.map((day) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  day,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  )
                  : const SizedBox(),
                    Row(
                children: [
                  Expanded(
                    child: MyInputField(
                      hint: _startTime,
                      readOnly: true,
                      title: "Start Time",
                      widget: IconButton(
                        icon: const Icon(
                          Icons.access_time_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          _getTimeFromUser(true);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: MyInputField(
                      hint: _endTime,
                      title: "End Time ",
                      readOnly: true,
                      widget: IconButton(
                        icon: const Icon(
                          Icons.access_time_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          _getTimeFromUser(false);
                        },
                      ),
                    ),
                  ),
                ],
              ),
                const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(" Color",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    Wrap(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _colorIndex = 1;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.blue,
                              child: _colorIndex == 1
                                  ? const Icon(
                                      Icons.done,
                                      color: Colors.white,
                                    )
                                  : Container(),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _colorIndex = 2;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.yellow,
                              child: _colorIndex == 2
                                  ? const Icon(
                                      Icons.done,
                                      color: Colors.white,
                                    )
                                  : Container(),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _colorIndex = 3;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.red,
                              child: _colorIndex == 3
                                  ? const Icon(
                                      Icons.done,
                                      color: Colors.white,
                                    )
                                  : Container(),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  _getDateFromUser() async {
    // ignore: unused_local_variable,
    DateTime? _pickerDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2035));
    if (_pickerDate != null) {
      setState(() {
        _selectedDate = _pickerDate;
      });
    }
  }

  _showTimePicker() async {
    return await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
            hour: int.parse(_startTime.split(":")[0]),
            minute: int.parse(_startTime.split(":")[1][1])),
        initialEntryMode: TimePickerEntryMode.input);
  }

  _getTimeFromUser(bool isStartTime) async {
    var _pickedTime = await _showTimePicker();
    if (_pickedTime == null) {
      print("nonononononononono");
    } else if (isStartTime == true) {
      String _formattedTime = _pickedTime.format(context);

      setState(() {
        _startTime = _formattedTime;
      });
    } else {
      String _formattedTime = _pickedTime.format(context);

      setState(() {
        _endTime = _formattedTime;
      });
    }
  }
}
