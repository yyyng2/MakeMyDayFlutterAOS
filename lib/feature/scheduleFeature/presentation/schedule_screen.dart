import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realm/realm.dart';
import 'package:intl/intl.dart';

import '../../commonFeature/presentation/navigation/app_router.dart';
import '../data/repositories/schedule_repository_impl.dart';
import '../domain/usecases/schedule_usecase.dart';
import '../domain/entities/schedule_entity.dart';
import 'bloc/schedule_bloc.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ScheduleScreenState createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen> {
  late Realm realm;
  late ScheduleRepositoryImpl scheduleRepositoryImpl;
  late ScheduleUsecase scheduleUsecase;
  late ScheduleBloc scheduleBloc;
  DateTime currentDate = DateTime.now();
  int targetMonth = DateTime.now().month;
  List<DateTime> dates = [];

  @override
  void initState() {
    super.initState();
    final config = Configuration.local([ScheduleEntity.schema]);
    print(config.path);
    realm = Realm(config);
    scheduleRepositoryImpl = ScheduleRepositoryImpl(realm);
    scheduleUsecase = ScheduleUsecase(repository: scheduleRepositoryImpl);
    scheduleBloc = ScheduleBloc(scheduleUsecase);

    scheduleBloc.add(FetchScheduleItems(currentDate));
  }

  @override
  void dispose() {
    realm.close();
    super.dispose();
  }

  DateTime getCurrentMonthDate() {
    return DateTime(currentDate.year, targetMonth, 1);
  }

  List<DateTime> extractDates() {
    final firstDayOfMonth =
        DateTime(getCurrentMonthDate().year, getCurrentMonthDate().month, 1);
    final lastDayOfMonth = DateTime(
        getCurrentMonthDate().year, getCurrentMonthDate().month + 1, 0);
    List<DateTime> days = [];

    for (int i = 0; i < firstDayOfMonth.weekday; i++) {
      days.add(DateTime(0));
    }

    for (int i = 0; i < lastDayOfMonth.day; i++) {
      days.add(DateTime(
          getCurrentMonthDate().year, getCurrentMonthDate().month, i + 1));
    }

    return days;
  }

  void handleMonthChange() {
    setState(() {
      currentDate = getCurrentMonthDate();
      scheduleBloc.add(FetchScheduleItems(currentDate));
    });
  }

  void handleDateChange(DateTime newDate) {
    setState(() {
      currentDate = newDate;
      scheduleBloc.add(FetchScheduleItems(currentDate));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //     automaticallyImplyLeading: false,
          // title: const Text('Schedule')
      // ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background/background.png',
              fit: BoxFit.cover,
            ),
          ),
          BlocBuilder<ScheduleBloc, ScheduleState>(
            bloc: scheduleBloc,
            builder: (context, state) {
              if (state is ScheduleInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ScheduleLoaded) {
                return Column(
                  children: [
                    _buildHeader(),
                    _buildDaysOfWeek(),
                    _buildCalendarGrid(state.scheduleItems),
                    _buildScheduleList(state.scheduleTargetItems),
                  ],
                );
              } else if (state is ScheduleError) {
                return Center(
                    child: Text('Failed to load notices: ${state.message}'));
              } else {
                return const Center(child: Text('Unknown state'));
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'scheduleScreen',
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.scheduleWrite, arguments: {
            'isEdit': false,
            'scheduleObject': ScheduleEntity(ObjectId(), '', currentDate),
            'scheduleBloc': scheduleBloc
          });
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    final monthYear = DateFormat('MMMM yyyy').format(getCurrentMonthDate());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(monthYear,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    targetMonth -= 1;
                    if (targetMonth < 1) {
                      targetMonth = 12; // Wrap around to December
                    }
                    handleMonthChange();
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    targetMonth += 1;
                    if (targetMonth > 12) {
                      targetMonth = 1;
                    }
                    handleMonthChange();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeek() {
    final daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Row(
      children: daysOfWeek.map((day) {
        return Expanded(
          child: Center(
            child: Text(day,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(List<ScheduleEntity> scheduleItems) {
    final dates = extractDates();

    return Expanded(
      child: GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];

          if (date.year == 0) {
            return const SizedBox
                .shrink(); // Empty space for previous month days
          }

          final isSelected = date.isSameDay(currentDate);
          final hasTask =
              // scheduleItems.any((item) => item.date.toLocal().isSameDay(date));

          scheduleItems.any((item) {
            final isSame = item.date.toLocal().isSameDay(date);
            // print('item.date: ${item.date.toLocal()}\ndate: $date');
            return isSame;
          });

          return GestureDetector(
            onTap: () {
              handleDateChange(date);
              scheduleBloc.add(FetchScheduleItemsByDate(date));
            },
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blueAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  if (hasTask)
                    const Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child:
                          CircleAvatar(radius: 2, backgroundColor: Colors.red),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleList(List<ScheduleEntity> scheduleItems) {
    return Expanded(
      child: ListView.builder(
        itemCount: scheduleItems.length,
        itemBuilder: (context, index) {
          final item = scheduleItems[index];

          return Material(
              color: Colors.transparent,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    title: Text(item.title),
                    subtitle:
                        Text(DateFormat('HH:mm').format(item.date.toLocal())),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.scheduleWrite,
                        arguments: {
                          'isEdit': true,
                          'scheduleObject': item,
                          'scheduleBloc': scheduleBloc,
                        },
                      );
                    },
                    onLongPress: () {
                      //Show a dialog for confirmation
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm Delete"),
                            content: const Text(
                                "Are you sure you want to delete this item?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                // Close the dialog
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  scheduleBloc.add(
                                      DeleteScheduleItem(item.id, currentDate));
                                  Navigator.pop(context); // Close the dialog
                                },
                                child: const Text("Delete",
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  )
              )
          );
        },
      ),
    );
  }
}

extension DateTimeExtensions on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
