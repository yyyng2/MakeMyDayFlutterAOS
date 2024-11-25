import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:realm/realm.dart';
import '../../../infrastructure/manager/realm_schema_version_manager.dart';
import '../../ddayFeature/domain/entities/dday_entity.dart';
import '../../../infrastructure/manager/widget_manager.dart';
import 'package:home_widget/home_widget.dart';

class DdaySelectionScreen extends StatefulWidget {
  final String widgetId;

  DdaySelectionScreen({required this.widgetId});

  @override
  _DdaySelectionScreenState createState() => _DdaySelectionScreenState();
}

class _DdaySelectionScreenState extends State<DdaySelectionScreen> {
  late Realm _realm;
  List<DdayEntity> _ddayList = [];

  @override
  void initState() {
    super.initState();
    _initRealm();
    _loadDdays();
  }

  void _initRealm() {
    final config = RealmSchemaVersionManager.getConfig();
    _realm = Realm(config);
  }

  void _loadDdays() {
    setState(() {
      _ddayList = _realm.all<DdayEntity>().toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('chooseDdayTitle'.tr()),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: _ddayList.length,
        itemBuilder: (context, index) {
          final dday = _ddayList[index];
          return ListTile(
            title: Text(dday.title),
            subtitle: Text(DateFormat('yyyy-MM-dd').format(dday.date.toLocal())),
            onTap: () => _selectDday(dday),
          );
        },
      ),
    );
  }

  void _selectDday(DdayEntity selectedDday) async {
    await WidgetManager.saveWidgetDdayId(widget.widgetId, selectedDday.id.toString());
    print('WidgetID: ${widget.widgetId}');
    await HomeWidget.saveWidgetData<String>('ddayId_${widget.widgetId}', selectedDday.id.toString());

    await HomeWidget.updateWidget(
      name: 'HomeScreenWidget',
      qualifiedAndroidName: 'io.github.yyyng2.make_my_day.HomeScreenWidget',
    );

    // 앱 강제 종료
    SystemNavigator.pop();
  }

  @override
  void dispose() {
    _realm.close();
    super.dispose();
  }
}