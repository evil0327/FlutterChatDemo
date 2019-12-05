class AppEvent{
  EventType eventType;

  AppEvent({this.eventType});
}

enum EventType{
  USER_UPDATED
}