import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:stacked/stacked.dart';
import 'package:vaccineApp/ui/shared/shared_styles.dart';
import 'package:vaccineApp/ui/shared/sticky_header_tool.dart';
import 'package:vaccineApp/ui/shared/ui_helpers.dart';
import 'package:vaccineApp/ui/widgets/dose_list_item.dart';
import 'package:vaccineApp/ui/widgets/text_link.dart';
import 'package:vaccineApp/view_models/schedule_view_model.dart';

class ScheduleView extends StatefulWidget{

  @override
  _ScheduleViewState createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  int selectedIndex = 9999;
  String filterName = "";
  ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
      _scrollController = ScrollController();
      bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
      return ViewModelBuilder<ScheduleViewModel>.reactive(
            disposeViewModel: false,
            initialiseSpecialViewModelsOnce: true,
            viewModelBuilder: () => ScheduleViewModel(),
            onModelReady: (model) => model.getAllDueDoses(),
            builder: (context, model, child) => Scaffold(
                appBar: AppBar(
                  title: Text('Schedule'),
                  actions: [
                    GestureDetector(
                      onTap: () {
                        model.viewManageChildren(model.isActiveChild());
                        setState(() {
                          selectedIndex = 9999;
                          filterName = "";
                          model.getFilteredDoses(9999, 9999);
                        });
                      },
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
                body: model.isActiveChild() ? CustomScrollView(
                    controller: _scrollController,
                    slivers: <Widget>[
                        model.dueDoses.isNotEmpty ? StickyHeader(headerText: "Vaccine Due: "+model.dueDoses.length.toString()) : SliverToBoxAdapter(child: Container()),
                        model.isLoadingDbProcess ? SliverToBoxAdapter(
                            child: Column(
                              children: <Widget>[
                                verticalSpaceMedium,
                                CupertinoActivityIndicator(),
                                verticalSpaceMedium
                              ]
                            )
                        ) : SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) => model.dueDoses.length > 0 ? DoseListItem(
                                isSchedule: true,
                                schedule: model.dueDoses[index],
                                onTapDose: () {
                                  filterName = "";
                                  selectedIndex = 9999;
                                  model.viewDose(index, 'c');
                                }
  //                  ) : Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation(Theme.of(context).primaryColor)),),
                            ) : Center(child: CupertinoActivityIndicator(),),
                            childCount: model.dueDoses.length,
                          ),
                        ),
                        StickyHeader(headerText: "Filter Vaccines by: "+filterName),
                        SliverToBoxAdapter(
                            child: Container(
                                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                                height: 100.0,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: model.doseFilter.length,
                                    itemBuilder: (context, index) {
                                        return GestureDetector(
                                            onTap: () {
                                                setState(() {
                                                    selectedIndex = index;
                                                    filterName = model.doseFilter[index];
                                                });
                                                model.filterDoseBy(index);
                                                model.scrollDown(_scrollController, 50, 500);
                                            },
                                            child: Container(
                                                width: 80.0,
                                                margin: EdgeInsets.symmetric(horizontal: 5),
                                                child: CircleAvatar(
                                                    radius: 40,
                                                    backgroundColor: isDark ? Colors.black : Colors.white,
                                                    child: CircleAvatar(
                                                        radius: 30,
                                                        backgroundColor: index == selectedIndex ? Theme.of(context).accentColor : Theme.of(context).primaryColor,
                                                        child: Text(model.doseFilter[index], style: TextStyle(color: isDark ? Colors.black : Colors.white),),
                                                    ),
                                                ),
                                            ),
                                        );
                                    },
                                ),
                            ),
                        ),
                        !model.isBusy ? SliverList(
                            delegate: SliverChildBuilderDelegate(
                                    (context, index) => model.filteredDoses.length > 0 ? DoseListItem(
                                      isSchedule: true,
                                      schedule: model.filteredDoses[index],
                                      onTapDose: () {
                                        filterName = "";
                                        selectedIndex = 9999;
                                        model.viewDose(index, 'a');
                                      },
                                    ): Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),),),
                                childCount: model.filteredDoses.length,
                            ),
                        ) : SliverToBoxAdapter(child: Container(height: 100, child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor))),)),
                    ]
                ) : Center(
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
            )
        );
    }
}