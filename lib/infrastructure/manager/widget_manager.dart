import 'package:shared_preferences/shared_preferences.dart';

class WidgetManager {
  static const String _prefix = 'widget_';

  static Future<void> saveWidgetDdayId(String widgetId, String ddayId) async {
    final prefs = await SharedPreferences.getInstance();
    print('saveWidgetDdayId: $widgetId');
    await prefs.setString('${_prefix}$widgetId', ddayId);
  }

  static Future<String?> getWidgetDdayId(String widgetId) async {
    final prefs = await SharedPreferences.getInstance();
    print('getWidgetDdayId: $widgetId');
    return prefs.getString('${_prefix}$widgetId');
  }

  static Future<void> removeWidgetDdayId(String widgetId) async {
    final prefs = await SharedPreferences.getInstance();
    print('removeWidgetDdayId: $widgetId');
    await prefs.remove('${_prefix}$widgetId');
  }
}