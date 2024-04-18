import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/Pages/create_project_page.dart';
import 'package:course_application/CustomModels/CustomProject.dart';
import 'package:course_application/Pages/single_project_page.dart';
import 'package:course_application/Pages/sync_dialog.dart';
import 'package:course_application/Utility/utility.dart';
import 'package:course_application/Utility/widget_templates.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../CustomModels/GetUserOrganisation.dart';
import '../Utility/colors.dart';

class ProjectsPage extends StatefulWidget{
  ProjectsPage(){}
  @override
  State<StatefulWidget> createState() => _ProjectsPageState();
}
class _ProjectsPageState extends State<ProjectsPage> with TickerProviderStateMixin{
  StreamSubscription<ConnectivityResult>? a;
  late final TabController _tabController= TabController(length: 3, vsync: this);
  bool firstinit=true;
  _ProjectsPageState(){
    getOrganisation();
    getGlobalData();
    a=Connectivity().onConnectivityChanged.listen((ConnectivityResult event)async {
      if(event==ConnectivityResult.wifi || event==ConnectivityResult.mobile){
        if(!firstinit){
          var a = showDialog(context: context, builder: (BuildContext context){
            return AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(30))),
                contentPadding: const EdgeInsets.only(top: 10.0),
                content: SyncDialog()
            );
          }).then((value){
            GetProjects();
          });
        }
    }
    });
    GetProjects();
  }
  Future<void> getGlobalData()async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      return;
    }
    Future.delayed(Duration(seconds: 3)).then((value)async{
      print("duration finished");
      await Utility.databaseHandler.GetAllData();
    });
  }
  Future<void> getOrganisation() async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      var org = await Utility.databaseHandler.getUserOrganisation();
      setState(() {
        userOrganisation = org;
      });
    }else{
      final String url = "http://${Utility.url}/profile/getUserOrganisation?id=" + Utility.user.id.toString();
      final response = await http.get(Uri.parse(url));
      if(response.statusCode == 200){
        print(response.toString());
        Map<String,dynamic> bodyBuffer = jsonDecode(response.body);
        setState(() {
          userOrganisation = GetUserOrganisation.fromJson(bodyBuffer);
          Utility.getUserOrganisation = userOrganisation;
        });
      }
      else{
        setState(() {
          userOrganisation = GetUserOrganisation(-1, "Вы не состоите в организации", "", -1, -1);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }
  @override
  void didUpdateWidget(covariant ProjectsPage oldWidget) {
    print("update");
    GetProjects();
    super.didUpdateWidget(oldWidget);
  }
  @override
  void dispose() {
    print("cancel");
    a?.cancel();
    super.dispose();
  }
  Widget getTextWidget(int index){
    if(index==0 && projects[index].isDone == true && projects.length==1){
      return Container(
        margin: EdgeInsets.only(left: 75),
        child: const Text("Выполненные проекты",style: TextStyle(fontSize: 25),),
      );
    }
    if(index == 0){
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          margin: EdgeInsets.only(left: 15),
          child: Text("Текущие проекты",style: TextStyle(fontSize: 20),),
        ),
      );
    }else if(projects[index].isDone == true && projects[index-1].isDone == false){
      return Align(
        // alignment: AlignmentDirectional.,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(color: Colors.blue,),
            Container(
              margin: EdgeInsets.only(left: 15),
              child: Text("Завершенные проекты",style: TextStyle(fontSize: 20),),
            ),
          ],
        )
      );
    }
    return Text("");
  }
  Widget getFloatingButton(){
    if(userOrganisation.id==-1){
      return Text("");
    }else{
      return Container(
        margin: EdgeInsets.only(bottom: 60,left: 0),
        child: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
          onPressed: (){
            Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) => CreateProjectPage())
            ).then((value){GetProjects();});
          },
          backgroundColor: MyColors.firstAccent,
          child: Icon(Icons.add,color: Colors.white,),
        ),
      );
    }
  }
  List<CustomProject> projects = [];
  GetUserOrganisation userOrganisation = GetUserOrganisation(-1, "", "", 0, 0);
  Future<void> GetProjects() async{
    getOrganisation();
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      var buffer = await Utility.databaseHandler.getProjectsFromLocal();
      setState(() {
        projects = buffer.where((element) => element.isDone ==false).toList();
        projects += buffer.where((element) => element.isDone == true).toList();
      });
      return;
    }else{
      final String url = "http://${Utility.url}/project/getAllUserProjects?userID=${Utility.user.id}";
      final response = await http.get(Uri.parse(url));
      if(response.statusCode==200){
        projects.clear();
        List<dynamic> bodyBuffer = jsonDecode(response.body);
        List<CustomProject> buffer = [];
        bodyBuffer.forEach((element) {
          buffer.add(CustomProject.fromJson(element));
        });
        setState(() {
          projects = buffer.where((element) => element.isDone ==false).toList();
          projects += buffer.where((element) => element.isDone == true).toList();
        });
      }
    }
    firstinit=false;
  }

  Widget getAllProjects(){
    return SizedBox(
      height: 250,
      child: Card(
        color: MyColors.secondBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ListView.builder(
          shrinkWrap: true,
            itemCount: projects.length,
            itemBuilder:(BuildContext context, int index){
              CustomProject project = projects[index];
              return Column(
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.push(context, CupertinoPageRoute(builder: (builder) => SingleProjectPage(project)));
                    },
                    leading: CircleAvatar(
                      backgroundColor: MyColors.firstAccent,
                      child: Icon(
                        Icons.person,
                        color: MyColors.secondBackground,
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    title: Text(project.Title),
                    subtitle: Text(project.Description),),
                ],
              );
            }
        ),
      ),
    );
  }
  Widget getCurrentProjects(){
    return SizedBox(
      height: 250,
      child: Card(
        color: MyColors.secondBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: projects.where((element) => !element.isDone).toList().length,
            itemBuilder:(BuildContext context, int index){
              CustomProject project = projects.where((element) => !element.isDone).toList()[index];
              return Column(
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (builder) => SingleProjectPage(project)));
                    },
                    leading: CircleAvatar(
                      backgroundColor: MyColors.firstAccent,
                      child: Icon(
                        Icons.person,
                        color: MyColors.secondBackground,
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    title: Text(project.Title),
                    subtitle: Text(project.Description),),
                ],
              );
            }
        ),
      ),
    );
  }
  Widget getFinishedProjects(){
    return SizedBox(
      height: 250,
      child: Card(
        color: MyColors.secondBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: projects.where((element) => element.isDone).toList().length,
            itemBuilder:(BuildContext context, int index){
              CustomProject project = projects.where((element) => element.isDone).toList()[index];
              return Column(
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (builder) => SingleProjectPage(project)));
                    },
                    leading: CircleAvatar(
                      backgroundColor: MyColors.firstAccent,
                      child: Icon(
                        Icons.person,
                        color: MyColors.secondBackground,
                      ),
                    ),
                    title: Text(project.Title),
                    trailing: Icon(Icons.arrow_forward_ios),
                    subtitle: Text(project.Description),),
                ],
              );
            }
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      floatingActionButton: getFloatingButton(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(135),
        child: Container(
          margin: EdgeInsets.only(top: 50),
          child: Column(
            children: [
              Container(
                width: 410,
                height: 65,
                child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35)
                    ),
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Проекты",textAlign: TextAlign.center,style: TextStyle(
                            fontSize: 20
                        ),)
                      ],
                    )
                ),
              ),
              TabBar(
                dividerHeight: 0,
                  indicatorColor: MyColors.firstAccent,
                  controller: _tabController,
                  labelColor: MyColors.firstAccent,
                  tabs: const [
                    Tab(text: "Все",),
                    Tab(text: "Текущие",),
                    Tab(text: "Завершенные",)
                  ]),
            ],
          )
        ),
      ),
      body: RefreshIndicator(
        onRefresh: GetProjects,
        child: Padding(
          padding: const EdgeInsets.only(left:15,right: 15,top: 5,bottom: 25),
          child:Column(
            children:[ SizedBox(
              height: 600,
              child: TabBarView(
                controller: _tabController,
                children: [
                  getAllProjects(),
                  getCurrentProjects(),
                  getFinishedProjects()
                ],
              ),
            )]
          )
        ),
      )

    );
  }

}