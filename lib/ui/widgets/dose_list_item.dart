import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        ListTile(
                            leading: isSchedule ? (schedule.isDoseGiven ? Icon(Icons.label, color: Colors.green) : Icon(Icons.label, color: Colors.red)) : (dose.givenDate == "" ? Icon(Icons.label, color: Colors.red) : Icon(Icons.label, color: Colors.green)),
                            title: Text((isSchedule ? schedule.vaccineID : dose.vaccineID)+" ("+ (isSchedule ? schedule.doseLabel : dose.label)+")"),
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