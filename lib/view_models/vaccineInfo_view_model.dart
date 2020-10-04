import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

import 'package:vaccineApp/constants/route_names.dart';
import 'package:vaccineApp/locator.dart';
import 'package:vaccineApp/models/Dose.dart';
import 'package:vaccineApp/models/Vaccine.dart';
import 'package:vaccineApp/models/schedule.dart';
import 'package:vaccineApp/services/authentication_service.dart';
import 'package:vaccineApp/services/dialog_service.dart';
import 'package:vaccineApp/services/firestore_service.dart';
import 'package:vaccineApp/services/localDb_service.dart';
import 'package:vaccineApp/services/navigation_service.dart';
import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';
import 'package:vaccineApp/view_models/schedule_view_model.dart';

import 'base_model.dart';

class VaccineInfoViewModel extends BaseModel {
    final AuthenticationService _authenticationService =
    locator<AuthenticationService>();
    final DialogService _dialogService = locator<DialogService>();
    final NavigationService _navigationService = locator<NavigationService>();
    final FirestoreService _firestoreService = locator<FirestoreService>();
    final LocalDbService _localDbService = locator<LocalDbService>();

    List<Dose> _doses = [];
    List<Dose> get doses => _doses;

    void listenToDoses(String vaccineID) {
        setBusy(true);
        print(_authenticationService.currentUser.fname+": "+_authenticationService.currentUser.selectedChild);
        print(vaccineID);
        _firestoreService.listenToDosesRealTime(vaccineID).listen((dosesData) {
            List<Dose> updatedDoses = dosesData;
            if (updatedDoses != null && updatedDoses.length > 0) {
                _doses = updatedDoses;
                notifyListeners();
            }
            setBusy(false);
        });
    }

    void setVaccine(String vaccineID, bool userSelected) async{
        bool setVaccineStatus = false;
        setBusy(true);
        setVaccineStatus = await _firestoreService.selectVaccine(vaccineID, userSelected).then((value) => value);
        if(setVaccineStatus) {
            setVaccineStatus = await _localDbService.updateVaccineStateForChild(_authenticationService.activeChild.documentID, vaccineID, !userSelected).then((response) => response);
            if(setVaccineStatus){
                ScheduleViewModel _scheduleObj = new ScheduleViewModel();
                _scheduleObj.getAllDueDoses();
                setBusy(false);
                _navigationService.pop();
            }
        }
        // _navigationService.removeAllAndNavigateTo(VaccineListRoute);
    }

    void viewDose(int index) async{
        setBusy(true);
        // print(index.toString()+": "+_doses[index].toJson().toString());
        await Hive.close();
        await Hive.openBox(_authenticationService.activeChild.documentID);
        await _localDbService.getChildDosesByVaccine(_authenticationService.activeChild.documentID, _doses[index].vaccineID).then((value){
            List<Schedule> schDoses = value;
            Schedule schDose;
            schDoses.forEach((doseData) {
                if(doseData.vaccineID == _doses[index].vaccineID && doseData.doseID == _doses[index].doseID){
                    schDose = doseData;
                }
            });
            if(schDose.vaccineID != null) {
                _navigationService.navigateTo(DoseInfoRoute, arguments: [_doses[index], schDose]);
                setBusy(false);
            } else {
                print("Could not find Dose Data");
            }
            // _navigationService.navigateTo(DoseDetailsRoute, arguments: _doses[index]);
        });
    }

    void goToChildrenList() {
        _navigationService.navigateTo(ChildrenListRoute);
    }

    Future<void> signOut() async {
        await _authenticationService.logOut();
        _navigationService.navigateTo(LoginViewRoute);
    }
}