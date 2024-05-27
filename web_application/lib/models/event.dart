import 'dart:ui';

class Event{
  Event(this.eventName, this.dateTime, this.background);
  String eventName;
  DateTime dateTime;
  Color background;

  /// IsAllDay which is equivalent to isAllDay property of [Appointment].
  // bool isAllDay;
}