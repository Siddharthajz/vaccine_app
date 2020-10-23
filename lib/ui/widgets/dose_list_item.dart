import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vaccineApp/models/Dose.dart';
import 'package:vaccineApp/models/schedule.dart';

class DoseListItem extends StatelessWidget {
  final Schedule schedule;
  final Dose dose;
  final Function onTapDose;
  final bool isSchedule;

    const DoseListItem({Key key, this.dose, this.onTapDose, this.schedule, this.isSchedule}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return ListTile(
            title: Card(
                color: Color.fromRGBO(255, 255, 255, 1),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        isSchedule ? ListTile(
                            // Is in Schedule page
                            leading: isSchedule ? (schedule.isDoseGiven ? Icon(Icons.label, color: Colors.green) : Icon(Icons.label, color: Colors.red)) : (dose.givenDate == "" ? Icon(Icons.label, color: Colors.red) : Icon(Icons.label, color: Colors.green)),
                            title: Text((isSchedule ? schedule.vaccineID : dose.vaccineID)+" ("+ (isSchedule ? finalLabel(schedule.doseLabel) : finalLabel(dose.label))+")"),
                            subtitle: Text("Reminder on: " + DateFormat("dd-MM-yyyy").format(schedule.dueDate).toString()),
                            trailing: Icon(Icons.arrow_forward),
                            onTap: () {
                                if (onTapDose != null) {
                                    onTapDose();
                                }
                            }
                        )
                            :
                        ListTile(
                            // Is not in Schedule page
                            leading: isSchedule ? (schedule.isDoseGiven ? Icon(Icons.label, color: Colors.green) : Icon(Icons.label, color: Colors.red)) : (dose.givenDate == "" ? Icon(Icons.label, color: Colors.red) : Icon(Icons.label, color: Colors.green)),
                            title: Text((isSchedule ? schedule.vaccineID : dose.vaccineID)+" ("+ (isSchedule ? finalLabel(schedule.doseLabel) : finalLabel(dose.label))+")"),
                            trailing: Icon(Icons.arrow_forward),
                            onTap: () {
                                if (onTapDose != null) {
                                    onTapDose();
                                }
                            }
                        )
                    ]
                )
            ),
        );
    }
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