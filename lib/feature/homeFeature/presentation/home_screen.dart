import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:realm/realm.dart';

import '../../commonFeature/presentation/navigation/app_router.dart';
import '../../ddayFeature/domain/entities/dday_entity.dart';
import '../../ddayFeature/data/repositories/dday_repository_impl.dart';
import '../../ddayFeature/domain/usecases/dday_usecase.dart';
import '../../ddayFeature/presentation/bloc/dday_bloc.dart';
import '../../scheduleFeature/domain/entities/schedule_entity.dart';
import '../../scheduleFeature/data/repositories/schedule_repository_impl.dart';
import '../../scheduleFeature/domain/usecases/schedule_usecase.dart';
import '../../scheduleFeature/presentation/bloc/schedule_bloc.dart';
import '../domain/usecases/home_usecase.dart';
import 'bloc/home_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late Realm realm;
  late DdayRepositoryImpl ddayRepositoryImpl;
  late ScheduleRepositoryImpl scheduleRepositoryImpl;
  late ScheduleUsecase scheduleUsecase;
  late ScheduleBloc scheduleBloc;
  late DdayUsecase ddayUsecase;
  late DdayBloc ddayBloc;
  late HomeUsecase homeUsecase;
  late HomeBloc homeBloc;

  DateTime currentDate = DateTime.now();
  bool isTapped = false;

  @override
  void initState() {
    super.initState();
    final config = Configuration.local([DdayEntity.schema, ScheduleEntity.schema]);
    realm = Realm(config);
    ddayRepositoryImpl = DdayRepositoryImpl(realm);
    scheduleRepositoryImpl = ScheduleRepositoryImpl(realm);
    scheduleUsecase = ScheduleUsecase(repository: scheduleRepositoryImpl);
    scheduleBloc = ScheduleBloc(scheduleUsecase);
    ddayUsecase = DdayUsecase(repository: ddayRepositoryImpl);
    ddayBloc = DdayBloc(ddayUsecase);
    homeUsecase = HomeUsecase(
      ddayRepository: ddayRepositoryImpl,
      scheduleRepository: scheduleRepositoryImpl,
    );
    homeBloc = HomeBloc(homeUsecase);

    homeBloc.add(FetchHomeItems(currentDate));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    realm.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background/background.png',
              fit: BoxFit.cover,
            ),
          ),
          BlocBuilder<HomeBloc, HomeState>(
            bloc: homeBloc,
            builder: (context, state) {
              if (state is HomeInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is HomeLoaded) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              MessageView(
                                topMessage: DateFormat('yyyy-MM-dd EEE').format(DateTime.now()),
                                bottomMessage: 'Welcome',
                              ),
                              if (state.homeItems.scheduleItems.isEmpty)
                                const MessageView(
                                  topMessage: "오늘의 일정이 없어요.",
                                  bottomMessage: "오늘의 일정을 추가해보세요.",
                                )
                              else ...[
                                OneMessageView(
                                  showImage: true,
                                  showDday: false,
                                  showDate: false,
                                  plusDay: false,
                                  titleMessage: "오늘의 일정을 알려드릴게요.",
                                  date: DateTime.now(),
                                ),
                                for (var item in state.homeItems.scheduleItems)
                                  InkWell(
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
                                    child: OneMessageView(
                                      showImage: false,
                                      showDday: false,
                                      showDate: true,
                                      plusDay: false,
                                      titleMessage: item.title,
                                      date: item.date,
                                    ),
                                  ),
                              ],
                              if (state.homeItems.ddayItems.isEmpty)
                                const MessageView(
                                  topMessage: "등록된 디데이가 없어요.",
                                  bottomMessage: "디데이를 추가해보세요.",
                                )
                              else ...[
                                OneMessageView(
                                  showImage: true,
                                  showDday: false,
                                  showDate: false,
                                  plusDay: false,
                                  titleMessage: "디데이를 알려드릴게요.",
                                  date: DateTime.now(),
                                ),
                                if (state.homeItems.ddayItems.isNotEmpty)
                                  for (var item in state.homeItems.ddayItems)
                                    InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRouter.ddayWrite,
                                          arguments: {
                                            'isEdit': true,
                                            'ddayObject': item,
                                            'ddayBloc': ddayBloc,
                                          },
                                        );
                                      },
                                      child: OneMessageView(
                                        showImage: false,
                                        showDday: true,
                                        showDate: true,
                                        plusDay: item.dayPlus,
                                        titleMessage: item.title,
                                        date: item.date,
                                      ),
                                    ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else if (state is HomeError) {
                return Center(
                  child: Text('Error: ${state.message}'),
                );
              } else {
                return const Center(child: Text('Unknown state'));
              }
            },
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              heroTag: 'homeScreen',
              onPressed: () {
                setState(() {
                  isTapped = !isTapped;
                });
                if (isTapped) {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return HomeWriteButtonView(
                        onSchedulePressed: () {
                          Navigator.pushNamed(context, AppRouter.scheduleWrite, arguments: {
                            'isEdit': false,
                            'scheduleObject': ScheduleEntity(ObjectId(), '', currentDate),
                            'scheduleBloc': scheduleBloc
                          });
                        },
                        onDdayPressed: () {
                          Navigator.pushNamed(context, AppRouter.ddayWrite, arguments: {
                            'isEdit': false,
                            'ddayObject': DdayEntity(ObjectId(), '', DateTime.now(), true),
                            'ddayBloc': ddayBloc
                          });
                        },
                      );
                    },
                  ).whenComplete(() {
                    homeBloc.add(FetchHomeItems(currentDate));
                  });
                }
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageView extends StatelessWidget {
  final String topMessage;
  final String bottomMessage;

  const MessageView({
    required this.topMessage,
    required this.bottomMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Column(
            children: [
              Image.asset(
                'assets/images/dicon/day_color.png',
                width: 50,
                height: 50,
              ),
              const Text("D"),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(topMessage),
              Text(bottomMessage),
            ],
          ),
          ),
        ],
      ),
    );
  }
}

class OneMessageView extends StatelessWidget {
  final bool showImage;
  final bool showDday;
  final bool showDate;
  final bool plusDay;
  final String titleMessage;
  final DateTime date;

  const OneMessageView({
    required this.showImage,
    required this.showDday,
    required this.showDate,
    required this.plusDay,
    required this.titleMessage,
    required this.date,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    var differenceInDays = date.difference(DateTime(now.year, now.month, now.day)).inDays;

    if (plusDay) {
      differenceInDays = differenceInDays - 1;
    }

    String ddayText;
    if (differenceInDays == 0) {
      ddayText = "D-day";
    } else if (differenceInDays > 0) {
      ddayText = "D-${differenceInDays.abs()}";
    } else {
      ddayText = "D+${differenceInDays.abs()}";
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          if (showImage)
            Column(
              children: [
                Image.asset(
                  'assets/images/dicon/day_color.png',
                  width: 50,
                  height: 50,
                ),
                const Text("D"),
              ],
            )
          else
            const SizedBox(width: 50),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titleMessage),
                if (showDate)
                  if (showDday)
                    Row(
                      children: [
                        Text(DateFormat('yyyy-MM-dd').format(date)),
                        const SizedBox(width: 5),
                        Text(
                          ddayText,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    )
                  else
                    Text(DateFormat('HH:mm').format(date.toLocal())),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeWriteButtonView extends StatelessWidget {
  final VoidCallback onSchedulePressed;
  final VoidCallback onDdayPressed;

  const HomeWriteButtonView({
    required this.onSchedulePressed,
    required this.onDdayPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: onSchedulePressed,
            child: const Text("Add Schedule"),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onDdayPressed,
            child: const Text("Add D-Day"),
          ),
        ],
      ),
    );
  }
}