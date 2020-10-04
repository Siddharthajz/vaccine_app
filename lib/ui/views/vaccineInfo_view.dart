//import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked/stacked.dart';
import 'package:vaccineApp/models/Vaccine.dart';
import 'package:vaccineApp/ui/widgets/busy_overlay.dart';
import 'package:vaccineApp/ui/widgets/dose_list_item.dart';
import 'package:vaccineApp/view_models/vaccineInfo_view_model.dart';
import 'package:vaccineApp/view_models/vaccineList_view_model.dart';

// TODO: UI
class VaccineInfo extends StatelessWidget {
    final Vaccine vaccine;
    VaccineInfo({Key key, this.vaccine}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return ViewModelBuilder<VaccineInfoViewModel>.reactive(
            onModelReady: (model) => model.listenToDoses(vaccine.vaccineID),
            disposeViewModel: false,
            viewModelBuilder: () => VaccineInfoViewModel(),
            builder: (context, model, child) => Scaffold(
                appBar: AppBar(
                    title: Text(vaccine.name),
                    actions: <Widget>[
                        IconButton(
                            icon: vaccine.userSelected ? Icon(Icons.check_box) : Icon(Icons.check_box_outline_blank),
                            onPressed: () => model.setVaccine(vaccine.vaccineID, vaccine.userSelected),
                        ),
                    ],
                ),
                body: BusyOverlay(
                    show: model.busy,
                  child: ListView.builder(
                      itemCount: model.doses.length,
                      itemBuilder: (context, index) => DoseListItem(
                          isSchedule: false,
                          dose: model.doses[index],
                          onTapDose: () => model.viewDose(index),
                      ),
                  ),
                ),
            ),
        );
    }
}

//Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
//    return ListTile(
//        title: Card(
//            child: Column(
//                mainAxisSize: MainAxisSize.min,
//                children: <Widget>[
//                    ListTile(
//                        leading: Icon(Icons.insert_emoticon),
//                        title: Text(document['label']),
//                        // subtitle: Text(document.documentID),
//                        trailing: Icon(Icons.arrow_forward),
//                        onTap: () => print("go to screen with info about the dose")
//                    )
//                ]
//            )
//        ),
//    );
//}