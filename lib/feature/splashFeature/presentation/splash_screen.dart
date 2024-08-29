import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../infrastructure/network/network_client.dart';
import '../data/datasources/splash_local_datasource.dart';
import '../data/datasources/splash_remote_datasource.dart';
import '../data/repositories/splash_repository_impl.dart';
import '../domain/usecases/splash_usecase.dart';
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
    final splashLocalDatasource = SplashLocalDatasource();
    final splashRemoteDatasource = SplashRemoteDatasource(networkClient: client);
    final splashRepository = SplashRepositoryImpl(
      localDatasource: splashLocalDatasource,
      remoteDatasource: splashRemoteDatasource,
    );
    final splashUsecase = SplashUsecase(repository: splashRepository);

    _splashBloc = SplashBloc(usecase: splashUsecase);

    // Start the version check
    _splashBloc.add(CheckVersionEvent());
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
          title: const Text('Update Required'),
          content: const Text('A new version is available. Please update the app.'),
          actions: [
            TextButton(
              onPressed: () async {
                _splashBloc.add(GoToStoreEvent());
              },
              child: const Text('Go to Store'),
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