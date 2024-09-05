import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../infrastructure/network/network_client.dart';
import '../../commonFeature/data/datasources/common_local_datasource.dart';
import '../../commonFeature/data/datasources/common_remote_datasource.dart';
import '../../commonFeature/data/repositories/common_repository_impl.dart';
import '../../commonFeature/domain/usecases/common_usecase.dart';
import '../../commonFeature/presentation/navigation/app_router.dart';
import '../data/datasources/settings_local_datasource.dart';
import '../data/repositories/settings_repository_impl.dart';
import '../domain/usecases/settings_usecase.dart';
import 'bloc/settings_bloc.dart';
import 'enums/settings_options.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final CommonLocalDatasource commonLocalDatasource = CommonLocalDatasource();
  late SettingsLocalDatasource settingsLocalDatasource;
  late SettingsRepositoryImpl settingsRepositoryImpl;
  late SettingsUsecase settingsUsecase;
  late SettingsBloc settingsBloc;

  @override
  void initState() {
    super.initState();
    final client = NetworkClient(client: http.Client());
    final commonLocalDatasource = CommonLocalDatasource();
    final commonRemoteDatasource = CommonRemoteDatasource(networkClient: client);
    final commonRepository = CommonRepositoryImpl(
      localDatasource: commonLocalDatasource,
      remoteDatasource: commonRemoteDatasource,
    );
    final commonUsecase = CommonUsecase(repository: commonRepository);
    settingsLocalDatasource = SettingsLocalDatasource(commonLocalDatasource);
    settingsRepositoryImpl = SettingsRepositoryImpl(datasource: settingsLocalDatasource);
    settingsUsecase = SettingsUsecase(settingsRepository: settingsRepositoryImpl);
    settingsBloc = SettingsBloc(usecase: settingsUsecase, commonUsecase: commonUsecase);

    settingsBloc.add(FetchSettingsItems());
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
          BlocBuilder<SettingsBloc, SettingsState>(
            bloc: settingsBloc,
            builder: (context, state) {
              if (state is SettingsInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SettingsLoaded) {
                return ListView.builder(
                  itemCount: SettingsOptions.values.length,
                  itemBuilder: (context, index) {
                    final option = SettingsOptions.values[index];
                    return Material(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          tileColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          title: Text(option.name.toString()),
                          onTap: () {
                            // Handle tap based on the selected option
                            switch (option) {
                              case SettingsOptions.appInfo:
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.appInfo,
                                  arguments: {
                                    'currentVersion': '1.0.0',
                                    'settingsBloc': settingsBloc,
                                    'existUpdate': state.existUpdate,
                                  },
                                );
                                break;
                              case SettingsOptions.editProfile:
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.editProfile,
                                  arguments: {
                                    'nickname': state.nickname,
                                    'settingsBloc': settingsBloc,
                                  },
                                );
                                break;
                              case SettingsOptions.theme:
                              // Navigate to Theme Settings
                                break;
                              case SettingsOptions.openSources:
                              // Navigate to Open Source Licenses
                                break;
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              } else if (state is SettingsError) {
                return Center(
                  child: Text('Error: ${state.message}'),
                );
              } else {
                return const Center(child: Text('Unknown state'));
              }
            },
          ),
        ],
      ),
    );
  }
}
