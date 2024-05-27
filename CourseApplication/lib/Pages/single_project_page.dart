import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/Pages/add_parent_task_dialog.dart';
import 'package:course_application/Pages/add_project_member_dialog.dart';
import 'package:course_application/Pages/add_subtask_dialog.dart';
import 'package:course_application/CustomModels/CustomProject.dart';
import 'package:course_application/CustomModels/CustomProjectMember.dart';
import 'package:course_application/CustomModels/SubTaskModel.dart';
import 'package:course_application/Utility/utility.dart';
import 'package:course_application/Utility/widget_templates.dart';
import 'package:course_application/widgets/checkbox_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../Models/subtask.dart';
import '../Models/user.dart';
import '../Utility/colors.dart';

class SingleProjectPage extends StatefulWidget{
  SingleProjectPage(this.project, {super.key});
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
    print("datetime: " + DateTime.timestamp().toString());
    print("datetime: " + DateTime.now().toString());
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
          print(childSubTasks[i].title);
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
      print("commiting changes");
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
    print(projectCreator.id);
    if (projectCreator.id == Utility.user.id) {
      print("im the creator");
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
    for (var element in projectMembersBuffer) {
      print(element.deleted);
      print(element.username);
    }
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
    String creatorUrl = "http://${Utility.url}/project/getProjectCreatorUserID?projectID=${project.id}";
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
    String url = "http://${Utility.url}/project/getAllProjectMembers?projectID=${project.id}";
    final response = await http.get(Uri.parse(url));
    List<dynamic> bodyBuffer = jsonDecode(response.body);
    for (var bodyBufferElement in bodyBuffer) {
      setState(() {
        projectMembers.add(CustomProjectMember.fromJson(bodyBufferElement));
      });
      for (var element in projectMembers) {
        print(element.deleted);
      }
      setState(() {
        projectMembers = projectMembers.where((element) => element.deleted==0).toList();
      });
    }
    print(projectMembers.length);
    String parenturl = "http://${Utility.url}/project/getProjectParentTasks?projectID=${project.id}";
    final secondResponse = await http.get(Uri.parse(parenturl));
    List<dynamic> parentTasksBuffer = jsonDecode(secondResponse.body);
    for (var element in parentTasksBuffer) {
      setState(() {
        parentSubTasks.add(SubTask.fromJson(element));
      });
    }
    final thirdResponse = await http.get(Uri.parse("http://${Utility.url}/project/getProjectChildTasks?projectID=${project.id}"));
    List<dynamic> childTasksBuffer = jsonDecode(thirdResponse.body);
    for (var element in childTasksBuffer) {
      print("childTasksBuffer iteration");
      setState(() {
        childSubTasks.add(SubTaskModel.fromJson(element));
        print("childLenthg: ${childSubTasks.length}");
        childSubTasksSnapshot.add(SubTaskModel.fromJson(element).isDone);
      });
    }
  }

  Widget addMemberButton(){
    if(project.isDone==true){
      return const Text("");
    }
    if(buttonFlag==false){
      return const Text("");
    }else{
      if (projectCreator.id != Utility.user.id) {
        return const Text("");
      }
      return ListTile(
        title: const Text("Добавить участника"),
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
      return const Text("");
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: MyColors.firstAccent
      ),
      child: IconButton(
        color: MyColors.firstAccent,
        onPressed: saveChanges,
        icon: const Icon(Icons.check,color: Colors.white,),
      ),
    );
  }
  Widget addTaskButton(){
    if(project.isDone==true){
      return const Text("");
    }
    return ListTile(
      leading: Icon(Icons.add,color: MyColors.firstAccent,),
      title: const Text("Добавить задачу"),
      onTap: () async {
        var a = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: MyColors.backgroundColor,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(15))),
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
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(topRight: Radius.circular(25),topLeft: Radius.circular(25))
      ),
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
            bool currentTileExpanded = false;
            return Column(
              children: [
                ExpansionTile(
                  backgroundColor: MyColors.firstAccent,
                  collapsedBackgroundColor: MyColors.firstAccent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15)),
                  ),
                  collapsedShape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15)),
                  ),
                  title: Text(parentSubTasks[mainTaskIndex].title,style: const TextStyle(
                      color: Colors.white
                  ),),
                  onExpansionChanged: (bool expanded) {
                    setState(() {
                      currentTileExpanded = !currentTileExpanded;
                    });
                  },
                  trailing: project.isDone ? Icon(
                    color: Colors.white,
                    currentTileExpanded
                        ? Icons.arrow_drop_down_circle
                        : Icons.arrow_drop_down,
                  ) :SizedBox(
                    width: 75,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add,color: Colors.white,),
                          onPressed: () async{
                            var a = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: MyColors.secondBackground,
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
                        Icon(
                          color: Colors.white,
                          currentTileExpanded
                              ? Icons.arrow_drop_down_circle
                              : Icons.arrow_drop_down,
                        ),
                      ],
                    ),
                  ),
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      child: SizedBox(
                        height: 200,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).length,
                          itemBuilder: (BuildContext context,int subTaskIndex){
                            return
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                width: 150,
                                child:  ListTile(
                                  tileColor: MyColors.secondBackground,
                                  title: Text(childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).toList()[subTaskIndex].title,style: const TextStyle(
                                      fontSize: 18,fontWeight: FontWeight.w400
                                  ),),
                                  subtitle: Text("Исполнитель: ${childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).toList()[subTaskIndex].username}\nДедлайн: ${Utility.getDate(childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).toList()[subTaskIndex].deadLine)}",style: const TextStyle(
                                      fontSize: 15,fontWeight: FontWeight.w400
                                  )),
                                  trailing: SizedBox(
                                    height: double.infinity,
                                    child: CheckBoxBuilder(childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).toList()[subTaskIndex],projectCreator.id==Utility.user.id),
                                  ),
                                  isThreeLine: true,
                                ),
                              );
                          },
                        ),
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 5,)
              ],
            );
          },
        ),
      ),
    );
  }
  Widget membersList(){
    return SizedBox(
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
        margin: const EdgeInsets.only(bottom: 55),
        child: footerButton(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
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
                  tabs: const [
                    SizedBox(width: 150,child:Tab(
                      text: "Задачи",
                    ),),
                    SizedBox(
                      width: 150,
                      child: Tab(
                        text: "Участники",
                      ),
                    )
                  ]),
              const SizedBox(height: 5,),
              SizedBox(
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