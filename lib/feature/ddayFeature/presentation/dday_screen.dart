import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realm/realm.dart';

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
    final config = Configuration.local([DdayEntity.schema]);
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
                  )
              ),
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
            'ddayObject': DdayEntity(ObjectId(), '', DateTime.now(), true),
            'ddayBloc': ddayBloc,
            'isDarkTheme': (ddayBloc.state is DdayLoaded) ? (ddayBloc.state as DdayLoaded).isDarkTheme : false,
          });
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDdayList(List<DdayEntity> ddayItems, bool isDarkTheme) {
    return Expanded(
      child:  ddayItems.isEmpty
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
                        "디데이가 없어요.",
                        style: TextStyle(
                            color:
                            isDarkTheme ? Colors.white : Colors.black),
                      ),
                      subtitle: Text(
                        "디데이를 작성해보세요.",
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
                            'ddayObject': DdayEntity(ObjectId(), '', DateTime.now(), true),
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

          var differenceInDays = item.date
              .difference(DateTime(now.year, now.month, now.day))
              .inDays;

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
                    tileColor: isDarkTheme ? Colors.black87 : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    title: Text(
                        item.title,
                      style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
                    ),
                    subtitle: Text(
                        ddayText,
                      style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
                    ),
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
                                  ddayBloc.add(DeleteDdayItem(item.id));
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
                  )));
        },
      ),
    );
  }
}
