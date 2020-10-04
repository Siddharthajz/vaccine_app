import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vaccineApp/models/Vaccine.dart';

class VaccineListItem extends StatelessWidget {
    final Vaccine vaccine;
    final Function onTapVaccine;
    final Widget leadingWidget;

    const VaccineListItem({Key key, this.vaccine, this.onTapVaccine, this.leadingWidget}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return ListTile(
            title: Card(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        ListTile(
                            leading: leadingWidget,//Icon(Icons.album, color: Colors.green),
                            title: Text(vaccine.name),
                            // TODO: look up "conditional branching of if statement"
                            subtitle: vaccine.recommendedByIndiaGov ? (Text("Govt. of India")) : ( vaccine.recommendedByCDC ? (Text("CDC")) : (Text("Optional"))),
                            trailing: Icon(Icons.arrow_forward),
                            onTap: () {
                                if (onTapVaccine != null) {
                                    onTapVaccine();
                                }
                            }
                        )
                    ]
                )
            ),
        );
    }
}