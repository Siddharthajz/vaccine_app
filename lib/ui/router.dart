import 'package:flutter/material.dart';
import 'package:vaccineApp/constants/route_names.dart';
import 'package:vaccineApp/models/Dose.dart';
import 'package:vaccineApp/models/Vaccine.dart';
import 'package:vaccineApp/models/schedule.dart';

import 'package:vaccineApp/ui/views/addChild_view.dart';
import 'package:vaccineApp/ui/views/childrenList_view.dart';
import 'package:vaccineApp/ui/views/doseInfo_view.dart';
import 'package:vaccineApp/ui/views/home_view.dart';
import 'package:vaccineApp/ui/views/restartApp_view.dart';
import 'package:vaccineApp/ui/views/schedule_view.dart';
import 'package:vaccineApp/ui/views/settings_view.dart';
import 'package:vaccineApp/ui/views/splashPage_view.dart';
import 'package:vaccineApp/ui/views/vaccineInfo_view.dart';
import 'package:vaccineApp/ui/views/vaccineList_view.dart';
import 'package:vaccineApp/ui/views/login_view.dart';
import 'package:vaccineApp/ui/views/signup_view.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
        case '/':
            return _getPageRoute(
                routeName: '/',
                viewToShow: SplashPage(),
            );
        case HomeRoute:
            return _getPageRoute(
                routeName: settings.name,
                viewToShow: Home(),
            );
        case ScheduleRoute:
            return _getPageRoute(
                routeName: settings.name,
                viewToShow: ScheduleView(),
            );
        case SettingsRoute:
            return _getPageRoute(
                routeName: settings.name,
                viewToShow: Settings(),
            );
        case RestartAppRoute:
            var previousPageRoute = settings.arguments as String;
            return _getPageRoute(
                routeName: settings.name,
                viewToShow: RestartApp(previousPageRoute: previousPageRoute)
            );
        case LoginViewRoute:
            return _getPageRoute(
                routeName: settings.name,
                viewToShow: LoginView(),
            );
        case SignUpViewRoute:
            return _getPageRoute(
                routeName: settings.name,
                viewToShow: SignUpView(),
            );
        case VaccineListRoute:
            return _getPageRoute(
                routeName: settings.name,
                viewToShow: VaccineList(),
            );
        case VaccineInfoRoute:
            var vaccineToView = settings.arguments as Vaccine;
            return _getPageRoute(
                routeName: settings.name,
                viewToShow: VaccineInfo(vaccine: vaccineToView)
            );
        case DoseInfoRoute:
            var listArgument = settings.arguments as List<dynamic>;
            var doseToView = listArgument[0] as Dose;
            var schDose = listArgument[1] as Schedule;
            return _getPageRoute(
                routeName: settings.name,
                viewToShow: DoseInfo(dose: doseToView, schDose: schDose)
            );
        case ChildrenListRoute:
            return _getPageRoute(
                routeName: settings.name,
                viewToShow: ChildrenList(),
            );
        case AddChildRoute:
            return _getPageRoute(
                routeName: settings.name,
                viewToShow: AddChild(),
            );
        default:
            return MaterialPageRoute(
                builder: (_) => Scaffold(
                    body: Center(
                        child: Text('No route defined for ${settings.name}')),
                ));
    }
}

PageRoute _getPageRoute({String routeName, Widget viewToShow}) {
    return MaterialPageRoute(
        settings: RouteSettings(
            name: routeName,
        ),
        builder: (_) => viewToShow);
}
