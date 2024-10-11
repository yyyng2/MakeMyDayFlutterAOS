import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:make_my_day/infrastructure/manager/widget_manager.dart';
import 'package:realm/realm.dart';

import '../domain/entities/dday_entity.dart';
import '../presentation/bloc/dday_bloc.dart';

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
  bool dayPlus = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(microseconds: 100));
    print('ddayEntity: ${widget.ddayEntity}');

    selectedDate = widget.ddayEntity?.date.toLocal() ?? DateTime.now();
    _contentController.text = (widget.ddayEntity?.title ?? '');
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

      final newItem = DdayEntity(
        widget.ddayEntity?.id ?? ObjectId(),
        title,
        selectedDate,
        dayPlus,
      );

      if (widget.isEdit) {
        final ddayId = widget.ddayEntity?.id ?? ObjectId();
        widget.ddayBloc
            .add(UpdateDdayItem(ddayId, newItem));
      } else {
        widget.ddayBloc.add(AddDdayItem(newItem));
      }

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
            widget.isEdit ? "Edit Dday" : "Write Dday",
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
                SwitchListTile(
                  activeColor: Colors.blueAccent,
                  title: Text(
                    "오늘부터 1일",
                    style: TextStyle(
                        color:
                            widget.isDarkTheme ? Colors.white : Colors.black),
                  ),
                  value: dayPlus,
                  onChanged: (bool value) {
                    setState(() {
                      dayPlus = value;
                    });
                  },
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                const SizedBox(height: 16),
                TextField(
                    controller: _contentController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Enter content…',
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
