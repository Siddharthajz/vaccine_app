import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:vaccineApp/locator.dart';
import 'package:vaccineApp/models/Dose.dart';
import 'package:vaccineApp/models/Vaccine.dart';
import 'package:vaccineApp/models/schedule.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:vaccineApp/services/authentication_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:vaccineApp/services/debug_service.dart';
import 'package:vaccineApp/services/notification_service.dart';

class LocalDbService{

  final AuthenticationService _authenticationService = locator<AuthenticationService>(); //Current User
  final Notifications _notifications = locator<Notifications>();
  final DebugService _debugService = locator<DebugService>();

  List<Schedule> _scheduleDoses = [];
  List<Schedule> get scheduleDoses => _scheduleDoses;

  List<Schedule> _scheduleFilteredDoses = [];
  List<Schedule> get scheduleFilteredDoses => _scheduleFilteredDoses;

  final StreamController<List<Schedule>> _scheduleDosesController = StreamController<List<Schedule>>.broadcast();
  final StreamController<List<Schedule>> _scheduleFilteredDosesController = StreamController<List<Schedule>>.broadcast();

  Future<Stream> listenToChildDueDosesRealTime(String boxName) async{
    print("Due Doses Stream");
    try {
      Hive.openBox<Schedule>(boxName).then((box) {
        print("Box: $boxName is Opened Now");
        print("Total Doses Found in Box: " + box.values.length.toString());
        _scheduleDoses = box.values.cast<Schedule>().where((scheduleDose) {
          // print(scheduleDose.vaccineID+"_"+scheduleDose.doseID+" UserSelected: "+scheduleDose.isUserSelected.toString()+" Is Dose Given: "+scheduleDose.isDoseGiven.toString());
          return ((scheduleDose.isDoseGiven == false) && (scheduleDose.dueDate.isBefore(DateTime.now())) && (scheduleDose.isUserSelected == true));
        }).toList();
        print("Total Doses Filtered: " + _scheduleDoses.length.toString());
        _scheduleDoses.sort((a, b) {
          var scheduleA = a,
              scheduleB = b;
          return scheduleA.dueDate.compareTo(scheduleB.dueDate);
        });
        _scheduleDosesController.add(_scheduleDoses);
      });
    } catch(e, s){
      print("listenToChildDueDosesRealTime(): Exception: "+e.toString());
      _debugService.debugException(e, s);
    }
    return _scheduleDosesController.stream;
  }

  Future<Stream> listenToFilteredChildDueDosesRealTime(String boxName, int filterStartDays, int filterEndDays) async{
    try {
      Hive.openBox<Schedule>(boxName).then((box){
        _scheduleFilteredDoses = box.values.cast<Schedule>().where((scheduleDoseData) {
          var dob = DateFormat('dd-MM-yyyy').parse(scheduleDoseData.childDOB);
          var filterDays = scheduleDoseData.dueDate
              .difference(dob)
              .inDays;
          return ((filterDays >= filterStartDays) &&
              (filterDays <= filterEndDays) &&
              (scheduleDoseData.isUserSelected == true));
        }).toList();

        _scheduleFilteredDoses.sort((a, b) {
          var scheduleA = a,
              scheduleB = b;
          return scheduleA.dueDate.compareTo(scheduleB.dueDate);
        });

        _scheduleFilteredDosesController.add(_scheduleFilteredDoses);
      })
          .catchError((onError)=>print("Error: listenToFilteredChildDueDosesRealTime() | "+onError.toString()));
    } catch(e, s){
      print("listenToFilteredChildDueDosesRealTime() Exception: "+e.toString());
      _debugService.debugException(e, s);
    }
    return _scheduleFilteredDosesController.stream;
  }

  Future getChildDosesByVaccine(String boxName, String vaccineID) async{
    var dosesByVaccine = [];
    try{
      print("Scheduled Doses for VaccineID: " + vaccineID);
      var box = Hive.box(boxName);
      print("Total Doses Found in Box: "+box.values.length.toString());
      dosesByVaccine = box.values.cast<Schedule>().where((scheduleDose) {
        // print(scheduleDose.vaccineID+"_"+scheduleDose.doseID+" UserSelected: "+scheduleDose.isUserSelected.toString());
        return (scheduleDose.vaccineID == vaccineID);
      }).toList();
      print("Returned Doses: "+dosesByVaccine.length.toString());
    } catch(e, s){
      print("getChildDosesByVaccine() Exception" + e.toString());
      _debugService.debugException(e, s);
    }
    return dosesByVaccine;
  }

  countDueDoses(String boxName){
    return scheduleDoses.length;
  }

  Future<int> countDueDosesRealtime(String boxName) async{
    int dueCount;
    await Hive.openBox<Schedule>(boxName).then((box){
      dueCount = box.values.where((scheduleDose){
        return ((scheduleDose.isDoseGiven == false) && (scheduleDose.dueDate.isBefore(DateTime.now())) && (scheduleDose.isUserSelected == true));
      }).length;
    });
    return dueCount;
    // return ;
  }

  Future<bool> isLocalDbInit() async {
    // bool dbInit;
    try {
      var appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
      print("Init Hive at path: " + appDocumentDirectory.path.toString());
      Hive.init(appDocumentDirectory.path);
      Hive.registerAdapter(ScheduleAdapter());
    } catch(e, s){
      print("isLocalDbInit() Exception: "+e.toString());
      _debugService.debugException(e, s);
    }
    return true;
  }

  Future<bool> isScheduleExist(String boxName) async {
    bool scheduleExists = false;
    await Hive.boxExists(boxName).then((value) => scheduleExists = value);
    return scheduleExists;
  }

  Future prepareSchedule(String newChildID, String newChildDOB, String boxName) async{
    bool prepareScheduleStatus = false;

    CollectionReference _userVaccineCollectionReference = FirebaseFirestore.instance.collection('users').doc(_authenticationService.currentUser.uid).collection("children").doc(_authenticationService.currentUser.selectedChild).collection("vaccines");

    List<QueryDocumentSnapshot> listOfVaccines = await _userVaccineCollectionReference.get().then((value) => value.docs);

    await Hive.close();
    try {
      var box = await Hive.openBox(newChildID).then((value) => value);

      List<int> scheduledNotificationID = [];
      box.values.cast<Schedule>().forEach((scheduleDose) {
        int _preNotificationID = getNotificationID(
            "pre", getScheduleKey(scheduleDose), boxName);
        int _mainNotificationID = getNotificationID(
            "main", getScheduleKey(scheduleDose), boxName);
        scheduledNotificationID.add(_preNotificationID);
        scheduledNotificationID.add(_mainNotificationID);
      });
      List<PendingNotificationRequest> _pendingNotifications = await _notifications
          .getPendingNotifications();
      if (_pendingNotifications.length > 0) {
        for (var i = 0; i < _pendingNotifications.length; i++) {
          PendingNotificationRequest _notification = _pendingNotifications[i];
          if (scheduledNotificationID.any((notificationID) =>
          _notification.id == notificationID)) {
            print(
                "Current User Notification ID: " + _notification.id.toString());
            await _notifications.cancelNotificationById(_notification.id)
                .whenComplete(() =>
                print(_notification.id.toString() + " deleted!"));
          }
        }
        // await _notifications.cancelAllNotification().whenComplete(() => print("Cancelled all notifications!"));
      } else {
        print("No notifications found!");
      }

      int _notifyCounter = 0;

      if (listOfVaccines.length > 0) {
        for (int i = 0; i < listOfVaccines.length; i++) {
          Vaccine vaccine = Vaccine.fromMap(
              listOfVaccines[i].data(), listOfVaccines[i].id);
          List<Dose> listOfDoses = await _userVaccineCollectionReference.doc(
              vaccine.vaccineID).collection('doses').get().then((dosesData) {
            List<Dose> dataDoses = [];
            if (dosesData.docs.isNotEmpty) {
              for (var Doc in dosesData.docs) {
                dataDoses.add(Dose.fromMap(Doc.data()));
              }
            }
            return dataDoses;
          });
          if (listOfDoses.length > 0) {
            for (int j = 0; j < listOfDoses.length; j++) {
              Dose dose = listOfDoses[j];
              String doseID = listOfDoses[j].doseID;
              var parsedDate = DateFormat('dd-MM-yyyy').parse(newChildDOB);
              var _reminderDate = new DateTime(
                  parsedDate.year, parsedDate.month,
                  parsedDate.day + dose.startDate);
              var _preReminderDate = new DateTime(
                  parsedDate.year, parsedDate.month,
                  (parsedDate.day + dose.startDate) - 1);
              // String dueDate = "${reminderDate.day.toString().padLeft(2,'0')}-${reminderDate.month.toString().padLeft(2,'0')}-${reminderDate.year.toString()}";
              final scheduleDose = Schedule(
                  newChildDOB,
                  vaccine.vaccineID,
                  doseID,
                  dose.label,
                  _reminderDate,
                  (dose.givenDate != null && dose.givenDate.isNotEmpty
                      ? true
                      : false),
                  vaccine.userSelected);
              print("Child: " + newChildID + " Adding Scheduled Dose: " +
                  vaccine.vaccineID + "_" + doseID + " for: " +
                  vaccine.siteOfInjection + " " +
                  _reminderDate.toIso8601String() + " User Selected: " +
                  vaccine.userSelected.toString());
              bool scheduleAddedStatus = false;
              scheduleAddedStatus =
              await addSchedule(scheduleDose, newChildID).then((
                  responseReceived) => responseReceived);
              if (scheduleAddedStatus) {
                Schedule updatedSchedule = Hive.box(newChildID).get(
                    vaccine.vaccineID + "_" + doseID);
                print("Added: " + updatedSchedule.dueDate.toIso8601String());
              } else {
                print("Could not add schedule.");
              }

              int _preNotificationID = getNotificationID(
                  "pre", getScheduleKey(scheduleDose), boxName);
              String _preNotificationTitle = "Vaccination Pre-Reminder!";
              String _preNotificationBody = scheduleDose.vaccineID + " dose: " +
                  scheduleDose.doseID + " is due tomorrow for vaccination.";

              int _mainNotificationID = getNotificationID(
                  "main", getScheduleKey(scheduleDose), boxName);
              String _mainNotificationTitle = "Vaccination Reminder!";
              String _mainNotificationBody = scheduleDose.vaccineID +
                  " dose: " + scheduleDose.doseID +
                  " is due today for vaccination.";


              if (_preReminderDate.isAfter(new DateTime.now())) {
                _notifyCounter++;
                await _notifications.scheduleNotification(
                    _preNotificationID, _preReminderDate, _preNotificationTitle,
                    _preNotificationBody, _preReminderDate.toIso8601String())
                    .whenComplete(() => print("Pre-Reminder Date Notify for:" +
                    getScheduleKey(scheduleDose) + " on " +
                    _preReminderDate.toIso8601String()));
              }
              if (_reminderDate.isAtSameMomentAs(new DateTime.now()) ||
                  _reminderDate.isAfter(new DateTime.now())) {
                _notifyCounter++;
                await _notifications.scheduleNotification(
                    _mainNotificationID, _reminderDate, _mainNotificationTitle,
                    _mainNotificationBody, _reminderDate.toIso8601String())
                    .whenComplete(() => print("Reminder Date Notify for:" +
                    getScheduleKey(scheduleDose) + " on " +
                    _reminderDate.toIso8601String()));
              }
            }
          } else {
            print("Could not find doses for Vaccine " + vaccine.vaccineID);
          }
        }
      } else {
        print("Could not find vaccines from Firebase");
      }
      print("Total Notifications Scheduled: "+_notifyCounter.toString());
      await Hive.openBox(newChildID);
      var preparedRecords = Hive.box(newChildID).values.length;
      if(preparedRecords == 69){
        prepareScheduleStatus = true;
      } else {
        print("Schedule not prepared correctly. Count should be 69 where it is: "+preparedRecords.toString());
      }
      return prepareScheduleStatus;
    } catch(e,s){
      _debugService.debugException(e, s);
    }
  }

  Future<bool> addSchedule(Schedule schedule, String boxName) async {
    try {
      bool addScheduleResponse = false;
      await Hive.box(boxName).put(getScheduleKey(schedule), schedule).whenComplete((){
        addScheduleResponse = true;
      }).catchError((err){
        print("addSchedule() Hive Put Error: "+err);
      });
      return addScheduleResponse;
    } catch(e, s){
      print("addSchedule(): Exception: "+ e.toString());
      _debugService.debugException(e, s);
    }
  }

  Future<bool> updateVaccineStateForChild(String childID, String vaccineId, bool vaccineState) async {
    try {
      bool updateVaccineStateForChildStatus = false;
      await Hive.close();
      await Hive.openBox<Schedule>(childID).then((box) {
        // print("Box: $childID is opened to Update Vaccine State");
        box.values.where((element) {
          return element.vaccineID == vaccineId;
        }).forEach((element) async {
          var currentKey = getScheduleKey(element);
          // print("Update "+currentKey+" Schedule from: "+element.isUserSelected.toString()+" to: "+vaccineState.toString());
          await box.put(currentKey, new Schedule(
              element.childDOB,
              element.vaccineID,
              element.doseID,
              element.doseLabel,
              element.dueDate,
              element.isDoseGiven,
              vaccineState)).whenComplete(() {
            print("Box Updated for: " + currentKey);
          });
        });
      }).whenComplete(() {
        updateVaccineStateForChildStatus = true;
      });
      return updateVaccineStateForChildStatus;
    } catch(e,s){
      _debugService.debugException(e, s);
    }
  }

  Future<bool> updateSchedule(Schedule schedule, String boxName) async{
    try {
      bool updateSchedule = false;
      await Hive.close();
      await Hive.openBox<Schedule>(boxName).then((box) {
        print("Box: $boxName is opened to Update Schedule");
        box.put(getScheduleKey(schedule), schedule).whenComplete(() {
          updateSchedule = true;
        });
      })
          .catchError((onError) =>
          print("Error: updateSchedule() | " + onError.toString()));

      int _preNotificationID = getNotificationID(
          "pre", getScheduleKey(schedule), boxName);
      String _preNotificationTitle = "Vaccination Pre-Reminder!";
      String _preNotificationBody = schedule.vaccineID + " dose: " +
          schedule.doseID + " is due tomorrow for vaccination.";
      var _preReminderDate = new DateTime(
          schedule.dueDate.year, schedule.dueDate.month,
          schedule.dueDate.day - 1);

      int _mainNotificationID = getNotificationID(
          "main", getScheduleKey(schedule), boxName);
      String _mainNotificationTitle = "Vaccination Reminder!";
      String _mainNotificationBody = schedule.vaccineID + " dose: " +
          schedule.doseID + " is due today for vaccination.";
      var _reminderDate = schedule.dueDate;


      await _notifications.cancelNotificationById(_preNotificationID);
      await _notifications.cancelNotificationById(_mainNotificationID);


      if (_preReminderDate.isAfter(new DateTime.now())) {
        await _notifications.scheduleNotification(
            _preNotificationID, _preReminderDate, _preNotificationTitle,
            _preNotificationBody, _preReminderDate.toIso8601String())
            .whenComplete(() => print(
            "Pre-Reminder Date Notify for:" + getScheduleKey(schedule) +
                " on " + _preReminderDate.toIso8601String()));
      }
      if (_reminderDate.isAtSameMomentAs(new DateTime.now()) ||
          _reminderDate.isAfter(new DateTime.now())) {
        await _notifications.scheduleNotification(
            _mainNotificationID, _reminderDate, _mainNotificationTitle,
            _mainNotificationBody, _reminderDate.toIso8601String())
            .whenComplete(() => print(
            "Reminder Date Notify for:" + getScheduleKey(schedule) + " on " +
                _reminderDate.toIso8601String()));
      }
      return updateSchedule;
    } catch(e,s){
      _debugService.debugException(e, s);
    }
  }

  String getScheduleKey(Schedule schedule){
    return schedule.vaccineID+"_"+schedule.doseID;
  }

  int getNotificationID(String salt, String hash, String uniqueID){
    return (salt+"_"+hash+"_"+uniqueID).hashCode;
  }

  Future<bool> deleteSchedule(String boxName) async{
    bool response = false;
    print("Deleting Box: $boxName");
    try{
      await Hive.deleteBoxFromDisk(boxName).whenComplete(() async{
        await Hive.boxExists(boxName).then((boxExists){
          if(!boxExists) {
            print("Box Deleted and Doesn't Exist");
            response = true;
          }
        });
      });
    } catch(e,s){
      print("deleteSchedule() Exception: "+ e.toString());
      _debugService.debugException(e, s);
    }
    return response;
  }
}