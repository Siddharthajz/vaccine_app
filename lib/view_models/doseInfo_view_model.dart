import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:vaccineApp/constants/route_names.dart';
import 'package:vaccineApp/locator.dart';
import 'package:vaccineApp/models/Dose.dart';
import 'package:vaccineApp/models/Vaccine.dart';
import 'package:vaccineApp/models/Child.dart';
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

class DoseInfoViewModel extends BaseModel {
    final AuthenticationService _authenticationService = locator<AuthenticationService>();
    final DialogService _dialogService = locator<DialogService>();
    final NavigationService _navigationService = locator<NavigationService>();
    final FirestoreService _firestoreService = locator<FirestoreService>();
    final LocalDbService _localDbService = locator<LocalDbService>();

    Dose dose;

    DoseInfoViewModel(){
        // print("This is the constructor");
        clearFilter();
    }

    Future<void> clearFilter()async{
        ScheduleViewModel _scheduleObject = new ScheduleViewModel();
        await _scheduleObject.clearScheduleDoseFilter();
    }

    void goToChildrenList() {
        _navigationService.navigateTo(ChildrenListRoute);
    }

    String getActiveChild() {
        return _authenticationService.activeChild.toJson().toString();
    }

    String getDoseDate(int startDate) {
        // print(_authenticationService.activeChild.dob);
        DateTime dobOfChild = DateFormat('dd-MM-yyyy').parse(_authenticationService.activeChild.dob);
        DateTime doseDate = new DateTime(dobOfChild.year, dobOfChild.month, dobOfChild.day + startDate);
        return DateFormat('dd-MM-yyyy').format(doseDate);
    }

    DateTime stringToDate(String date) {
        return DateFormat('dd-MM-yyyy').parse(date);
    }

    String getChildDOB() {
        print(_authenticationService.activeChild.dob);
        return _authenticationService.activeChild.dob;
    }

    Future<void> signOut() async {
        await _authenticationService.logOut();
        _navigationService.navigateTo(LoginViewRoute);
    }

    Future enterData(Dose dose, Schedule schedule) async {
        setBusy(true);

        await _firestoreService.updateDoseInfo(
            dose,
            _authenticationService.currentUser.uid,
            _authenticationService.currentUser.selectedChild)
            .whenComplete(() {
                notifyListeners();
                _localDbService.updateSchedule(schedule, _authenticationService.activeChild.documentID).whenComplete(() async{
                    ScheduleViewModel _scheduleObject = new ScheduleViewModel();
                    await _scheduleObject.getAllDueDoses();
                    setBusy(false);
                    _navigationService.pop();
                });
            });


    }

    String finalLabel(String dose) {
        Map<String, String> doses = {
            "D1": "Dose 1",
            "D2": "Dose 2",
            "D3": "Dose 3",
            "D4": "Dose 4",
            "D5": "Dose 5",
            "D6": "Dose 6",
            "D7": "Dose 7",
            "D8": "Dose 8",
            "Booster": "Booster",
            "Booster 1": "Booster 1",
            "Booster 2": "Booster 2",
            "Booster 3": "Booster 3",
            "Booster 4": "Booster 4",
        };
        return doses[dose];
    }
}