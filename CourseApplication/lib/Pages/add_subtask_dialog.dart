import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/Pages/add_subtask_executor_dialog.dart';
import 'package:course_application/CustomModels/CustomProjectMember.dart';
import 'package:course_application/Models/subtask.dart';
import 'package:course_application/Utility/colors.dart';
import 'package:course_application/Utility/widget_templates.dart';
import 'package:course_application/widgets/cupertino_button_template.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../CustomModels/CustomProject.dart';
import '../Utility/button_styles.dart';
import '../Utility/utility.dart';

class AddSubTaskDialog extends StatefulWidget{
  AddSubTaskDialog(this.project,this.projectMembers,this.parentID){}
  CustomProject project;
  List<CustomProjectMember> projectMembers;
  int parentID;
  @override
  State<StatefulWidget> createState() => _AddSubTaskDialog(project,projectMembers,parentID);
}

class _AddSubTaskDialog extends State<AddSubTaskDialog> {
  _AddSubTaskDialog(CustomProject project,this.projectMembers,int parentID){
    subtask.parent=parentID;
    subtask.ProjectID=project.id;
  }
  CustomProjectMember subTaskExecutors = CustomProjectMember(0,"Выбрать исполнителя",0,0);
  List<CustomProjectMember> projectMembers;
  TextEditingController controller = TextEditingController();
  SubTask subtask = SubTask.empty();

  Future<void> addChildSubTask()async{
    if(controller.text.length < 3){
      Fluttertoast.showToast(msg: "Минимальная длина названия подзадачи - 3 символа!");
      return;
    }else if(subTaskExecutors.username==""){
      Fluttertoast.showToast(msg: "Выберите исполнителя!");
      return;
    }

    final connectivityResult = await (Connectivity().checkConnectivity());

    if(connectivityResult == ConnectivityResult.none){
      var a = await Utility.databaseHandler.getParenSubTaskCondition(subtask.parent!);
      if(a.created==1){
        Utility.databaseHandler.addChildSubTask(subtask,subTaskExecutors,1);
      }else{
        Utility.databaseHandler.addChildSubTask(subtask,subTaskExecutors,0);
      }
      Navigator.pop(context,true);
    }else{
      print(jsonEncode(subtask));
      final String url = "http://${Utility.url}/project/addChildSubTask";
      final response = await http.post(
          Uri.parse(url), headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
      }, body: jsonEncode(subtask));
      if (response.statusCode == 200) {
        addSubTaskExecutor(int.parse(response.body));
      } else {
        Fluttertoast.showToast(msg: "Произошла ошибка");
      }
    }

  }
  Future<void> addSubTaskExecutor(int subtaskID)async{
    String url = "http://${Utility.url}/project/addSubTaskExecutor?subtaskID=" + subtaskID.toString();
    final response = await http.post(
        Uri.parse(url), headers: <String, String>{
      'Content-Type': 'application/json;charset=UTF-8',
    }, body: jsonEncode(subTaskExecutors));
    if(response.statusCode==200){
      Navigator.pop(context,true);
    }else{
      Fluttertoast.showToast(msg: "Произошла ошибка");
    }
  }
  void chooseSubtaskDeadLine()async{
    var a = await showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
              content: SizedBox(
                height: 370,
                child: Column(
                  children: [
                    DateRangePickerWidget(
                      theme: CalendarTheme(
                        selectedColor: Colors.blue,
                        dayNameTextStyle: TextStyle(color: Colors.black45, fontSize: 10),
                        inRangeColor: Color(0xFFD9EDFA),
                        inRangeTextStyle: TextStyle(color: Colors.blue),
                        selectedTextStyle: TextStyle(color: Colors.white),
                        todayTextStyle: TextStyle(fontWeight: FontWeight.bold),
                        defaultTextStyle: TextStyle(color: Colors.black, fontSize: 12),
                        radius: 10,
                        tileSize: 33,
                        disabledTextStyle: TextStyle(color: Colors.grey),
                      ),
                      doubleMonth: false,
                      height: 310,
                      initialDisplayedDate:DateTime.now(),
                      onDateRangeChanged: (dateRange){
                        setState(() {
                          subtask.deadLine = dateRange!.start.toString().substring(0,10);
                          subtask.deadLine = dateRange!.end.toString().substring(0,10);
                        });
                      },
                    ),
                    SizedBox(
                      width: 220,
                      child: TextButton(
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                        child: Text("Подтвердить выбор",style: TextStyle(
                            fontFamily: 'SanFranciscoPro',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: MyColors.backgroundColor),),
                        style: ButtonStyles.mainButton(),
                      ),
                    )
                  ],
                ),
              )
          );
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Text("Добавить подзадачу",style: TextStyle(
              fontSize: 20
            ),),
            SizedBox(height: 15,),
           Container(
             height: 60,
             child:  WidgetTemplates.getTextField(controller, "Введите название"),
           ),
            SizedBox(height: 15,),
            SizedBox(
              width: 260,
              height: 45,
              child: TextButton(
                onPressed: ()async{
                  var a = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: MyColors.backgroundColor,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(30))),
                          contentPadding: EdgeInsets.only(top: 10.0),
                          content: AddSubTaskExecutorDialog(projectMembers),
                        );
                      }
                  );
                  if (a != null) {
                    setState(() {
                      subTaskExecutors = a;
                    });
                  }
                },
                style: ButtonStyles.mainButton(),
                child: Text(subTaskExecutors.username,
                    style: TextStyle(
                        fontFamily: 'SanFranciscoPro',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: MyColors.backgroundColor)),
              ),
            ),
            SizedBox(height: 10,),
            SizedBox(
              height: 45,
              child: TextButton(
                onPressed: (){
                  chooseSubtaskDeadLine();
                },
                style: ButtonStyles.mainButton(),
                child: Text("Выбрать дедлайн",
                    style: TextStyle(
                        fontFamily: 'SanFranciscoPro',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: MyColors.backgroundColor)),
              ),
              width: 260,
            ),
            Container(height: 10,),
            SizedBox(
              height: 45,
              width: 260,
              child: TextButton(
                onPressed: (){
                  subtask.title=controller.text;
                  addChildSubTask();
                },
                style: ButtonStyles.mainButton(),
                child: Text("Сохранить",
                    style: TextStyle(
                        fontFamily: 'SanFranciscoPro',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: MyColors.backgroundColor)),
              ),
            )
          ],
        ),
      )
    );
  }
}
