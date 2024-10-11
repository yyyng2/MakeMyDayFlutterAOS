import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_widget/home_widget.dart';
import 'package:http/http.dart' as http;

import '../../../infrastructure/network/network_client.dart';
import '../../commonFeature/data/datasources/common_local_datasource.dart';
import '../../commonFeature/data/datasources/common_remote_datasource.dart';
import '../../commonFeature/data/repositories/common_repository_impl.dart';
import '../../commonFeature/domain/usecases/common_usecase.dart';
import 'bloc/splash_bloc.dart';
import '../../commonFeature/presentation/navigation/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late final SplashBloc _splashBloc;

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

    _splashBloc = SplashBloc(usecase: commonUsecase);

    // Start the version check
    _splashBloc.add(CheckVersionEvent());

    HomeWidget.saveWidgetData<String>('homeWidgetEmptyTitle',  'homeWidgetEmptyTitle'.tr());
  }

  @override
  void dispose() {
    _splashBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: BlocProvider(
        create: (context) => _splashBloc,
        child: BlocListener<SplashBloc, SplashState>(
          listener: (context, state) {
            if (state is SplashLoaded && state.existUpdate) {
              _showUpdateDialog();
            } else if (state is SplashLoaded && !state.existUpdate) {
              _navigateToMainScreen();
            } else if (state is SplashError) {
              Text('${state.props}');
            }
          },
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('updateRequiredTitle').tr(),
          content: const Text('updateRequiredContents').tr(),
          actions: [
            TextButton(
              onPressed: () async {
                _splashBloc.add(GoToStoreEvent());
              },
              child: const Text('updateRequiredGoStoreButtonTitle').tr(),
            ),
          ],
        );
      },
    );
  }

  void _navigateToMainScreen() {
    Navigator.pushNamed(context, AppRouter.mainTab);
  }
}