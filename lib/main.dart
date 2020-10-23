import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:vaccineApp/locator.dart';
import 'package:vaccineApp/services/debug_service.dart';
import 'package:vaccineApp/services/dialog_service.dart';
import 'package:vaccineApp/services/navigation_service.dart';
import 'package:vaccineApp/ui/router.dart';

import 'managers/dialog_manager.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
final DebugService _debugService = locator<DebugService>();

Future<void> main() async{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp().whenComplete(() async{
        setupLocator();
        await _debugService.isDebugInit();
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((value) {
            runApp(MyApp());
        });
    });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

    final Future<FirebaseApp> _initialization = Firebase.initializeApp();

    @override
    void dispose() {
        Hive.close();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return FutureBuilder(
            future: _initialization,
            builder: (context, snapshot){
            // Check for errors
            if (snapshot.hasError) {
                return Center(
                    child: Column(
                        children: [
                            Text("Something Went Wrong!"),
                            CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation(
                                    Color(0xff19c7c1),
                                ),
                            ),
                        ],
                    ),
                );
            }
            // Once complete, show your application
            if (snapshot.connectionState == ConnectionState.done) {
                return MaterialApp(
                    title: 'vaccineApp',
                    builder: (context, child) => Navigator(
                        key: locator<DialogService>().dialogNavigationKey,
                        onGenerateRoute: (settings) => MaterialPageRoute(
                            builder: (context) => DialogManager(child: child)),
                    ),
                    debugShowCheckedModeBanner: false,
                    navigatorKey: locator<NavigationService>().navigationKey,
                    theme: ThemeData(
                        scaffoldBackgroundColor: Color.fromARGB(255, 230, 255, 243),
                        primaryColor: Color.fromARGB(255, 9, 202, 172),
                        backgroundColor: Color.fromARGB(255, 26, 27, 30),
                        textTheme: Theme.of(context).textTheme.apply(
                            fontFamily: 'Open Sans',
                        ),
                    ),
                    // TODO: darkTheme: ThemeData.dark(),
                    initialRoute: '/',
                    onGenerateRoute: generateRoute,
                );
            }

            return Center();
        }
        );
    }
}

//class MyApp extends StatelessWidget {
//    // This widget is the root of your application.
//    @override
//    Widget build(BuildContext context) {
//        return MaterialApp(
//            title: 'Vaccine App',
////            onGenerateRoute: generateRoute,
//            navigatorKey: navigatorKey,
//            theme: ThemeData(
//                primarySwatch: Colors.green,
//                // visualDensity: VisualDensity.adaptivePlatformDensity,
//            ),
//            initialRoute: '/splash',
//            routes: {
//                '/vaccineList' : (context) => VaccineList(),
//                '/splash' : (context) => SplashPage(),
//                '/schedule' : (context) => Schedule(),
//                '/login': (BuildContext context) => LoginPage(),
//                '/register': (BuildContext context) => RegisterPage(),
//                '/childrenList': (context) => ChildrenList(),
//                '/addChild': (context) => AddChild(),
////                '/doseInfo': (context) => DoseInfo(),
////                '/vaccineInfo' : (context) => VaccineInfo(),
//        },
//    );
//  }
//}