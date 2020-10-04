import 'package:flutter/cupertino.dart';

import 'package:vaccineApp/constants/route_names.dart';
import 'package:vaccineApp/locator.dart';
import 'package:vaccineApp/models/Vaccine.dart';
import 'package:vaccineApp/services/authentication_service.dart';
import 'package:vaccineApp/services/dialog_service.dart';
import 'package:vaccineApp/services/firestore_service.dart';
import 'package:vaccineApp/services/navigation_service.dart';
import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'base_model.dart';

class VaccineListViewModel extends BaseModel {
    final AuthenticationService _authenticationService = locator<AuthenticationService>();
    final DialogService _dialogService = locator<DialogService>();
    final NavigationService _navigationService = locator<NavigationService>();
    final FirestoreService _firestoreService = locator<FirestoreService>();

    List<Vaccine> _vaccines = [];
    List<Vaccine> get vaccines => _vaccines;

    List<Vaccine> _userSelectedVaccines = [];
    List<Vaccine> get userSelectedVaccines => _userSelectedVaccines;

    bool isActiveChild(){
        if(_authenticationService.activeChild != null)
            return true;
        else
            return false;
    }

    String getActiveChildName(){
        if(isActiveChild()){
            return _authenticationService.activeChild.fname;
        } else {
            return "Add Child";
        }
    }

    void viewManageChildren(bool isChild){
        if(isChild) {
            _navigationService.navigateTo(ChildrenListRoute);
        } else {
            _navigationService.navigateTo(AddChildRoute);
        }
    }

    void listenToVaccinesRealTime() async{
        setBusy(true);
        var _returnedStreamA = await _firestoreService.listenToChildVaccinesRealTime(true);
        _returnedStreamA.listen((vaccinesData) {
            List<Vaccine> updatedVaccines = vaccinesData;
            if (updatedVaccines != null && updatedVaccines.length > 0) {
                _userSelectedVaccines = updatedVaccines;
                notifyListeners();
            } else {
                _userSelectedVaccines = [];
            }
//            setBusy(false);
        });
        var _returnedStreamB = await _firestoreService.listenToChildVaccinesRealTime(false);
        _returnedStreamB.listen((vaccinesData) {
            List<Vaccine> updatedVaccines = vaccinesData;
            if (updatedVaccines != null && updatedVaccines.length > 0) {
                _vaccines = updatedVaccines;
                notifyListeners();
            } else {
                _vaccines = [];
                notifyListeners();
            }
            setBusy(false);
        });
    }

    void listenToVaccines(bool isSelected) {
        setBusy(true);
        if(isActiveChild()) {
            print(_authenticationService.currentUser.fname+": "+_authenticationService.currentUser.selectedChild);
            _firestoreService.listenToChildVaccines(isSelected).then((
                vaccinesData) {
                List<Vaccine> updatedVaccines = vaccinesData;
                if (updatedVaccines != null && updatedVaccines.length > 0) {
                    _userSelectedVaccines = updatedVaccines;
                    notifyListeners();
                }
//            setBusy(false);
            });
            _firestoreService.listenToChildVaccines(false).then((vaccinesData) {
                List<Vaccine> updatedVaccines = vaccinesData;
                if (updatedVaccines != null && updatedVaccines.length > 0) {
                    _vaccines = updatedVaccines;
                    notifyListeners();
                }
                setBusy(false);
            });
        } else {
            print("No Active Child or Children. Handle Error");
        }
    }

    bool isVaccineSelected(int index) {
        return _vaccines[index].userSelected;
    }

    void viewVaccine(int index, bool isSelected) {
        if (isSelected) {
            _navigationService.navigateTo(VaccineInfoRoute, arguments: _userSelectedVaccines[index]);
        }
        else {
            _navigationService.navigateTo(VaccineInfoRoute, arguments: _vaccines[index]);
        }
    }

    Future<void> signOut() async {
        await _authenticationService.logOut();
        _navigationService.navigateTo(LoginViewRoute);
    }
}