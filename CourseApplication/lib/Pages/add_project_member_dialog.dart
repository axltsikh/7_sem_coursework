import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:course_application/CustomModels/CustomOrganisationMember.dart';
import 'package:flutter/material.dart';
import '../CustomModels/CustomProjectMember.dart';
import '../Utility/utility.dart';


class AddProjectMemberDialog extends StatefulWidget{
  AddProjectMemberDialog(this.projectMembers, {super.key});
  List<CustomProjectMember> projectMembers;
  @override
  State<StatefulWidget> createState() => _AddProjectMemberDialog(projectMembers);
}

class _AddProjectMemberDialog extends State<AddProjectMemberDialog> {
  _AddProjectMemberDialog(this.projectMembers){
    getOrganisationMembers();
    print(Utility.user.id);
    print(projectMembers.length);
  }
  Future<void> getOrganisationMembers() async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      var organisationMembersBuffer = await Utility.databaseHandler.getOrganisationMember(Utility.user.id);
      setState(() {
        organisationMembers.clear();
        for (var element in organisationMembersBuffer) {
          if(!projectMembers.any((subelement) => subelement.organisationID == element.id)){
            setState(() {
              organisationMembers.add(element);
            });
          }
        }
      });
    }else {
      final String url = "http://${Utility.url}/organisation/getMembers";
      final response = await http.post(Uri.parse(url),headers: <String,String>{
        'Content-Type': 'application/json;charset=UTF-8',
      },body: jsonEncode(<String,String>{
        'organisationID': Utility.getUserOrganisation.id.toString(),
      }));
      print(response.body);
      if(response.statusCode==200){
        organisationMembers.clear();
        List<dynamic> bodyBuffer = jsonDecode(response.body);
        for (var bodyBufferElement in bodyBuffer) {

          print(CustomOrganisationMember.fromJson(bodyBufferElement).id);
          print(CustomOrganisationMember.fromJson(bodyBufferElement).username);

          if(!projectMembers.any((element) => element.username == CustomOrganisationMember.fromJson(bodyBufferElement).username) &&
              CustomOrganisationMember.fromJson(bodyBufferElement).username != Utility.user.Username){
            setState(() {
              organisationMembers.add(CustomOrganisationMember.fromJson(bodyBufferElement));
            });
          }
        }
      }else{
        print("Произошла ошибка");
      }
    }
  }
  List<CustomOrganisationMember> organisationMembers=[];
  List<CustomProjectMember> projectMembers;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 250,
        height: 350,
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              const Text("Выберите участника",style: TextStyle(
                  fontSize: 18
              ),),
              const SizedBox(height: 5,),
              Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(33),bottomRight: Radius.circular(33))
                ),
                height: 319,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: organisationMembers.length,
                    itemBuilder: (BuildContext context,int index){
                      return ListTile(
                        onTap: (){
                          CustomProjectMember buffer = CustomProjectMember(0, organisationMembers[index].username, organisationMembers[index].id,0);
                          Navigator.pop(context,buffer);
                        },
                        title: Text(organisationMembers[index].username),
                      );
                      return ConstrainedBox(
                        constraints: const BoxConstraints(
                            minHeight: 50
                        ),
                        child: Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: InkWell(
                              onTap: () => Navigator.pop(context,projectMembers[index]),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(projectMembers[index].username),
                              ),
                            )
                        ),
                      );
                    }
                ),
              )
            ],
          ),
        )
    );
    return SizedBox(
        width: 250,
        height: 350,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const Text("Добавление участника"),
              const Divider(thickness: 1,color: Colors.blue),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 285
                ),
                child:  ListView.builder(
                    shrinkWrap: true,
                    itemCount: organisationMembers.length,
                    itemBuilder: (BuildContext context,int index){
                      return ConstrainedBox(
                        constraints: const BoxConstraints(
                            minHeight: 50
                        ),
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: InkWell(
                            onTap: (){
                              CustomProjectMember buffer = CustomProjectMember(0, organisationMembers[index].username, organisationMembers[index].id,0);
                              Navigator.pop(context,buffer);
                            },
                              child: Align(
                              alignment: Alignment.center,
                              child: Text(organisationMembers[index].username),
                            ),
                          )
                        ),
                      );
                    }
                ),
              ),
            ],
          ),
        )
    );
  }

}