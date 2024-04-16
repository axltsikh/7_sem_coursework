import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/CustomModels/GetUserOrganisation.dart';
import 'package:course_application/Pages/ChangePasswordPage.dart';
import 'package:course_application/Pages/JoinOrganizationPage.dart';
import 'package:course_application/Pages/OrganisationManagementPage.dart';
import 'package:course_application/Utility/Utility.dart';
import 'package:course_application/Utility/WidgetTemplates.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Utility/Colors.dart';

class ProfilePage extends StatefulWidget{
  ProfilePage(){}
  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver{

  _ProfilePageState(){
    getOrganisation();
  }
  Future<bool> uploadMyData()async{
    await Utility.databaseHandler.uploadData().then((value){
    });
    return true;
  }
  Future<void> getGlobalData()async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      return;
    }
    Future.delayed(Duration(seconds: 5)).then((value)async{
      print("duration finished");
      await Utility.databaseHandler.GetAllData();
    });
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    print("update");
    getOrganisation();
    super.didUpdateWidget(oldWidget);
  }


  Future<void> getOrganisation() async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      var org = await Utility.databaseHandler.getUserOrganisation();
      setState(() {
        userOrganisation = org;
      });
    }else{
      final String url = "http://${Utility.url}/profile/getUserOrganisation?id=" + Utility.user.id.toString();
      final response = await http.get(Uri.parse(url));
      if(response.statusCode == 200){
        Map<String,dynamic> bodyBuffer = jsonDecode(response.body);
        setState(() {
          userOrganisation = GetUserOrganisation.fromJson(bodyBuffer);
        });
      }
      else{
        setState(() {
          userOrganisation = GetUserOrganisation(-1, "Вы не состоите в организации", "", -1, -1);
        });
      }
    }
  }
  Future<void> leaveOrganisation() async{
    if(userOrganisation.id==-1){
      print("Нет организации");
      return;
    }
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      if(connectivityResult==ConnectivityResult.none){
        Fluttertoast.showToast(msg: "Проверьте подключение к сети!");
        return;
      }
      int result = await Utility.databaseHandler.leaveOrganisation();
      if(result == 1){
        setState(() {
          userOrganisation = GetUserOrganisation(-1, "Вы не состоите в организации", "", -1, -1);
        });
      }else{
        Fluttertoast.showToast(msg: "Произошла ошибка");
      }
    }else{
      final String url = "http://${Utility.url}/organisation/leave?id=" + Utility.user.id.toString();
      final response = await http.delete(Uri.parse(url));
      if(response.statusCode==200){
        setState(() {
          userOrganisation = GetUserOrganisation(-1, "Вы не состоите в организации", "", -1, -1);
        });
      }else{
        Fluttertoast.showToast(msg: "Произошла ошибка");
      }
    }
  }
  Future<void> logout() async{
    await SharedPreferences.getInstance().then((value)async{
      await value.remove("id");
      await value.remove("Username");
      await value.remove("Password");
      Navigator.of(context, rootNavigator: true).pop();
    });
  }
  Future<void> synchronize()async{
    Fluttertoast.showToast(msg: "Синхронизация началсь");
    await uploadMyData().then((value) {
      Future.delayed(Duration(seconds: 3)).then((value)async{
        await getGlobalData().then((value){
          Fluttertoast.showToast(msg: "Синхронизация прошла успешно");
        });
      });
    });
  }


  //region variables
  GetUserOrganisation userOrganisation = GetUserOrganisation(-1, "", "", 0, 0);
  //endregion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: WidgetTemplates.getAppBar("Профиль"),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 25,),
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                    color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(90))
                ),
                child: const Icon(Icons.person,color: Colors.white,size: 50,),
              ),
              const SizedBox(height: 15,),
              Text(Utility.user.Username,textAlign: TextAlign.center,style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600
              ),),
              const SizedBox(height: 5,),
              Text(userOrganisation.name,textAlign: TextAlign.center,style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                color: Colors.grey
              ),),
              const SizedBox(height: 15,),
              Container(
                width: 324,
                decoration: const BoxDecoration(border: null),
                child: ListTile(
                  onTap: (){
                    if(userOrganisation.id!=-1){
                      Navigator.push(context, CupertinoPageRoute(builder: (builder) => OrganisationManagementPage(userOrganisation)));
                    }else{
                      Navigator.push(context, CupertinoPageRoute(builder: (builder) => JoinOrganizationPage()));
                    }
                  },
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          topLeft: Radius.circular(15))),
                  tileColor: MyColors.secondBackground,
                  leading:
                  Icon(Icons.people, color: MyColors.firstAccent),
                  title: Text(
                    "Организация",
                    style: TextStyle(
                        fontFamily: 'SanFranciscoPro',
                        fontSize: 15,
                        color: MyColors.textColor),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ),
              Divider(
                color: MyColors.backgroundColor,
                height: 1,
              ),
              SizedBox(
                width: 324,
                child: ListTile(
                  onTap: () {
                    synchronize();
                  },
                  tileColor: MyColors.secondBackground,
                  leading: Icon(Icons.sync, color: MyColors.firstAccent),
                  title: Text("Синхронизация",
                      style: TextStyle(
                          fontFamily: 'SanFranciscoPro',
                          fontSize: 15,
                          color: MyColors.textColor)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ),
              Divider(
                color: MyColors.backgroundColor,
                height: 1,
              ),
              // SizedBox(
              //   width: 324,
              //   child: ListTile(
              //     onTap: () {
              //
              //     },
              //     tileColor: MyColors.secondBackground,
              //     leading: Icon(
              //       Icons.notifications,
              //       color: MyColors.firstAccent,
              //     ),
              //     title: Text("Уведомления",
              //         style: TextStyle(
              //             fontFamily: 'SanFranciscoPro',
              //             fontSize: 15,
              //             color: MyColors.textColor)),
              //     trailing: const Icon(Icons.arrow_forward_ios),
              //   ),
              // ),
              // Divider(
              //   color: MyColors.backgroundColor,
              //   height: 1,
              // ),
              SizedBox(
                width: 324,
                child: ListTile(
                  onTap: () {
                    Navigator.push(context, CupertinoPageRoute(builder: (builder) => ChangePasswordPage()));
                  },
                  tileColor: MyColors.secondBackground,
                  leading: Icon(Icons.lock_outline,
                      color: MyColors.firstAccent),
                  title: Text("Изменить пароль",
                      style: TextStyle(
                          fontFamily: 'SanFranciscoPro',
                          fontSize: 15,
                          color: MyColors.textColor)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ),
              Divider(
                color: MyColors.backgroundColor,
                height: 1,
              ),
              // SizedBox(
              //   width: 324,
              //   child: ListTile(
              //     onTap: (){},
              //     tileColor: MyColors.secondBackground,
              //     leading:
              //     Icon(Icons.close, color: MyColors.fourthAccent),
              //     title: Text(
              //       "Удалить аккаунт",
              //       style: TextStyle(
              //           fontFamily: 'SanFranciscoPro',
              //           fontSize: 15,
              //           color: MyColors.fourthAccent),
              //     ),
              //     trailing: const Icon(Icons.arrow_forward_ios),
              //   ),
              // ),
              // Divider(
              //   color: MyColors.backgroundColor,
              //   height: 1,
              // ),
              SizedBox(
                width: 324,
                child: ListTile(
                  onTap: logout,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15))),
                  tileColor: MyColors.secondBackground,
                  leading: Icon(
                    Icons.exit_to_app_outlined,
                    color: MyColors.fourthAccent,
                  ),
                  title: Text("Выйти",
                      style: TextStyle(
                          fontFamily: 'SanFranciscoPro',
                          fontSize: 15,
                          color: MyColors.fourthAccent)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

}