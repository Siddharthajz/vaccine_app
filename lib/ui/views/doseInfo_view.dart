//import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked/stacked.dart';
import 'package:vaccineApp/models/Dose.dart';
import 'package:vaccineApp/models/Vaccine.dart';
import 'package:vaccineApp/models/schedule.dart';
import 'package:vaccineApp/ui/widgets/dose_list_item.dart';
import 'package:vaccineApp/view_models/doseInfo_view_model.dart';

import 'package:vaccineApp/ui/shared/ui_helpers.dart';
import 'package:vaccineApp/ui/widgets/busy_button.dart';
import 'package:vaccineApp/ui/widgets/checkbox_widget.dart';
import 'package:vaccineApp/ui/widgets/expansion_list.dart';
import 'package:vaccineApp/ui/widgets/input_field.dart';
import 'package:vaccineApp/ui/widgets/text_link.dart';
import 'package:vaccineApp/ui/shared/shared_styles.dart';

// TODO: UI
class DoseInfo extends StatelessWidget {
    final Dose dose;
    final Schedule schDose;

    DoseInfo({Key key, this.dose, this.schDose}) : super(key: key);

    final doctorNameController = TextEditingController();
    final reminderController = TextEditingController();
    final givenDateController = TextEditingController();
    final notesController = TextEditingController();

    bool isGiven = false;

    @override
    Widget build(BuildContext context) {
        // reminderController.text = "${schDose.dueDate.day.toString().padLeft(2,'0')}-${schDose.dueDate.month.toString().padLeft(2,'0')}-${schDose.dueDate.year.toString()}";
        // doctorNameController.text = dose.doctorName;
        // givenDateController.text = dose.givenDate;
        // notesController.text = dose.notes;

        return ViewModelBuilder<DoseInfoViewModel>.reactive(
            viewModelBuilder: () => DoseInfoViewModel(),
            disposeViewModel: false,
              builder: (context, model, child) => Scaffold(
                appBar: AppBar(
                    title: Row(
                        children: <Widget>[
                            Text(dose.vaccineID),
                            Text(" (" + model.finalLabel(dose.label) + ")", style: TextStyle(fontSize: 16))
                        ],
                    ),
                ),
                body: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                                verticalSpaceMedium,
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                        Text("Due on", style: labelTextSyle),
                                        Text(model.getDoseDate(dose.startDate), style: labelTextSyle),
                                    ],
                                ),
                                verticalSpaceMedium,
                                CheckBoxField(
                                    title: "Is dose given?",
                                    value: dose.givenDate == "" ? false : true,
                                    controlAffinity: false,
                                    isChecked: (value) {
                                        isGiven = value;
                                    },
                                ),
                                Text("Reminder:", style: labelTextSyle),
                                InputField(
                                    placeholder: (schDose.dueDate != null ? "${schDose.dueDate.day.toString().padLeft(2,'0')}-${schDose.dueDate.month.toString().padLeft(2,'0')}-${schDose.dueDate.year.toString()}" : "Set Date"),
                                    controller: reminderController,
                                    textInputAction: TextInputAction.done,
                                    onTap: () async {
                                        DateTime reminderDate = schDose.dueDate;
                                        DateTime doseDate = model.stringToDate(model.getDoseDate(dose.startDate));
                                        FocusScope.of(context).requestFocus(new FocusNode());
                                        reminderDate = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime(reminderDate.year, reminderDate.month, reminderDate.day),
                                            firstDate: DateTime(doseDate.year, doseDate.month, doseDate.day),
                                            lastDate: DateTime(doseDate.year + 100, doseDate.month, doseDate.day)
                                        );
                                        reminderController.text = "${reminderDate.day.toString().padLeft(2,'0')}-${reminderDate.month.toString().padLeft(2,'0')}-${reminderDate.year.toString()}";
                                    }
                                ),
                                verticalSpaceMedium,
                                Text("Date given:", style: labelTextSyle),
                                InputField(
                                    placeholder: dose.givenDate,
                                    controller: givenDateController,
                                    textInputAction: TextInputAction.done,
                                    onTap: () async {
                                        // DateTime dob = model.stringToDate(model.getChildDOB());
                                        DateTime date = DateTime.now();
                                        DateTime doseDate = model.stringToDate(model.getDoseDate(dose.startDate));
                                        DateTime now = DateTime.now();
                                        FocusScope.of(context).requestFocus(new FocusNode());
                                        date = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime(now.year, now.month, now.day),
                                            firstDate: DateTime(doseDate.year, doseDate.month, doseDate.day),
                                            lastDate: DateTime(now.year, now.month, now.day)
                                        );
                                        givenDateController.text = "${date.day.toString().padLeft(2,'0')}-${date.month.toString().padLeft(2,'0')}-${date.year.toString()}";
                                    }
                                ),
                                verticalSpaceSmall,
                                Text("Doctor\'s Name:", style: labelTextSyle),
                                InputField(
                                    placeholder: dose.doctorName,
                                    controller: doctorNameController,
                                ),
                                verticalSpaceSmall,
                                Text("Notes:", style: labelTextSyle),
                                InputField(
                                    // fieldHeight: 150,
                                  placeholder: dose.notes,
                                  controller: notesController,
                                ),
                                verticalSpaceLarge,
                                Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                        BusyButton(
                                            title: 'SAVE',
                                            busy: model.busy,
                                            onPressed: () {
                                                model.enterData(
                                                    Dose(
                                                        label: dose.label,
                                                        doseID: dose.doseID,
                                                        startDate: dose.startDate,
                                                        endDate: dose.endDate,
                                                        vaccineID: dose.vaccineID,
                                                        givenDate: isGiven ? givenDateController.text : "",
                                                        doctorName: isGiven ? doctorNameController.text : "",
                                                        notes: isGiven ? notesController.text : "",
                                                    ),
                                                    Schedule(
                                                        schDose.childDOB,
                                                        schDose.vaccineID,
                                                        schDose.doseID,
                                                        schDose.doseLabel,
                                                        reminderController.text.isNotEmpty ? model.stringToDate(reminderController.text) : schDose.dueDate,
                                                        isGiven,
                                                        schDose.isUserSelected
                                                    )
                                                );
                                            },
                                        )
                                    ],
                                ),
                                verticalSpaceMedium,
                            ],
                        ),
                    )
                ),
            ),
        );
    }
}