
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:intl/intl.dart';
import 'package:realm/realm.dart';

import '../domain/entities/schedule_entity.dart';
import '../presentation/bloc/schedule_bloc.dart';

class ScheduleWriteScreen extends StatefulWidget {
  final bool isEdit;
  final ScheduleEntity? scheduleEntity;
  final ScheduleBloc scheduleBloc;
  final bool isDarkTheme;

  const ScheduleWriteScreen({
    super.key,
    required this.isEdit,
    required this.scheduleEntity,
    required this.scheduleBloc,
    required this.isDarkTheme,
  });

  @override
  ScheduleWriteScreenState createState() => ScheduleWriteScreenState();
}

class ScheduleWriteScreenState extends State<ScheduleWriteScreen> {
  final TextEditingController _contentController = TextEditingController();
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(microseconds: 100));
    print('ScheduleEntity: ${widget.scheduleEntity}');

    selectedDate = widget.scheduleEntity?.date.toLocal() ?? DateTime.now();
    if (widget.scheduleEntity?.content != null) {
      _contentController.text = (widget.scheduleEntity?.title ?? '') +
          ('\n') +
          (widget.scheduleEntity?.content ?? '');
    } else {
      _contentController.text = (widget.scheduleEntity?.title ?? '');
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
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
            widget.isEdit ? "Edit Schedule" : "Write Schedule",
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
                if (_contentController.text.trim().isEmpty) {
                  Navigator.pop(context);
                } else {
                  if (widget.isEdit) {
                    final text = _contentController.text;
                    final index = text.indexOf('\n');

                    final title = index == -1 ? text : text.substring(0, index);
                    final content =
                        index == -1 ? '' : text.substring(index + 1);

                    final newItem = ScheduleEntity(
                        widget.scheduleEntity?.id ?? ObjectId(),
                        title,
                        selectedDate,
                        content: content);

                    widget.scheduleBloc.add(UpdateScheduleItem(
                        widget.scheduleEntity!.id, newItem, newItem.date));
                  } else {
                    final textParts = _contentController.text.split('\n');
                    final title = textParts[0];
                    final content = textParts.length > 1 ? textParts[1] : '';

                    final newItem = ScheduleEntity(
                        widget.scheduleEntity?.id ?? ObjectId(),
                        title,
                        selectedDate,
                        content: content);

                    widget.scheduleBloc
                        .add(AddScheduleItem(newItem, selectedDate));
                  }
                  Navigator.pop(context);
                }
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
                            color: widget.isDarkTheme
                                ? Colors.white
                                : Colors.black,
                            fontSize: 18),
                      ),
                    )),
                const SizedBox(height: 10),
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
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                              hour: selectedDate.hour,
                              minute: selectedDate.minute),
                        );

                        if (picked != null) {
                          setState(() {
                            selectedDate = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              picked.hour,
                              picked.minute,
                            ).toLocal();
                            print(picked);
                            print(selectedDate);
                          });
                        }
                      },
                      icon: Icon(
                        Icons.access_time,
                        color: widget.isDarkTheme ? Colors.white : Colors.black,
                      ),
                      label: Text(
                        DateFormat('a hh:mm').format(selectedDate),
                        style: TextStyle(
                            color: widget.isDarkTheme
                                ? Colors.white
                                : Colors.black,
                            fontSize: 18),
                      ),
                    )),
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
