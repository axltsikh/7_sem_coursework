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
import 'package:course_application/Utility/WidgetTemplates.dart';
import 'package:course_application/manyUsageTemplate/CheckBoxBuilder.dart';
import 'package:course_application/manyUsageTemplate/CupertinoButtonTemplate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../Models/SubTask.dart';
import '../Models/User.dart';
import '../Utility/Colors.dart';

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
      return ListTile(
        title: Text("Добавить участника"),
        onTap: () async {
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
        },
        leading: Icon(Icons.add,color: MyColors.firstAccent,),
      );
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
    return ListTile(
      leading: Icon(Icons.add,color: MyColors.firstAccent,),
      title: Text("Добавить задачу"),
      onTap: () async {
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
    );
  }
  Widget tasksList(){
    return Container(
      height: 550,
      child: Card(
        elevation: 0,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: parentSubTasks.length+1,
          itemBuilder: (BuildContext context, int mainTaskIndex) {
            if(mainTaskIndex == parentSubTasks.length){
              return addTaskButton();
            }
            return Column(
              children: [
                ListTile(
                  title: Text(parentSubTasks[mainTaskIndex].title,style: TextStyle(
                    color: MyColors.textColor
                  ),),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
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
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).length,
                  itemBuilder: (BuildContext context,int subTaskIndex){
                    return
                      Container(
                        width: 150,
                        child:  ListTile(
                          title: Text(childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).toList()[subTaskIndex].title),
                          subtitle: Text(childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).toList()[subTaskIndex].username),
                          trailing: CheckBoxBuilder(childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).toList()[subTaskIndex],projectCreator.id==Utility.user.id),
                        ),
                      );
                  },
                ),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                )
              ],
            );
          },
        ),
      ),
    );
  }
  Widget membersList(){
    return Container(
      height: 550,
      child: Card(
        elevation: 0,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: projectMembers.length+1,
          itemBuilder: (BuildContext context, int index) {
            if(index == projectMembers.length){
              return addMemberButton();
            }
            return ListTile(
              title: Text(projectMembers[index].username),
              leading: Icon(Icons.person,color: MyColors.firstAccent,),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 55),
        child: footerButton(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: WidgetTemplates.getAppBarWithReturnButton(project.Title, context),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 5,),
              Container(margin: const EdgeInsets.only(top: 25),),
              TabBar(
                indicatorColor: MyColors.firstAccent,
                  labelColor: MyColors.firstAccent,
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
                height: 550,
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