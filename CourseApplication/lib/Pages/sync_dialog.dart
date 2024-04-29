import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/Utility/button_styles.dart';
import 'package:course_application/Utility/colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Utility/utility.dart';

class SyncDialog extends StatefulWidget{
  const SyncDialog({super.key});
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
      Future.delayed(const Duration(seconds: 3)).then((value)async{
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
    Future.delayed(const Duration(seconds: 5)).then((value)async{
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
      return const Text("Желаете провести\nсинхронизацию?",style: TextStyle(fontSize: 17),textAlign: TextAlign.center,);
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
            style: ButtonStyles.mainButton(),
            child: const Text("Да",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 16),),
          ),),
          SizedBox(width: 80,child: TextButton(
            onPressed: decline,
            style: ButtonStyles.mainButton(),
            child: const Text("Нет",style: TextStyle(color: Colors.white,fontSize: 16),),
          ),),
        ],
      );
    }else{
      return const Text("");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 250,
        height: 180,
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              const SizedBox(height: 15,),
              const Text("Синхронизация",style: TextStyle(fontSize: 18),),
              const SizedBox(height: 10,),
              getState(),
              const SizedBox(height: 15,),
              buttons()
            ],
          ),
        )
    );
  }

}