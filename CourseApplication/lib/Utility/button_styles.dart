import 'package:flutter/material.dart';

import 'colors.dart';

class ButtonStyles {

  static ButtonStyle mainButton(){
    return ButtonStyle(
        backgroundColor: MaterialStateProperty.all(MyColors.firstAccent),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)))
    );
  }
  static ButtonStyle secondaryButton(){
    return ButtonStyle(
        backgroundColor: MaterialStateProperty.all(MyColors.secondAccent),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)))
    );
  }

  static Widget getSecondaryButtonChild(String text){
    return Container(
      alignment: Alignment.center,
      width: 330,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: MyColors.firstAccent,
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: MyColors.firstAccent)),
    );
  }

  static Widget getMainButtonChild(String text){
    return Container(
      alignment: Alignment.center,
      width: 330,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: MyColors.firstAccent,
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 16,
              color: MyColors.backgroundColor)),
    );
  }

}
