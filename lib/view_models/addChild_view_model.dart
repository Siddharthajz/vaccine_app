import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vaccineApp/constants/route_names.dart';
import 'package:vaccineApp/locator.dart';
import 'package:vaccineApp/services/authentication_service.dart';
import 'package:vaccineApp/services/dialog_service.dart';
import 'package:vaccineApp/services/firestore_service.dart';
import 'package:vaccineApp/services/navigation_service.dart';
import 'package:flutter/foundation.dart';

import 'base_model.dart';

class AddChildViewModel extends BaseModel {
    final AuthenticationService _authenticationService = locator<AuthenticationService>();
    final DialogService _dialogService = locator<DialogService>();
    final NavigationService _navigationService = locator<NavigationService>();
    final FirestoreService _firestoreService = locator<FirestoreService>();

    String _selectedGender = 'Select Gender';
    String get selectedGender => _selectedGender;

    List<String> genderItems = ['Male', 'Female', 'Others'];

    void setSelectedGender(dynamic gender){
        _selectedGender = gender;
        notifyListeners();
    }

    Future addChild({
        @required String firstName,
        @required String lastName,
        @required String dob,
        @required bool isCDC,

    }) async {
        setBusy(true);
        await _firestoreService.addChild(firstName: firstName, lastName: lastName, dob: dob, gender: selectedGender, isCDC: isCDC).whenComplete(() => _navigationService.removeAllAndNavigateTo(HomeRoute));
        setBusy(false);
    }
}