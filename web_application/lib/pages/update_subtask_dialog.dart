import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:http/http.dart' as http;
import 'package:web_application/Models/subtask_model.dart';
import '../Models/custom_project.dart';
import '../Models/custom_project_member.dart';
import '../Models/subtask.dart';
import '../button_styles.dart';
import '../my_colors.dart';
import '../utility.dart';
import '../widget_templates.dart';
import 'add_subtask_executor_dialog.dart';

class AddSubTaskDialog extends StatefulWidget{
  AddSubTaskDialog(this.project,this.projectMembers,this.subTask, {super.key});
  CustomProject project;
  List<CustomProjectMember> projectMembers;
  SubTaskModel subTask;
  @override
  State<StatefulWidget> createState() => _AddSubTaskDialog(project,projectMembers,subTask);
}

class _AddSubTaskDialog extends State<AddSubTaskDialog> {
  _AddSubTaskDialog(CustomProject project,this.projectMembers,this.subTask);


  List<CustomProjectMember> projectMembers;
  TextEditingController controller = TextEditingController();
  SubTaskModel subTask;
  CustomProjectMember newSubTaskExecutor = CustomProjectMember(-1,"",-1,-1);

  Future<void> updateSubTask()async{
    final String url = "http://${Utility.url}/web/updateSubTask";
    final response = await http.post(
        Uri.parse(url), headers: <String, String>{
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode({
      'id':subTask.SubTaskID.toString(),
      'title':controller.text.toString(),
      'deadLine':subTask.deadLine.toString(),
      'executorID' : newSubTaskExecutor.id == -1 ? subTask.SubTaskID : newSubTaskExecutor.id
    }));
    if(response.statusCode == 200){
      print("Success");
      Navigator.of(context).pop(true);
    }else{
      print("error");
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
                      theme: const CalendarTheme(
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
                          subTask.deadLine = dateRange!.start.toString().substring(0,10);
                          subTask.deadLine = dateRange.end.toString().substring(0,10);
                        });
                      },
                    ),
                    SizedBox(
                      width: 220,
                      child: TextButton(
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                        style: ButtonStyles.mainButton(),
                        child: Text("Подтвердить выбор",style: TextStyle(
                            fontFamily: 'SanFranciscoPro',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: MyColors.backgroundColor),),
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
    return SizedBox(
      height: 300,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            const Text("Обновить подзадачу",style: TextStyle(
              fontSize: 20
            ),),
            const SizedBox(height: 15,),
           SizedBox(
             height: 60,
             child:  WidgetTemplates.getTextField(controller, subTask.title),
           ),
            const SizedBox(height: 15,),
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
                          contentPadding: const EdgeInsets.only(top: 10.0),
                          content: AddSubTaskExecutorDialog(projectMembers),
                        );
                      }
                  );
                  if (a != null) {
                    setState(() {
                      newSubTaskExecutor = a;
                      subTask.username = newSubTaskExecutor.username;
                    });
                  }
                },
                style: ButtonStyles.mainButton(),
                child: Text(subTask.username,
                    style: TextStyle(
                        fontFamily: 'SanFranciscoPro',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: MyColors.backgroundColor)),
              ),
            ),
            const SizedBox(height: 10,),
            SizedBox(
              height: 45,
              width: 260,
              child: TextButton(
                onPressed: (){
                  chooseSubtaskDeadLine();
                },
                style: ButtonStyles.mainButton(),
                child: Text(Utility.getDate(subTask.deadLine.toString().substring(0,10)),
                    style: TextStyle(
                        fontFamily: 'SanFranciscoPro',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: MyColors.backgroundColor)),
              ),
            ),
            Container(height: 10,),
            SizedBox(
              height: 45,
              width: 260,
              child: TextButton(
                onPressed: (){
                  updateSubTask();
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
