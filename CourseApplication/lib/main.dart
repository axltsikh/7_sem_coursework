import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/Pages/MainPage.dart';
import 'package:course_application/Utility/Utility.dart';
import 'package:course_application/Utility/WidgetTemplates.dart';
import 'package:course_application/Pages/registerPage.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Models/User.dart';
import 'Utility/ButtonStyles.dart';
import 'Utility/Colors.dart';

void main() async{
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'TaskMate'),
    );
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
    SharedPreferences.getInstance().then((value)async{
      final int? id = value.getInt("id");
      final String? username = value.getString("Username");
      final String? password = value.getString("Password");
      if(id!=null && username!=null && password!=null ){
        Utility.user = User(id, username, password);
        print(Utility.user.id);
        final connectivityResult = await (Connectivity().checkConnectivity());
        if(connectivityResult == ConnectivityResult.none){
          isLoading = false;
          Navigator.push(context, MaterialPageRoute(builder: (context)=>MainPage()));
        }else{
          await Utility.databaseHandler.uploadData().then((value){
            isLoading = false;
            Navigator.push(context, MaterialPageRoute(builder: (context)=>MainPage()));
          });
        }
      }else{
        isLoading = false;
        setState(() {
          getBody();
        });
      }
    });
  }

  bool isLoading = true;
  final loginFieldController = TextEditingController();
  final passwordFieldController = TextEditingController();
  bool obscurePassword = true;

  void loginClick() async{
    await login();
  }
  Future<void> login() async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      List<User> users = await Utility.databaseHandler.getUser(loginFieldController.text);
      if(users.length!=0){
        if(users[0].Password == md5.convert(utf8.encode(passwordFieldController.text)).toString()){
          Utility.user.id=users[0].id;
          Utility.user.Username=users[0].Username;
          Utility.user.Password=users[0].Password;
          SharedPreferences.getInstance().then((value){
            value.setInt("id",Utility.user.id);
            value.setString("Username", Utility.user.Username);
            value.setString("Password", Utility.user.Password);
          });
          setState(() {
            loginFieldController.text = "";
            passwordFieldController.text = "";
          });
          Navigator.push(context, MaterialPageRoute(builder: (context)=>MainPage()));
        }else{
          Fluttertoast.showToast(msg: "Неверное имя пользователя или пароль!",toastLength: Toast.LENGTH_SHORT,);
        }
      }
    }else{
      final String url = "http://${Utility.url}/user/login";
      final response = await http.post(Uri.parse(url),headers: <String,String>{
        'Content-Type': 'application/json;charset=UTF-8',
      },body: jsonEncode(<String,String>{
        'name': loginFieldController.text,
        'password': md5.convert(utf8.encode(passwordFieldController.text)).toString()
      }));
      print(md5.convert(utf8.encode(passwordFieldController.text)).toString());
      if(response.statusCode==200){
        Utility.user.id=int.parse(response.body);
        Utility.user.Username=loginFieldController.text;
        Utility.user.Password=md5.convert(utf8.encode(passwordFieldController.text)).toString();
        print(Utility.user.Password);
        SharedPreferences.getInstance().then((value){
          value.setInt("id",Utility.user.id);
          value.setString("Username", Utility.user.Username);
          value.setString("Password", Utility.user.Password);
        });
        await Utility.databaseHandler.uploadData().then((value){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>MainPage()));
        });
        setState(() {
          loginFieldController.text = "";
          passwordFieldController.text = "";
        });
      }else{
        Fluttertoast.showToast(msg: "Неверное имя пользователя или пароль!",toastLength: Toast.LENGTH_SHORT,);
      }
    }
  }
  Future<void> uploadMyData()async{
    await Utility.databaseHandler.uploadData();
  }
  Future<void> getGlobalData()async{
    await Utility.databaseHandler.GetAllData();
  }
  void registerClick() async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      Fluttertoast.showToast(msg: "Проверьте подключение к сети!");
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context)=>RegisterPage()));
  }

  Widget getBody(){
    if(isLoading){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }else{
      return SingleChildScrollView(
        child: Center(
            child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 350,
                  child: Column(
                    children: [
                      SizedBox(height: 250,),
                      WidgetTemplates.getTextField(loginFieldController, "Имя пользователя"),
                      SizedBox(height: 15,),
                      WidgetTemplates.getPasswordTextField(passwordFieldController, obscurePassword,"Пароль"),
                      SizedBox(height: 150,),
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
                      Container(
                          width: 400,
                          height: 60,
                          margin: const EdgeInsets.only(top: 15),
                          child: TextButton(
                            onPressed: registerClick,
                            style: ButtonStyles.secondaryButton(),
                            child: Text("Создать аккаунт",
                                style: TextStyle(
                                    fontFamily: 'SanFranciscoPro',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: MyColors.firstAccent)),
                          )
                      ),
                    ],
                  ),
                )
            )
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: WidgetTemplates.getAppBar("TaskMate"),
      body: getBody()
    );
  }
}
