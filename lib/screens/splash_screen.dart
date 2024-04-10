import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/helpers/addons_helper.dart';
import 'package:active_ecommerce_flutter/helpers/auth_helper.dart';
import 'package:active_ecommerce_flutter/helpers/business_setting_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/presenter/currency_presenter.dart';
import 'package:active_ecommerce_flutter/providers/locale_provider.dart';
import 'package:active_ecommerce_flutter/screens/intro_directory/get_started_page.dart';
import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  PackageInfo _packageInfo = PackageInfo(
    appName: AppConfig.app_name,
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initPackageInfo();
    getSharedValueHelperData().then((value) {
      Future.delayed(Duration(seconds: 3)).then((value) {
        Provider.of<LocaleProvider>(context, listen: false)
            .setLocale(app_mobile_language.$!);
        checkFirstSeen();
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) {
        //       return Main(
        //         go_back: false,
        //       );
        //     },
        //   ),
        //   (route) => false,
        // );
      });
    });
  }

  Future<void> checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      // If user has seen the introduction screen before, navigate to your main screen
     if(is_logged_in.$){
       Navigator.pushAndRemoveUntil(
         context,
         MaterialPageRoute(
           builder: (context) {
             return Main(
               go_back: false,
             );
           },
         ),
             (route) => false,
       );
     }else{
       Navigator.pushAndRemoveUntil(
         context,
         MaterialPageRoute(
           builder: (context) {
             return Login(
             );
           },
         ),
             (route) => false,
       );
     }
    } else {
      // If it's the first time, navigate to the introduction screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GetStartedPage(),
        ), // Replace OnBoardingPage with your actual introduction screen
      );

      // Set the flag to true so that the introduction screen won't be shown again
      await prefs.setBool('seen', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return splashScreen();
  }

  Widget splashScreen() {
    return Container(
      width: DeviceInfo(context).height,
      height: DeviceInfo(context).height,
      color: MyTheme.splash_screen_color,
      child: InkWell(
        child: Stack(
          // mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Hero(
                tag: "backgroundImageInSplash",
                child: Container(
                  child: Image.asset(
                      "assets/splash_login_registration_background_image.png"),
                ),
              ),
              radius: 140.0,
            ),
            Positioned.fill(
              top: DeviceInfo(context).height! / 2 - 72,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        height: 72,
                        width: 72,
                        "assets/splash_screen_image.png",
                        filterQuality: FilterQuality.low,
                      ),
                      Column(
                        children: [
                          Text(
                            AppConfig.app_name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0,
                                color: Colors.white),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Online Groceries",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: Colors.white),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
              // child: Column(
              //   children: [
              //     Padding(
              //       padding: const EdgeInsets.only(bottom: 10.0),
              //       child: Hero(
              //         tag: "splashscreenImage",
              //         child: Container(
              //           height: 72,
              //           width: 72,
              //           padding: EdgeInsets.symmetric(horizontal: 12,vertical: 12),
              //           decoration: BoxDecoration(
              //             color: MyTheme.white,
              //             borderRadius: BorderRadius.circular(8)
              //           ),
              //           child: Image.asset(
              //               "assets/splash_screen_logo.png",
              //             filterQuality: FilterQuality.low,
              //           ),
              //         ),
              //       ),
              //     ),
              //     Padding(
              //       padding: const EdgeInsets.only(bottom: 5.0),
              //       child: Text(
              //         AppConfig.app_name,
              //         style: TextStyle(
              //             fontWeight: FontWeight.bold,
              //             fontSize: 14.0,
              //             color: Colors.white),
              //       ),
              //     ),
              //     Text(
              //       "V " + _packageInfo.version,
              //       style: TextStyle(
              //           fontWeight: FontWeight.bold,
              //           fontSize: 14.0,
              //           color: Colors.white,
              //       ),
              //     ),
              //   ],
              // ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 51.0),
                  child: Text(
                    AppConfig.copyright_text,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
/*
            Padding(
              padding: const EdgeInsets.only(top: 120.0),
              child: Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                    ],
                  )),
            ),*/
          ],
        ),
      ),
    );
  }

  Future<String?> getSharedValueHelperData() async {
    access_token.load().whenComplete(() {
      AuthHelper().fetch_and_set();
    });
    AddonsHelper().setAddonsData();
    BusinessSettingHelper().setBusinessSettingData();
    await app_language.load();
    await app_mobile_language.load();
    await app_language_rtl.load();
    await system_currency.load();
    Provider.of<CurrencyPresenter>(context, listen: false).fetchListData();

    // print("new splash screen ${app_mobile_language.$}");
    // print("new splash screen app_language_rtl ${app_language_rtl.$}");

    return app_mobile_language.$;
  }
}
