import 'package:course_application/Models/subtask.dart';
import 'package:course_application/widgets/cupertino_button_template.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../CustomModels/CustomProject.dart';
import '../Utility/button_styles.dart';
import '../Utility/colors.dart';
import '../Utility/widget_templates.dart';
class AddParentTaskDialog extends StatefulWidget{
  AddParentTaskDialog(this.project){}
  CustomProject project;
  @override
  State<StatefulWidget> createState() => _AddParentTaskDialog(project);
}

class _AddParentTaskDialog extends State<AddParentTaskDialog> {
  _AddParentTaskDialog(this.project){
    print(project.id);
  }
  CustomProject project;
  TextEditingController controller = TextEditingController();

  void returnSubTask(){
    if(controller.text.length < 3){
      Fluttertoast.showToast(msg: "Минимальная длина названия задачи - 3 символа!");
      return;
    }
    subTask.title=controller.text;
    subTask.ProjectID=project.id;
    Navigator.pop(context,subTask);
  }

  SubTask subTask = SubTask.empty();
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 250,
        height: 220,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text("Добавление задачи",style: TextStyle(
                  fontSize: 20
              ),),
              const SizedBox(height: 15,),
              WidgetTemplates.getTextField(controller, "Введите название задачи"),
              const SizedBox(height: 15,),
              SizedBox(
                width: 260,
                height: 50,
                child: TextButton(
                  onPressed: returnSubTask,
                  style: ButtonStyles.mainButton(),
                  child: Text("Сохранить",
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
    );
  }

}