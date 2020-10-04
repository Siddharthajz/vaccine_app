import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:stacked/stacked.dart';

import 'package:vaccineApp/locator.dart';
import 'package:vaccineApp/constants/route_names.dart';
import 'package:vaccineApp/models/Child.dart';
import 'package:vaccineApp/models/Dose.dart';
import 'package:vaccineApp/models/schedule.dart';
import 'package:vaccineApp/services/authentication_service.dart';
import 'package:vaccineApp/services/debug_service.dart';
import 'package:vaccineApp/services/firestore_service.dart';
import 'package:vaccineApp/services/localDb_service.dart';
import 'package:vaccineApp/services/navigation_service.dart';
import 'package:vaccineApp/services/notification_service.dart';

class ScheduleViewModel extends IndexTrackingViewModel{

    final NavigationService _navigationService = locator<NavigationService>();
    final AuthenticationService _authenticationService = locator<AuthenticationService>();
    final FirestoreService _dataService = locator<FirestoreService>();
    final LocalDbService _localDbService = locator<LocalDbService>();
    final Notifications _notifications = locator<Notifications>();
    final DebugService _debugService = locator<DebugService>();

    List<Dose> _doses = [];
    List<Dose> get doses => _doses;
    List doseFilter = ['Birth', '1M', '2M', '4M', '6M', '12M', '15M', '18M', '18-24M', '2-3Y', '4-6Y', '7-10Y', '11Y+'];

    List<Schedule> _filteredDoses = [];
    List<Schedule> get filteredDoses => _filteredDoses;

    List<Schedule> _dueDoses = [];
    List<Schedule> get dueDoses => _dueDoses;

    bool isLoadingDbProcess = false;
    bool isFilteredListBusy = false;

    Future<bool> getAllDueDoses() async{
        bool getAllDueDosesStatus = false;
        await clearScheduleDoseFilter();
        await getDueDoses().then((getDueDosesResponse) => getAllDueDosesStatus = getDueDosesResponse);
        print("Get Due Doses Status: "+getAllDueDosesStatus.toString());
        notifyListeners();
        return getAllDueDosesStatus;
    }

    Future<void> clearScheduleDoseFilter() async{
        if(_authenticationService.activeChild != null) {
            try {
                await getFilteredDoses(9999, 9999);
                notifyListeners();
            } catch (e) {
                print("clearScheduleDoseFilter() Exception: " + e.toString());
            }
        }
    }

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

    Future<bool> getDueDoses() async{
        bool getDueDosesStatus = false;
        var activeChild = _authenticationService.activeChild;
        if(activeChild != null) {
            print("Getting Due Doses");
            setBusy(true);
            Stopwatch stopwatch = new Stopwatch()..start();
            try {
                await _localDbService.isScheduleExist(activeChild.documentID).then((value) async {
                    // print("isScheduleExist(): " + value.toString());
                    if (value) {
                        await Hive.close();
                        var returnedStream = await _localDbService.listenToChildDueDosesRealTime(activeChild.documentID).then((value)=> value);
                        getDueDosesStatus = true;
                        returnedStream.listen((scheduleDoses) {
                            // print("listenToChildDueDosesRealTime(): " + scheduleDoses.length.toString());
                            if (scheduleDoses != null && scheduleDoses.length > 0) {
                                _dueDoses = scheduleDoses;
                            } else {
                                _dueDoses = [];
                                print("No Scheduled Doses");
                            }
                            notifyListeners();
                            setBusy(false);
                            print('getDueDoses() executed in ${stopwatch.elapsed}');
                        }).onError((err){
                            print("Error listenToChildDueDosesRealTime(): "+ err.toString());
                        });
                    } else {
                        print("No Local Database Found! Let's prepare it first.");
                        isLoadingDbProcess = true;
                        setBusy(true);
                        print("Setting Busy True");
                        bool prepareScheduleStatus = false;
                        await _localDbService.prepareSchedule(activeChild.documentID, activeChild.dob, activeChild.documentID).then((receivedStatus) async{
                            if(receivedStatus){
                                prepareScheduleStatus = receivedStatus;
                                print("prepareSchedule(): Completed");
                            }
                        }).catchError((onError) {
                            print("Error: prepareSchedule(): " + onError.toString());
                        });
                        if(prepareScheduleStatus){
                            await getDueDoses().whenComplete(() => getDueDosesStatus = true);
                            print("Setting Busy False");
                            isLoadingDbProcess = false;
                            setBusy(false);
                        }
                    }
                });
            } catch(e){
                print("isScheduleExist() Exception: "+e.toString());
            }
        }
        print("getDueDosesStatus() return: "+getDueDosesStatus.toString());
        return getDueDosesStatus;
    }

    Future<void> getFilteredDoses(int filterStartDate, int filterEndDate) async{
        if(filterStartDate == null && filterEndDate == null){
            _filteredDoses = [];
        } else {
            var activeChild = _authenticationService.activeChild;
            setBusy(true);
            Stopwatch stopwatch = new Stopwatch()
                ..start();
            // print("Filtered Doses for child: "+ activeChild.documentID);
            await Hive.close();
            var returnedStream = await _localDbService.listenToFilteredChildDueDosesRealTime(
                activeChild.documentID, filterStartDate, filterEndDate);
            returnedStream.listen((
                scheduleDoses) {
                // print("getFilteredDoses(): " + scheduleDoses.length.toString());
                if (scheduleDoses != null && scheduleDoses.length > 0) {
                    _filteredDoses = scheduleDoses;
                    notifyListeners();
                } else {
                    _filteredDoses = [];
                    notifyListeners();
                    // print("No Scheduled Doses");
                }
                notifyListeners();
                setBusy(false);
                // print('getDueDoses() executed in ${stopwatch.elapsed}');
            });
        }
    }

    void viewDose(int index, String typeDose) async{
        // isLoadingDbProcess = true;
        setBusy(true);
        Stopwatch stopwatch = new Stopwatch()..start();
        switch(typeDose) {
            case 'a':
                print("Viewing Filtered Dose of Vaccine: " + _filteredDoses[index].vaccineID);
                await _dataService.getChildDoseByDoseVaccineID(_filteredDoses[index].vaccineID, _filteredDoses[index].doseID).then((value){
                    _navigationService.navigateTo(DoseInfoRoute, arguments: [Dose.fromMap(value), _filteredDoses[index]]);
                }).whenComplete((){
                    // isLoadingDbProcess = false;
                    setBusy(false);
                    print('viewDose() executed in ${stopwatch.elapsed}');
                });
                break;
            case 'b':
                print("Viewing Due Dose of Vaccine: " + _doses[index].vaccineID);
                _navigationService.navigateTo(
                    DoseInfoRoute, arguments: _doses[index]);
                break;
            case 'c':
                print("Viewing Scheduled Dose of Vaccine: " + _dueDoses[index].vaccineID);
                await _dataService.getChildDoseByDoseVaccineID(_dueDoses[index].vaccineID, _dueDoses[index].doseID).then((value){
                    _navigationService.navigateTo(DoseInfoRoute, arguments: [Dose.fromMap(value), _dueDoses[index]]);
                }).whenComplete((){
                    // isLoadingDbProcess = false;
                    setBusy(false);
                    print('viewDose() executed in ${stopwatch.elapsed}');
                });
        }
    }

    void filterDoseBy(int index){
        print("Filter Dose List by: "+doseFilter[index]);
        switch(index){
            case 0: getFilteredDoses(0, 0);
                break;
            case 1: getFilteredDoses(1, 30);
                break;
            case 2: getFilteredDoses(31, 61);
                break;
            case 3: getFilteredDoses(62, 122);
                break;
            case 4: getFilteredDoses(123, 183);
                break;
            case 5: getFilteredDoses(184, 365);
                break;
            case 6: getFilteredDoses(366, 455);
                break;
            case 7: getFilteredDoses(456, 546);
                break;
            case 8: getFilteredDoses(547, 730);
                break;
            case 9: getFilteredDoses(731, 1460);
                break;
            case 10: getFilteredDoses(1461, 2554);
                break;
            case 11: getFilteredDoses(2555, 4016);
                break;
            case 12: getFilteredDoses(4017, 5843);
                break;
            default: getFilteredDoses(null, null);
        }
    }

    void tempFunction()async{
        // for crashing app
        await FirebaseCrashlytics.instance.setCustomKey("Custom Logs","tempFunction() Called").whenComplete(() => print("Logged!"));
        _debugService.debugLog("Custom Log using Debug Service");
        _debugService.forceCrash();

        // return;
        print("Notification Called");
        // await _notifications.cancelAllNotification().whenComplete(() => print("Cancelled all notifications!"));
        // return;

        await Hive.close();
        try {
            List<PendingNotificationRequest> _pendingNotifications = [];
            List<PendingNotificationRequest> _activeChildPendingNotifications = [];
            List<PendingNotificationRequest> _inActiveChildPendingNotifications = [];
            String boxName = _authenticationService.activeChild.documentID;
            var box = await Hive.openBox(boxName).then((value) => value).whenComplete(() => print("Box opened!"));

            List<int> scheduledNotificationID = [];
            box.values.cast<Schedule>().forEach((scheduleDose) {
                int _preNotificationID = _localDbService.getNotificationID("pre", _localDbService.getScheduleKey(scheduleDose), boxName);
                int _mainNotificationID = _localDbService.getNotificationID("main", _localDbService.getScheduleKey(scheduleDose), boxName);
                scheduledNotificationID.add(_preNotificationID);
                scheduledNotificationID.add(_mainNotificationID);
            });

            // await _notifications.cancelAllNotification();
            // await _notifications.scheduleNotification("ABC".hashCode, new DateTime.now().add(Duration(seconds: 120)), "Vaccination Pre-Reminder!", "ABC is due tomorrow for vaccination.", "Payload ABC").whenComplete(() => print("Pre-Reminder Date Notify for: ABC"));
            // await _notifications.scheduleNotification("DEF".hashCode, new DateTime.now().add(Duration(seconds: 120)), "Vaccination Pre-Reminder!", "DEF is due tomorrow for vaccination.", "Payload DEF").whenComplete(() => print("Pre-Reminder Date Notify for: DEF"));
            // await _notifications.scheduleNotification("GHI".hashCode, new DateTime.now().add(Duration(seconds: 120)), "Vaccination Pre-Reminder!", "GHI is due tomorrow for vaccination.", "Payload GHI").whenComplete(() => print("Pre-Reminder Date Notify for: GHI"));
            _pendingNotifications = await _notifications.getPendingNotifications();
            for(var i = 0; i < _pendingNotifications.length; i++){
                PendingNotificationRequest _notification = _pendingNotifications[i];
                if(scheduledNotificationID.any((notificationID) => _notification.id == notificationID)){
                    print("Current User Notification ID: "+ _notification.id.toString());
                    _activeChildPendingNotifications.add(_notification);
                } else {
                    print("Other User Notification ID:"+ _notification.id.toString());
                    _inActiveChildPendingNotifications.add(_notification);
                }
                print("Pending Notification ID: "+_notification.id.toString()+" Payload:"+_notification.payload.toString() + " Title: "+_notification.title + " Body: "+_notification.body);
            }
            print("Total Pending Notifications: "+_pendingNotifications.length.toString());
            print("Total Active Child Notifications: "+_activeChildPendingNotifications.length.toString());
            print("Total Inactive Child Notifications: "+_inActiveChildPendingNotifications.length.toString());

            // await _notifications.showNotification("Vaccination Reminder!", "One or more doses are due for vaccination.", ChildrenListRoute);
            // await _notifications.scheduleNotification(new DateTime.now().add(Duration(seconds: 5)), "Vaccination Reminder!", "One or more doses are due for vaccination.", ChildrenListRoute);
        } catch(e){
            print("showNotification() Exception: "+ e.toString());
        }
    }

}