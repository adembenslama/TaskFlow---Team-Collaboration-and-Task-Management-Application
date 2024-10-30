import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:manager/model/event.model.dart';

class EventController extends GetxController{
  
RxList eventList = [].obs;

Future initilaizeList() async {
  List<event> newList = [];
  await FirebaseFirestore.instance
      .collection("events")
      .get()
      .then((QuerySnapshot querySnapshot) {
    for (var doc in querySnapshot.docs) {
      newList.add(fromJsonEvent(doc));
    }
  });
  eventList.value = newList;
}
//add event  - delete - update - update status - put note -- 



event fromJsonEvent(QueryDocumentSnapshot json) => event(
    date: (json['date'] as Timestamp).toDate(),
    title: json['title'],
    startTime: json['start Time'],
    endTime: json['end Time'],
    note: json['note'],
    color: json['Color'],
    userUid: json['user'],
    id: json.id,
    access: json["access"]);

}