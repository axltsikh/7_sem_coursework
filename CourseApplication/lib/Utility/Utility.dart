import 'package:course_application/CustomModels/GetUserOrganisation.dart';
import 'package:course_application/Utility/DatabaseHandler.dart';

import '../Models/User.dart';

class Utility{
  static String url = "10.0.2.2:1234";
  //10.0.2.2:1234 emulator
  //192.168.144.55:1234 phone
  static int asd = 1;
  static GetUserOrganisation getUserOrganisation = GetUserOrganisation(0, "", "", 0, 0);
  static User user = User(0,"","");
  static DatabaseHandler databaseHandler = DatabaseHandler();
  static bool connectionStatus = false;
}