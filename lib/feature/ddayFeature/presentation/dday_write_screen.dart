import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:realm/realm.dart';

import '../domain/entities/dday_entity.dart';
import '../presentation/bloc/dday_bloc.dart';

class DdayWriteScreen extends StatefulWidget {
  final bool isEdit;
  final DdayEntity? ddayEntity;
  final DdayBloc ddayBloc;

  const DdayWriteScreen({super.key, required this.isEdit, required this.ddayEntity, required this.ddayBloc});

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
    Future.delayed(Duration(microseconds: 100));
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

  void _handleSave() {
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
        widget.ddayBloc.add(UpdateDdayItem(widget.ddayEntity?.id ?? ObjectId(), newItem));
      } else {
        widget.ddayBloc.add(AddDdayItem(newItem));
      }

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
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text("Write Dday"),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
               _handleSave();
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
                        _selectDate();
                      },
                      child: Text(
                        DateFormat('yyyy-MM-dd').format(selectedDate),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    SwitchListTile(
                      activeColor: Colors.blueAccent,
                      title: const Text("오늘부터 1일"),
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
