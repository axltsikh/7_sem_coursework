import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/Pages/AddParentTaskDialog.dart';
import 'package:course_application/Pages/AddProjectMemberDialog.dart';
import 'package:course_application/Pages/AddSubTaskDialog.dart';
import 'package:course_application/CustomModels/CustomProject.dart';
import 'package:course_application/CustomModels/CustomProjectMember.dart';
import 'package:course_application/CustomModels/SubTaskModel.dart';
import 'package:course_application/Utility/Utility.dart';
import 'package:course_application/manyUsageTemplate/CheckBoxBuilder.dart';
import 'package:course_application/manyUsageTemplate/CupertinoButtonTemplate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../Models/SubTask.dart';
import '../Models/User.dart';

class SingleProjectPage extends StatefulWidget{
  SingleProjectPage(this.project, {super.key}){}
  CustomProject project;
  List<SubTask> parentSubTasks = [];
  @override
  State<StatefulWidget> createState() => _SingleProjectState(project);
}
class _SingleProjectState extends State<SingleProjectPage> with TickerProviderStateMixin{
  StreamSubscription<ConnectivityResult>? a;
  bool firstinit=true;
  _SingleProjectState(this.project){
    InitializeProject();
  }
  @override
  void initState() {
    super.initState();
    tabController = TabController(
        length: 2,
        vsync: this
    );
  }
  //region variables
  CustomProject project;
  List<CustomProjectMember> projectMembers = [];
  List<SubTask> parentSubTasks = [];
  List<SubTaskModel> childSubTasks = [];
  List<bool> childSubTasksSnapshot = [];
  User projectCreator = User(0,"","");
  String ButtonText = "";
  bool buttonFlag=true;
  late TabController tabController;
  //endregion

  Future<void> InitializeProject() async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      projectMembers.clear();
      parentSubTasks.clear();
      childSubTasks.clear();
      childSubTasksSnapshot.clear();
      projectMembers.clear();
    });
    if(connectivityResult == ConnectivityResult.none){
      print("local");
      buttonFlag=false;
      await localInitialization();
    }else {
      print("global");
      await globalInitialization().then((value){
      });
    }
  }
  Future<void> addProjectMember(CustomProjectMember member) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      Utility.databaseHandler.addProjectMembers([member], project.id.toString());
      InitializeProject();
    }else{
      final String url = "http://${Utility.url}/project/addProjectMember";
      final response = await http.post(Uri.parse(url), headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
      }, body: jsonEncode(<String, String>{
        'organisationMemberID': member.organisationID.toString(),
        'projectID': project.id.toString(),
      }));
      if (response.statusCode == 200) {
        InitializeProject();
      } else {
        print("Ошибка");
      }
    }
  }
  Future<void> addParentSubTask(SubTask subtask) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      Utility.databaseHandler.addParentSubTask(subtask);
      InitializeProject();
    }else{
      final String url = "http://${Utility.url}/project/addParentSubTask";
      final response = await http.post(
          Uri.parse(url), headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
      }, body: jsonEncode(subtask));
      if (response.statusCode == 200) {
        InitializeProject();
      } else {
        print("asd");
      }
    }

  }
  Future<void> saveChanges()async{
    if(projectCreator.id==Utility.user.id){
      commitChanges();
    }else{
      List<SubTaskModel> buffer = [];
      for(int i =0;i<childSubTasks.length;i++){
        if(childSubTasks[i].isDone!=childSubTasksSnapshot[i]){
          buffer.add(childSubTasks[i]);
        }
      }
      if(buffer.isEmpty){
        Fluttertoast.showToast(msg: "Нет никаких изменений!");
      }else{
        await offerChanges(buffer);
      }
    }
  }
  Future<void> offerChanges(List<SubTaskModel> buffer) async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      Utility.databaseHandler.offerChanges(buffer);
      InitializeProject();
    }else{
      final String url = "http://${Utility.url}/project/offerChanges";
      final response = await http.post(Uri.parse(url),headers: <String,String>{
        'Content-Type': 'application/json;charset=UTF-8',
      },body: jsonEncode(buffer));
      if(response.statusCode==200){
        InitializeProject();
      }else{
        Fluttertoast.showToast(msg: "Произошла ошибка");
      }
    }
  }
  Future<void> commitChanges() async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      Utility.databaseHandler.commitChanges(childSubTasks.where((element) => element.isTotallyDone==false).toList());
      InitializeProject();
    }else{
      final String url = "http://${Utility.url}/project/commitChanges";
      final response = await http.post(Uri.parse(url),headers: <String,String>{
        'Content-Type': 'application/json;charset=UTF-8',
      },body: jsonEncode(childSubTasks.where((element) => element.isTotallyDone==false).toList()));
      if(response.statusCode==200){
        InitializeProject();
      }else{
        Fluttertoast.showToast(msg: "Произошла ошибка");
      }
    }

  }
  Future<void> localInitialization() async {
    print("Local db init question");
    var creatorBuffer = await Utility.databaseHandler.getProjectCreatorUserID(project.id);
    for (var element in creatorBuffer) {
      projectCreator = element;
    }
    if (projectCreator.id == Utility.user.id) {
      setState(() {
        ButtonText = "Сохранить изменения";
      });
    }
    else {
      setState(() {
        ButtonText = "Предложить изменения";
      });
    }
    var projectMembersBuffer = await Utility.databaseHandler.getAllProjectMembers(project.id);
    projectMembersBuffer.forEach((element) {
      print(element.deleted);
      print(element.username);
    });
    setState(() {
      projectMembers = projectMembersBuffer.where((element) => element.deleted==0).toList();
    });
    var parentSubTasksBuffer = await Utility.databaseHandler.getProjectParentTasks(project.id);
    setState(() {
      parentSubTasks = parentSubTasksBuffer;
    });
    var childSubTasksBuffer = await Utility.databaseHandler.getProjectChildTasks(project.id);
    setState(() {
      childSubTasks = childSubTasksBuffer;
      for(var a in childSubTasksBuffer){
        childSubTasksSnapshot.add(a.isDone);
      }
    });
  }
  Future<void> globalInitialization() async{
    String creatorUrl = "http://${Utility.url}/project/getProjectCreatorUserID?projectID=" + project.id.toString();
    final fourthReponse = await http.get(Uri.parse(creatorUrl));
    List<dynamic> creatorBuffer = jsonDecode(fourthReponse.body);
    for (var element in creatorBuffer) {
      projectCreator = User.fromJson(element);
    }
    if (projectCreator.id == Utility.user.id) {
      setState(() {
        ButtonText = "Сохранить изменения";
      });
    }
    else {
      setState(() {
        ButtonText = "Предложить изменения";
      });
    }
    String url = "http://${Utility.url}/project/getAllProjectMembers?projectID=" + project.id.toString();
    final response = await http.get(Uri.parse(url));
    List<dynamic> bodyBuffer = jsonDecode(response.body);
    bodyBuffer.forEach((bodyBufferElement) {
      setState(() {
        projectMembers.add(CustomProjectMember.fromJson(bodyBufferElement));
      });
      projectMembers.forEach((element) {
        print(element.deleted);
      });
      setState(() {
        projectMembers = projectMembers.where((element) => element.deleted==0).toList();
      });
    });
    print(projectMembers.length);
    String parenturl = "http://${Utility.url}/project/getProjectParentTasks?projectID=" + project.id.toString();
    final secondResponse = await http.get(Uri.parse(parenturl));
    List<dynamic> parentTasksBuffer = jsonDecode(secondResponse.body);
    parentTasksBuffer.forEach((element) {
      setState(() {
        parentSubTasks.add(SubTask.fromJson(element));
      });
    });
    final thirdResponse = await http.get(Uri.parse("http://${Utility.url}/project/getProjectChildTasks?projectID=" + project.id.toString()));
    List<dynamic> childTasksBuffer = jsonDecode(thirdResponse.body);
    for (var element in childTasksBuffer) {
      print("childTasksBuffer iteration");
      setState(() {
        childSubTasks.add(SubTaskModel.fromJson(element));
        print("childLenthg: " + childSubTasks.length.toString());
        childSubTasksSnapshot.add(SubTaskModel.fromJson(element).isDone);
      });
    }
  }

  Widget addMemberButton(){
    if(project.isDone==true){
      return Text("");
    }
    if(buttonFlag==false){
      return Text("");
    }else{
      if (projectCreator.id != Utility.user.id) {
        return Text("");
      }
      return CupertinoButton.filled(
        borderRadius: BorderRadius.circular(15),
        padding: EdgeInsets.fromLTRB(20,0,20,0),
        child: Text(
          "Добавить участника", style: TextStyle(fontSize: 15),textAlign: TextAlign.center,
        ),
        onPressed: () async {
          var a = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(30))),
                  contentPadding: const EdgeInsets.only(top: 10.0),
                  content: AddProjectMemberDialog(projectMembers),
                );
              }
          );
          if (a != null) {
            addProjectMember(a);
          }
        });
      return CupertinoButtonTemplate(
          "Добавить\nучастника", () async {
        var a = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(30))),
                contentPadding: const EdgeInsets.only(top: 10.0),
                content: AddProjectMemberDialog(projectMembers),
              );
            }
        );
        if (a != null) {
          addProjectMember(a);
        }
      });
    }

  }
  Widget footerButton(){
    if(project.isDone==true){
      return Text("");
    }
    return CupertinoButton.filled(
        padding: EdgeInsets.fromLTRB(20,0,20,0),
        child: Text(ButtonText),
        onPressed: saveChanges,
        borderRadius: BorderRadius.circular(15)
    );
  }
  Widget addTaskButton(){
    if(project.isDone==true){
      return Text("");
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 150
      ),
      // width: 150,
      child: CupertinoButton.filled(
          borderRadius: BorderRadius.circular(15),
          padding: EdgeInsets.fromLTRB(20,0,20,0),
          child: Text(
            "Добавить задачу", style: TextStyle(fontSize: 15),textAlign: TextAlign.center,
          ),

          onPressed: () async {
            var a = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(30))),
                    contentPadding: const EdgeInsets.only(top: 10.0),
                    content: AddParentTaskDialog(project),
                  );
                }
            );
            if (a != null) {
              addParentSubTask(a);
            }
          },

      ),
    );
  }
  Widget tasksList(){
    return ListView.builder(
      shrinkWrap: true,
      itemCount: parentSubTasks.length+1,
      itemBuilder: (BuildContext context, int mainTaskIndex) {
        if(mainTaskIndex == parentSubTasks.length){
          return addTaskButton();
        }
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                  elevation: 7,
                  shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.blue,
                      ),
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                        minHeight: 50,
                      maxWidth: 300
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 15,),
                            Text(parentSubTasks[mainTaskIndex].title),
                          ],
                        ),
                        IconButton(
                          onPressed: () async{
                            var a = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15))),
                                    contentPadding: const EdgeInsets.only(top: 10.0),
                                    content: AddSubTaskDialog(project,projectMembers,parentSubTasks[mainTaskIndex].id),
                                  );
                                }
                            );
                            if (a != null) {
                              if(a==true){
                                InitializeProject();
                              }
                            }
                          },
                          icon: const Icon(Icons.add),
                        )
                      ],
                    ),
                  )
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).length,
                itemBuilder: (BuildContext context,
                    int subTaskIndex) {
                  return Row(
                    children: [
                      Card(
                          shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                color: Colors.blue,
                              ),
                              borderRadius: BorderRadius
                                  .circular(10)
                          ),
                          elevation: 7,
                          child: Align(
                            alignment: Alignment.center,
                            child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                    minHeight: 25,
                                  minWidth: 150,
                                  maxWidth: 150
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).toList()[subTaskIndex].title),
                                )
                            ),
                          )
                      ),
                      Card(
                          elevation: 7,
                          shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                color: Colors.blue,
                              ),
                              borderRadius: BorderRadius
                                  .circular(10)
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                                minHeight: 35,
                                minWidth: 100,
                              maxWidth: 100
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).toList()[subTaskIndex].username),
                            ),
                          )
                      ),
                      CheckBoxBuilder(childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).toList()[subTaskIndex],projectCreator.id==Utility.user.id),
                    ],
                  );
                },
              )
            ]
        );
      },
    );
  }
  Widget membersList(){
    return ListView.builder(
      shrinkWrap: true,
      itemCount: projectMembers.length+1,
      itemBuilder: (BuildContext context, int index) {
        if(index == projectMembers.length){
          return addMemberButton();
        }
        return ConstrainedBox(
          constraints: const BoxConstraints(
              minHeight: 40,
              maxWidth: 100
          ),
          child: Card(
            elevation: 7,
            shape: RoundedRectangleBorder(
                side: const BorderSide(
                  color: Colors.blue,
                ),
                borderRadius: BorderRadius.circular(10)
            ),
            child: Align(
              alignment: Alignment.center,
              child: Text(projectMembers[index].username,style: TextStyle(fontSize:17),),

            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 55),
        child: footerButton(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        title: Text(project.Title ?? ""),
        actions: [
          IconButton(onPressed: InitializeProject, icon: Icon(Icons.refresh))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.blue,
                    ),
                    borderRadius: BorderRadius.circular(20)
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      minHeight: 50,
                      minWidth: 150
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(project.Title),
                  ),
                ),

              ),
              Container(height: 5,),
              Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.blue,
                      ),
                      borderRadius: BorderRadius.circular(40)
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                        minHeight: 150
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: 250,
                          child: Text(project.Description),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(project.StartDate.substring(0, 10),
                                style: const TextStyle(color: Colors.black)),
                            const Text(
                                "                       "),
                            Text(project.EndDate.substring(0, 10),
                                style: const TextStyle(color: Colors.black))
                          ],
                        ),
                      ],
                    ),
                  )
              ),
              Container(margin: const EdgeInsets.only(top: 25),),
              TabBar(
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.black,
                  controller: tabController,
                  tabs: [
                    Container(width: 150,child:Tab(
                      text: "Задачи",
                    ),),
                    Container(
                      width: 150,
                      child: Tab(
                        text: "Участники",
                      ),
                    )
                  ]),
              SizedBox(height: 5,),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 300,
                child: TabBarView(
                  controller: tabController,
                  children: [
                    tasksList(),
                    membersList(),
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }

  }