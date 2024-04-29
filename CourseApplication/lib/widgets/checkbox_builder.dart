import 'package:course_application/CustomModels/SubTaskModel.dart';
import 'package:flutter/material.dart';

import '../Utility/colors.dart';
import '../Utility/utility.dart';

class CheckBoxBuilder extends StatefulWidget{
  CheckBoxBuilder(this.subtask,this.creatorFlag, {super.key});
  SubTaskModel subtask;
  bool creatorFlag;
  @override
  State<StatefulWidget> createState() => _CheckBoxBuilderState(subtask,creatorFlag);
}
class _CheckBoxBuilderState extends State<CheckBoxBuilder> {
  _CheckBoxBuilderState(this.subtask,this.creatorFlag);
  SubTaskModel subtask;
  bool creatorFlag;
  @override
  Widget build(BuildContext context) {
    return createCheckBox();
  }

  Widget createCheckBox(){
    print(creatorFlag);
    if(creatorFlag && subtask.isTotallyDone==false){
      return Checkbox(
        checkColor: Colors.white,
        focusColor: MyColors.firstAccent,
        fillColor: MaterialStateProperty.resolveWith((states){
          if (!states.contains(MaterialState.selected)) {
            return Colors.transparent;
          }
          return MyColors.firstAccent;
        }),
        value: subtask.isDone,
        onChanged: (bool? value) {
          setState(() {
            subtask.isDone = value!;
          });
        },
      );
    }else if(subtask.username!=Utility.user.Username || subtask.isTotallyDone==true){
      return Checkbox(
        value: subtask.isDone,
        onChanged: null,
      );
    }
    return Checkbox(
      value: subtask.isDone,
      onChanged: (bool? value) {
        setState(() {
          subtask.isDone = value!;
        });
      },
    );
  }
}