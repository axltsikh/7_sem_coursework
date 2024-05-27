import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/CustomModels/GetUserOrganisation.dart';
import 'package:course_application/Utility/database_handler.dart';
import 'package:http/http.dart' as http;

import '../Models/user.dart';

class Utility{
  static String url = "10.0.2.2:1234";
  //10.0.2.2:1234 emulator
  //192.168.48.1:1234 phone
  static int asd = 1;
  static GetUserOrganisation getUserOrganisation = GetUserOrganisation(0, "", "", 0, 0);
  static User user = User(0,"","");
  static DatabaseHandler databaseHandler = DatabaseHandler();
  static bool connectionStatus = false;
  static Future<void> getOrganisation() async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      var org = await Utility.databaseHandler.getUserOrganisation();
      Utility.getUserOrganisation = org;
    }else{
      final String url = "http://${Utility.url}/profile/getUserOrganisation?id=${Utility.user.id}";
      final response = await http.get(Uri.parse(url));
      if(response.statusCode == 200){
        print(response.toString());
        Map<String,dynamic> bodyBuffer = jsonDecode(response.body);
        Utility.getUserOrganisation = GetUserOrganisation.fromJson(bodyBuffer);
        print("вы состоите в организации");
      }
      else{
        print("не состоите");
        Utility.getUserOrganisation = GetUserOrganisation(-1, "Вы не состоите в организации", "", -1, -1);
      }
    }
  }
  static String getDate(String date){
    String month;
    String day = date.substring(8,10);
    String year = date.substring(0,4);
    switch(date.substring(5,7)){
      case "01": month = "января";break;
      case "02":month = "февраля";break;
      case "03": month = "марта";break;
      case "04":month = "апреля";break;
      case "05":month = "мая";break;
      case "06":month =  "июня";break;
      case "07":month = "июля";break;
      case "08":month = "августа";break;
      case "09":month = "сентября";break;
      case "10":month = "октября";break;
      case "11":month = "ноября";break;
      default: month = "декабря";break;
    }
    return "$day $month $year";
  }

}