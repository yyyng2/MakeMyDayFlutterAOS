import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:realm/realm.dart';

import '../domain/entities/schedule_entity.dart';
import '../presentation/bloc/schedule_bloc.dart';

class ScheduleWriteScreen extends StatefulWidget {
  final bool isEdit;
  final ScheduleEntity? scheduleEntity;
  final ScheduleBloc scheduleBloc;

  const ScheduleWriteScreen({super.key, required this.isEdit, required this.scheduleEntity, required this.scheduleBloc});

  @override
  ScheduleWriteScreenState createState() => ScheduleWriteScreenState();
}

class ScheduleWriteScreenState extends State<ScheduleWriteScreen> {
  final TextEditingController _contentController = TextEditingController();
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(microseconds: 100));
    print('ScheduleEntity: ${widget.scheduleEntity}');

    selectedDate = widget.scheduleEntity?.date.toLocal() ?? DateTime.now();
    if (widget.scheduleEntity?.content != null) {
      _contentController.text = (widget.scheduleEntity?.title ?? '')+('\n')+(widget.scheduleEntity?.content ?? '');
    } else {
      _contentController.text = (widget.scheduleEntity?.title ?? '');
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Write Schedule"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (_contentController.text.trim().isEmpty) {
                Navigator.pop(context);
              } else {
                if (widget.isEdit) {
                  final text = _contentController.text;
                  final index = text.indexOf('\n');

                  final title = index == -1 ? text : text.substring(0, index);
                  final content = index == -1 ? '' : text.substring(index + 1);

                  final newItem = ScheduleEntity(
                    widget.scheduleEntity?.id ?? ObjectId(),
                    title,
                    selectedDate,
                    content: content
                  );
                  print('UpdateScheduleItem!!!, $selectedDate');
                  widget.scheduleBloc.add(UpdateScheduleItem(widget.scheduleEntity!.id, newItem, newItem.date));
                } else {
                  final textParts = _contentController.text.split('\n');
                  final title = textParts[0];
                  final content = textParts.length > 1 ? textParts[1] : '';

                  final newItem = ScheduleEntity(
                      widget.scheduleEntity?.id ?? ObjectId(),
                      title,
                      selectedDate,
                      content: content
                  );
                  print('AddScheduleItem!!!, $selectedDate');
                  widget.scheduleBloc.add(
                      AddScheduleItem(newItem, selectedDate));
                }

                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body:
      Stack(
        children: [
      Positioned.fill(
      child: Image.asset(
        'assets/images/background/background.png',
        fit: BoxFit.cover,
      ),
    ),Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );

                if (picked != null && picked != selectedDate) {
                  setState(() {
                    print(picked);
                    selectedDate = picked.toLocal();
                    print(selectedDate);
                  });
                }
              },
              child: Text(
                DateFormat('yyyy-MM-dd').format(selectedDate),
                style: const TextStyle(fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: selectedDate.hour, minute: selectedDate.minute),
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
              child: Text(
                DateFormat('kk:mm').format(selectedDate),
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Enter content…',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    ]));
  }
}
