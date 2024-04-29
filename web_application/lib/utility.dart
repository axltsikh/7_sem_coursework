import 'Models/user.dart';

class Utility{

  //192,168
  static User user = User(0,"","");
  static String url = "127.0.0.1:1234";
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
    return day + " " + month + " " + year;
  }
}