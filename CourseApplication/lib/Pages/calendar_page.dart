import 'dart:convert';
import 'package:course_application/Utility/widget_templates.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:http/http.dart' as http;
import '../CustomModels/CustomProject.dart';
import '../Models/event.dart';
import '../Models/event_data_source.dart';
import '../Models/subtask.dart';
import '../Utility/colors.dart';
import '../Utility/utility.dart';


class CalendarPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _CalendarPageState();

}
class _CalendarPageState extends State<CalendarPage>{

  List<CustomProject> projects = [];
  List<List<SubTask>> childSubTasks = [];

  Future<void> GetProjects() async{
    final response = await http.post(Uri.http('${Utility.url}','/web/getAllCreatorProjects'),headers: <String,String>{
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(<String,String>{
      'userID': Utility.user.id.toString(),
    }));
    if(response.statusCode==200){
      projects.clear();
      List<dynamic> bodyBuffer = jsonDecode(response.body);
      List<CustomProject> buffer = [];
      for (var element in bodyBuffer) {
        buffer.add(CustomProject.fromJson(element));
      }
      setState(() {
        projects = buffer.where((element) => element.isDone ==false).toList();
        projects += buffer.where((element) => element.isDone == true).toList();
      });
      await GetChildSubTasks();
    }else{
      print("Projects error");
    }
  }
  Future<void> GetChildSubTasks() async{
    projects.forEach((element) async {
      final response = await http.post(Uri.http('${Utility.url}','/web/GetAllChildSubTasks'),headers: <String,String>{
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json;charset=UTF-8',
      },body: jsonEncode(<String,String>{
        'projectID': element.id.toString(),
      }));
      if(response.statusCode==200){
        print(response.body);
        List<dynamic> bodyBuffer = jsonDecode(response.body);
        List<SubTask> buffer = [];
        for (var element in bodyBuffer) {
          buffer.add(SubTask.fromJson(element));
        }
        setState(() {
          childSubTasks.add(buffer);
        });
      }else{
        print("ChildSubTasks error");
      }
    });
  }
  CalendarView currentView = CalendarView.schedule;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize()async{
    projects.clear();
    childSubTasks.clear();
    await GetProjects();
    await GetChildSubTasks();
    setState(() {
      getEventInfo();
    });
  }
  bool isa = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: Container(
          margin: EdgeInsets.only(top: 50),
          width: 324,
          height: 66,
          child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35)
              ),
              color: Colors.white,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Календарь",textAlign: TextAlign.center,style: TextStyle(
                      fontSize: 20
                  ),),
                ],
              )
          ),
        ),
      ),
      body: SfCalendar(
        backgroundColor: MyColors.backgroundColor,
        todayHighlightColor: MyColors.firstAccent,
        view: CalendarView.schedule,
        dataSource: EventDataSource(getEventInfo()),
        monthViewSettings: const MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
      ),
    );
  }

  List<Event> getEventInfo(){
    final List<Event> events = <Event>[];
    for(var a in projects){
      events.add(Event("Срок выполнения проекта: " + a.Title,DateTime.parse(a.EndDate.substring(0,10)),MyColors.fourthAccent));
    }
    for(var a in childSubTasks){
      for(var b in a){
        if(!events.any((element) => element.eventName.contains(b.title))){
          if(b.isTotallyDone){
            events.add(Event("Выполнена задача: " + b.title,DateTime.parse(b.completionDate.toString().substring(0,10)),MyColors.greenColor));
          }else if(b.isDone){
            events.add(Event("Предложено к изменению: " + b.title,DateTime.parse(b.completionDate.toString().substring(0,10)),Colors.yellow.shade100));
          }else{
            events.add(Event("Срок выполнения задачи: " + b.title,DateTime.parse(b.deadLine.substring(0,10)),MyColors.fourthAccent));
          }
        }
      }
    }
    return events;
  }



}