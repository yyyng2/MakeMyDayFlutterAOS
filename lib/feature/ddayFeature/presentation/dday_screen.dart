import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realm/realm.dart';

import '../../../infrastructure/manager/realm_schema_version_manager.dart';
import '../../commonFeature/data/datasources/common_local_datasource.dart';
import '../../commonFeature/data/repositories/common_repository_impl.dart';
import '../../commonFeature/domain/usecases/common_usecase.dart';
import '../../commonFeature/presentation/navigation/app_router.dart';
import '../data/repositories/dday_repository_impl.dart';
import '../domain/entities/dday_entity.dart';
import '../domain/usecases/dday_usecase.dart';
import 'bloc/dday_bloc.dart';

class DdayScreen extends StatefulWidget {
  const DdayScreen({super.key});

  @override
  DdayScreenState createState() => DdayScreenState();
}

class DdayScreenState extends State<DdayScreen> {
  final CommonLocalDatasource commonLocalDatasource = CommonLocalDatasource();
  late final CommonRepositoryImpl commonRepositoryImpl;
  late final CommonUsecase commonUsecase;
  late Realm realm;
  late DdayRepositoryImpl ddayRepositoryImpl;
  late DdayUsecase ddayUsecase;
  late DdayBloc ddayBloc;

  @override
  void initState() {
    super.initState();
    commonRepositoryImpl = CommonRepositoryImpl(
        localDatasource: commonLocalDatasource, remoteDatasource: null);
    commonUsecase = CommonUsecase(repository: commonRepositoryImpl);
    final config = RealmSchemaVersionManager.getConfig();
    realm = Realm(config);
    ddayRepositoryImpl = DdayRepositoryImpl(realm);
    ddayUsecase = DdayUsecase(repository: ddayRepositoryImpl);
    ddayBloc = DdayBloc(commonUsecase: commonUsecase, usecase: ddayUsecase);

    ddayBloc.add(FetchDdayItems());
  }

  @override
  void dispose() {
    realm.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DdayBloc, DdayState>(
        bloc: ddayBloc,
        builder: (context, state) {
          if (state is DdayInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DdayLoaded) {
            return Stack(children: [
              Positioned.fill(
                  child: Image.asset(
                state.isDarkTheme
                    ? 'assets/images/background/background_black.png'
                    : 'assets/images/background/background.png',
                fit: BoxFit.cover,
              )),
              Column(
                children: [
                  _buildDdayList(state.ddayItems, state.isDarkTheme),
                ],
              )
            ]);
          } else if (state is DdayError) {
            return Center(
                child: Text('Failed to load notices: ${state.message}'));
          } else {
            return const Center(child: Text('Unknown state'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'ddayScreen',
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.ddayWrite, arguments: {
            'isEdit': false,
            'ddayObject':
                DdayEntity(ObjectId(), '', DateTime.now(), false, 0, true),
            'ddayBloc': ddayBloc,
            'isDarkTheme': (ddayBloc.state is DdayLoaded)
                ? (ddayBloc.state as DdayLoaded).isDarkTheme
                : false,
          });
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDdayList(List<DdayEntity> ddayItems, bool isDarkTheme) {
    final timeFormat = DateFormat('yyyy-MM-dd', Intl.systemLocale);

    return Expanded(
      child: ddayItems.isEmpty
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
                            "homeNoDday".tr(),
                            style: TextStyle(
                                color:
                                    isDarkTheme ? Colors.white : Colors.black),
                          ),
                          subtitle: Text(
                            "homeNoDdayAdd".tr(),
                            style: TextStyle(
                                color:
                                    isDarkTheme ? Colors.white : Colors.black),
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.ddayWrite,
                              arguments: {
                                'isEdit': false,
                                'ddayObject': DdayEntity(ObjectId(), '',
                                    DateTime.now(), false, 0, true),
                                'ddayBloc': ddayBloc,
                                'isDarkTheme': isDarkTheme,
                              },
                            );
                          },
                        )));
              })
          : ListView.builder(
              itemCount: ddayItems.length,
              itemBuilder: (context, index) {
                final item = ddayItems[index];
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final localTime = item.date.toLocal();
                var formattedTime = timeFormat.format(localTime);
                String anniversaryYear = '';

                var differenceInDays;

                if (item.repeatAnniversary) {
                  // 올해의 같은 날짜로 설정
                  var thisYearDate = DateTime(
                    now.year,
                    localTime.month,
                    localTime.day,
                  );

                  // 만약 올해의 날짜가 이미 지났다면 내년으로 설정
                  if (thisYearDate.isBefore(today)) {
                    thisYearDate = DateTime(
                      now.year + 1,
                      localTime.month,
                      localTime.day,
                    );
                    formattedTime = timeFormat.format(thisYearDate);
                  }

                  // 기념일 년수 계산
                  var years = now.year - localTime.year;
                  if (thisYearDate.year > now.year) {
                    years += 1; // 내년이면 1년 추가
                  }
                  if (years > 0) {
                    String suffix;
                    if (years % 10 == 1 && years != 11) {
                      suffix = 'st';
                    } else if (years % 10 == 2 && years != 12) {
                      suffix = 'nd';
                    } else if (years % 10 == 3 && years != 13) {
                      suffix = 'rd';
                    } else {
                      suffix = 'th';
                    }
                    anniversaryYear = ' ($years$suffix)';
                  }

                  differenceInDays = thisYearDate.difference(today).inDays;
                } else {
                  differenceInDays = localTime.difference(today).inDays;
                }

                if (item.dayPlus) {
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
                          subtitle: Row(children: [
                            Text(
                              formattedTime + anniversaryYear,
                              style: TextStyle(
                                  color: isDarkTheme
                                      ? Colors.white
                                      : Colors.black),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              ddayText,
                              style: TextStyle(color: Colors.green),
                            ),
                          ]),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.ddayWrite,
                              arguments: {
                                'isEdit': true,
                                'ddayObject': item,
                                'ddayBloc': ddayBloc,
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
                                        ddayBloc.add(DeleteDdayItem(item.id));
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
}
