import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/Pages/create_project_page.dart';
import 'package:course_application/CustomModels/CustomProject.dart';
import 'package:course_application/Pages/single_project_page.dart';
import 'package:course_application/Pages/sync_dialog.dart';
import 'package:course_application/Utility/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../CustomModels/GetUserOrganisation.dart';
import '../Utility/colors.dart';

class ProjectsPage extends StatefulWidget{
  const ProjectsPage({super.key});
  @override
  State<StatefulWidget> createState() => _ProjectsPageState();
}
class _ProjectsPageState extends State<ProjectsPage> with TickerProviderStateMixin, WidgetsBindingObserver{
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
            return const AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(30))),
                contentPadding: EdgeInsets.only(top: 10.0),
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
    Future.delayed(const Duration(seconds: 3)).then((value)async{
      print("duration finished");
      await Utility.databaseHandler.GetAllData();
    });
  }
  Future<void> getOrganisation() async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      var org = await Utility.databaseHandler.getUserOrganisation();
      setState(() {
        Utility.getUserOrganisation = org;
      });
    }else{
      final String url = "http://${Utility.url}/profile/getUserOrganisation?id=${Utility.user.id}";
      final response = await http.get(Uri.parse(url));
      if(response.statusCode == 200){
        print(response.toString());
        Map<String,dynamic> bodyBuffer = jsonDecode(response.body);
        setState(() {
          Utility.getUserOrganisation = GetUserOrganisation.fromJson(bodyBuffer);
        });
      }
      else{
        setState(() {
          Utility.getUserOrganisation = GetUserOrganisation(-1, "Вы не состоите в организации", "", -1, -1);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    a?.cancel();
    super.dispose();
  }

  Widget getTextWidget(int index){
    if(index==0 && projects[index].isDone == true && projects.length==1){
      return Container(
        margin: const EdgeInsets.only(left: 75),
        child: const Text("Выполненные проекты",style: TextStyle(fontSize: 25),),
      );
    }
    if(index == 0){
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          margin: const EdgeInsets.only(left: 15),
          child: const Text("Текущие проекты",style: TextStyle(fontSize: 20),),
        ),
      );
    }else if(projects[index].isDone == true && projects[index-1].isDone == false){
      return Align(
        // alignment: AlignmentDirectional.,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: Colors.blue,),
            Container(
              margin: const EdgeInsets.only(left: 15),
              child: const Text("Завершенные проекты",style: TextStyle(fontSize: 20),),
            ),
          ],
        )
      );
    }
    return const Text("");
  }
  Widget getFloatingButton(){
    if(Utility.getUserOrganisation.id==-1){
      return const Text("");
    }else{
      return Container(
        margin: const EdgeInsets.only(bottom: 60,left: 0),
        child: FloatingActionButton(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
          onPressed: (){
            Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) => const CreateProjectPage())
            ).then((value){GetProjects();});
          },
          backgroundColor: MyColors.firstAccent,
          child: const Icon(Icons.add,color: Colors.white,),
        ),
      );
    }
  }
  List<CustomProject> projects = [];
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
        for (var element in bodyBuffer) {
          buffer.add(CustomProject.fromJson(element));
        }
        setState(() {
          projects = buffer.where((element) => element.isDone ==false).toList();
          projects += buffer.where((element) => element.isDone == true).toList();
        });
      }
    }
    firstinit=false;
  }

  Widget getAllProjects(){
    return RefreshIndicator(color: MyColors.firstAccent,child: Container(
      height: MediaQuery.of(context).size.height*0.7,
      padding: EdgeInsets.only(bottom: 15),
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
                        Icons.group,
                        color: MyColors.secondBackground,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    title: Text(project.Title),
                    subtitle: Text(project.Description),),
                ],
              );
            }
        ),
      ),
    ), onRefresh: GetProjects);
  }
  Widget getCurrentProjects(){
    return RefreshIndicator(child: SizedBox(
      height: MediaQuery.of(context).size.height*0.7,
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
                    trailing: const Icon(Icons.arrow_forward_ios),
                    title: Text(project.Title),
                    subtitle: Text(project.Description),),
                ],
              );
            }
        ),
      ),
    ),color: MyColors.firstAccent, onRefresh: GetProjects);
  }
  Widget getFinishedProjects(){
    return RefreshIndicator(color: MyColors.firstAccent,child: SizedBox(
      height: MediaQuery.of(context).size.height*0.7,
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
                    trailing: const Icon(Icons.arrow_forward_ios),
                    subtitle: Text(project.Description),),
                ],
              );
            }
        ),
      ),
    ), onRefresh: GetProjects);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      floatingActionButton: getFloatingButton(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(135),
        child: Container(
          margin: const EdgeInsets.only(top: 50),
          child: Column(
            children: [
              SizedBox(
                width: 410,
                height: 65,
                child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35)
                    ),
                    color: Colors.white,
                    child: const Column(
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
            children:[ Container(
              height: MediaQuery.of(context).size.height*0.7,
              margin: EdgeInsets.only(bottom: 25),
              // padding: EdgeInsets.only(bottom: 25),
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