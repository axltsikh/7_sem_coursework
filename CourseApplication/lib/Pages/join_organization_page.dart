import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/Pages/create_organization_page.dart';
import 'package:course_application/Utility/widget_templates.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../Models/organization.dart';
import '../Utility/button_styles.dart';
import '../Utility/colors.dart';
import '../Utility/utility.dart';

class JoinOrganizationPage extends StatefulWidget{
  const JoinOrganizationPage({super.key});

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
          for (var element in bodyBuffer) {
            organizations.add(Organization.fromJson(element));
            searchBuffer.add(Organization.fromJson(element));
          }
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
        margin: const EdgeInsets.only(bottom: 60,left: 0),
        child: FloatingActionButton(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
          onPressed: (){
            Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) => const CreateOrganizationPage())
            ).then((value)async{
              setState(()async{
                await Utility.getOrganisation();
              });
            });
          },
          backgroundColor: MyColors.firstAccent,
          child: const Icon(Icons.add,color: Colors.white,),
        ),
      ),
      appBar: WidgetTemplates.getAppBarWithReturnButton("Вступить в организацию", context),
      body: SingleChildScrollView(
        child: Center(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: SizedBox(
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
                    SizedBox(height: 15,),
                    Padding(
                        padding: const EdgeInsets.only(left: 5,right: 5),
                        child: SizedBox(
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
                                              backgroundColor: MyColors.backgroundColor,
                                                shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(30))),
                                                contentPadding: const EdgeInsets.all(15),
                                                content: SizedBox(
                                                  width: 150,
                                                  height: 180,
                                                  child: Column(
                                                    children: [
                                                      const Text("Введите пароль",style: TextStyle(fontSize: 20),),
                                                      Container(height: 15,),
                                                      WidgetTemplates.getTextField(organizationPasswordController, "Введите пароль"),
                                                      Container(height: 15,),
                                                      TextButton(
                                                        onPressed: () async{
                                                          if(organizations[index].password==organizationPasswordController.text){
                                                            var a = await joinOrganization(organizations[index].id);
                                                            if(a==1){
                                                              setState(()async{
                                                                await Utility.getOrganisation();
                                                              });
                                                              Navigator.of(context).pop(1);
                                                              // Navigator.of(context).pop(1);
                                                            }
                                                          }else{
                                                            setState(() {
                                                              organizationPasswordController.text="";
                                                            });
                                                            Fluttertoast.showToast(msg: "Неверный пароль");
                                                          }
                                                        },
                                                        child: Text("Вступить",style: TextStyle(
                                                          color: Colors.white
                                                        ),),
                                                        style: ButtonStyles.mainButton(),
                                                      )
                                                    ],
                                                  ),
                                                )
                                            );
                                          }
                                      );
                                    },
                                    leading: Icon(
                                      Icons.people,
                                      color: MyColors.firstAccent,
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