//import 'package:vaccineApp/view_models/splashPage_view_model.dart';
//import 'package:flutter/material.dart';
//import 'package:stacked/stacked.dart';
//
//class StartUpView extends StatelessWidget {
//  const StartUpView({Key key}) : super(key: key);
//
//  @override
//  Widget build(BuildContext context) {
//    return ViewModelBuilder<SplashPageViewModel>.reactive(
//      viewModelBuilder: () => SplashPageViewModel(),
//      onModelReady: (model) => model.handleStartUpLogic(),
//      builder: (context, model, child) => Scaffold(
//        backgroundColor: Colors.white,
//        body: Center(
//          child: Column(
//            mainAxisSize: MainAxisSize.min,
//            children: <Widget>[
//              SizedBox(
//                width: 300,
//                height: 100,
//                child: Text("ok"),
//              ),
//              CircularProgressIndicator(
//                strokeWidth: 3,
//                valueColor: AlwaysStoppedAnimation(
//                  Color(0xff19c7c1),
//                ),
//              )
//            ],
//          ),
//        ),
//      ),
//    );
//  }
//}
