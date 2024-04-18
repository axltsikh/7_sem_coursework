import 'dart:convert';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:http/http.dart' as http;
import 'package:oktoast/oktoast.dart';
import 'package:web_application/Models/subtask.dart';
import 'dart:html' as html;
import '../Models/custom_project.dart';
import '../my_colors.dart';
import 'single_project_page.dart';
import '../utility.dart';


class MainPage extends StatefulWidget{
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  _MainPageState(){
    GetProjects();
    html.document.body!
        .addEventListener('contextmenu', (event) => event.preventDefault());
  }

  List<CustomProject> projects = [];
  List<List<SubTask>> childSubTasks = [];
  String newEndDate = "";
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

  double getSubtaskPercentsForProgressBars(CustomProject project){
    try{
      List<SubTask> subTasksBuffer = [];
      for (int i = 0; i < childSubTasks.length; i++) {
        if (childSubTasks[i].any((element) => element.ProjectID == project.id)) {
          subTasksBuffer = childSubTasks[i];
        }
      }
      int buffer = subTasksBuffer.length;
      if(buffer==0){
        buffer=1;
      }
      double percents = subTasksBuffer
          .where((element) => element.isTotallyDone == true)
          .toList()
          .length / buffer;
      return percents*100;
    }
    catch(e){
      print("exc");
      return 0;
    }
  }
  double getDaysPercentsForProgressBar(CustomProject project){
    try{
      int alltime = DateTime
          .parse(project.EndDate)
          .difference(DateTime.parse(project.StartDate))
          .inDays;
      int timeEllapsed = DateTime.now().difference(DateTime.parse(project.StartDate)).inDays;
      double timeElapsedPercent = (timeEllapsed / alltime);
      if(timeElapsedPercent>1){
        return 100;
      }
      return timeElapsedPercent*100;
    }catch(e){
      print("exc");
      return 0;
    }
  }
  Color getSubTaskColorByPercents(double percents){
    try{
      if(percents<40){
        return Colors.red.shade300;
      }else if(percents<70){
        return Colors.yellow.shade300;
      }
      return Colors.green.shade300;
    }
    catch(e){
      print("exc");
      return Colors.white70;
    }
  }
  Color getDaysColorByPercents(double percents){
    try{
      if(percents<40){
        return Colors.green.shade300;
      }else if(percents<70){
        return Colors.yellow.shade300;
      }
      return Colors.red.shade300;
    }
    catch(e){
      print("exc");
      return Colors.white70;
    }
  }


  Future<void> updateProjectDate(CustomProject project)async{
    final response = await http.post(Uri.http('127.0.0.1:1234','/web/prolongProjectDate'),headers: <String,String>{
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(<String,String>{
      'projectID': project.id.toString(),
      'endDate': newEndDate.toString()
    }));
    if(response.statusCode==200){
      await GetProjects();
      await GetChildSubTasks();
      Navigator.pop(context);
    }else{

      showToast("Произошла ошибка");
    }
  }
  Future<void> endProject(CustomProject project)async{
    List<SubTask> subTasksBuffer = [];
    for (int i = 0; i < childSubTasks.length; i++) {
      if (childSubTasks[i].any((element) => element.ProjectID == project.id)) {
        subTasksBuffer = childSubTasks[i];
      }
    }
    if(subTasksBuffer.any((element) => element.isTotallyDone == false)){
      showToast("Все задачи проекта должны быть выполнены!");
      return;
    }
    final response = await http.post(Uri.http('127.0.0.1:1234','/web/endProject'),headers: <String,String>{
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(<String,String>{
      'projectID': project.id.toString(),
    }));
    if(response.statusCode==200){
      await GetProjects();
      await GetChildSubTasks();
    }else{
      showToast("Произошла ошибка!",position: ToastPosition.bottom,);
    }
  }
  Future<void> deleteProject(CustomProject project)async{
    final response = await http.delete(Uri.http('127.0.0.1:1234','/project/delete'),headers: <String,String>{
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(<String,String>{
      'id': project.id.toString(),
    }));
    if(response.statusCode==200){
      await GetProjects();
      await GetChildSubTasks();
    }else{
      showToast("Произошла ошибка!",position: ToastPosition.bottom,);
    }
  }

  Widget getTextWidget(int index){
    if(index==0 && projects[index].isDone == true && projects.length==1){
      return Container(
        margin: const EdgeInsets.only(left: 75),
        child: const Text("Завершенные проекты",style: TextStyle(fontSize: 25),),
      );
    }
    if(index == 0){
      return Container(
        margin: const EdgeInsets.only(left: 75),
        child: const Text("Текущие проекты",style: TextStyle(fontSize: 25),),
      );
    }else if(projects[index].isDone == true && projects[index-1].isDone == false){
      return Container(
        margin: const EdgeInsets.only(left: 75),
        child: const Text("Завершенные проекты",style: TextStyle(fontSize: 25),),
      );
    }
    return const Text("");
  }
  Future<void> setDate(int index)async{
    var a = await showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              contentPadding: const EdgeInsets.only(top: 10.0),
              content: Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
                    width: 300,
                    height: 412,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Выберите новую дату"),
                        const Divider(color: Colors.blue,),
                        DateRangePickerWidget(
                          doubleMonth: false,
                          initialDisplayedDate:DateTime.parse(projects[index].EndDate),
                          onDateRangeChanged: (dateRange){
                            setState(() {
                              newEndDate = dateRange!.end.toString().substring(0,10);
                            });
                          },
                        ),
                        CupertinoButton.filled(
                          onPressed: (){
                            updateProjectDate(projects[index]);
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: const Text("Сохранить изменения"),
                        )
                      ],
                    )
                ),
              )
          );
        }
    );
    print("prolong");
  }
  Widget inkWell(int index){
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleProjectPage(projects[index])));},
      child: SizedBox(
        height: 250,
        width: 500,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(projects[index].Title,style: const TextStyle(color: Colors.black,fontSize: 20))
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Container(
                      margin: const EdgeInsets.only(left: 25),
                      child: Text(projects[index].Description,style: const TextStyle(color: Colors.black))
                  )
                ],
              ),
            ),
            Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(projects[index].StartDate.substring(0,10)),
                        const Text("                                                          "),
                        Text(projects[index].EndDate.substring(0,10))
                      ],
                    ),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ContextMenuOverlay(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:Colors.white,
          title: Text("Проекты"),
        ),
        backgroundColor: MyColors.backgroundColor,
          body: ListView.builder(
            itemCount: projects.length,
            itemBuilder: (BuildContext context,int index){
              var project = projects[index];
              return ListTile(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleProjectPage(project)));
                },
                tileColor: Colors.white,
                title: Text(project.Title),
                subtitle: Text(project.Description + "\n" + "Статус проекта: " + (project.isDone ? "Завершен" : "Текущий")),
                trailing: PopupMenuButton<int>(
                  tooltip: "Дополнительные действия",
                  onSelected: (value){
                    if(value == 0){
                      setDate(index);
                    }else if(value ==1){
                      endProject(project);
                    }else{
                      deleteProject(project);
                    }
                  },
                  itemBuilder: (BuildContext context){
                    return <PopupMenuEntry<int>>[
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Text("Изменить дату завершения"),
                      ),
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Text("Завершить проект"),
                      ),
                      const PopupMenuItem<int>(
                        value: 2,
                        child: Text("Удалить проект"),
                      ),
                    ];
                  },
                )
              );
            },
          ),
      ),
    );
  }

}