import 'dart:ui';

class Event{
  Event(this.eventName, this.dateTime, this.background);

  /// Event name which is equivalent to subject property of [Appointment].
  String eventName;

  DateTime dateTime;

  /// Background which is equivalent to color property of [Appointment].
  Color background;

  /// IsAllDay which is equivalent to isAllDay property of [Appointment].
  // bool isAllDay;
}