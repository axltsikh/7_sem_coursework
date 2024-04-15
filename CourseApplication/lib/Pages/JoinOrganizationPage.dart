import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/Pages/CreateOrganizationPage.dart';
import 'package:course_application/Utility/WidgetTemplates.dart';
import 'package:course_application/manyUsageTemplate/CupertinoButtonTemplate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../Models/Organization.dart';
import '../Utility/Colors.dart';
import '../Utility/Utility.dart';

class JoinOrganizationPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _JoinOrganizationPage();
}

class _JoinOrganizationPage extends State<JoinOrganizationPage> {
  _JoinOrganizationPage(){
    getOrganisationsList();
  }

  TextEditingController organizationPasswordController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  List<Organization> searchBuffer=[];
  List<Organization> organizations = [];

  Future<void> getOrganisationsList() async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      var buffer = await Utility.databaseHandler.getAllOrganisatios();
      setState(() {
        organizations = buffer;
        searchBuffer=buffer;
      });
    }else{
      final response = await http.get(Uri.parse("http://${Utility.url}/organisation/getAllOrganisations"));
      if(response.statusCode==200){
        organizations.clear();
        List<dynamic> bodyBuffer = jsonDecode(response.body);
        setState(() {
          bodyBuffer.forEach((element) {
            organizations.add(Organization.fromJson(element));
            searchBuffer.add(Organization.fromJson(element));
          });
        });
      }
    }
  }

  Future<int> joinOrganization(int organisationID) async{
    final String url = "http://${Utility.url}/organisation/joinOrganisation";
    final response = await http.post(Uri.parse(url),headers: <String,String>{
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(<String,String>{
      'userID': Utility.user.id.toString(),
      'organisationID':organisationID.toString()
    }));
    if(response.statusCode==200){
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Вы успешно вступили в организацию");
      return 1;
    }else{
      Fluttertoast.showToast(msg:"Произошла ошибка");
      return -1;
    }
  }

  void textChanged(String value){
    RegExp exp = RegExp(value.toLowerCase());
    setState(() {
      organizations=searchBuffer.where((element) => exp.hasMatch(element.name.toLowerCase())).toList();
    });print(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 60,left: 0),
        child: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
          onPressed: (){
            Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) => CreateOrganizationPage())
            );
          },
          backgroundColor: MyColors.firstAccent,
          child: Icon(Icons.add,color: Colors.white,),
        ),
      ),
      appBar: WidgetTemplates.getAppBarWithReturnButton("Вступить в организацию", context),
      body: SingleChildScrollView(
        child: Center(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Container(
                height: 700,
                child: Column(
                  children: [
                    TextField(
                        controller: searchController,
                        cursorColor: MyColors.textColor,
                        onChanged: textChanged,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: MyColors.secondBackground,
                            hintText: "Поиск организации"),
                        style: const TextStyle(
                            fontFamily: 'SanFranciscoPro',
                            fontWeight: FontWeight.w500,
                            fontSize: 16)),
                    Padding(
                        padding: EdgeInsets.only(left: 5,right: 5),
                        child: Container(
                          height: 600,
                          child: Card(
                            color: Colors.white,
                            elevation: 0,
                            child: ListView.builder(
                                itemCount: organizations.length,
                                itemBuilder: (BuildContext context,int index){
                                  return ListTile(
                                    onTap: (){
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context){
                                            return AlertDialog(
                                                shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(30))),
                                                contentPadding: const EdgeInsets.all(15),
                                                content: SizedBox(
                                                  width: 150,
                                                  height: 150,
                                                  child: Column(
                                                    children: [
                                                      const Text("Введите пароль",style: TextStyle(fontSize: 20),),
                                                      const Divider(
                                                        thickness: 1,
                                                        color: Colors.blue,
                                                      ),
                                                      Container(height: 15,),
                                                      CupertinoTextField(
                                                        placeholder: "Введите пароль",
                                                        controller: organizationPasswordController,
                                                        clearButtonMode: OverlayVisibilityMode.always,
                                                        obscureText: true,
                                                      ),
                                                      Container(height: 15,),
                                                      CupertinoButtonTemplate("Вступить", () async{
                                                        if(organizations[index].password==organizationPasswordController.text){
                                                          var a = await joinOrganization(organizations[index].id);
                                                          if(a==1){
                                                            Navigator.pop(context);
                                                          }
                                                        }else{
                                                          setState(() {
                                                            organizationPasswordController.text="";
                                                          });
                                                          Fluttertoast.showToast(msg: "Неверный пароль");
                                                        }
                                                      })
                                                    ],
                                                  ),
                                                )
                                            );
                                          }
                                      );
                                    },
                                    leading: Icon(
                                      Icons.group_work,
                                      color: MyColors.textColor,
                                    ),
                                    title: Text(organizations[index].name),
                                  );
                                }
                            ),
                          ),
                        )
                    ),
                  ],
                ),
              ),
            )
        ),
      )
    );
  }

}