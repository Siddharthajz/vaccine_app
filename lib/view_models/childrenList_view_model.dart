import 'package:flutter/cupertino.dart';

import 'package:vaccineApp/constants/route_names.dart';
import 'package:vaccineApp/locator.dart';
import 'package:vaccineApp/models/Child.dart';
import 'package:vaccineApp/models/Vaccine.dart';
import 'package:vaccineApp/services/authentication_service.dart';
import 'package:vaccineApp/services/dialog_service.dart';
import 'package:vaccineApp/services/firestore_service.dart';
import 'package:vaccineApp/services/navigation_service.dart';
import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';
import 'package:vaccineApp/view_models/schedule_view_model.dart';
import 'package:vaccineApp/view_models/vaccineList_view_model.dart';

import 'base_model.dart';

class ChildrenListViewModel extends BaseModel {
    final AuthenticationService _authenticationService = locator<AuthenticationService>();
    final DialogService _dialogService = locator<DialogService>();
    final NavigationService _navigationService = locator<NavigationService>();
    final FirestoreService _firestoreService = locator<FirestoreService>();

    List<Child> _children = [];
    List<Child> get children => _children;

    void listenToChildren() {
        setBusy(true);
        _firestoreService.listenToChildrenRealTime().listen((childrenData) {
            List<Child> updatedChildren = childrenData;
            if (updatedChildren != null && updatedChildren.length > 0) {
                _children = updatedChildren;
                notifyListeners();
            } else {
                _children = [];
            }
        });
        setBusy(false);
    }

    bool isActiveChild(int index) {
        bool activeChildState = false;
        if(_children[index].documentID == _authenticationService.currentUser.selectedChild) {
            activeChildState = true;
        }
        return activeChildState;
    }

    void setActiveChild(int index) async{
        setBusy(true);
        await _firestoreService.setSelectedChild(_children[index].documentID);
        await _authenticationService.isUserLoggedIn().whenComplete(() async{
            ScheduleViewModel _obj = ScheduleViewModel();
            await _obj.getAllDueDoses();

            VaccineListViewModel _obj2 = VaccineListViewModel();
            _obj2.listenToVaccinesRealTime();
        });
        _navigationService.pop();
        setBusy(false);
        // _navigationService.replaceAndNavigateTo(RestartAppRoute, arguments: ChildrenListRoute);
    }

    void goToVaccineList() {
        _navigationService.replaceAndNavigateTo(VaccineListRoute);
    }

    void goToAddChild() {
        _navigationService.navigateTo(AddChildRoute);
    }

    Future<void> signOut() async {
        await _authenticationService.logOut();
        _navigationService.navigateTo(LoginViewRoute);
    }
}