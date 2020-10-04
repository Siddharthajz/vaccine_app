import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

import 'package:animations/animations.dart';
import 'package:vaccineApp/ui/views/childrenList_view.dart';
import 'package:vaccineApp/ui/views/schedule_view.dart';
import 'package:vaccineApp/ui/views/settings_view.dart';
import 'package:vaccineApp/ui/views/vaccineList_view.dart';
import 'package:vaccineApp/ui/widgets/joe_icon_widget.dart';
import 'package:vaccineApp/view_models/home_view_model.dart';

class Home extends StatefulWidget {
    const Home({Key key}) : super(key: key);

    @override
    _HomeScreenState createState() => _HomeScreenState();

}
class _HomeScreenState extends State<Home> {
    @override
    Widget build(BuildContext context) {

        GlobalKey globalKey = new GlobalKey(debugLabel: 'btm_app_bar');
        bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

        if(isDark){
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
        } else {
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
        }

        print("Dark Theme: "+ isDark.toString());

        int _currentIndex = 0;

        @override
        void initState() {
            print("Init State");
            super.initState();
            _currentIndex = 1;
        }

        return ViewModelBuilder<HomeViewModel>.reactive(
            disposeViewModel: false,
            builder: (context, model, child) => CupertinoTabScaffold(
                tabBar: CupertinoTabBar(
                    activeColor: Theme.of(context).primaryColor,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    currentIndex: _currentIndex,
                    items: const <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                            icon: Icon(Icons.event),
                            title: Text('Schedule'),
                        ),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.list),
                            title: Text('Vaccines'),
                        ),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.settings),
                            title: Text('Settings'),
                        ),
                    ],
                ),
                tabBuilder: (context, index){
                    CupertinoTabView returnValue;
                    switch (index) {
                        case 0:
                            returnValue = CupertinoTabView(builder: (context) {
                                return CupertinoPageScaffold(
                                    child: ScheduleView(),
                                );
                            });
                            break;
                        case 1:
                            returnValue = CupertinoTabView(builder: (context) {
                                return CupertinoPageScaffold(
                                    child: VaccineList(),
                                );
                            });
                            break;
                        case 2:
                            returnValue = CupertinoTabView(builder: (context) {
                                return CupertinoPageScaffold(
                                    child: Settings(),
                                );
                            });
                            break;
                    }
                    return returnValue;
                },
            ),
//            Scaffold(
//                body: PageTransitionSwitcher(
//                    duration: const Duration(milliseconds: 300),
//                    reverse: model.reverse,
//                    transitionBuilder: (Widget child, Animation<double> animation, Animation<double> secondaryAnimation){
//                        return SharedAxisTransition(
//                            child: child,
//                            animation: animation,
//                            secondaryAnimation: secondaryAnimation,
//                            transitionType: SharedAxisTransitionType.horizontal,
//                        );
//                    },
//                    child: getScreenForIndex(model.currentIndex)
//                ),
//                bottomNavigationBar: new BottomNavigationBar(
//                    key: globalKey,
//                    type: BottomNavigationBarType.fixed,
//                    currentIndex: model.currentIndex,
//                    onTap: model.setIndex,
//                    items: [
//                        BottomNavigationBarItem(
//                            title: Text("Schedule"),
//                            icon: JoeIcon(
//                                text: "Schedule",
//                                iconData: Icons.event,
//                                notificationCount: model.getScheduleNotificationCount(),
//                            )
//                        ),
//                        BottomNavigationBarItem(title: Text("Vaccines"), icon: Icon(Icons.format_list_bulleted)),
//                        BottomNavigationBarItem(title: Text("Settings"), icon: Icon(Icons.settings)),
//                    ],
//                ),
//            ),
            viewModelBuilder: () => HomeViewModel(),
        );
    }

    Widget getScreenForIndex(int index) {
        switch (index) {
            case 0:
                return ScheduleView();
            case 1:
                return VaccineList();
            case 2:
                return Settings();
            default:
                return Settings();
        }
    }
}