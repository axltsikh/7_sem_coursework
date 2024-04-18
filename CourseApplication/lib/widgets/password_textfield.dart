import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Utility/colors.dart';

class PasswordTextField extends StatefulWidget{
  PasswordTextField(this.controller,this.obscureText,this.text);
  TextEditingController controller;
  bool obscureText;
  String text;
  @override
  State<StatefulWidget> createState() => _PasswordTextFieldState(controller,obscureText,text);
}
class _PasswordTextFieldState extends State<PasswordTextField>{

  _PasswordTextFieldState(this.controller,this.obscureText,this.text);
  TextEditingController controller;
  bool obscureText;
  String text;

  @override
  Widget build(BuildContext context) {
    return TextField(
        obscureText: obscureText,
        enableSuggestions: false,
        autocorrect: false,
        obscuringCharacter: '*',
        controller: controller,
        cursorColor: MyColors.textColor,
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none),
            suffixIcon: IconButton(
                icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    color: MyColors.firstAccent),
                onPressed: () {
                  setState(() {
                    obscureText = !obscureText;
                  });
                }),
            filled: true,
            fillColor: MyColors.secondBackground,
            hintText: text),
        style: const TextStyle(
            fontFamily: 'SanFranciscoPro',
            fontWeight: FontWeight.w500,
            fontSize: 16));
  }
}
