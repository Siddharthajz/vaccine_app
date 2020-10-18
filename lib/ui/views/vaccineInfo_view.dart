//import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked/stacked.dart';
import 'package:vaccineApp/models/Vaccine.dart';
import 'package:vaccineApp/ui/shared/ui_helpers.dart';
import 'package:vaccineApp/ui/widgets/busy_button.dart';
import 'package:vaccineApp/ui/widgets/busy_overlay.dart';
import 'package:vaccineApp/ui/widgets/dose_list_item.dart';
import 'package:vaccineApp/view_models/vaccineInfo_view_model.dart';
import 'package:vaccineApp/view_models/vaccineList_view_model.dart';
import 'package:vaccineApp/ui/shared/shared_styles.dart';

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
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                    title: Text(vaccine.name),
                    // actions: <Widget>[
                    //     IconButton(
                    //         icon: vaccine.userSelected ? Icon(Icons.check_box) : Icon(Icons.check_box_outline_blank),
                    //         onPressed: () => model.setVaccine(vaccine.vaccineID, vaccine.userSelected),
                    //     ),
                    // ],
                ),
                body: CustomScrollView(
                    slivers: <Widget>[
                        SliverToBoxAdapter(
                            child: Column(
                                children: [
                                    verticalSpaceSmall,
                                    Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                            BusyButton(
                                                title: vaccine.userSelected ? "Unselect Vaccine" : "Select Vaccine",
                                                onPressed: () => model.setVaccine(vaccine.vaccineID, vaccine.userSelected),
                                            ),
                                        ]
                                    ),
                                ],
                            ),
                        ),
                        SliverList(
                            delegate: SliverChildBuilderDelegate(
                                (context, index) => DoseListItem(
                                    isSchedule: false,
                                    dose: model.doses[index],
                                    onTapDose: () => model.viewDose(index),
                                ),
                                childCount: model.doses.length,
                            ),
                        ),
                        SliverToBoxAdapter(
                            child: Column (
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                    verticalSpaceSmall,
                                    Container(
                                        padding: EdgeInsets.only(left: 20, right: 20),
                                        child: RichText(
                                            text: TextSpan(
                                                children: <TextSpan>[
                                                    TextSpan(text: "Protects Against: ", style: vaccineTopicTextStyle),
                                                    TextSpan(text: vaccine.protectsAgainst, style: vaccineDescTextStyle),
                                                ]
                                            )
                                        )
                                    ),
                                    verticalSpaceSmall,
                                    Container(
                                        padding: EdgeInsets.only(left: 20, right: 20),
                                        child: RichText(
                                            text: TextSpan(
                                                children: <TextSpan>[
                                                    TextSpan(text: "Description: \n", style: vaccineTopicTextStyle),
                                                    TextSpan(text: vaccine.description.replaceAll("\\n", "\n\n"), style: vaccineDescTextStyle),
                                                ]
                                            )
                                        )
                                    ),
                                    verticalSpaceSmall,
                                    Container(
                                        padding: EdgeInsets.only(left: 20, right: 20),
                                        child: RichText(
                                            text: TextSpan(
                                                children: <TextSpan>[
                                                    TextSpan(text: "Site of Administration: ", style: vaccineTopicTextStyle),
                                                    TextSpan(text: vaccine.siteOfInjection, style: vaccineDescTextStyle),
                                                ]
                                            )
                                        )
                                    ),
                                    verticalSpaceSmall,
                                    Container(
                                        padding: EdgeInsets.only(left: 20, right: 20),
                                        child: RichText(
                                            text: TextSpan(
                                                children: <TextSpan>[
                                                    TextSpan(text: "Method of Administration: ", style: vaccineTopicTextStyle),
                                                    TextSpan(text: vaccine.methodOfInjection, style: vaccineDescTextStyle),
                                                ]
                                            )
                                        )
                                    ),
                                    verticalSpaceSmall,
                                    Container(
                                        padding: EdgeInsets.only(left: 20, right: 20),
                                        child: RichText(
                                            text: TextSpan(
                                                children: <TextSpan>[
                                                    TextSpan(text: "Recommended by Govt. of India: ", style: vaccineTopicTextStyle),
                                                    TextSpan(text: vaccine.recommendedByIndiaGov ? "Yes" : "No", style: vaccineDescTextStyle),
                                                ]
                                            )
                                        )
                                    ),
                                    verticalSpaceSmall,
                                    Container(
                                        padding: EdgeInsets.only(left: 20, right: 20),
                                        child: RichText(
                                            text: TextSpan(
                                                children: <TextSpan>[
                                                    TextSpan(text: "Recommended by the CDC: ", style: vaccineTopicTextStyle),
                                                    TextSpan(text: vaccine.recommendedByCDC ? "Yes" : "No", style: vaccineDescTextStyle),
                                                ]
                                            )
                                        )
                                    ),
                                    verticalSpaceLarge,
                                ],
                            )
                        ),
                    ],
                )
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