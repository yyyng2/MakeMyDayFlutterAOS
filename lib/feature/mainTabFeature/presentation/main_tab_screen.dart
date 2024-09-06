import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../commonFeature/data/datasources/common_local_datasource.dart';
import '../../commonFeature/data/repositories/common_repository_impl.dart';
import '../../commonFeature/domain/usecases/common_usecase.dart';
import '../../../infrastructure/service/ad_service.dart';
import '../../ddayFeature/presentation/bloc/dday_bloc.dart';
import '../../ddayFeature/presentation/dday_screen.dart';
import '../../homeFeature/presentation/bloc/home_bloc.dart';
import '../../homeFeature/presentation/home_screen.dart';
import '../../scheduleFeature/presentation/schedule_screen.dart';
import '../../scheduleFeature/presentation/bloc/schedule_bloc.dart';
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
  BannerAd? _bannerAd;
  bool isAdLoaded = false;

  late MainTabBloc mainTabBloc;
  final CommonLocalDatasource commonLocalDatasource = CommonLocalDatasource();
  late final CommonRepositoryImpl commonRepositoryImpl;
  late final CommonUsecase commonUsecase;

  final GlobalKey<HomeScreenState> _homeScreenKey =
      GlobalKey<HomeScreenState>();
  final GlobalKey<ScheduleScreenState> _scheduleScreenKey =
      GlobalKey<ScheduleScreenState>();
  final GlobalKey<DdayScreenState> _ddayScreenKey =
      GlobalKey<DdayScreenState>();

  @override
  void initState() {
    super.initState();
    commonRepositoryImpl = CommonRepositoryImpl(
        localDatasource: commonLocalDatasource, remoteDatasource: null);
    commonUsecase = CommonUsecase(repository: commonRepositoryImpl);
    mainTabBloc = MainTabBloc(commonUsecase);
    mainTabBloc.add(LoadThemeEvent());
  }

  void _createNativeAd(bool isDarkTheme) {
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
      nativeTemplateStyle:
          isDarkTheme ? nativeTemplateDark() : nativeTemplateLight(),
    )..load();
  }

  void _createBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      listener: BannerAdListener(onAdLoaded: (ad) {
        setState(() {
          isAdLoaded = true;
        });
      }, onAdFailedToLoad: (ad, error) {
        print('Failed to load a banner ad: ${error.message}');
        ad.dispose();
      }),
      request: const AdRequest(),
      size: AdSize.banner,
    )..load();
  }

  //Dark Mode
  NativeTemplateStyle nativeTemplateDark() {
    final templateType = MediaQuery.of(context).size.width < 360
        ? TemplateType.small
        : TemplateType.medium;
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
    final templateType = MediaQuery.of(context).size.width < 360
        ? TemplateType.small
        : TemplateType.medium;
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
            // _createNativeAd(state.isDarkTheme);
            _createBannerAd();
          }
        },
        child: BlocBuilder<MainTabBloc, MainTabState>(
          builder: (context, state) {
            final isDarkTheme =
                state is MainTabLoaded ? state.isDarkTheme : false;
            return Scaffold(
              backgroundColor: isDarkTheme ? Colors.black : Colors.white,
              body: SafeArea(
                child: Column(
                  children: [
                    if (isAdLoaded)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: SizedBox(
                          height: 62,
                          child: AdWidget(ad: _bannerAd!),
                        ),
                      ),
                    Expanded(
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: [
                          HomeScreen(key: _homeScreenKey),
                          ScheduleScreen(
                            key: _scheduleScreenKey,
                          ),
                          DdayScreen(
                            key: _ddayScreenKey,
                          ),
                          SettingsScreen(
                            mainTabBloc: mainTabBloc,
                          ),
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
                  backgroundColor: isDarkTheme ? Colors.black : Colors.white,
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;

                      if (index == 0) {
                        _homeScreenKey.currentState?.homeBloc
                            .add(FetchHomeItems(DateTime.now()));
                      } else if (index == 1) {
                        _scheduleScreenKey.currentState?.scheduleBloc
                            .add(FetchScheduleItemsByDate(DateTime.now()));
                      } else if (index == 2) {
                        _ddayScreenKey.currentState?.ddayBloc
                            .add(FetchDdayItems());
                      }
                    });
                  },
                  selectedItemColor: isDarkTheme ? Colors.white : Colors.black,
                  unselectedItemColor: Colors.grey,
                  selectedLabelStyle: TextStyle(
                      color: isDarkTheme ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold),
                  unselectedLabelStyle: TextStyle(
                      color: isDarkTheme ? Colors.black : Colors.white,
                      fontWeight: FontWeight.normal),
                  items: [
                    _buildBottomNavigationBarItem(
                      isDarkTheme: isDarkTheme,
                      label: 'Home',
                      unselectedIconPath:
                          'assets/images/tabbar/homeTab/home_black.png',
                      unselectedIconPathDarkMode:
                          'assets/images/tabbar/homeTab/home_white.png',
                      selectedIconPath:
                          'assets/images/tabbar/homeTab/home_black_fill.png',
                      selectedIconPathDarkMode:
                          'assets/images/tabbar/homeTab/home_white_fill.png',
                      index: 0,
                    ),
                    _buildBottomNavigationBarItem(
                      isDarkTheme: isDarkTheme,
                      label: 'Schedule',
                      unselectedIconPath:
                          'assets/images/tabbar/scheduleTab/schedule_black.png',
                      unselectedIconPathDarkMode:
                          'assets/images/tabbar/scheduleTab/schedule_white.png',
                      selectedIconPath:
                          'assets/images/tabbar/scheduleTab/schedule_black_fill.png',
                      selectedIconPathDarkMode:
                          'assets/images/tabbar/scheduleTab/schedule_white_fill.png',
                      index: 1,
                    ),
                    _buildBottomNavigationBarItem(
                      isDarkTheme: isDarkTheme,
                      label: 'D-day',
                      unselectedIconPath:
                          'assets/images/tabbar/dDayTab/dday_black.png',
                      unselectedIconPathDarkMode:
                          'assets/images/tabbar/dDayTab/dday_white.png',
                      selectedIconPath:
                          'assets/images/tabbar/dDayTab/dday_black_fill.png',
                      selectedIconPathDarkMode:
                          'assets/images/tabbar/dDayTab/dday_white_fill.png',
                      index: 2,
                    ),
                    _buildBottomNavigationBarItem(
                      isDarkTheme: isDarkTheme,
                      label: 'Settings',
                      unselectedIconPath:
                          'assets/images/tabbar/settingsTab/setting_black.png',
                      unselectedIconPathDarkMode:
                          'assets/images/tabbar/settingsTab/setting_white.png',
                      selectedIconPath:
                          'assets/images/tabbar/settingsTab/setting_black_fill.png',
                      selectedIconPathDarkMode:
                          'assets/images/tabbar/settingsTab/setting_white_fill.png',
                      index: 3,
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

  BottomNavigationBarItem _buildBottomNavigationBarItem({
    required bool isDarkTheme,
    required String label,
    required String unselectedIconPath,
    required String unselectedIconPathDarkMode,
    required String selectedIconPath,
    required String selectedIconPathDarkMode,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: _selectedIndex == index
          ? Image.asset(
              isDarkTheme ? selectedIconPathDarkMode : selectedIconPath,
              width: 25,
              height: 25,
            )
          : Image.asset(
              isDarkTheme ? unselectedIconPathDarkMode : unselectedIconPath,
              width: 25,
              height: 25,
            ),
      label: label,
    );
  }
}
