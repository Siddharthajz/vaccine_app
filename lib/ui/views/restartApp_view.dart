import 'package:vaccineApp/view_models/restartApp_view_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class RestartApp extends StatelessWidget {
    final String previousPageRoute;
    RestartApp({Key key, this.previousPageRoute}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return ViewModelBuilder<RestartAppViewModel>.reactive(
            viewModelBuilder: () => RestartAppViewModel(),
            onModelReady: (model) => model.handleStartUpLogic(previousPageRoute),
            builder: (context, model, child) => Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                            CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation(
                                    Color(0xdfdc197c),
                                ),
                            )
                        ],
                    ),
                ),
            ),
        );
    }
}