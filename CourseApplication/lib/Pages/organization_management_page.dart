import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/CustomModels/GetUserOrganisation.dart';
import 'package:course_application/Utility/widget_templates.dart';
import 'package:course_application/widgets/cupertino_button_template.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../CustomModels/CustomOrganisationMember.dart';
import '../Utility/colors.dart';
import '../Utility/utility.dart';

class OrganisationManagementPage extends StatefulWidget{
  OrganisationManagementPage(this.organisation){}
  GetUserOrganisation organisation;
  @override
  State<StatefulWidget> createState() => _OrganisationManagementPage(organisation);
}
class _OrganisationManagementPage extends State<OrganisationManagementPage> {
  _OrganisationManagementPage(this.organisation){
    getOrganisationMembers();
    print("orgID: " + organisation.id.toString());
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    setState(() {
      controller.text = organisation.name;
    });
    super.initState();
  }

  TextEditingController controller = TextEditingController();
  GetUserOrganisation organisation;
  List<CustomOrganisationMember> organisationMembers = [];
  Future<void> getOrganisationMembers() async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      var organisationMembersBuffer = await Utility.databaseHandler.getOrganisationMember(Utility.user.id);
      print("orgmemlen: " + organisationMembersBuffer.length.toString());
      setState(() {
        organisationMembers = organisationMembersBuffer;
        controller.text = organisation.name;
      });
    }else {
      final String url = "http://${Utility.url}/organisation/getMembers";
      final response = await http.post(Uri.parse(url),headers: <String,String>{
        'Content-Type': 'application/json;charset=UTF-8',
      },body: jsonEncode(<String,String>{
        'organisationID': organisation.id.toString(),
      }));
      if(response.statusCode==200){
        organisationMembers.clear();
        List<dynamic> bodyBuffer = jsonDecode(response.body);
        bodyBuffer.forEach((bodyBufferElement) {
          if(CustomOrganisationMember.fromJson(bodyBufferElement).id!=organisation.creatorID){
            organisationMembers.add(CustomOrganisationMember.fromJson(bodyBufferElement));
          }
        });
      }else{
        print("Произошла ошибка");
      }
      setState(() {
        controller.text = organisation.name;
      });
    }
  }
  Future<void> deleteOrganisationMember(CustomOrganisationMember member) async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      Fluttertoast.showToast(msg: "Проверьте подключение к сети!");
      return;
    }
    final String url = "http://${Utility.url}/organisation/removeMember?id=" + member.id.toString();
    final response = await http.delete(Uri.parse(url));
    if(response.statusCode==200){
      print("successs");
      setState(() {
        organisationMembers.remove(member);
      });
    }else{
      print("Error: " + response.body);
    }
  }
  Future<void> changeOrgName()async{
    print("changeName");
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      Fluttertoast.showToast(msg: "Проверьте подключение к сети!");
      return;
    }
    final String url = "http://${Utility.url}/organisation/updateName";
    final response = await http.put(Uri.parse(url),headers: <String,String>{
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(<String,String>{
      'organisationID': organisation.id.toString(),
      'newName': controller.text,
    }));
    print(response);
    if(response.statusCode==200){
      setState(() {
        organisation.name=controller.text;
      });
      Fluttertoast.showToast(msg: "Название успешно изменено");
    }else{
      Fluttertoast.showToast(msg: "Произошла ошибка!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: WidgetTemplates.getAppBarWithReturnButton(organisation.name, context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 15,),
            Padding(
              padding: EdgeInsets.only(left: 5,right: 5,top: 5),
              child: Container(
                height: 650,
                child: Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: organisationMembers.length+1,
                      itemBuilder:(BuildContext context, int index){
                        if(index==0){
                          return Column(
                            // margin: EdgeInsets.only(top: 15),
                              children:[
                                SizedBox(height: 15,),
                                Text("Список участников",textAlign: TextAlign.center,style: TextStyle(
                                    fontSize: 18,fontWeight: FontWeight.w500),),
                                SizedBox(height: 15,),
                              ]
                          );
                        }
                        CustomOrganisationMember member = organisationMembers[index-1];
                        return Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: MyColors.secondBackground,
                                child: Icon(
                                  Icons.person,
                                  color: MyColors.firstAccent,
                                ),
                              ),
                              title: Text(member.username),
                              trailing: (organisation.creatorID == Utility.user.id) ? IconButton(
                                icon: Icon(Icons.close,color: MyColors.fourthAccent,),
                                onPressed: (){

                                  deleteOrganisationMember(member);
                                },
                              ) : Text(""),
                            ),
                          ],
                        );
                      }
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}