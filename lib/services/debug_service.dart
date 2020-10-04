import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';

class DebugService{

  Future<bool> isDebugInit() async {
    try {
      // Force disable Crashlytics collection while doing every day development.
      // Temporarily toggle this to true if you want to test crash reporting in your app.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    } catch(e){
      print("isLocalDbInit() Exception: "+e.toString());
    }
    return true;
  }

  Future debugLog(String _logMessage) async{
    if(FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
      await FirebaseCrashlytics.instance.log(_logMessage);
    }
  }

  Future debugException(dynamic _exception, StackTrace _stack) async{
    if(FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
      await FirebaseCrashlytics.instance.recordError(_exception, _stack);
    }
  }

  void forceCrash(){
    FirebaseCrashlytics.instance.crash();
  }
}