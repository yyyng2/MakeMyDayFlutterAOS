import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realm/realm.dart';
import 'package:intl/intl.dart';

import '../../../infrastructure/manager/realm_schema_version_manager.dart';
import '../../commonFeature/data/datasources/common_local_datasource.dart';
import '../../commonFeature/data/repositories/common_repository_impl.dart';
import '../../commonFeature/domain/usecases/common_usecase.dart';
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
  final CommonLocalDatasource commonLocalDatasource = CommonLocalDatasource();
  late final CommonRepositoryImpl commonRepositoryImpl;
  late final CommonUsecase commonUsecase;
  late Realm realm;
  late ScheduleRepositoryImpl scheduleRepositoryImpl;
  late ScheduleUsecase scheduleUsecase;
  late ScheduleBloc scheduleBloc;
  DateTime currentDate = DateTime.now();
  int targetYear = DateTime.now().year;
  int targetMonth = DateTime.now().month;
  List<DateTime> dates = [];

  @override
  void initState() {
    super.initState();
    commonRepositoryImpl = CommonRepositoryImpl(
        localDatasource: commonLocalDatasource, remoteDatasource: null);
    commonUsecase = CommonUsecase(repository: commonRepositoryImpl);
    final config = RealmSchemaVersionManager.getConfig();
    realm = Realm(config);
    scheduleRepositoryImpl = ScheduleRepositoryImpl(realm);
    scheduleUsecase = ScheduleUsecase(repository: scheduleRepositoryImpl);
    scheduleBloc =
        ScheduleBloc(commonUsecase: commonUsecase, usecase: scheduleUsecase);

    scheduleBloc.add(FetchScheduleItemsByDate(currentDate));
  }

  @override
  void dispose() {
    realm.close();
    super.dispose();
  }

  DateTime getCurrentMonthDate() {
    return DateTime(targetYear, targetMonth, 1);
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
      scheduleBloc.add(FetchScheduleItemsByDate(currentDate));
    });
  }

  void handleDateChange(DateTime newDate) {
    setState(() {
      currentDate = newDate;
      scheduleBloc.add(FetchScheduleItemsByDate(currentDate));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ScheduleBloc, ScheduleState>(
        bloc: scheduleBloc,
        builder: (context, state) {
          if (state is ScheduleInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ScheduleLoaded) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    state.isDarkTheme
                        ? 'assets/images/background/background_black.png'
                        : 'assets/images/background/background.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Column(
                  children: [
                    _buildHeader(state.isDarkTheme),
                    _buildDaysOfWeek(state.isDarkTheme),
                    _buildCalendarGrid(state.scheduleItems, state.isDarkTheme, state.isWeekMode),
                    _buildScheduleList(state.scheduleTargetItems, state.isDarkTheme),
                  ],
                ),
                if (state.isSearchVisible)
                  _buildSearchPopup(state.searchResults, state.isDarkTheme, ''),
                Positioned(
                  right: 16,
                  bottom: 160,
                  child: FloatingActionButton(
                    heroTag: 'searchButton',
                    onPressed: () {
                      scheduleBloc.add(const ToggleSearchPopup(true));
                    },
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.search, color: Colors.black),
                  ),
                ),
              ],
            );
          } else if (state is ScheduleError) {
            return Center(child: Text('Failed to load schedules: ${state.message}'));
          } else {
            return const Center(child: Text('Unknown state'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'scheduleScreen',
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.scheduleWrite, arguments: {
            'isEdit': false,
            'scheduleObject': ScheduleEntity(ObjectId(), '', currentDate),
            'scheduleBloc': scheduleBloc,
            'isDarkTheme': (scheduleBloc.state is ScheduleLoaded)
                ? (scheduleBloc.state as ScheduleLoaded).isDarkTheme
                : false,
          });
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(bool isDarkTheme) {
    final monthYear = DateFormat('MMMM yyyy').format(getCurrentMonthDate());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(monthYear,
              style: TextStyle(
                  color: isDarkTheme ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.keyboard_double_arrow_left,
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    targetYear -= 1;
                    handleMonthChange();
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    targetMonth -= 1;
                    if (targetMonth < 1) {
                      targetMonth = 12;
                      targetYear -=
                          1; // Decrement year when moving from January to December
                    }
                    handleMonthChange();
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    targetMonth += 1;
                    if (targetMonth > 12) {
                      targetMonth = 1;
                      targetYear +=
                          1; // Increment year when moving from December to January
                    }
                    handleMonthChange();
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.keyboard_double_arrow_right,
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    targetYear += 1;
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

  Widget _buildDaysOfWeek(bool isDarkTheme) {
    final daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Row(
      children: daysOfWeek.map((day) {
        return Expanded(
          child: Center(
            child: Text(day,
                style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  List<DateTime> _extractWeekDates() {
    final startOfWeek = currentDate.subtract(Duration(days: currentDate.weekday % 7));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  Widget _buildCalendarGrid(
      List<ScheduleEntity> scheduleItems, bool isDarkTheme, bool isWeekMode) {
    final dates = isWeekMode ? _extractWeekDates() : extractDates();
    final rowCount = isWeekMode ? 1 : (dates.length / 7).ceil();

    return Column(
      children: [
        SizedBox(
          height: rowCount * 60.0,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7),
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];

                if (date.year == 0) {
                  return const SizedBox.shrink();
                }

                final isSelected = date.isSameDay(currentDate);
                final hasTask = scheduleItems
                    .any((item) => item.date.toLocal().isSameDay(date));

                return GestureDetector(
                  onTap: () {
                    handleDateChange(date);
                    scheduleBloc.add(FetchScheduleItemsByDate(date));
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? Colors.blueAccent : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isDarkTheme
                                ? isSelected
                                    ? Colors.black
                                    : Colors.white
                                : isSelected
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                        if (hasTask)
                          const Padding(
                            padding: EdgeInsets.only(top: 2.0),
                            child: CircleAvatar(
                                radius: 2, backgroundColor: Colors.red),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: Icon(
              isWeekMode ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
              color: isDarkTheme ? Colors.white : Colors.black,
            ),
            onPressed: () {
              scheduleBloc.add(const ToggleCalendarMode());
            },
          ),
        ],
      );
  }

  Widget _buildScheduleList(
      List<ScheduleEntity> scheduleItems, bool isDarkTheme) {
    return Expanded(
      child: scheduleItems.isEmpty
          ? ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return Material(
                    color: Colors.transparent,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          tileColor:
                              isDarkTheme ? Colors.black87 : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          title: Text(
                            "scheduleEmpty".tr(),
                            style: TextStyle(
                                color:
                                    isDarkTheme ? Colors.white : Colors.black),
                          ),
                          subtitle: Text(
                            "homeNoScheduleTodayAdd".tr(),
                            style: TextStyle(
                                color:
                                    isDarkTheme ? Colors.white : Colors.black),
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.scheduleWrite,
                              arguments: {
                                'isEdit': false,
                                'scheduleObject':
                                    ScheduleEntity(ObjectId(), '', currentDate),
                                'scheduleBloc': scheduleBloc,
                                'isDarkTheme': isDarkTheme,
                              },
                            );
                          },
                        )));
              })
          : ListView.builder(
              itemCount: scheduleItems.length,
              itemBuilder: (context, index) {
                final item = scheduleItems[index];

                return Material(
                    color: Colors.transparent,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          tileColor:
                              isDarkTheme ? Colors.black87 : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                                color:
                                    isDarkTheme ? Colors.white : Colors.black),
                          ),
                          subtitle: Text(
                            DateFormat('a hh:mm').format(item.date.toLocal()),
                            style: TextStyle(
                                color:
                                    isDarkTheme ? Colors.white : Colors.black),
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.scheduleWrite,
                              arguments: {
                                'isEdit': true,
                                'scheduleObject': item,
                                'scheduleBloc': scheduleBloc,
                                'isDarkTheme': isDarkTheme,
                              },
                            );
                          },
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("commonConfirmDeleteTitle".tr()),
                                  content: Text("commonConfirmDelete".tr()),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      // Close the dialog
                                      child: Text("commonCancel".tr()),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        scheduleBloc.add(DeleteScheduleItem(
                                            item.id, currentDate));
                                        FlutterBackgroundService()
                                            .invoke('updateData');
                                        Navigator.pop(
                                            context); // Close the dialog
                                      },
                                      child: Text("commonDelete".tr(),
                                          style: const TextStyle(
                                              color: Colors.red)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        )));
              },
            ),
    );
  }

  Widget _buildSearchPopup(
      List<ScheduleEntity> searchResults, bool isDarkTheme, String searchQuery) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => scheduleBloc.add(const ToggleSearchPopup(false)),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // 팝업 내부 탭 무시
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 350,
                margin: const EdgeInsets.only(bottom: 150),
                decoration: BoxDecoration(
                  color: isDarkTheme ? Colors.black87 : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        autofocus: true,
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'scheduleFindTitle'.tr(),
                          hintStyle: TextStyle(
                            color: isDarkTheme ? Colors.grey : Colors.grey[600],
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: isDarkTheme ? Colors.white : Colors.black,
                          ),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: isDarkTheme ? Colors.white : Colors.black,
                            ),
                            onPressed: () {
                              scheduleBloc.add(const SearchScheduleItems(''));
                            },
                          )
                              : null,
                          filled: true,
                          fillColor: isDarkTheme ? Colors.grey[800] : Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          scheduleBloc.add(SearchScheduleItems(value));
                        },
                      ),
                    ),
                    Divider(color: isDarkTheme ? Colors.grey[700] : Colors.grey[300]),
                    Expanded(
                      child: searchResults.isEmpty
                          ? Center(
                        child: Text(
                          'scheduleEmpty'.tr(),
                          style: TextStyle(
                            color: isDarkTheme ? Colors.white : Colors.black,
                          ),
                        ),
                      )
                          : ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final item = searchResults[index];
                          return ListTile(
                            title: Text(
                              item.title,
                              style: TextStyle(
                                color: isDarkTheme ? Colors.white : Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat('yyyy-MM-dd a hh:mm').format(item.date.toLocal()),
                              style: TextStyle(
                                color: isDarkTheme ? Colors.grey : Colors.grey[600],
                              ),
                            ),
                            onTap: () {
                              scheduleBloc.add(const ToggleSearchPopup(false));
                              Navigator.pushNamed(
                                context,
                                AppRouter.scheduleWrite,
                                arguments: {
                                  'isEdit': true,
                                  'scheduleObject': item,
                                  'scheduleBloc': scheduleBloc,
                                  'isDarkTheme': isDarkTheme,
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension DateTimeExtensions on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
