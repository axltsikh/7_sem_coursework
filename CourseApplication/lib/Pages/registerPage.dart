import 'dart:convert';
import 'package:course_application/Utility/Colors.dart';
import 'package:course_application/Utility/WidgetTemplates.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../Utility/ButtonStyles.dart';
import '../Utility/Utility.dart';

class RegisterPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _RegisterPage();
}
class _RegisterPage extends State<RegisterPage>{
  final loginFieldController = TextEditingController();
  final passwordFieldController = TextEditingController();
  final repeatPasswordFieldController = TextEditingController();
  String errorText = "";

  void registerClick() async {
    if(loginFieldController.text.length<3){
      Fluttertoast.showToast(msg: "Минимальная длина логина - 3 символа");
      return;
    }else if(passwordFieldController.text.length<8){
      Fluttertoast.showToast(msg: "Минмальная длина пароля - 8 символов");
      return;
    }else if(repeatPasswordFieldController.text!=passwordFieldController.text){
      Fluttertoast.showToast(msg: "Пароли не совпадают!");
      return;
    }
    await createUser();
  }

  Future<void> createUser() async{
    final response = await http.post(Uri.parse("http://${Utility.url}/user/create"),headers: <String,String>{
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(<String,String>{
      'name': loginFieldController.text,
      'password': md5.convert(utf8.encode(repeatPasswordFieldController.text)).toString()
    }));
    if(response.statusCode==200){
      Fluttertoast.showToast(msg: "Аккаунт успешно создан");
      Navigator.pop(context);
    }else{
      Fluttertoast.showToast(msg: "Имя пользователя занято!");
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: WidgetTemplates.getAppBarWithReturnButton("Регистрация", context),
      body: Center(
          child: Container(
            width: 350,
            child: Column(
              children: [
                SizedBox(height: 200,),
                WidgetTemplates.getTextField(loginFieldController, "Имя пользователя"),
                const SizedBox(height: 15,),
                WidgetTemplates.getPasswordTextField(passwordFieldController,true, "Пароль"),
                const SizedBox(height: 15,),
                WidgetTemplates.getPasswordTextField(repeatPasswordFieldController,true, "Повторите пароль"),
                SizedBox(height: 150,),
                Container(
                  width: 400,
                  height: 60,
                  margin: EdgeInsets.all(15),
                  child: TextButton(
                    onPressed: registerClick,
                    style: ButtonStyles.mainButton(),
                    child: Text("Создать аккаунт",
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
      ),
    );
  }

}
