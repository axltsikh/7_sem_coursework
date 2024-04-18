import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../Models/bar_chart_data.dart';
import '../Models/chart_data.dart';
import '../Models/custom_project.dart';
import '../Models/custom_project_member.dart';
import '../Models/subtask.dart';
import '../Models/subtask_model.dart';
import '../Models/user.dart';
import '../my_colors.dart';
import '../utility.dart';
import "package:collection/collection.dart";

class SingleProjectPage extends StatefulWidget{
  SingleProjectPage(this.project, {super.key});
  CustomProject project;
  List<SubTask> parentSubTasks = [];
  @override
  State<StatefulWidget> createState() => _SingleProjectState(project);
}
class _SingleProjectState extends State<SingleProjectPage>{


  _SingleProjectState(this.project){
    InitializeProject();
  }
  CustomProject project;
  List<CustomProjectMember> projectMembers = [];
  List<SubTask> parentSubTasks = [];
  List<SubTaskModel> childSubTasks = [];
  List<SubTaskModel> childSubTasksSnapshot = [];
  User projectCreator = User(0,"","");
  String ButtonText = "";
  double getDaysPercentsForProgressBar( ){

    try{
      int alltime = DateTime
          .parse(project.EndDate)
          .difference(DateTime.parse(project.StartDate))
          .inDays;
      int timeEllapsed = DateTime.now().difference(DateTime.parse(project.StartDate)).inDays;
      double timeElapsedPercent = (timeEllapsed / alltime);
      if(timeElapsedPercent>1){
        return 100;
      }else if(timeElapsedPercent < 0){
        return 0;
      }
      return timeElapsedPercent*100;
    }catch(e){
      print("exc");
      return 100;
    }
  }
  double getSubtaskPercentsForProgressBars(){
    if(childSubTasks.isEmpty){
      return 1;
    }
    try{
      double percents = childSubTasks
          .where((element) => element.isTotallyDone == true)
          .toList()
          .length / childSubTasks.length;
      return percents*100;
    }
    catch(e){
      print("exc");
      return 100;
    }
  }
  Future<void> InitializeProject() async{
      projectMembers.clear();
      parentSubTasks.clear();
      childSubTasks.clear();
      childSubTasksSnapshot.clear();
    await globalInitialization();
    print(project.StartDate);
    print(project.EndDate);
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
    String url = "http://${Utility.url}/web/getAllProjectMembersWeb?projectID=${project.id}";
    final response = await http.get(Uri.parse(url));
    List<dynamic> bodyBuffer = jsonDecode(response.body);
    for (var bodyBufferElement in bodyBuffer) {
      setState(() {
        projectMembers.add(CustomProjectMember.fromJson(bodyBufferElement));
      });
    }
    projectMembers = projectMembers.where((element) => element.deleted == 0).toList();
    // projectMembers = projectMembers.where((element) => element.username != Utility.user.Username).toList();
    print(projectMembers.length);
    String parenturl = "http://${Utility.url}/project/getProjectParentTasks?projectID=${project.id}";
    final secondResponse = await http.get(Uri.parse(parenturl));
    List<dynamic> parentTasksBuffer = jsonDecode(secondResponse.body);
    for (var element in parentTasksBuffer) {
      setState(() {
        parentSubTasks.add(SubTask.fromJson(element));
      });
    }
    String childurl = "http://${Utility.url}/project/getProjectChildTasks?projectID=${project.id}";
    final thirdResponse = await http.get(Uri.parse(childurl));
    List<dynamic> childTasksBuffer = jsonDecode(thirdResponse.body);
    print(childTasksBuffer);
    for (var element in childTasksBuffer) {
      setState(() {
        childSubTasks.add(SubTaskModel.fromJson(element));
        childSubTasksSnapshot.add(SubTaskModel.fromJson(element));
      });
    }
  }

  List<ChartData> groupSubTasks(){
    List<ChartData> result = [];
    var buffer = groupBy(childSubTasks.where((element) => element.isTotallyDone), (p0) => p0.completionDate);
    int number = 0;
    for(var a in buffer.entries){
      result.add(ChartData(a.key.toString(), a.value.length,number,number+5));
      number+=1;
    }
    return result;
  }

  List<ColumnChartData> groupMembersByTasks(){
    var buffer = groupBy(childSubTasks, (p0) => p0.username);
    List<ColumnChartData> result = [];
    for(var a in buffer.entries){
      result.add(ColumnChartData(a.key,a.value.length,a.value.where((element) => element.isTotallyDone).length,a.value.where((element) => !element.isTotallyDone).length));
    }
    return result;
  }


  Future<void> deleteMember(int index)async{
    String url = "http://${Utility.url}/web/deleteMember?id=$index";
    final response = await http.delete(Uri.parse(url));
    if(response.statusCode==200){
      InitializeProject();
    }
  }

  Future<void> deleteChildSubTask(int index)async{
    String url = "http://${Utility.url}/web/deleteChildSubTask?id=$index";
    final response = await http.delete(Uri.parse(url));
    if(response.statusCode==200){
      InitializeProject();
    }
  }

  Future<void> deleteParentSubTask(int index)async{
    String url = "http://${Utility.url}/web/deleteParentSubTask?id=$index";
    final response = await http.delete(Uri.parse(url));
    if(response.statusCode==200){
      InitializeProject();
    }else{
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
        appBar: AppBar(
          title: Text(project.Title ?? ""),
        ),
        body: Stack(
          children: [
            Positioned(
              top: 80,
              left: 50,
              child: Container(
                width: 485,
                height: 316,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5))
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height:5,),
                    Row(
                      children: [
                        const SizedBox(width: 15,),
                        Text("Задачи",textAlign: TextAlign.start,style: TextStyle(
                            fontSize: 25,
                            color: MyColors.textColor,
                            fontWeight: FontWeight.w500

                        ),),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 15,),
                        Column(
                          crossAxisAlignment:CrossAxisAlignment.start,
                          children: [
                            Text("Всего задач: ${childSubTasks.length}",textAlign: TextAlign.start,style: const TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                                fontWeight: FontWeight.w200
                            ),),
                            Text("Выполненных задач: ${childSubTasks.where((element) => element.isTotallyDone).length}",textAlign: TextAlign.start,style: TextStyle(
                              fontSize: 20,
                              color: MyColors.greenColor,
                              fontWeight: FontWeight.w200,
                            ),),
                            Text("Невыполненных задач: ${childSubTasks.where((element) => !element.isTotallyDone).length}",textAlign: TextAlign.start,style: TextStyle(
                                fontSize: 20,
                                color: MyColors.fourthAccent,
                                fontWeight: FontWeight.w200
                            ),),
                          ],
                        ),
                        const SizedBox(width: 15,),
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: PieChart(
                              PieChartData(
                                  borderData: FlBorderData(
                                    show: false,
                                  ),
                                  sections: [
                                    PieChartSectionData(
                                      value: childSubTasks.where((element) => element.isTotallyDone).length.toDouble(),
                                      color:MyColors.greenColor,
                                      titleStyle: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        // shadows: shadows,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      value: childSubTasks.where((element) => !element.isTotallyDone).length.toDouble(),
                                      color:MyColors.fourthAccent,
                                      titleStyle: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        // shadows: shadows,
                                      ),
                                    ),
                                  ]
                              )
                          ),
                        ),
                        const SizedBox(width: 10,)
                      ],
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: 560,
              child:Container(
                width: 730,
                height: 316,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5))
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 15,),
                    Text("Распределение задач между участниками проекта",textAlign: TextAlign.start,style: TextStyle(
                        fontSize: 15,
                        color: MyColors.textColor,
                        fontWeight: FontWeight.w500

                    ),),
                    SizedBox(
                      height: 280,
                      width: 730,
                      child: SfCartesianChart(
                        tooltipBehavior: TooltipBehavior(enable: true),
                        legend: Legend(isVisible:true),
                        plotAreaBorderWidth: 0,
                        primaryXAxis: CategoryAxis(
                          majorGridLines: MajorGridLines(width: 0),
                        ),
                        primaryYAxis: NumericAxis(
                            minimum: 0,
                            interval: 2,
                            axisLine: AxisLine(width: 0),
                            majorTickLines: MajorTickLines(size: 0)),
                        series: [
                          ColumnSeries<ColumnChartData, String>(
                              width: 0.8,
                              spacing: 0.2,
                              dataSource: groupMembersByTasks(),
                              color: Colors.grey,
                              xValueMapper: (ColumnChartData data, _) => data.member as String,
                              yValueMapper: (ColumnChartData data, _) => data.amountOfTasks,
                              name: 'Всего задач'),
                          ColumnSeries<ColumnChartData, String>(
                              width: 0.8,
                              spacing: 0.2,
                              dataSource: groupMembersByTasks(),
                              color: MyColors.greenColor,
                              xValueMapper: (ColumnChartData data, _) => data.member as String,
                              yValueMapper: (ColumnChartData data, _) => data.completedTasks,
                              name: 'Выполненных\nзадач'),
                          ColumnSeries<ColumnChartData, String>(
                              width: 0.8,
                              spacing: 0.2,
                              dataSource: groupMembersByTasks(),
                              color: MyColors.fourthAccent,
                              xValueMapper: (ColumnChartData data, _) => data.member as String,
                              yValueMapper: (ColumnChartData data, _) => data.uncompletedTasks,
                              name: 'Невыполненных\nзадач')
                        ],
                      ),
                    ),
                  ],
                ),
              ) ,
            ),
            Positioned(
              top: 80,
              left: 1315,
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5))
                ),
                width: 250,
                height: 316,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 15,),
                          Text("Прогресс проекта",textAlign: TextAlign.start,style: TextStyle(
                              fontSize: 25,
                              color: MyColors.textColor,
                              fontWeight: FontWeight.w500
                          ),),
                          SizedBox(height: 15,),
                          Text("Выполнено ${childSubTasks.where((element) => element.isTotallyDone).length} из ${childSubTasks.length} задач",style: TextStyle(
                              fontSize: 17,
                              color: MyColors.textColor,
                              fontWeight: FontWeight.w500
                          )),
                          SizedBox(height: 5,),
                          Text("Завершено ${getSubtaskPercentsForProgressBars().floor()}% задач",style: TextStyle(
                              fontSize: 17,
                              color: MyColors.textColor,
                              fontWeight: FontWeight.w500
                          )),
                          SizedBox(height: 5,),
                          Container(
                            margin: EdgeInsets.only(left:15,right:15),
                            alignment:Alignment.center,
                            child: LinearPercentIndicator( //leaner progress bar
                              barRadius: Radius.circular(5),
                              animation: true,
                              animationDuration: 1000,
                              lineHeight: 20.0,
                              percent:getSubtaskPercentsForProgressBars()/100,
                              center: Text(
                                getSubtaskPercentsForProgressBars().floor().toString() + "%",
                                style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                              linearStrokeCap: LinearStrokeCap.roundAll,
                              progressColor: Colors.blue[400],
                              backgroundColor: Colors.grey[300],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text("Прошло ${getDaysPercentsForProgressBar().floor()}% времени",style: TextStyle(
                              fontSize: 17,
                              color: MyColors.textColor,
                              fontWeight: FontWeight.w500
                          )),
                          SizedBox(height: 5,),
                          Container(
                            margin: EdgeInsets.only(left:15,right:15),
                            alignment:Alignment.center,
                            child: LinearPercentIndicator( //leaner progress bar
                              barRadius: Radius.circular(5),
                              animation: true,
                              animationDuration: 1000,
                              lineHeight: 20.0,
                              percent:getDaysPercentsForProgressBar().floor()/100,
                              center: Text(
                                "${getDaysPercentsForProgressBar().floor()}%",
                                style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                              linearStrokeCap: LinearStrokeCap.roundAll,
                              progressColor: Colors.blue[400],
                              backgroundColor: Colors.grey[300],
                            ),
                          ),
                          Text("Начало проекта: " + Utility.getDate(project.StartDate.substring(0,10)),style: TextStyle(
                              fontSize: 15,
                              color: MyColors.textColor,
                              fontWeight: FontWeight.w500
                          )),
                          Text("Завершение проекта: " + Utility.getDate(project.EndDate.substring(0,10)),style: TextStyle(
                              fontSize: 15,
                              color: MyColors.textColor,
                              fontWeight: FontWeight.w500
                          ))
                        ],
                      ),
                    )
                  ],
                ),
              )
            ),
            Positioned(
              top: 420,
              left: 820,
              child: Container(
                width: 350,
                height: 420,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5))
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height:5,),
                    Row(
                      children: [
                        const SizedBox(width: 15,),
                        Text("Список участников",textAlign: TextAlign.start,style: TextStyle(
                            fontSize: 25,
                            color: MyColors.textColor,
                            fontWeight: FontWeight.w500

                        ),),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 15,),
                        SizedBox(
                          height: 350,
                          child: Column(
                            crossAxisAlignment:CrossAxisAlignment.start,
                            children: [
                              Text("Количество участников: ${projectMembers.length}",textAlign: TextAlign.start,style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w200
                              ),),
                              SizedBox(
                                  height: 250,
                                  width: 335,
                                  child:ListView.builder(
                                    itemCount: projectMembers.length,
                                    itemBuilder: (BuildContext context,int index){
                                      print(projectMembers.length);
                                      var member = projectMembers[index];
                                      return ListTile(
                                        leading: Icon(Icons.person,color: MyColors.firstAccent,),
                                        title: Text(member.username),
                                        trailing: PopupMenuButton<int>(
                                          onSelected: (value){
                                            if(value == 0){
                                              deleteMember(member.id);
                                            }
                                          },
                                          itemBuilder: (BuildContext context){
                                            return <PopupMenuEntry<int>>[
                                              const PopupMenuItem<int>(
                                                value: 0,
                                                child: Text("Удалить участника"),
                                              ),
                                            ];
                                          },
                                        ),
                                      );
                                    },
                                  )
                              )
                            ],
                          ),
                        ),

                      ],
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              top: 420,
              left: 50,
              child:Container(
                width: 750,
                height: 420,
                decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.all(Radius.circular(5))
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height:5,),
                    const Row(
                      children: [
                        SizedBox(width: 15,),
                        Text("Участник/задача",textAlign: TextAlign.start,style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.w500

                        ),),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 15,),
                        SizedBox(
                          height: 370,
                          child: Column(
                            crossAxisAlignment:CrossAxisAlignment.start,
                            children: [
                              Text("Количество участников: ${projectMembers.length}",textAlign: TextAlign.start,style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w200
                              ),),
                              Text("Количество задач: ${childSubTasks.length}",textAlign: TextAlign.start,style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w200
                              ),),
                              SizedBox(
                                  width: 700,
                                  child:SfCartesianChart(
                                      plotAreaBackgroundColor: MyColors.backgroundColor,
                                      plotAreaBorderWidth: 0,
                                      tooltipBehavior: TooltipBehavior(enable: true, header: '', canShowMarker: false),
                                      primaryXAxis: DateTimeAxis(
                                        borderColor: Colors.white,
                                        labelStyle: TextStyle(color: Colors.white),
                                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                                        intervalType: DateTimeIntervalType.days,
                                      ),
                                      primaryYAxis: NumericAxis(
                                          borderColor: Colors.white,
                                          labelStyle: TextStyle(color: Colors.white),
                                          labelFormat: '{value}',
                                          minimum: 0,
                                          interval: 1,
                                          majorTickLines: MajorTickLines(color: Colors.transparent),
                                          majorGridLines: MajorGridLines(color: Colors.transparent)),
                                      series: <CartesianSeries>[
                                        // Renders line chart
                                        LineSeries<ChartData, DateTime>(
                                          dataSource:groupSubTasks(),
                                          xValueMapper: (ChartData data, _) => DateTime.parse(data.date.substring(0,10)),
                                          yValueMapper: (ChartData data, _) => data.amountOfTasks,
                                        ),
                                      ]
                                  )
                              )
                            ],
                          ),
                        ),

                      ],
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              top: 420,
              left: 1195,
              child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(5))
                  ),
                height: 420,
                width: 351,
                child: Column(
                  children: [
                    const SizedBox(height:5,),
                    Text("Список задач",textAlign: TextAlign.start,style: TextStyle(
                        fontSize: 25,
                        color: MyColors.textColor,
                        fontWeight: FontWeight.w500

                    ),),
                    Container(
                      height: 379,
                      width: 350,
                      child: ListView.builder(
                        itemCount: parentSubTasks.length,
                        itemBuilder: (BuildContext context, int mainTaskIndex) {
                          return Column(
                            children: [
                              Container(
                                color:MyColors.firstAccent,
                                child: ListTile(
                                  title: Text(parentSubTasks[mainTaskIndex].title,style: TextStyle(
                                      color: MyColors.secondBackground
                                  ),),
                                  trailing: PopupMenuButton<int>(
                                    onSelected: (value){
                                      if(value == 0){
                                        deleteParentSubTask(parentSubTasks[mainTaskIndex].id);
                                      }
                                    },
                                    iconColor: Colors.white,
                                    itemBuilder: (BuildContext context){
                                      return <PopupMenuEntry<int>>[
                                        const PopupMenuItem<int>(
                                          value: 0,
                                          child: Text("Удалить задачу"),
                                        ),
                                      ];
                                    },
                                  ),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).length,
                                itemBuilder: (BuildContext context,int subTaskIndex){
                                  return
                                    Container(
                                      margin: const EdgeInsets.only(left: 50),
                                      child:  ListTile(
                                          title: Text(childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).toList()[subTaskIndex].title),
                                          subtitle: Text(childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).toList()[subTaskIndex].username),
                                          trailing: PopupMenuButton<int>(
                                            onSelected: (value){
                                              if(value == 0){
                                                deleteChildSubTask(childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).toList()[subTaskIndex].SubTaskID);
                                              }
                                            },
                                            itemBuilder: (BuildContext context){
                                              return <PopupMenuEntry<int>>[
                                                const PopupMenuItem<int>(
                                                  value: 0,
                                                  child: Text("Удалить задачу"),
                                                ),
                                              ];
                                            },
                                          )
                                      ),
                                    );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  ],
                )
              ),
            ),
          ],
        ),
    );
  }

}