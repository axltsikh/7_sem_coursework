import 'package:flutter/material.dart';

import 'colors.dart';

class WidgetTemplates{
  static Widget getTextField(TextEditingController controller, String text){
    return TextField(
        controller: controller,
        cursorColor: MyColors.textColor,
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none),
            filled: true,
            fillColor: MyColors.secondBackground,
            hintText: text),
        style: const TextStyle(
            fontFamily: 'SanFranciscoPro',
            fontWeight: FontWeight.w400,
            fontSize: 16));
  }
  static PreferredSize getAppBar(String text){
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: Container(
        margin: const EdgeInsets.only(top: 50),
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
              Text(text,textAlign: TextAlign.center,style: const TextStyle(
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
      preferredSize: const Size.fromHeight(120),
      child: Container(
        margin: const EdgeInsets.only(top: 50),
        width: 324,
        height: 66,
        child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35)
            ),
            color: Colors.white,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Positioned(
                  left: 5,
                  top:17,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                        margin: const EdgeInsets.only(left: 16),
                        child: const Icon(Icons.arrow_back_ios))),),
                Text(text,textAlign: TextAlign.center,style: const TextStyle(
                    fontSize: 20
                ),),
              ],
            ),
        ),
      ),
    );
  }
}