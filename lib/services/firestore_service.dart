import 'dart:async';

import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:vaccineApp/models/Child.dart';
import 'package:vaccineApp/models/Dose.dart';
import 'package:vaccineApp/models/Parent.dart';
import 'package:vaccineApp/models/Vaccine.dart';
import 'package:vaccineApp/models/schedule.dart';
import 'package:vaccineApp/services/debug_service.dart';
import 'package:vaccineApp/services/localDb_service.dart';
import 'package:vaccineApp/services/notification_service.dart';
import 'package:vaccineApp/view_models/schedule_view_model.dart';
import 'package:vaccineApp/view_models/vaccineList_view_model.dart';

import '../locator.dart';
import 'authentication_service.dart';


class FirestoreService {
  final CollectionReference _usersCollectionReference = FirebaseFirestore.instance.collection('users');
  final CollectionReference _vaccinesCollectionReference = FirebaseFirestore.instance.collection('vaccines');

  // Create the controller that will broadcast the vaccines
  final StreamController<List<Vaccine>> _vaccinesController = StreamController<List<Vaccine>>.broadcast();
  final StreamController<List<Vaccine>> _vaccinesUserSelectedController = StreamController<List<Vaccine>>.broadcast();
  final StreamController<List<Dose>> _dosesController = StreamController<List<Dose>>.broadcast();
  final StreamController<List<Child>> _childrenController = StreamController<List<Child>>.broadcast();

  get value => false;

  Stream listenToVaccinesRealTime() {
    // Register the handler for when the vaccines data changes
    _vaccinesCollectionReference.snapshots().listen((vaccinesSnapshot) {
      if (vaccinesSnapshot.docs.isNotEmpty) {
        var vaccines = vaccinesSnapshot.docs
            .map((snapshot) => Vaccine.fromMap(snapshot.data(), snapshot.id))
//            .where((mappedItem) => mappedItem.userSelected == true)
            .toList();
        // Add the vaccines onto the controller
        _vaccinesController.add(vaccines);
      }
    });
    // Return the stream underlying our _vaccinesController.
    return _vaccinesController.stream;
  }

  Future<Stream> listenToChildVaccinesRealTime(bool isVaccineSelected) async{
    // Register the handler for when the vaccines data changes
    final AuthenticationService _authenticationService = locator<AuthenticationService>(); //Current User
    _usersCollectionReference
        .doc(_authenticationService.currentUser.uid)
        .collection('children')
        .doc(_authenticationService.currentUser.selectedChild)
        .collection('vaccines')
        .snapshots().listen((vaccinesSnapshot) {
      if (vaccinesSnapshot.docs.isNotEmpty) {
        var vaccines = vaccinesSnapshot.docs
            .map((snapshot) => Vaccine.fromMap(snapshot.data(), snapshot.id))
            .where((mappedItem) => mappedItem.userSelected == isVaccineSelected) // only displaying those vaccines that have been selected
            .toList();
        // Add the vaccines onto the controller
        if(isVaccineSelected){
          _vaccinesUserSelectedController.add(vaccines);
        } else {
          _vaccinesController.add(vaccines);
        }
      }
    });
    // Return the stream underlying our _vaccinesController.
    if(isVaccineSelected){
      return _vaccinesUserSelectedController.stream;
    } else {
      return _vaccinesController.stream;
    }
  }

  Future listenToChildVaccines(bool isVaccineSelected) async {
    final AuthenticationService _authenticationService = locator<AuthenticationService>(); //Current User
    var vaccineDocumentSnapshot = await _usersCollectionReference
        .doc(_authenticationService.currentUser.uid)
        .collection('children')
        .doc(_authenticationService.currentUser.selectedChild)
        .collection('vaccines')
        .get();
    try {
      var vaccineDocuments = vaccineDocumentSnapshot;
      if (vaccineDocuments.docs.isNotEmpty) {
        return vaccineDocuments.docs
            .map((snapshot) => Vaccine.fromMap(snapshot.data(), snapshot.id))
            .where((mappedItem) => mappedItem.userSelected == isVaccineSelected)
            .toList();
      }
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }
      return e.toString();
    }
  }

  Stream listenToChildrenRealTime() {
    final AuthenticationService _authenticationService = locator<AuthenticationService>(); //Current User
    _usersCollectionReference.doc(_authenticationService.currentUser.uid)
    .collection('children')
    .snapshots().listen((childrenSnapshot) {
      if (childrenSnapshot.docs.isNotEmpty) {
        var children = childrenSnapshot.docs
            .map((snapshot) => Child.fromMap(snapshot.data(), snapshot.id))
//            .where((mappedItem) => )
            .toList();
        _childrenController.add(children);
      }
    });
    return _childrenController.stream;
  }

  Stream listenToDosesRealTime(String vaccineID) {
    final AuthenticationService _authenticationService = locator<AuthenticationService>(); //Current User
  // Register the handler for when the vaccines data changes
    _usersCollectionReference.doc(_authenticationService.currentUser.uid)
        .collection('children')
        .doc(_authenticationService.currentUser.selectedChild)
        .collection('vaccines')
        .doc(vaccineID)
        .collection('doses')
        .snapshots().listen((dosesSnapshot) {
      if (dosesSnapshot.docs.isNotEmpty) {
        var doses = dosesSnapshot.docs
            .map((snapshot) => Dose.fromMap(snapshot.data()))
//            .where((mappedItem) => mappedItem.name != null)
            .toList();
        print("firestore_service.dart || doses: " + doses.toList().toString());
        // Add the vaccines onto the controller
        _dosesController.add(doses);
      } else {
        print("firestore_service.dart || dosesSnapshot.documents is empty!!" );
        // Is this because I've set some fields to null?
      }
    });
    // Return the stream underlying our _vaccinesController.
    return _dosesController.stream;
  }

  Future setSelectedChild(String selectedChild) async {
    final DebugService _debugService = locator<DebugService>();
    final AuthenticationService _authenticationService = locator<AuthenticationService>(); //Current User
    try {
      await _usersCollectionReference.doc(
          _authenticationService.currentUser.uid).update({
        'selectedChild': selectedChild,
      });
    } catch(e,s){
      _debugService.debugException(e, s);
    }
  }

  Future<bool> selectVaccine(String vaccineID, bool isSelected) async {
    final AuthenticationService _authenticationService = locator<AuthenticationService>(); //Current User
    await _usersCollectionReference
        .doc(_authenticationService.currentUser.uid)
        .collection('children')
        .doc(_authenticationService.currentUser.selectedChild)
        .collection('vaccines')
        .doc(vaccineID)
        .update({
      'userSelected': !isSelected,
    });
    return true;
  }

  Future getChildDoseByDoseVaccineID(String vaccineID, String doseID) async {
    try {
      final AuthenticationService _authenticationService = locator<AuthenticationService>(); //Current User
      var doseDocumentSnapshot = await _usersCollectionReference.doc(_authenticationService.currentUser.uid).collection("children").doc(_authenticationService.currentUser.selectedChild).collection("vaccines").doc(vaccineID).collection("doses").doc(doseID).get();
      if(doseDocumentSnapshot.data().isNotEmpty) {
        return doseDocumentSnapshot.data();
      } else {
        return false;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future getChildDosesDataByChild(Child child, int maxDosesCount) async {
    try {
      final AuthenticationService _authenticationService = locator<AuthenticationService>(); //Current User
      print("Reading Doses of Parent:"+_authenticationService.currentUser.uid+" for Child: "+child.fname);

      List<Dose> doses = [];
      List listOfVaccines = await _usersCollectionReference.doc(_authenticationService.currentUser.uid).collection("children").doc(_authenticationService.currentUser.selectedChild).collection("vaccines").where('userSelected', isEqualTo: true).get().then((value) => value.docs);

      for(int i=0; i<maxDosesCount; i++){
        await _usersCollectionReference.doc(_authenticationService.currentUser.uid).collection("children").doc(_authenticationService.currentUser.selectedChild).collection("vaccines").doc(listOfVaccines[i].documentID).collection("doses").get().then((dosesData) {
          if(dosesData.docs.isNotEmpty) {
//            print(dosesData.documents.length);
            for(var Doc in dosesData.docs) {
              doses.add(Dose.fromMap(Doc.data()));
            }
          } else{
//            print("No Dose");
          }

        });
      }
      return doses;
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }
      return e.toString();
    }
  }

  Future addChild({
    @required String firstName,
    @required String lastName,
    @required String dob,
    @required String gender,
    @required bool isCDC,
  }) async {
    final AuthenticationService _authenticationService = locator<AuthenticationService>(); //Current User
    final LocalDbService _localDbService = locator<LocalDbService>();
    final Notifications _notifications = locator<Notifications>();
    final DebugService _debugService = locator<DebugService>();

    DocumentReference childData;

    _debugService.debugLog("Add Child Service");

    try {
      childData = await _usersCollectionReference.doc(
          _authenticationService.currentUser.uid).collection("children").add({
        'firstName': firstName,
        'lastName': lastName,
        'dob': dob,
        'gender': gender,
      }).then((newChild) async {
        return childData = newChild;
      });
    } catch(e, s){
      print("addChild() Exception: "+e.toString());
      _debugService.debugException(e, s);
    }
    if(childData != null){
      List<QueryDocumentSnapshot> _listOfVaccines = await _vaccinesCollectionReference.get().then((value) => value.docs);
      await Hive.close();
      await Hive.openBox(childData.id).then((value) => print("$value box opened!"));

      int _notifyCounter = 0;

      if(_listOfVaccines.length > 0) {
        // for (int i = 0; i < 3; i++) {
        for (int i = 0; i < _listOfVaccines.length; i++) {
          Vaccine vaccine = Vaccine.fromMap(
              _listOfVaccines[i].data(), _listOfVaccines[i].id);

          bool userSelected = false;
          if (isCDC &&
              (vaccine.recommendedByIndiaGov || vaccine.recommendedByCDC)) {
            userSelected = true;
          } else if (vaccine.recommendedByIndiaGov) {
            userSelected = true;
          }
          try {
            await _usersCollectionReference.doc(
                _authenticationService.currentUser.uid).collection("children")
                .doc(childData.id).collection("vaccines").doc(
                vaccine.vaccineID)
                .set({
              "name": vaccine.name,
              "description": vaccine.description,
              "methodOfInjection": vaccine.methodOfInjection,
              "protectsAgainst": vaccine.protectsAgainst,
              "recommendedByCDC": vaccine.recommendedByCDC,
              "recommendedByIndiaGov": vaccine.recommendedByIndiaGov,
              "siteOfInjection": vaccine.siteOfInjection,
              "userSelected": userSelected
            }).whenComplete(() =>
                print("Vaccine Added: " + vaccine.vaccineID))
                .catchError((err) {
              print("Firebase Adding Vaccine error: " + err);
            });
          } catch(e, s){
            print("Set Vaccine Exception: "+e.toString());
            _debugService.debugException(e, s);
          }
          List<QueryDocumentSnapshot> _listOfDoses = await _vaccinesCollectionReference
              .doc(vaccine.vaccineID).collection("doses").get().then((
              value) => value.docs);
          if (_listOfDoses.length > 0) {
            for (int j = 0; j < _listOfDoses.length; j++) {
              var dose = Dose.fromMap(_listOfDoses[j].data());
              String _doseID = _listOfDoses[j].id;
              try {
                await _usersCollectionReference.doc(
                    _authenticationService.currentUser.uid).collection(
                    "children").doc(childData.id).collection("vaccines").doc(
                    vaccine.vaccineID).collection("doses").doc(_doseID).set({
                  "startDate": dose.startDate,
                  "endDate": dose.endDate,
                  "label": dose.label,
                  "doseID": _doseID,
                  "vaccineID": vaccine.vaccineID,
                  "doctorName": "",
                  "givenDate": "",
                  "notes": ""
                });
              } catch(e, s){
                print("Set Dose Exception: "+e.toString());
                _debugService.debugException(e, s);
              }
              var parsedDate = DateFormat('dd-MM-yyyy').parse(dob);
              var _reminderDate = new DateTime(parsedDate.year, parsedDate.month, parsedDate.day + dose.startDate);
              var _preReminderDate = new DateTime(parsedDate.year, parsedDate.month, (parsedDate.day + dose.startDate) - 1);
              final scheduleDose = Schedule(dob, vaccine.vaccineID, _doseID, dose.label, _reminderDate, false, userSelected);
              bool scheduleAddedStatus = false;
              scheduleAddedStatus = await _localDbService.addSchedule(scheduleDose, childData.id).then((responseReceived) => responseReceived);
              if (scheduleAddedStatus) {
                Schedule updatedSchedule = Hive.box(childData.id).get(
                    vaccine.vaccineID + "_" + _doseID);
                print("Added: " + updatedSchedule.dueDate.toIso8601String());
              } else {
                print("Could not add schedule.");
              }
              int _preNotificationID = _localDbService.getNotificationID("pre", _localDbService.getScheduleKey(scheduleDose), childData.id);
              String _preNotificationTitle = "Vaccination Pre-Reminder!";
              String _preNotificationBody = scheduleDose.vaccineID+" dose: "+scheduleDose.doseID+" is due tomorrow for vaccination.";

              int _mainNotificationID = _localDbService.getNotificationID("main", _localDbService.getScheduleKey(scheduleDose), childData.id);
              String _mainNotificationTitle = "Vaccination Reminder!";
              String _mainNotificationBody = scheduleDose.vaccineID+" dose: "+scheduleDose.doseID+" is due today for vaccination.";

              if(_preReminderDate.isAfter(new DateTime.now())){
                _notifyCounter++;
                await _notifications.scheduleNotification(_preNotificationID, _preReminderDate, _preNotificationTitle, _preNotificationBody, _preReminderDate.toIso8601String()).whenComplete(() => print("Pre-Reminder Date Notify for:"+_localDbService.getScheduleKey(scheduleDose)+" on "+_preReminderDate.toIso8601String()));
              }
              if(_reminderDate.isAtSameMomentAs(new DateTime.now()) || _reminderDate.isAfter(new DateTime.now())) {
                _notifyCounter++;
                await _notifications.scheduleNotification(_mainNotificationID, _reminderDate, _mainNotificationTitle, _mainNotificationBody, _reminderDate.toIso8601String()).whenComplete(() => print("Reminder Date Notify for:"+_localDbService.getScheduleKey(scheduleDose)+" on "+_reminderDate.toIso8601String()));
              }
            }
          }
        }
      }
      print("Total Notifications Scheduled: "+_notifyCounter.toString());
      try {
        var preparedRecords = Hive
            .box(childData.id)
            .values
            .length;
        if (preparedRecords == 69) {
          print("Schedule prepared correctly!");
        } else {
          print(
              "Schedule not prepared correctly. Count should be 69 where it is: " +
                  preparedRecords.toString());
        }
      } catch(e,s){
        _debugService.debugException(e, s);
      }
      await setSelectedChild(childData.id);
      bool isLoggedIn = false;
      isLoggedIn = await _authenticationService.isUserLoggedIn().then((value)=> value);
      if(isLoggedIn){
        if(_authenticationService.activeChild != null){
          ScheduleViewModel _scheduleObject = new ScheduleViewModel();
          await _scheduleObject.getAllDueDoses();
          VaccineListViewModel _vaccineListObject = new VaccineListViewModel();
          _vaccineListObject.listenToVaccinesRealTime();
        }
      } else {
        print("Are you sure there's an active child?");
      }
    }
  }

  Future updateDoseInfo(Dose dose, String uid, String selectedChild) async {
    print("In firestore_service.dart >> updateDoseInfo");
    try {
      print("firestore_service.dart >> updateDoseInfo || " + dose.toJson().toString());
      await _usersCollectionReference.doc(uid)
          .collection("children")
          .doc(selectedChild)
          .collection("vaccines")
          .doc(dose.vaccineID)
          .collection("doses")
          .doc(dose.doseID)
          .update(dose.toJson());
    } catch (e) {
      return e.message;
    }
  }

  Future createUser(Parent user) async {
    try {
      await _usersCollectionReference.doc(user.uid).set(user.toMap());
    } catch (e) {
      return e.message;
    }
  }

  Future getUser(String uid) async {
    try {
      var userData = await _usersCollectionReference.doc(uid).get();
      return Parent.fromData(userData.data());
    } catch (e) {
      return e.message;
    }
  }

  Future getActiveChild(String uid) async {
    String activeChildID;
    try {
      var userData = await _usersCollectionReference.doc(uid)
          .get().then((parentData) => activeChildID = parentData.data()["selectedChild"]);
      var childData = await _usersCollectionReference.doc(uid)
          .collection("children").doc(activeChildID).get();
      return Child.fromMap(childData.data(), childData.id);
    } catch (e) {
      return e.message;
    }
  }

  Future<QuerySnapshot> getVaccines() async {
    return await _vaccinesCollectionReference.get();
  }

  String getDoseDate(int startDate, String dob) {
    DateTime dobOfChild = DateFormat('dd-MM-yyyy').parse(dob);
    DateTime doseDate = new DateTime(dobOfChild.year, dobOfChild.month, dobOfChild.day + startDate);
    return DateFormat('dd-MM-yyyy').format(doseDate);
  }
}


//     _vaccinesCollectionReference.get().then((snapshot) {
//         for (var vaccine in snapshot.docs) {
//           FirebaseFirestore.instance
//               .collection("users")
//               .doc(_authenticationService.currentUser.uid)
//               .collection("children")
//               .doc(newChild.id)
//               .collection("vaccines")
//               .doc(vaccine.id)
//               .set({
//             "description": vaccine.data()["description"],
//             "name": vaccine.data()["name"],
//             "methodOfInjection": vaccine.data()["methodOfInjection"],
//             "protectsAgainst": vaccine.data()["protectsAgainst"],
//             "recommendedByCDC": vaccine.data()["recommendedByCDC"],
//             "recommendedByIndiaGov": vaccine.data()["recommendedByIndiaGov"],
//             "siteOfInjection": vaccine.data()["siteOfInjection"],
//             "userSelected": vaccine.data()["recommendedByIndiaGov"] ? true : vaccine.data()["recommendedByCDC"],
//             });
//           vaccine.reference.collection("doses").get().then((doses) async{
//             for(var dose in doses.docs) {
//               FirebaseFirestore.instance
//                   .collection("users")
//                   .doc(_authenticationService.currentUser.uid)
//                   .collection("children")
//                   .doc(newChild.id)
//                   .collection("vaccines")
//                   .doc(vaccine.id)
//                   .collection("doses")
//                   .doc(dose.id)
//                   .set({
//                 "startDate": dose.data()["startDate"],
//                 "endDate": dose.data()["endDate"],
//                 "label": dose.data()["label"],
//                 "doseID": dose.id,
//                 "vaccineID": vaccine.id,
//                 "reminderDate": getDoseDate(dose.data()["startDate"], dob),
//                 "givenDate": "",
//                 "doctorName": "",
//                 "notes": "",
//               });
//
//               var parsedDate = DateFormat('dd-MM-yyyy').parse(dob);
//               var reminderDate = new DateTime(parsedDate.year, parsedDate.month, parsedDate.day + dose.data()["startDate"]);
//               var preReminderDate = new DateTime(parsedDate.year, parsedDate.month, (parsedDate.day + dose.data()["startDate"]) - 1);
//               String dueDate = "${reminderDate.day.toString().padLeft(2,'0')}-${reminderDate.month.toString().padLeft(2,'0')}-${reminderDate.year.toString()}";
//               print("Adding Scheduled Dose for: "+dueDate);
//               final scheduleDose = Schedule(dob, vaccine.id, dose.id, dose.data()["label"], reminderDate, false, vaccine.data()["recommendedByIndiaGov"] ? true : vaccine.data()["recommendedByCDC"]);
//
//               // Add Schedule
//               await _localDbService.addSchedule(scheduleDose, newChild.id);
//
//               //Add Notifications
//               int _preNotificationID = _localDbService.getNotificationID("pre", _localDbService.getScheduleKey(scheduleDose));
//               String _preNotificationTitle = "Vaccination Pre-Reminder!";
//               String _preNotificationBody = scheduleDose.vaccineID+" dose: "+scheduleDose.doseID+" is due tomorrow for vaccination.";
//
//               int _mainNotificationID = _localDbService.getNotificationID("main", _localDbService.getScheduleKey(scheduleDose));
//               String _mainNotificationTitle = "Vaccination Reminder!";
//               String _mainNotificationBody = scheduleDose.vaccineID+" dose: "+scheduleDose.doseID+" is due today for vaccination.";
//
//               if(preReminderDate.isAfter(new DateTime.now())){
//                 await _notifications.scheduleNotification(_preNotificationID, preReminderDate, _preNotificationTitle, _preNotificationBody, preReminderDate.toIso8601String()).whenComplete(() => print("Pre-Reminder Date Notify for:"+_localDbService.getScheduleKey(scheduleDose)+" on "+preReminderDate.toIso8601String()));
//               }
//               if(reminderDate.isAtSameMomentAs(new DateTime.now()) || reminderDate.isAfter(new DateTime.now())) {
//                 await _notifications.scheduleNotification(_mainNotificationID, reminderDate, _mainNotificationTitle, _mainNotificationBody, reminderDate.toIso8601String()).whenComplete(() => print("Reminder Date Notify for:"+_localDbService.getScheduleKey(scheduleDose)+" on "+reminderDate.toIso8601String()));
//               }
//             }
//           });
//         }
//       });
//       return newChild.id;
//     });
//   } catch (e) {
//     return e.message;
//   }
// } else {
//   // CDC not selected
//   try {
//     await _usersCollectionReference.doc(_authenticationService.currentUser.uid).collection("children").add({
//       'firstName': firstName,
//       'lastName': lastName,
//       'dob': dob,
//       'gender': gender,
//     }).then((newChild) {
//       _vaccinesCollectionReference.get().then((snapshot) {
//         for (var vaccine in snapshot.docs) {
//           FirebaseFirestore.instance
//               .collection("users")
//               .doc(_authenticationService.currentUser.uid)
//               .collection("children")
//               .doc(newChild.id)
//               .collection("vaccines")
//               .doc(vaccine.id)
//               .set({
//             "description": vaccine.data()["description"],
//             "name": vaccine.data()["name"],
//             "methodOfInjection": vaccine.data()["methodOfInjection"],
//             "protectsAgainst": vaccine.data()["protectsAgainst"],
//             "recommendedByCDC": vaccine.data()["recommendedByCDC"],
//             "recommendedByIndiaGov": vaccine.data()["recommendedByIndiaGov"],
//             "siteOfInjection": vaccine.data()["siteOfInjection"],
//             "userSelected": vaccine.data()["recommendedByIndiaGov"],
//           });
//           vaccine.reference.collection("doses").get().then((doses) {
//             for(var dose in doses.docs) {
//               FirebaseFirestore.instance
//                   .collection("users")
//                   .doc(_authenticationService.currentUser.uid)
//                   .collection("children")
//                   .doc(newChild.id)
//                   .collection("vaccines")
//                   .doc(vaccine.id)
//                   .collection("doses")
//                   .doc(dose.id)
//                   .set({
//                 "startDate": dose.data()["startDate"],
//                 "endDate": dose.data()["endDate"],
//                 "label": dose.data()["label"],
//                 "doseID": dose.id,
//                 "vaccineID": vaccine.id,
//                 "givenDate": "",
//                 "doctorName": "",
//                 "notes": "",
//               });
//               var parsedDate = DateFormat('dd-MM-yyyy').parse(dob);
//               var reminderDate = new DateTime(parsedDate.year, parsedDate.month, parsedDate.day + dose.data()["startDate"]);
//               String dueDate = "${reminderDate.day.toString().padLeft(2,'0')}-${reminderDate.month.toString().padLeft(2,'0')}-${reminderDate.year.toString()}";
//               print("Adding Scheduled Dose for: "+dueDate);
//               final scheduleDose = Schedule(dob, vaccine.id, dose.id, dose.data()["label"], reminderDate, false, vaccine.data()["recommendedByIndiaGov"]);
//               _localDbService.addSchedule(scheduleDose, newChild.id);
//             }
//           });
//         }
//       });
//       return newChild.id;
//     });
//   } catch (e) {
//     return e.message;
//   }