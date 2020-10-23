import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:vaccineApp/main.dart';
import 'package:vaccineApp/ui/shared/ui_helpers.dart';
import 'package:vaccineApp/ui/widgets/busy_button.dart';
import 'package:vaccineApp/ui/widgets/busy_overlay.dart';
import 'package:vaccineApp/ui/widgets/checkbox_widget.dart';
import 'package:vaccineApp/ui/widgets/expansion_list.dart';
import 'package:vaccineApp/ui/widgets/input_field.dart';
import 'package:vaccineApp/ui/widgets/text_link.dart';
import 'package:vaccineApp/view_models/addChild_view_model.dart';

class AddChild extends StatelessWidget {
    final firstNameInputController = TextEditingController();
    final lastNameInputController = TextEditingController();
    final dobController = TextEditingController();

    bool recommendedByCDC = false;

    @override
    Widget build(BuildContext context) {
        return ViewModelBuilder<AddChildViewModel>.reactive(
            viewModelBuilder: () => AddChildViewModel(),
            builder: (context, model, child) => Scaffold(
                backgroundColor: Color.fromARGB(255, 9, 202, 172),//Colors.white,
                appBar: AppBar(
                    title: const Text('Add Child Profile'),
                ),
                body: BusyOverlay(
                    show: model.busy,
                    // TODO: come up with a suitable title
                    title: "Please wait, as this may take a minute!\nDo not navigate out of this page",
                    child: SingleChildScrollView(
                        child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                                verticalSpaceLarge,
                                InputField(
                                    placeholder: 'First Name',
                                    controller: firstNameInputController,
                                ),
                                verticalSpaceSmall,
                                InputField(
                                    placeholder: 'Surname',
                                    controller: lastNameInputController,
                                ),
                                verticalSpaceSmall,
                                InputField(
                                    placeholder: 'Date of Birth',
                                    controller: dobController,
                                    textInputAction: TextInputAction.done,
                                    onTap: () async {
                                        DateTime date = DateTime.now();
                                        DateTime now = DateTime.now();
                                        FocusScope.of(context).requestFocus(new FocusNode());
                                        date = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime(date.year, date.month, date.day - 1),
                                            firstDate: DateTime(1900, 1, 1),
                                            lastDate: DateTime(now.year, now.month, now.day)
                                        );
                                        dobController.text = "${date.day.toString().padLeft(2,'0')}-${date.month.toString().padLeft(2,'0')}-${date.year.toString()}";
                                    }
                                ),
                                verticalSpaceSmall,
                                ExpansionList<String>(
                                    items: model.genderItems,
                                    title: model.selectedGender,
                                    onItemSelected: model.setSelectedGender
                                ),
                                verticalSpaceSmall,
                                CheckBoxField(
                                    title: "Add CDC Vaccines",
                                    value: false,
                                    controlAffinity: true,
                                    isChecked: (value) {
                                        recommendedByCDC = value;
                                    },
                                ),
                                verticalSpaceMedium,
                                Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                        BusyButton(
                                            title: 'Save Profile',
                                            busy: model.busy,
                                            onPressed: () {
                                                model.addChild( //TODO: add the missing fields here
                                                    firstName: firstNameInputController.text,
                                                    lastName: lastNameInputController.text,
                                                    dob: dobController.text,
                                                    isCDC: recommendedByCDC
                                                );
                                            },
                                        )
                                    ],
                                ),
                            ],
                        ),
                    ),
                  ),
                )
            ),
        );
    }
}
