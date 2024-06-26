import 'package:course_application/CustomModels/CustomProjectMember.dart';
import 'package:flutter/material.dart';



class AddSubTaskExecutorDialog extends StatefulWidget{
  AddSubTaskExecutorDialog(this.projectMembers, {super.key});
  List<CustomProjectMember> projectMembers;
  @override
  State<StatefulWidget> createState() => _AddSubTaskExecutorDialog(projectMembers);
}

class _AddSubTaskExecutorDialog extends State<AddSubTaskExecutorDialog> {
  _AddSubTaskExecutorDialog(this.projectMembers);
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
              const Text("Выберите исполнителя",style: TextStyle(
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
                    itemCount: projectMembers.length,
                    itemBuilder: (BuildContext context,int index){
                      return ListTile(
                        onTap: (){
                          Navigator.pop(context,projectMembers[index]);
                        },
                        title: Text(projectMembers[index].username),
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
  }
}