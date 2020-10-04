import 'package:vaccineApp/constants/route_names.dart';
import 'package:vaccineApp/locator.dart';
import 'package:vaccineApp/services/authentication_service.dart';
import 'package:vaccineApp/services/dialog_service.dart';
import 'package:vaccineApp/services/localDb_service.dart';
import 'package:vaccineApp/services/navigation_service.dart';
import 'package:flutter/foundation.dart';

import 'base_model.dart';

class SignUpViewModel extends BaseModel {
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  final DialogService _dialogService = locator<DialogService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final LocalDbService _localDbService = locator<LocalDbService>();

//  String _selectedRole = 'Select a User Role';
//  String get selectedRole => _selectedRole;
//
//  void setSelectedRole(dynamic role) {
//    _selectedRole = role;
//    notifyListeners();
//  }

  Future signUp({
    @required String email,
    @required String password,
    @required String fname,
    @required String surname,
    @required String dob,
    @required String selectedChild,
  }) async {
    setBusy(true);

    var result = await _authenticationService.signUpWithEmail(
        email: email,
        password: password,
        fname: fname,
        surname: surname,
        dob: dob,
        selectedChild: null, //Initially your selectedChild would be null
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
          title: 'Sign Up Failure',
          description: 'General sign up failure. Please try again later',
        );
      }
    } else {
      await _dialogService.showDialog(
        title: 'Sign Up Failure',
        description: result,
      );
    }
  }
  void navigateToSignIn() {
    _navigationService.replaceAndNavigateTo(LoginViewRoute);
  }
}
