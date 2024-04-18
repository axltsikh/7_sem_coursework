import 'dart:ui';

import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:web_application/Models/event.dart';

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Event> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).dateTime;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).dateTime;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return false;
  }

  Event _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    late final Event meetingData;
    if (meeting is Event) {
      meetingData = meeting;
    }
    return meetingData;
  }
}