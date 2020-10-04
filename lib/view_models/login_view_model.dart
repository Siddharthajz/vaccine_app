import 'package:vaccineApp/constants/route_names.dart';
import 'package:vaccineApp/locator.dart';
import 'package:vaccineApp/services/authentication_service.dart';
import 'package:vaccineApp/services/dialog_service.dart';
import 'package:vaccineApp/services/localDb_service.dart';
import 'package:vaccineApp/services/navigation_service.dart';
import 'package:flutter/foundation.dart';

import 'base_model.dart';

class LoginViewModel extends BaseModel {
  final AuthenticationService _authenticationService = locator<AuthenticationService>();
  final DialogService _dialogService = locator<DialogService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final LocalDbService _localDbService = locator<LocalDbService>();

  Future login({
    @required String email,
    @required String password,
  }) async {
    setBusy(true);

    var result = await _authenticationService.loginWithEmail(
      email: email,
      password: password,
    );

    setBusy(false);

    if (result is bool) {
      if (result) {
        setBusy(true);
        _authenticationService.isUserLoggedIn().whenComplete(() async {
          await _localDbService.isLocalDbInit().then((dbInit) {
            if (dbInit) {
              print("DB Initialised!");
              _navigationService.replaceAndNavigateTo(HomeRoute);
            } else {
              print("Unable to initialise Local DB");
            }
          });
        });
      } else {
        await _dialogService.showDialog(
          title: 'Login Failure',
          description: 'General login failure. Please try again later',
        );
      }
    } else {
      await _dialogService.showDialog(
        title: 'Login Failure',
        description: result,
      );
    }
  }

  void navigateToSignUp() {
    _navigationService.replaceAndNavigateTo(SignUpViewRoute);
  }
}
