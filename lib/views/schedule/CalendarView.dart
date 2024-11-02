import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manager/theme.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDay;
  DateTime _selectedDate = DateTime.now();
  CalendarFormat format = CalendarFormat.month;
  late DateTime _selectedDay;

  // Sample events for demonstration, including a multi-day event.
  final Map<DateTime, List<Event>> _events = {
    DateTime(2024, 11, 3): [Event('aa')],
    DateTime(2024, 11, 8): [Event('bb')],
    DateTime(2024, 11, 15): [Event('cc')],
    DateTime(2024, 11, 20): [Event('gtt')],
    DateTime(2024, 11, 25): [Event('tt')],
    DateTime(2024, 11, 10): [
      Event('desgning', isMultiDay: true, end: DateTime(2024, 11, 14))
    ],
  };

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime(2024, 11, 1);
    _selectedDay = _focusedDay;
  }

  List<Event> _getEventsForDay(DateTime day) {
    List<Event> events = [];
    _events.forEach((key, value) {
      if (isSameDay(key, day) ||
          value.any((e) =>
              e.isMultiDay &&
              e.end != null &&
              day.isAfter(key) &&
              day.isBefore(e.end!))) {
        events.addAll(value);
      }
    });
    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        title: Text('Calendar', style: boldTitle,),
        centerTitle: true,
        backgroundColor: backColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
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
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDay), // Use _selectedDay here
                  firstDay: DateTime.utc(2022, 1, 1),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: _focusedDay,
                  calendarFormat: format,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _selectedDate = selectedDay; // Update _selectedDate here
                    });
                  },
                  availableGestures: AvailableGestures.all,
                  eventLoader: _getEventsForDay,
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
                      shape: BoxShape.rectangle,
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
            child: ListView.builder(
              itemCount: _getEventsForDay(_selectedDay).length,
              itemBuilder: (context, index) {
                final event = _getEventsForDay(_selectedDay)[index];
                return ListTile(
                  title: Text(event.title),
                  subtitle:
                      event.isMultiDay ? const Text('Multi-day event') : null,
                  trailing:
                      event.isMultiDay ? const Icon(Icons.date_range) : null,
                );
              },
            ),
          ),
        ],
      ),
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
