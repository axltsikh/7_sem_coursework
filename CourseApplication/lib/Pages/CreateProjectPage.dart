import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/CustomModels/CustomOrganisationMember.dart';
import 'package:course_application/manyUsageTemplate/CupertinoButtonTemplate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'AddProjectMemberDialog.dart';
import '../CustomModels/CustomProjectMember.dart';
import '../Utility/Utility.dart';

class CreateProjectPage extends StatefulWidget{
  CreateProjectPage({super.key}){}
  @override
  State<StatefulWidget> createState() => _CreateProjectPage();
}
class _CreateProjectPage extends State<CreateProjectPage> {
  String startDate="Начало";
  String endDate="Конец";
  List<CustomOrganisationMember> organisationMembers = <CustomOrganisationMember>[];
  List<CustomProjectMember> projectMembers = <CustomProjectMember>[];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();


  Future<void> createProject() async{
    if(titleController.text.length<3){
      Fluttertoast.showToast(msg: "Минимальная длина названия проекта - 3 символа");
    }else if(startDate=="Начало" || endDate=="Конец"){
      Fluttertoast.showToast(msg: "Выберите даты проекта!");
    }
    if(descriptionController.text==""){
      descriptionController.text = "Описание отстутсвует";
    }
    print("createProject");
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      await Utility.databaseHandler.createProject(titleController.text, descriptionController.text, startDate, endDate,projectMembers);
      Fluttertoast.showToast(msg: "Проект успешно создан!");
      Navigator.pop(context,1);
    }else {
      final String url = "http://${Utility.url}/project/create";
      final response = await http.post(Uri.parse(url),headers: <String,String>{
        'Content-Type': 'application/json;charset=UTF-8',
      },body: jsonEncode(<String,String>{
        'userID': Utility.user.id.toString(),
        'title': titleController.text,
        'description' : descriptionController.text,
        'startDate': startDate,
        'endDate' : endDate
      }));
      if(response.statusCode==200){
        print(projectMembers.length);
        print("createdProjectID: " + response.body);
        if(projectMembers.length==0){
          Fluttertoast.showToast(msg: "Проект успешно создан!");
          Navigator.pop(context,1);
        }else{
          for(var a in projectMembers){
            await addProjectMembers(a,response.body);
          }
        }
      }else{
        Fluttertoast.showToast(msg: "Произошла ошибка!");
      }
    }
  }
  Future<void> addProjectMembers(CustomProjectMember member,String projectID) async{
    print(projectMembers.length);
    final String url = "http://${Utility.url}/project/addProjectMember";
    final response = await http.post(Uri.parse(url),headers: <String,String>{
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(<String,String>{
      "organisationMemberID" : member.organisationID.toString(),
      "projectID" : projectID
    }));
    print("responseStatesCode: " + response.statusCode.toString());
    if(response.statusCode==200){
      Fluttertoast.showToast(msg: "Проект успешно создан!");
      Navigator.pop(context,1);
    }else{
      Fluttertoast.showToast(msg: "Произошла ошибка!");
    }
  }
  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Создание проекта"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Card(
                  elevation: 15,
                  shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.blue,
                      ),
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                        minHeight: 50,
                        minWidth: 250
                    ),
                    child: CupertinoTextField.borderless(
                      textAlign: TextAlign.center,
                      placeholder: "Название",
                      controller: titleController,
                    ),
                  )
              ),
              Card(
                  elevation: 15,
                  shadowColor: Colors.grey,

                  shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.blue,
                      ),
                      borderRadius: BorderRadius.circular(40)
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                        minHeight: 150,
                        minWidth: 250
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 25,top: 25),
                          child: CupertinoTextField.borderless(
                            maxLines: null,
                            controller: descriptionController,
                            placeholder: "Введите описание",
                          ),
                        )
                      ],
                    ),
                  )
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Card(
                      elevation: 15,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            minHeight: 50,
                            minWidth: 90
                        ),
                        child: Align(
                            alignment: Alignment.center,
                            child: Container(
                                child: Text(startDate)
                            )
                        ),
                      )
                  ),
                  Card(
                      elevation: 15,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: SizedBox(
                          child: CupertinoButtonTemplate(
                            "Выбрать даты",
                              () async{
                                var a = await showDialog(
                                    context: context,
                                    builder: (BuildContext context){
                                      return AlertDialog(
                                          content:  DateRangePickerWidget(
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
                                            height: 360,
                                            initialDisplayedDate:DateTime.now(),
                                            onDateRangeChanged: (dateRange){
                                              setState(() {
                                                startDate = dateRange!.start.toString().substring(0,10);
                                                endDate = dateRange!.end.toString().substring(0,10);
                                              });
                                            },
                                          ),
                                      );
                                    }
                                );
                              }
                          )
                      )
                  ),
                  Card(
                      elevation: 15,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(
                              minHeight: 50,
                              minWidth:90
                          ),
                          child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                  child: Text(endDate)
                              )
                          ),
                      )
                  ),
                ],
              ),
              SizedBox(height: 25,),
              Divider(),
              Align(
                alignment: Alignment.center,
                child: Text("Управление участниками"),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 150
                ),
                child: ListView.builder(
                  itemCount: projectMembers.length,
                  itemBuilder: (BuildContext context,int index){
                    return Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: SizedBox(
                        height: 40,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(projectMembers[index].username as String),
                        ),
                      ),
                    );
                  },
                ),
              ),
              CupertinoButtonTemplate("Добавить участника", () async{
                var a = await showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30))),
                        contentPadding: EdgeInsets.only(top: 10.0),
                        content: AddProjectMemberDialog(projectMembers),
                      );
                    }
                );
                setState(() {
                  if(a!=null){
                    projectMembers.add(a);
                  }
                });
              }),
              Container(height: 25,),
              CupertinoButtonTemplate("Создать проект", createProject)
            ],
          ),
        )
      ),
    );
  }

}