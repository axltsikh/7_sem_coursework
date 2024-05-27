import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_application/widget_templates.dart';
import 'package:web_application/widgets/password_text_field.dart';
import 'button_styles.dart';
import 'my_colors.dart';
import 'Pages/home_page.dart';
import 'utility.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

   // MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return OKToast(child: MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: MyColors.firstAccent

        ),
        primarySwatch: Colors.blue,
      ),

      home: const MyHomePage(title: 'Trello'),
    ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  _MyHomePageState(){
    checkPrefs();
  }


  Future<void> checkPrefs()async{
    final sharedPrefs = await SharedPreferences.getInstance();
    if(sharedPrefs.containsKey("id")){
      Utility.user.id=int.parse((await sharedPrefs.getString("id"))!);
      Utility.user.Username= (await sharedPrefs.getString("username"))!;
      Utility.user.Password=(await sharedPrefs.getString("password"))!;
      Navigator.push(context, MaterialPageRoute(builder: (context)=>const HomePage()));
    }
  }
  
  final loginFieldController = TextEditingController(text: "axl");
  final passwordFieldController = TextEditingController(text:"12345678");
  Future<void> login() async{
    final response = await http.post(Uri.http('127.0.0.1:1234','/user/login'),headers: <String,String>{
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(<String,String>{
      'name': loginFieldController.text,
      'password': md5.convert(utf8.encode(passwordFieldController.text)).toString()
    }));
    if(response.statusCode==200){
      Utility.user.id=int.parse(response.body);
      Utility.user.Username=loginFieldController.text;
      Utility.user.Password=md5.convert(utf8.encode(passwordFieldController.text)).toString();
      final sharedPrefs = await SharedPreferences.getInstance();
      sharedPrefs.setString("id", Utility.user.id.toString());
      sharedPrefs.setString("username", Utility.user.Username.toString());
      sharedPrefs.setString("password", Utility.user.Password.toString());
      Navigator.push(context, MaterialPageRoute(builder: (context)=>const HomePage()));
    }else{
      showToast("Неверное имя пользователя или пароль!",position: ToastPosition.bottom,);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MyColors.backgroundColor,
        appBar: AppBar(title: const Text("Вход"),),
        body: Center(
            child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 350,
                  margin: const EdgeInsets.only(top: 150),
                  child: Column(
                    children: [
                      Image.asset("assets/images/logo.png"),
                      Text("TaskMate",style: TextStyle(
                        fontSize: 20
                      ),),
                      SizedBox(height: 100,),
                      WidgetTemplates.getTextField(loginFieldController, "Имя пользователя"),
                      SizedBox(height: 25,),
                      PasswordTextField(passwordFieldController,true, 'Пароль'),
                      SizedBox(height: 100,),
                      Container(
                          width: 350,
                          height: 60,
                          margin: const EdgeInsets.only(top: 15),
                          child: TextButton(
                            onPressed: login,
                            style: ButtonStyles.mainButton(),
                            child: Text("Войти",
                                style: TextStyle(
                                    fontFamily: 'SanFranciscoPro',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: MyColors.backgroundColor)),
                          )
                      ),
                    ],
                  ),
                )
            )
        )
    );
  }
}
