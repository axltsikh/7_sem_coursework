import 'dart:convert';
import 'package:course_application/Utility/Utility.dart';
import 'package:course_application/Utility/WidgetTemplates.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../Utility/ButtonStyles.dart';
import '../Utility/Colors.dart';


class CreateOrganizationPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _CreateOrganizationPage();
}

class _CreateOrganizationPage extends State<CreateOrganizationPage> {

  TextEditingController organizationNameController = TextEditingController();
  TextEditingController organizationPasswordController = TextEditingController();
  TextEditingController organizationRepeatPasswordController = TextEditingController();
  Future<void> createOrganisation() async{
    if(organizationNameController.text.length<3){
      Fluttertoast.showToast(msg: "Минимальная длина логина - 3 символа");
      return;
    }else if(organizationPasswordController.text.length<8){
      Fluttertoast.showToast(msg: "Минмальная длина пароля - 8 символов");
      return;
    } else if(organizationPasswordController.text != organizationRepeatPasswordController.text){
      Fluttertoast.showToast(msg: "Пароли не совпадают!");
      return;
    }
    final String url = "http://${Utility.url}/organisation/create";
    await http.post(Uri.parse(url),headers: <String,String>{
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(<String,String>{
      'organisationName': organizationNameController.text,
      'organisationPassword': organizationRepeatPasswordController.text,
      'creatorID': Utility.user.id.toString()
    })).then((value) => {
      if(value.statusCode==200){
        Fluttertoast.showToast(msg: "Организация создана"),
        Navigator.pop(context),
        Navigator.pop(context)
        
      }
      else{
        Fluttertoast.showToast(msg: "Произошла ошибка!")
      }

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: WidgetTemplates.getAppBarWithReturnButton("Создание организации", context),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(height: 50,width: 150,),
              WidgetTemplates.getTextField(organizationNameController, "Название организации"),
              SizedBox(height: 15,),
              WidgetTemplates.getPasswordTextField(organizationPasswordController,true, "Пароль организации"),
              SizedBox(height: 15),
              WidgetTemplates.getPasswordTextField(organizationRepeatPasswordController,true, "Подтвердите пароль организации"),

              Container(height: 25,),
              Container(
                width: 350,
                height: 60,
                padding: EdgeInsets.only(top:15),
                child: TextButton(
                  onPressed: createOrganisation,
                  child: Text("Создать организацию",style: TextStyle(
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
      ),
    );
  }

}