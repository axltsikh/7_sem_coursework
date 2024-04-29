import 'package:course_application/CustomModels/GetUserOrganisation.dart';
import 'package:course_application/Utility/database_handler.dart';

import '../Models/user.dart';

class Utility{
  static String url = "192.168.150.55:1234";
  //10.0.2.2:1234 emulator
  //192.168.48.1:1234 phone
  static int asd = 1;
  static GetUserOrganisation getUserOrganisation = GetUserOrganisation(0, "", "", 0, 0);
  static User user = User(0,"","");
  static DatabaseHandler databaseHandler = DatabaseHandler();
  static bool connectionStatus = false;

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