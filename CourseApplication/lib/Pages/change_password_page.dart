import 'dart:convert';
import 'package:course_application/widgets/password_textfield.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/Utility/widget_templates.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Utility/button_styles.dart';
import '../Utility/colors.dart';
import '../Utility/utility.dart';

class ChangePasswordPage extends StatefulWidget{
  const ChangePasswordPage({super.key});

  @override
  State<StatefulWidget> createState() => ChangePasswordPageState();
}
class ChangePasswordPageState extends State<ChangePasswordPage>{

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController repeatNewPasswordController = TextEditingController();

  Future<void> changePassword() async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      Utility.databaseHandler.updatePassword(md5.convert(utf8.encode(repeatNewPasswordController.text)).toString());
    }else{
      final String url = "http://${Utility.url}/user/changePassword";
      final response = await http.post(Uri.parse(url),headers: <String,String>{
        'Content-Type': 'application/json;charset=UTF-8',
      },body: jsonEncode(<String,String>{
        'id': Utility.user.id.toString(),
        'password': md5.convert(utf8.encode(repeatNewPasswordController.text)).toString()
      }));
      if(response.statusCode==200){
        Utility.user.Password=md5.convert(utf8.encode(repeatNewPasswordController.text)).toString();
        setState(() {
          oldPasswordController.text="";
          newPasswordController.text ="";
          repeatNewPasswordController.text = "";
        });
        Fluttertoast.showToast(msg: "Пароль успешно изменен!");
      }else{
        Fluttertoast.showToast(msg: "Произошла ошибка!");
      }
    }
  }
  void changePasswordClick() async{
    if(md5.convert(utf8.encode(oldPasswordController.text)).toString() != Utility.user.Password){
      Fluttertoast.showToast(msg: "Неверный пароль!");
      return;
    }else if(newPasswordController.text.length<8){
      Fluttertoast.showToast(msg: "Минимальная длина пароля - 8 символов!");
      return;
    }else if(newPasswordController.text != repeatNewPasswordController.text){
      Fluttertoast.showToast(msg: "Пароли не совпадают!");
      return;
    }
    else{
      await changePassword();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: WidgetTemplates.getAppBarWithReturnButton("Изменить пароль", context),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 15,right: 15),
            child: Column(
              children: [
                const SizedBox(height: 50,),
                PasswordTextField(oldPasswordController,true, "Введите старый пароль"),
                const SizedBox(height: 15,),
                PasswordTextField(newPasswordController,true, "Введите новый пароль"),
                const SizedBox(height: 15,),
                PasswordTextField(repeatNewPasswordController,true, "Подтвердите новый пароль"),
                const SizedBox(height: 325,),
                SizedBox(
                  width: 350,
                  height: 60,
                  child:TextButton(
                    onPressed: changePasswordClick,
                    style: ButtonStyles.mainButton(),
                    child: Text("Изменить пароль",style: TextStyle(
                        fontFamily: 'SanFranciscoPro',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: MyColors.backgroundColor),),
                  ),
                )
              ],
            ),
          ),
        ) ,
      ),
    );
  }

}