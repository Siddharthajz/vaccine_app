import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vaccineApp/models/Child.dart';
import 'package:vaccineApp/models/Vaccine.dart';

class ChildListItem extends StatelessWidget {
    final Child child;
    final Function onTapChild;
    final Widget leadingWidget;

    const ChildListItem({Key key, this.child, this.onTapChild, this.leadingWidget}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return ListTile(
            title: Card(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        ListTile(
                            leading: leadingWidget,
                            title: Text(child.fname + " " + child.surname),
                            subtitle: Text("Date of birth: " + child.dob),
                            onTap: () {
                                if (onTapChild != null) {
                                    onTapChild();
                                }
                            }
                        )
                    ]
                )
            ),
        );
    }
}