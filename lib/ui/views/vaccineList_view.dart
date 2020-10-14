import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:vaccineApp/ui/shared/shared_styles.dart';
import 'package:vaccineApp/ui/shared/silver_appbar_delegate_tool.dart';
import 'package:vaccineApp/ui/shared/sticky_header_tool.dart';
import 'package:vaccineApp/ui/shared/ui_helpers.dart';
import 'dart:math' as math;

import 'package:vaccineApp/ui/widgets/vaccine_list_item.dart';
import 'package:vaccineApp/view_models/vaccineList_view_model.dart';
import 'package:vaccineApp/models/Vaccine.dart';

class VaccineList extends StatelessWidget {
    static List<Vaccine> allVaccines = new List<Vaccine>();
    final String uid;
    VaccineList({Key key, this.uid}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return ViewModelBuilder<VaccineListViewModel>.reactive(
            disposeViewModel: false,
            onModelReady: (model) => model.listenToVaccinesRealTime(),
            viewModelBuilder: () => VaccineListViewModel(),
            builder: (context, model, child) => Scaffold(
                appBar: AppBar(
                    title: const Text('Vaccine List'),
                    actions: [
                        GestureDetector(
                            onTap: () => model.viewManageChildren(model.isActiveChild()),
                            child: Container(
                                margin: const EdgeInsets.only(right: 15),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                        Icon(Icons.child_care),
                                        verticalSpaceTiny,
                                        Text(model.getActiveChildName(), style: TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis)
                                    ],
                                ),
                            ),
                        )
                    ],
                ),
                body:  (model.isActiveChild()) ? new CustomScrollView(
                    slivers: <Widget>[
                        model.userSelectedVaccines.isNotEmpty ? StickyHeader(headerText: "Vaccines") : SliverToBoxAdapter( child: Container() ),
                        SliverPadding(padding: const EdgeInsets.only(left: 0.0,right: 0.0,
                            top: 0,bottom: 0.0),
                            sliver: new SliverList(
                                delegate: SliverChildBuilderDelegate(
                                        (context, index) => model.userSelectedVaccines.isNotEmpty ? GestureDetector(
                                        onTap: () => model.viewVaccine(index, true),
                                        child: VaccineListItem(
                                            leadingWidget: Icon(Icons.check_circle, color: Colors.green),
                                            vaccine: model.userSelectedVaccines[index],
                                            onTapVaccine: () => model.viewVaccine(index, true),
//                            onDeleteItem: () => model.deletePost(index),
                                        ),
                                    ) : SliverToBoxAdapter( child: Container(
                                        child: Text("Nothing Found!"),
                                    ) ),
                                    childCount: model.userSelectedVaccines.length
                                )
                            ),
                        ),
                        model.vaccines.isNotEmpty ? StickyHeader(headerText: "Optional Vaccines") : SliverToBoxAdapter( child: Container() ),
                        SliverPadding(padding: const EdgeInsets.only(left: 0.0,right: 0.0,
                            top: 0,bottom: 0.0),
                            sliver: new SliverList(
                                delegate: SliverChildBuilderDelegate(
                                        (context, index) => GestureDetector(
                                        onTap: () => model.viewVaccine(index, false),
                                        child: VaccineListItem(
                                            leadingWidget: Icon(Icons.album, color: Colors.red),
                                            vaccine: model.vaccines[index],
                                            onTapVaccine: () => model.viewVaccine(index, false),
//                            onDeleteItem: () => model.deletePost(index),
                                        ),
                                    ),
                                    childCount: model.vaccines.length
                                )
                            ),
                        )
                    ],
                ): Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Icon(
                                Icons.child_care,
                                size: 120,
                            ),
                            verticalSpaceMedium,
                            Text("No Active Child Profile!", style: labelTextStyle),
                            verticalSpaceSmall,
                            RaisedButton(
                                child: Text("Add Child"),
                                onPressed: () => model.viewManageChildren(model.isActiveChild()),
                                color: Colors.black,
                                textColor: Colors.white,
                            ),
                        ],
                    ),
                )
            ),
        );
    }
}