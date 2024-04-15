import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Colors.dart';

class WidgetTemplates{
  static Widget getTextField(TextEditingController controller, String text){
    return TextField(
        controller: controller,
        cursorColor: MyColors.textColor,
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide.none),
            filled: true,
            fillColor: MyColors.secondBackground,
            hintText: text),
        style: const TextStyle(
            fontFamily: 'SanFranciscoPro',
            fontWeight: FontWeight.w500,
            fontSize: 16));
  }
  static Widget getPasswordTextField(
      TextEditingController controller, bool obscureText, String text) {
    return TextField(
        obscureText: obscureText,
        enableSuggestions: false,
        autocorrect: false,
        obscuringCharacter: '*',
        controller: controller,
        cursorColor: MyColors.textColor,
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide.none),
            suffixIcon: IconButton(
                icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    color: MyColors.firstAccent),
                onPressed: () {
                  obscureText=!obscureText;
                }),
            filled: true,
            fillColor: MyColors.secondBackground,
            hintText: text),
        style: const TextStyle(
            fontFamily: 'SanFranciscoPro',
            fontWeight: FontWeight.w500,
            fontSize: 16));
  }
  static PreferredSize getAppBar(String text){
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: Container(
        margin: EdgeInsets.only(top: 50),
        width: 324,
        height: 66,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35)
          ),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(text,textAlign: TextAlign.center,style: TextStyle(
                  fontSize: 20
              ),)
            ],
          )
        ),
      ),
    );
  }
  static PreferredSize getAppBarWithReturnButton(String text,BuildContext context){
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: Container(
        margin: EdgeInsets.only(top: 50),
        width: 324,
        height: 66,
        child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35)
            ),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                            margin: const EdgeInsets.only(left: 16),
                            child: const Icon(Icons.arrow_back_ios))),
                    SizedBox(width: 70,),
                    Text(text,textAlign: TextAlign.center,style: TextStyle(
                        fontSize: 20
                    ),),
                  ],
                )
              ],
            )
        ),
      ),
    );
  }
}