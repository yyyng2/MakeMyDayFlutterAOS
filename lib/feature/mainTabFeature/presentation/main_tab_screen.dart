import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:make_my_day/feature/ddayFeature/presentation/bloc/dday_bloc.dart';
import 'package:make_my_day/feature/homeFeature/presentation/bloc/home_bloc.dart';
import 'package:make_my_day/feature/scheduleFeature/presentation/bloc/schedule_bloc.dart';

import '../../commonFeature/data/datasources/common_local_datasource.dart';
import '../data/datasources/main_tab_local_datasource.dart';
import '../data/repositories/main_tab_repository_impl.dart';
import '../domain/usecases/main_tab_usecase.dart';
import '../../../infrastructure/service/ad_service.dart';
import '../../ddayFeature/presentation/dday_screen.dart';
import '../../homeFeature/presentation/home_screen.dart';
import '../../scheduleFeature/presentation/schedule_screen.dart';
import '../../settingsFeature/presentation/settings_screen.dart';
import 'bloc/main_tab_bloc.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  MainTabScreenState createState() => MainTabScreenState();
}

class MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;
  NativeAd? _nativeAd;
  bool isAdLoaded = false;

  late MainTabBloc mainTabBloc;
  final CommonLocalDatasource commonLocalDatasource = CommonLocalDatasource();
  late final MainTabLocalDatasource mainTabLocalDatasource;
  late final MainTabRepositoryImpl mainTabRepositoryImpl;
  late final MainTabUsecase mainTabUsecase;

  final GlobalKey<HomeScreenState> _homeScreenKey = GlobalKey<HomeScreenState>();
  final GlobalKey<ScheduleScreenState> _scheduleScreenKey = GlobalKey<ScheduleScreenState>();
  final GlobalKey<DdayScreenState> _ddayScreenKey = GlobalKey<DdayScreenState>();

  @override
  void initState() {
    super.initState();
    mainTabLocalDatasource = MainTabLocalDatasource(commonLocalDatasource);
    mainTabRepositoryImpl = MainTabRepositoryImpl(datasource: mainTabLocalDatasource);
    mainTabUsecase = MainTabUsecase(repository: mainTabRepositoryImpl);
    mainTabBloc = MainTabBloc(mainTabUsecase);
    mainTabBloc.add(LoadMainTabThemeEvent());
    // _createNativeAd();
  }

  void _createNativeAd(bool isDarkMode) {
    _nativeAd = NativeAd(
      adUnitId: AdService.nativeAdUnitId,
      listener: NativeAdListener(onAdLoaded: (ad) {
        setState(() {
          isAdLoaded = true;
        });
      }, onAdFailedToLoad: (ad, error) {
        print('Failed to load a banner ad: ${error.message}');
        ad.dispose();
      }),
      request: const AdRequest(),
      nativeTemplateStyle: isDarkMode
          ? nativeTemplateDark()
          : nativeTemplateLight(),
    )..load();
  }

  //Dark Mode
  NativeTemplateStyle nativeTemplateDark() {
    final templateType =
    MediaQuery.of(context).size.width < 360 ? TemplateType.small : TemplateType.medium;
    return NativeTemplateStyle(
      templateType: templateType,
      mainBackgroundColor: Colors.grey.shade800,
      cornerRadius: 10.0,
      callToActionTextStyle: NativeTemplateTextStyle(
        textColor: Colors.white,
        backgroundColor: Colors.blue, // or any color suitable for your app
        style: NativeTemplateFontStyle.normal,
        size: 16.0,
      ),
      primaryTextStyle: NativeTemplateTextStyle(
        textColor: Colors.white,
        backgroundColor: Colors.transparent,
        style: NativeTemplateFontStyle.bold,
        size: 16.0,
      ),
      secondaryTextStyle: NativeTemplateTextStyle(
        textColor: Colors.grey.shade100,
        backgroundColor: Colors.transparent,
        style: NativeTemplateFontStyle.normal,
        size: 14.0,
      ),
      tertiaryTextStyle: NativeTemplateTextStyle(
        textColor: Colors.grey.shade100,
        backgroundColor: Colors.transparent,
        style: NativeTemplateFontStyle.normal,
        size: 14.0,
      ),
    );
  }

  // Light Mode
  NativeTemplateStyle nativeTemplateLight() {
    final templateType =
    MediaQuery.of(context).size.width < 360 ? TemplateType.small : TemplateType.medium;
    return NativeTemplateStyle(
      templateType: templateType,
      mainBackgroundColor: Colors.white,
      cornerRadius: 10.0,
      callToActionTextStyle: NativeTemplateTextStyle(
        textColor: Colors.white,
        backgroundColor: Colors.blue, // or any color suitable for your app
        style: NativeTemplateFontStyle.normal,
        size: 16.0,
      ),
      primaryTextStyle: NativeTemplateTextStyle(
        textColor: Colors.grey.shade900,
        backgroundColor: Colors.transparent,
        style: NativeTemplateFontStyle.bold,
        size: 16.0,
      ),
      secondaryTextStyle: NativeTemplateTextStyle(
        textColor: Colors.blueGrey.shade600,
        backgroundColor: Colors.transparent,
        style: NativeTemplateFontStyle.normal,
        size: 14.0,
      ),
      tertiaryTextStyle: NativeTemplateTextStyle(
        textColor: Colors.blueGrey.shade500,
        backgroundColor: Colors.transparent,
        style: NativeTemplateFontStyle.normal,
        size: 14.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => mainTabBloc,
      child: BlocListener<MainTabBloc, MainTabState>(
        listener: (context, state) {
          if (state is MainTabLoaded) {
            print('MainTabLoaded');
            _createNativeAd(state.isDarkMode);
          }
        },
        child: BlocBuilder<MainTabBloc, MainTabState>(
          builder: (context, state) {
            final isDarkMode = state is MainTabLoaded ? state.isDarkMode : false;
            return Scaffold(
              backgroundColor: isDarkMode ? Colors.black : Colors.white,
              body: SafeArea(
                child: Column(
                  children: [
                    if (isAdLoaded)
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 5),
                        child: SizedBox(
                          height: 72, // Adjust height based on your ad size.
                          child: AdWidget(ad: _nativeAd!),
                        ),
                      ),
                    Expanded(
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: [
                          HomeScreen(key: _homeScreenKey),
                          ScheduleScreen(key: _scheduleScreenKey,),
                          DdayScreen(key: _ddayScreenKey,),
                          const SettingsScreen(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.25),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;

                      if (index == 0) {
                        _homeScreenKey.currentState?.homeBloc.add(FetchHomeItems(DateTime.now()));
                      } else if (index == 1) {
                        _scheduleScreenKey.currentState?.scheduleBloc.add(FetchScheduleItemsByDate(DateTime.now()));
                      } else if (index == 2) {
                        _ddayScreenKey.currentState?.ddayBloc.add(FetchDdayItems());
                      }
                    });
                  },
                  selectedItemColor: isDarkMode ? Colors.white : Colors.black,
                  unselectedItemColor: Colors.grey,
                  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                  items: [
                    _buildBottomNavigationBarItem(
                      'Home',
                      'assets/images/tabbar/homeTab/home_black.png',
                      'assets/images/tabbar/homeTab/home_black_fill.png',
                      0,
                    ),
                    _buildBottomNavigationBarItem(
                      'Schedule',
                      'assets/images/tabbar/scheduleTab/schedule_black.png',
                      'assets/images/tabbar/scheduleTab/schedule_black_fill.png',
                      1,
                    ),
                    _buildBottomNavigationBarItem(
                      'D-day',
                      'assets/images/tabbar/dDayTab/dday_black.png',
                      'assets/images/tabbar/dDayTab/dday_black_fill.png',
                      2,
                    ),
                    _buildBottomNavigationBarItem(
                      'Settings',
                      'assets/images/tabbar/settingsTab/setting_black.png',
                      'assets/images/tabbar/settingsTab/setting_black_fill.png',
                      3,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
      String label,
      String unselectedIconPath,
      String selectedIconPath,
      int index,
      ) {
    return BottomNavigationBarItem(
      icon: _selectedIndex == index
          ? Image.asset(selectedIconPath)
          : Image.asset(unselectedIconPath),
      label: label,
    );
  }
}
