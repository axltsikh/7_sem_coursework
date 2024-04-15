import 'package:fl_chart/fl_chart.dart';

class ColumnChartData{
  ColumnChartData(this.member,this.amountOfTasks,this.completedTasks,this.uncompletedTasks);
  String member;
  int amountOfTasks;
  int completedTasks;
  int uncompletedTasks;
}