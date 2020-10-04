import 'package:vaccineApp/services/authentication_service.dart';
import 'package:vaccineApp/services/firestore_service.dart';
import 'package:vaccineApp/services/debug_service.dart';
import 'package:get_it/get_it.dart';
import 'package:vaccineApp/services/localDb_service.dart';
import 'package:vaccineApp/services/navigation_service.dart';
import 'package:vaccineApp/services/dialog_service.dart';
import 'package:vaccineApp/services/notification_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => DebugService());
  locator.registerLazySingleton(() => Notifications());
  locator.registerLazySingleton(() => LocalDbService());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => AuthenticationService());
  locator.registerLazySingleton(() => FirestoreService());
}
