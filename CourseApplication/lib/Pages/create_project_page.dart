import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/CustomModels/CustomOrganisationMember.dart';
import 'package:course_application/CustomModels/OrganisationMember.dart';
import 'package:course_application/Utility/widget_templates.dart';
import 'package:course_application/widgets/cupertino_button_template.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../Utility/button_styles.dart';
import '../Utility/colors.dart';
import 'add_project_member_dialog.dart';
import '../CustomModels/CustomProjectMember.dart';
import '../Utility/utility.dart';

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
  void chooseProjectDates()async{
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
                        startDate = dateRange!.start.toString().substring(0,10);
                        endDate = dateRange!.end.toString().substring(0,10);
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



  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: WidgetTemplates.getAppBarWithReturnButton("Создание проекта",context),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(width: 370,child: WidgetTemplates.getTextField(titleController, "Название проекта"),),
              SizedBox(height: 15,),
              SizedBox(width: 370,child: WidgetTemplates.getTextField(descriptionController, "Описание проекта"),),
              SizedBox(height: 5,),
              Padding(
                padding: EdgeInsets.only(left: 5,right: 5,top: 5),
                child: Container(
                  height: 360,
                  child: Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: projectMembers.length+2,
                        itemBuilder:(BuildContext context, int index){
                          if(index==0){
                            return const Column(
                              // margin: EdgeInsets.only(top: 15),
                                children:[
                                  SizedBox(height: 15,),
                                  Text("Список участников",textAlign: TextAlign.center,style: TextStyle(
                                      fontSize: 18,fontWeight: FontWeight.w400),),
                                  SizedBox(height: 15,)
                                ]
                            );
                          }
                          if(index==projectMembers.length+1){
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.add,
                                  color: MyColors.firstAccent,
                                ),
                              ),
                              onTap: ()async{
                                var a = await showDialog(
                                    context: context,
                                    builder: (BuildContext context){
                                      return AlertDialog(
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(30))),
                                        contentPadding: EdgeInsets.only(top: 10.0),
                                        content: AddProjectMemberDialog(projectMembers),
                                      );
                                    }
                                );
                                setState(() {
                                  if(a!=null){
                                    setState(() {
                                      projectMembers.add(a);
                                    });
                                  }
                                });
                              },
                              title: Text("Добавить участника"),
                            );
                          }
                          var member = projectMembers[index-1];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: MyColors.firstAccent,
                              child: Icon(
                                Icons.person,
                                color: MyColors.secondBackground,
                              ),
                            ),
                            title: Text(member.username),
                          );
                        }
                    ),
                  ),
                ),
              ),
              Container(
                width: 350,
                height: 70,
                padding: EdgeInsets.only(top: 15),
                child: TextButton(
                  child: Text(startDate == "Начало" ? "Выбрать даты проекта" : Utility.getDate(startDate) + " - " + Utility.getDate(endDate),style: TextStyle(
                      fontFamily: 'SanFranciscoPro',
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: MyColors.firstAccent),),
                  onPressed: chooseProjectDates,
                  style: ButtonStyles.secondaryButton(),
                ),
              ),
              Container(height: 5,),
              Container(
                width: 350,
                height: 70,
                padding: EdgeInsets.only(top: 15),
                child: TextButton(
                  child: Text("Создать проект",style: TextStyle(
                      fontFamily: 'SanFranciscoPro',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: MyColors.backgroundColor),),
                  onPressed: createProject,
                  style: ButtonStyles.mainButton(),
                ),
              )
            ],
          ),
        )
      ),
    );
  }

}