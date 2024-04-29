import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:web_application/Models/event.dart';
import 'package:web_application/Models/event_data_source.dart';
import 'package:http/http.dart' as http;

import '../Models/custom_project.dart';
import '../Models/subtask.dart';
import '../my_colors.dart';
import '../utility.dart';

class CalendarPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _CalendarPageState();
  
}
class _CalendarPageState extends State<CalendarPage>{

  List<CustomProject> projects = [];
  List<List<SubTask>> childSubTasks = [];

  Future<void> GetProjects() async{
    final response = await http.post(Uri.http('127.0.0.1:1234','/web/getAllCreatorProjects'),headers: <String,String>{
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
      final response = await http.post(Uri.http('127.0.0.1:1234','/web/GetAllChildSubTasks'),headers: <String,String>{
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCalendar(
        timeSlotViewSettings: TimeSlotViewSettings(
          timeTextStyle:  TextStyle(
            color: Colors.red
          ),
          timeRulerSize: 0
        ),
        view: CalendarView.schedule,
        dataSource: EventDataSource(getEventInfo()),
        monthViewSettings: const MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
      ),
    );
  }

  List<Event> getEventInfo(){

    // final List<Event> meetings = <Event>[];
    // final DateTime today = DateTime.now();
    // final DateTime startTime = DateTime(today.year, today.month, today.day, 9);
    // final DateTime endTime = startTime.add(const Duration(hours: 2));
    // meetings.add(Event(
    //     'Conference', startTime, const Color(0xFF0F8644)));
    // return meetings;

    final List<Event> events = <Event>[];
    print("projects length: " + projects.length.toString());
    print("subtasks length: " + childSubTasks.length.toString());
    for(var a in projects){
      events.add(Event("Срок выполнения проекта: " + a.Title,DateTime.parse(a.EndDate.substring(0,10)),MyColors.fourthAccent));
    }
    for(var a in childSubTasks){
      print("iteration: " + a.length.toString());
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
    print("events length: " + events.length.toString());
    return events;
  }



}