import 'package:vaccineApp/constants/route_names.dart';
import 'package:vaccineApp/locator.dart';
import 'package:vaccineApp/services/authentication_service.dart';
import 'package:vaccineApp/services/dialog_service.dart';
import 'package:vaccineApp/services/firestore_service.dart';
import 'package:vaccineApp/services/localDb_service.dart';
import 'package:vaccineApp/services/navigation_service.dart';
import 'package:flutter/foundation.dart';
import 'package:vaccineApp/view_models/schedule_view_model.dart';

import 'base_model.dart';

class SettingsViewModel extends BaseModel {

    final AuthenticationService _authenticationService = locator<AuthenticationService>();
    final DialogService _dialogService = locator<DialogService>();
    final NavigationService _navigationService = locator<NavigationService>();
    final FirestoreService _firestoreService = locator<FirestoreService>();
    final LocalDbService _localDbService = locator<LocalDbService>();

    Future<void> signOut() async {
        await _authenticationService.logOut();
        _navigationService.navigateTo(LoginViewRoute);
    }

    void goToChildrenList() {
        _navigationService.navigateTo(ChildrenListRoute);
    }

    String getActiveChild() {
        String name = "";
        if (_authenticationService.activeChild != null) {
            name = _authenticationService.activeChild.fname;
        }
        return name;
    }
    void resetSchedule() async{
        print("resetSchedule(): called");
        var response = await _dialogService.showConfirmationDialog(
            title: 'Reset Schedule?',
            description: "Warning: This will reset the reminder date of all the vaccine. Do you want to continue?",
            confirmationTitle: 'Yes',
            cancelTitle: 'Cancel',
        );
        if(response.confirmed) {
            setBusy(true);
            bool deleteScheduleStatus = false;
            await _localDbService.deleteSchedule(_authenticationService.activeChild.documentID).then((deleteScheduleResponse) => deleteScheduleStatus = deleteScheduleResponse);
            if(deleteScheduleStatus){
                ScheduleViewModel _scheduleObject = new ScheduleViewModel();
                await _scheduleObject.getAllDueDoses().whenComplete(() async{
                    setBusy(false);
                    await _dialogService.showConfirmationDialog(
                        title: 'Schedule Reset',
                        description: "Child's schedule is reset now.",
                        cancelTitle: 'Cancel',
                    );
                });
            } else{
                print("Schedule not deleted: "+deleteScheduleStatus.toString());
            }
        }
    }
}