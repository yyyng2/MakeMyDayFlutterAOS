import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:realm/realm.dart';

import '../../commonFeature/data/datasources/common_local_datasource.dart';
import '../../commonFeature/data/repositories/common_repository_impl.dart';
import '../../commonFeature/domain/usecases/common_usecase.dart';
import '../../commonFeature/presentation/navigation/app_router.dart';
import '../../ddayFeature/domain/entities/dday_entity.dart';
import '../../ddayFeature/data/repositories/dday_repository_impl.dart';
import '../../ddayFeature/domain/usecases/dday_usecase.dart';
import '../../ddayFeature/presentation/bloc/dday_bloc.dart';
import '../../scheduleFeature/domain/entities/schedule_entity.dart';
import '../../scheduleFeature/data/repositories/schedule_repository_impl.dart';
import '../../scheduleFeature/domain/usecases/schedule_usecase.dart';
import '../../scheduleFeature/presentation/bloc/schedule_bloc.dart';
import '../data/datasources/home_local_datasource.dart';
import '../data/repositories/home_repository_impl.dart';
import '../domain/usecases/home_usecase.dart';
import 'bloc/home_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final CommonLocalDatasource commonLocalDatasource = CommonLocalDatasource();
  late final CommonRepositoryImpl commonRepositoryImpl;
  late final CommonUsecase commonUsecase;
  late HomeLocalDatasource homeLocalDatasource;
  late HomeRepositoryImpl homeRepositoryImpl;
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
    commonRepositoryImpl = CommonRepositoryImpl(
        localDatasource: commonLocalDatasource,
        remoteDatasource: null
    );
    commonUsecase = CommonUsecase(repository: commonRepositoryImpl);
    homeLocalDatasource = HomeLocalDatasource(CommonLocalDatasource());
    final config =
        Configuration.local([DdayEntity.schema, ScheduleEntity.schema]);
    realm = Realm(config);
    homeRepositoryImpl = HomeRepositoryImpl(datasource: homeLocalDatasource);
    ddayRepositoryImpl = DdayRepositoryImpl(realm);
    scheduleRepositoryImpl = ScheduleRepositoryImpl(realm);
    scheduleUsecase = ScheduleUsecase(repository: scheduleRepositoryImpl);
    scheduleBloc = ScheduleBloc(
        commonUsecase: commonUsecase,
        usecase: scheduleUsecase
    );
    ddayUsecase = DdayUsecase(repository: ddayRepositoryImpl);
    ddayBloc = DdayBloc(
        commonUsecase: commonUsecase,
        usecase: ddayUsecase
    );
    homeUsecase = HomeUsecase(
      homeRepository: homeRepositoryImpl,
      ddayRepository: ddayRepositoryImpl,
      scheduleRepository: scheduleRepositoryImpl,
    );
    homeBloc = HomeBloc(
      commonUsecase: commonUsecase,
        usecase: homeUsecase
    );

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
          BlocBuilder<HomeBloc, HomeState>(
            bloc: homeBloc,
            builder: (context, state) {
              if (state is HomeInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is HomeLoaded) {
                return Stack(children: [
                  Positioned.fill(
                      child: Image.asset(
                        state.isDarkTheme
                            ? 'assets/images/background/background_black.png'
                            : 'assets/images/background/background.png',
                        fit: BoxFit.cover,
                      )
                  ),
                  LayoutBuilder(
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
                                isDarkTheme: state.isDarkTheme,
                                profileImageInfo: state.profileImage,
                                nickname: state.nickname,
                                topMessage: DateFormat('yyyy-MM-dd EEE')
                                    .format(DateTime.now()),
                                bottomMessage: 'homeWelcome'.tr(),
                              ),
                              if (state.homeItems.scheduleItems.isEmpty)
                                MessageView(
                                  isDarkTheme: state.isDarkTheme,
                                  profileImageInfo: state.profileImage,
                                  nickname: state.nickname,
                                  topMessage: "homeNoScheduleToday".tr(),
                                  bottomMessage: "homeNoScheduleTodayAdd".tr(),
                                )
                              else ...[
                                OneMessageView(
                                  isDarkTheme: state.isDarkTheme,
                                  profileImageInfo: state.profileImage,
                                  nickname: state.nickname,
                                  showImage: true,
                                  showDday: false,
                                  showDate: false,
                                  plusDay: false,
                                  titleMessage: "homeScheduleToday".tr(),
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
                                          'isDarkTheme': state.isDarkTheme,
                                        },
                                      );
                                    },
                                    child: OneMessageView(
                                      isDarkTheme: state.isDarkTheme,
                                      profileImageInfo: state.profileImage,
                                      nickname: state.nickname,
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
                                MessageView(
                                  isDarkTheme: state.isDarkTheme,
                                  profileImageInfo: state.profileImage,
                                  nickname: state.nickname,
                                  topMessage: "homeNoDday".tr(),
                                  bottomMessage: "homeNoDdayAdd".tr(),
                                )
                              else ...[
                                OneMessageView(
                                  isDarkTheme: state.isDarkTheme,
                                  profileImageInfo: state.profileImage,
                                  nickname: state.nickname,
                                  showImage: true,
                                  showDday: false,
                                  showDate: false,
                                  plusDay: false,
                                  titleMessage: "homeDdayToday".tr(),
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
                                            'isDarkTheme': state.isDarkTheme,
                                          },
                                        );
                                      },
                                      child: OneMessageView(
                                        isDarkTheme: state.isDarkTheme,
                                        profileImageInfo: state.profileImage,
                                        nickname: state.nickname,
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
                )]);
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
                        isDarkTheme: false,
                        onSchedulePressed: () {
                          Navigator.pushNamed(context, AppRouter.scheduleWrite,
                              arguments: {
                                'isEdit': false,
                                'scheduleObject':
                                    ScheduleEntity(ObjectId(), '', currentDate),
                                'scheduleBloc': scheduleBloc,
                                'isDarkTheme': (homeBloc.state is HomeLoaded) ? (homeBloc.state as HomeLoaded).isDarkTheme : false,
                              });
                        },
                        onDdayPressed: () {
                          Navigator.pushNamed(context, AppRouter.ddayWrite,
                              arguments: {
                                'isEdit': false,
                                'ddayObject': DdayEntity(
                                    ObjectId(), '', DateTime.now(), true),
                                'ddayBloc': ddayBloc,
                                'isDarkTheme': (homeBloc.state is HomeLoaded) ? (homeBloc.state as HomeLoaded).isDarkTheme : false,
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
  final bool isDarkTheme;
  final Map<String, dynamic> profileImageInfo;
  final String nickname;
  final String topMessage;
  final String bottomMessage;

  const MessageView({
    required this.isDarkTheme,
    required this.profileImageInfo,
    required this.nickname,
    required this.topMessage,
    required this.bottomMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;

    if (profileImageInfo['isFile'] == true) {
      imageProvider = FileImage(profileImageInfo['image'] as File);
    } else {
      imageProvider = AssetImage(profileImageInfo['image'] as String);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: imageProvider,
                backgroundColor: Colors.transparent,
              ),
              Text(
                nickname,
                style: TextStyle(
                  fontSize: 7,
                  color: isDarkTheme ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkTheme ? Colors.black87 : Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topMessage,
                    style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  Text(
                    bottomMessage,
                    style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class OneMessageView extends StatelessWidget {
  final bool isDarkTheme;
  final Map<String, dynamic> profileImageInfo;
  final String nickname;
  final bool showImage;
  final bool showDday;
  final bool showDate;
  final bool plusDay;
  final String titleMessage;
  final DateTime date;

  const OneMessageView({
    required this.isDarkTheme,
    required this.profileImageInfo,
    required this.nickname,
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

    var differenceInDays =
        date.difference(DateTime(now.year, now.month, now.day)).inDays;

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

    ImageProvider imageProvider;

    if (profileImageInfo['isFile'] == true) {
      imageProvider = FileImage(profileImageInfo['image'] as File);
    } else {
      imageProvider = AssetImage(profileImageInfo['image'] as String);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showImage)
            Column(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: imageProvider,
                  backgroundColor: Colors.transparent,
                ),
                Text(
                  nickname,
                  style: TextStyle(
                    fontSize: 7,
                    color: isDarkTheme ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            )
          else
            Column(children: [
              const SizedBox(width: 50),
              Text(
                nickname,
                style: const TextStyle(
                  fontSize: 7,
                  color: Colors.transparent,
                  fontWeight: FontWeight.bold,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ]),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: isDarkTheme ? Colors.black87 : Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleMessage,
                    style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  if (showDate)
                    if (showDday)
                      Row(
                        children: [
                          Text(
                              DateFormat('yyyy-MM-dd').format(date.toLocal()),
                          style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),),
                          const SizedBox(width: 5),
                          Text(
                            ddayText,
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      )
                    else
                      Text(
                          DateFormat('a hh:mm').format(date.toLocal()),
                        style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
                      ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class HomeWriteButtonView extends StatelessWidget {
  final bool isDarkTheme;
  final VoidCallback onSchedulePressed;
  final VoidCallback onDdayPressed;

  const HomeWriteButtonView({
    required this.isDarkTheme,
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
            child: Text(
                "writeScheduleTitle".tr(),
              style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onDdayPressed,
            child: Text(
                "writeDdayTitle".tr(),
              style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
