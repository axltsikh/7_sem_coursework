import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/Models/subtask.dart';
import 'package:course_application/Utility/button_styles.dart';
import 'package:course_application/Utility/colors.dart';
import 'package:course_application/widgets/cupertino_button_template.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../CustomModels/CustomProject.dart';
import '../Utility/utility.dart';
import 'project_page.dart';
class SyncDialog extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _SyncDialog();
}

class _SyncDialog extends State<SyncDialog> {

  void sync()async{
    state=true;
    setState(() {
      getState();
    });
    Fluttertoast.showToast(msg: "Синхронизация началсь");
    await uploadMyData().then((value) {
      Future.delayed(Duration(seconds: 3)).then((value)async{
        await getGlobalData().then((value){
          Fluttertoast.showToast(msg: "Синхронизация прошла успешно");
          Navigator.pop(context);
        });
      });
    });
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
  void decline(){
    Navigator.pop(context);
  }
  bool state=false;
  Widget getState(){
    if(!state){
      return Text("Желаете провести\nсинхронизацию?",style: TextStyle(fontSize: 17),textAlign: TextAlign.center,);
    }else{
      return Center(child: CircularProgressIndicator(color: MyColors.firstAccent,));
    }
  }
  Widget buttons(){
    if(!state){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(width: 80,child: TextButton(
            onPressed: sync,
            child: Text("Да",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 16),),
            style: ButtonStyles.mainButton(),
          ),),
          SizedBox(width: 80,child: TextButton(
            onPressed: decline,
            child: Text("Нет",style: TextStyle(color: Colors.white,fontSize: 16),),
            style: ButtonStyles.mainButton(),
          ),),
        ],
      );
    }else{
      return Text("");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 250,
        height: 180,
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SizedBox(height: 15,),
              Text("Синхронизация",style: TextStyle(fontSize: 18),),
              SizedBox(height: 10,),
              getState(),
              SizedBox(height: 15,),
              buttons()
            ],
          ),
        )
    );
  }

}