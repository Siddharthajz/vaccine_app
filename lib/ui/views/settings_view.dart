import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:vaccineApp/ui/shared/ui_helpers.dart';
import 'package:vaccineApp/ui/widgets/busy_overlay.dart';
import 'package:vaccineApp/view_models/settings_view_model.dart';
import 'package:settings_ui/settings_ui.dart';

class Settings extends StatefulWidget {
    @override
    _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
    @override
    Widget build(BuildContext context) {
        return ViewModelBuilder<SettingsViewModel>.reactive(
            viewModelBuilder: () => SettingsViewModel(),
            builder: (context, model, child) =>
                Scaffold(
                    appBar: AppBar(
                        title: const Text('Settings'),
                    ),
                    body: BusyOverlay(
                        title: "Please wait...",
                        show: model.busy,
                        child: SettingsList(
                          sections: [
                              SettingsSection(
                                  title: 'Profile',
                                  tiles: [
                                      SettingsTile(
                                          title: 'Child List',
                                          subtitle: (model.getActiveChild().isNotEmpty) ? "Active Child: " + model.getActiveChild() : "No Children",
                                          leading: Icon(Icons.child_care),
                                          onTap: () {
                                              model.goToChildrenList();
                                          },
                                      ),
                                      SettingsTile(
                                          title: 'Reset Schedule',
                                          subtitle: "Reset Vaccines schedule to default settings.",
                                          leading: Icon(Icons.refresh),
                                          onTap: () {
                                              model.resetSchedule();
                                          },
                                      ),
                                      SettingsTile(
                                          title: 'Sign Out',
                                          leading: Icon(Icons.exit_to_app),
                                          onTap: () {
                                              model.signOut();
                                          },
                                      ),
//                                    SettingsTile.switchTile(
//                                        title: 'Use fingerprint',
//                                        leading: Icon(Icons.fingerprint),
//                                        switchValue: value,
//                                        onToggle: (bool value) {},
//                                    ),
                                  ],
                              ),
                          ],
                      ),
                    )
//                    Padding(
//                        padding: const EdgeInsets.symmetric(horizontal: 10),
//                        child: Column(
//                            mainAxisSize: MainAxisSize.max,
//                            mainAxisAlignment: MainAxisAlignment.center,
//                            crossAxisAlignment: CrossAxisAlignment.center,
//                            children: <Widget>[
//                                Card(
//                                    child: ListTile(
//                                        leading: Icon(Icons.child_care),
//                                        title: Text("Child List"),
//                                        subtitle: Text("Active Child: " + model.getActiveChild()),
//                                        trailing: Icon(Icons.arrow_forward),
//                                        onTap: () {
//                                            model.goToChildrenList();
//                                        }
//                                    )
//                                ),
//                            ]
//                        )
//                    ),
                ),
        );
    }
}