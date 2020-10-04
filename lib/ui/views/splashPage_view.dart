import 'package:vaccineApp/ui/shared/app_colors.dart';
import 'package:vaccineApp/ui/shared/ui_helpers.dart';
import 'package:vaccineApp/view_models/splashPage_view_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class SplashPage extends StatelessWidget {
    const SplashPage({Key key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return ViewModelBuilder<SplashPageViewModel>.reactive(
            viewModelBuilder: () => SplashPageViewModel(),
            onModelReady: (model) => model.handleStartUpLogic(),
            builder: (context, model, child) => Scaffold(
                backgroundColor: splashBgColor,
                body: Center(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                            Image.asset('assets/images/app_icon_320.png', scale: 3),
                            verticalSpaceLarge,
                            CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation(
                                    Color(0xff19c7c1),
                                ),
                            )
                        ],
                    ),
                ),
            ),
        );
    }
}


//
//import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'VaccineList.dart';
//
//class SplashPage extends StatefulWidget {
//    SplashPage({Key key}) : super(key: key);
//
//    @override
//    _SplashPageState createState() => _SplashPageState();
//}
//
//class _SplashPageState extends State<SplashPage> {
//    @override
//    initState() {
//        FirebaseAuth.instance
//            .currentUser()
//            .then((currentUser) => {
//            if (currentUser == null)
//                {Navigator.pushReplacementNamed(context, "/login")}
//            else
//                {
//                    Firestore.instance
//                        .collection("users")
//                        .document(currentUser.uid)
//                        .get()
//                        .then((DocumentSnapshot result) =>
//                        Navigator.pushReplacement(
//                            context,
//                            MaterialPageRoute(
//                                builder: (context) => VaccineList(
//                                    uid: currentUser.uid,
//                                ))))
//                        .catchError((err) => print(err))
//                }
//        })
//            .catchError((err) => print(err));
//        super.initState();
//    }
//
//    @override
//    Widget build(BuildContext context) {
//        return Scaffold(
//            body: Center(
//                child: Container(
//                    child: Text("Loading..."),
//                ),
//            ),
//        );
//    }
//}