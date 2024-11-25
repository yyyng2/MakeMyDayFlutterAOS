import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:realm/realm.dart';

import '../domain/entities/dday_entity.dart';
import '../presentation/bloc/dday_bloc.dart';
import 'enums/notification_type.dart';

class DdayWriteScreen extends StatefulWidget {
  final bool isEdit;
  final DdayEntity? ddayEntity;
  final DdayBloc ddayBloc;
  final bool isDarkTheme;

  const DdayWriteScreen(
      {super.key,
        required this.isEdit,
        required this.ddayEntity,
        required this.ddayBloc,
        required this.isDarkTheme});

  @override
  DdayWriteScreenState createState() => DdayWriteScreenState();
}

class DdayWriteScreenState extends State<DdayWriteScreen> {
  final TextEditingController _contentController = TextEditingController();
  late DateTime selectedDate;
  bool repeatAnniversary = false;
  late NotificationType notificationType;
  bool dayPlus = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(microseconds: 100));
    selectedDate = widget.ddayEntity?.date.toLocal() ?? DateTime.now();
    _contentController.text = (widget.ddayEntity?.title ?? '');
    print(widget.ddayEntity?.repeatAnniversary);
    repeatAnniversary = widget.ddayEntity?.repeatAnniversary ?? false;
    notificationType = NotificationTypeExtension.fromInt(widget.ddayEntity?.notificationType ?? 0);
    dayPlus = widget.ddayEntity?.dayPlus ?? false;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_contentController.text.trim().isEmpty) {
      Navigator.pop(context);
    } else {
      final title = _contentController.text;

      var intNotificationType = notificationType.toInt();

      final newItem = DdayEntity(
        widget.ddayEntity?.id ?? ObjectId(),
        title,
        selectedDate,
        repeatAnniversary,
        repeatAnniversary ? intNotificationType: 0,
        repeatAnniversary ? false : dayPlus,
      );
      print("Just before update - repeatAnniversary: $repeatAnniversary, intNotification: $intNotificationType");
      print("before save - repeatAnniversary: ${newItem.repeatAnniversary}, intNotificationType: ${newItem.notificationType}");

      if (widget.isEdit) {
        final ddayId = widget.ddayEntity?.id ?? ObjectId();
        widget.ddayBloc
            .add(UpdateDdayItem(ddayId, newItem));
      } else {
        widget.ddayBloc.add(AddDdayItem(newItem));
      }

      final savedItem = await widget.ddayBloc.usecase.repository.fetchDdayItems();
      print("Saved DdayEntity - repeatAnniversary: ${savedItem.first.repeatAnniversary}, notificationType: ${savedItem.first.notificationType}");

      await HomeWidget.saveWidgetData<String>('force_update', DateTime.now().toString());
      await HomeWidget.updateWidget(
        name: 'HomeScreenWidget',
        qualifiedAndroidName: 'io.github.yyyng2.make_my_day.HomeScreenWidget',
      );

      Navigator.pop(context);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked.toLocal();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: widget.isDarkTheme ? Colors.black87 : Colors.white,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: widget.isDarkTheme ? Colors.white : Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            widget.isEdit ? "editDdayTitle".tr() : "writeDdayTitle".tr(),
            style: TextStyle(
                color: widget.isDarkTheme ? Colors.white : Colors.black),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.check,
                color: widget.isDarkTheme ? Colors.white : Colors.black,
              ),
              onPressed: () {
                _handleSave();
              },
            ),
          ],
        ),
        body: Stack(children: [
          Positioned.fill(
              child: Image.asset(
                widget.isDarkTheme
                    ? 'assets/images/background/background_black.png'
                    : 'assets/images/background/background.png',
                fit: BoxFit.cover,
              )
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.isDarkTheme ? Colors.white : Colors.black,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(
                          8.0), // Optional: Adds rounded corners
                    ),
                    child: TextButton.icon(
                      onPressed: () async {
                        _selectDate();
                      },
                      icon: Icon(
                        Icons.calendar_today,
                        color: widget.isDarkTheme ? Colors.white : Colors.black,
                      ),
                      label: Text(
                        DateFormat('yyyy-MM-dd').format(selectedDate),
                        style: TextStyle(
                            fontSize: 18,
                            color: widget.isDarkTheme
                                ? Colors.white
                                : Colors.black),
                      ),
                    )),
                // Anniversary Radio Button
                SwitchListTile(
                  activeColor: Colors.blueAccent,
                  title: Text(
                    "ddayRepeatAnniversary".tr(),
                    style: TextStyle(
                        color: widget.isDarkTheme ? Colors.white : Colors.black),
                  ),
                  value: repeatAnniversary,
                  onChanged: (bool? value) {
                    setState(() {
                      repeatAnniversary = value ?? false;
                    });
                  },
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                // Show either Day Plus switch or Notification Type dropdown based on anniversary selection
                if (!repeatAnniversary)
                  SwitchListTile(
                    activeColor: Colors.blueAccent,
                    title: Text(
                      "ddayWritePlusDay".tr(),
                      style: TextStyle(
                          color: widget.isDarkTheme ? Colors.white : Colors.black),
                    ),
                    value: dayPlus,
                    onChanged: (bool value) {
                      setState(() {
                        dayPlus = value;
                      });
                    },
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Text(
                          "ddayNotificationType".tr(),
                          style: TextStyle(
                            color: widget.isDarkTheme ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 100),
                        Expanded(
                          child: DropdownButton<NotificationType>(
                            value: notificationType,
                            isExpanded: true,
                            dropdownColor: widget.isDarkTheme ? Colors.black87 : Colors.white,
                            style: TextStyle(
                              color: widget.isDarkTheme ? Colors.white : Colors.black,
                            ),
                            items: NotificationType.values.map((NotificationType type) {
                              return DropdownMenuItem<NotificationType>(
                                value: type,
                                child: Text(type.name.tr()),
                              );
                            }).toList(),
                            onChanged: (NotificationType? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  notificationType = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                TextField(
                    controller: _contentController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'commonWritePlaceHolder'.tr(),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color:
                          widget.isDarkTheme ? Colors.white : Colors.black,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color:
                          widget.isDarkTheme ? Colors.blue : Colors.black,
                        ),
                      ),
                    ),
                    cursorColor:
                    widget.isDarkTheme ? Colors.blue : Colors.black,
                    style: TextStyle(
                        color:
                        widget.isDarkTheme ? Colors.white : Colors.black)),
              ],
            ),
          ),
        ]));
  }
}
