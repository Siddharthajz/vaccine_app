import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:vaccineApp/ui/widgets/busy_overlay.dart';
import 'package:vaccineApp/ui/widgets/child_list_item.dart';
import 'package:vaccineApp/view_models/childrenList_view_model.dart';

class ChildrenList extends StatelessWidget {
    final String uid;
    ChildrenList({Key key, this.uid}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return ViewModelBuilder<ChildrenListViewModel>.reactive(
            onModelReady: (model) => model.listenToChildren(),
            disposeViewModel: false,
            viewModelBuilder: () => ChildrenListViewModel(),
            builder: (context, model, child) => Scaffold(
                appBar: AppBar(
                    title: const Text('Child List'),
                ),
                body: BusyOverlay(
                    show: model.busy,
                    title: "Please wait...",
                    child: (model.children.length > 0) ? ListView.builder(
                      itemCount: model.children.length,
                      itemBuilder: (context, index) => ChildListItem(
                          leadingWidget: model.isActiveChild(index) ? Icon(Icons.check_box, color: Colors.lightBlue) : Icon(Icons.check_box_outline_blank),
                          child: model.children[index],
                          onTapChild: () => model.setActiveChild(index),
                      ),
                    ) : Center(child: Text("No children profiles, add one?")),
                ),
                floatingActionButton: FloatingActionButton(
                    onPressed: () => model.goToAddChild(),
                    child: Icon(Icons.add),
                    backgroundColor: Colors.lightBlueAccent,
                ),
            ),
        );
    }
}