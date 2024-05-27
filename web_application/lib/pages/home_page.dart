import 'dart:html';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:side_navigation/side_navigation.dart';
import 'package:web_application/Pages/calendar_page.dart';

import '../my_colors.dart';
import 'main_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }
  List<Widget> views = [
    MainPage(),
    CalendarPage()
  ];
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
          children: [
            SideNavigationBar(
                theme: SideNavigationBarTheme(
                    itemTheme: SideNavigationBarItemTheme(
                      // unselectedBackgroundColor: AppColors.black,
                        selectedBackgroundColor: MyColors.firstAccent,
                        selectedItemColor: Colors.white,
                        unselectedItemColor: Colors.black
                    ), togglerTheme: SideNavigationBarTogglerTheme.standard(), dividerTheme: SideNavigationBarDividerTheme.standard()
                ),
                selectedIndex: selectedIndex,
                items: const [
                  SideNavigationBarItem(
                    icon: Icons.dashboard,
                    label: 'Проекты',
                  ),
                  SideNavigationBarItem(
                    icon: Icons.calendar_month,
                    label: 'Календарь',
                  ),
                ],
                header: SideNavigationBarHeader(
                  image: Image.asset("assets/images/logo.png"), title: Text(""), subtitle: Text("")
                ),
                footer:SideNavigationBarFooter(
                  label: ListTile(
                    onTap: ()async{
                      final prefs = await SharedPreferences.getInstance();
                      prefs.remove("id");
                      prefs.remove("username");
                      prefs.remove("password");
                      Navigator.of(context).pop();
                    },
                    leading: Icon(Icons.exit_to_app,color: MyColors.fourthAccent,),
                    title: Text("Выйти",style: TextStyle(
                      color: MyColors.fourthAccent
                    ),),
                  )
                ),
                expandable: false,
                onTap: (index){
                  setState(() {
                    selectedIndex = index;
                  });
                }
            ),
            Expanded(
              child: Navigator(
                onGenerateRoute: (route){
                  return MaterialPageRoute(builder: (context)=>views.elementAt(selectedIndex));
                },
              ),
            )
          ],
        )
    );
  }
}