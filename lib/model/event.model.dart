// ignore_for_file: camel_case_types


class event {
  final DateTime date;
  final String title;
  final String startTime;
  final String endTime;
  final String note;
  final int color;
  final String userUid;
  final String id;
  final String access;

  event(
      {required this.date,
      required this.id,
      required this.title,
      required this.startTime,
      required this.endTime,
      required this.note,
      required this.userUid,
      required this.color,
      required this.access
      //
      });
}
