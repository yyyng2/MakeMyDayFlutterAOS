enum NotificationType {
  always,
  monthBefore,
  weekBefore,
  dayBefore
}

extension NotificationTypeExtension on NotificationType {
  int toInt() {
    return index;
  }

  static NotificationType fromInt(int value) {
    print("fromInt type:$value, ${NotificationType.values}");
    return NotificationType.values[value];
  }
}