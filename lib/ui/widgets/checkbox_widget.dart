import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CheckBoxField extends StatefulWidget {
    final String title;
    bool value;
    final bool controlAffinity;
    final Function(dynamic) isChecked;

    CheckBoxField({this.title, this.value, this.controlAffinity, this.isChecked});

    @override
    _CheckBoxFieldState createState() => _CheckBoxFieldState();
}

class _CheckBoxFieldState extends State<CheckBoxField> {
//  bool isValue;

    @override
    void initState() {
        super.initState();
//    isValue = widget.value;
    }

    @override
    Widget build(BuildContext context) {
        return CheckboxListTile(
            title: Text(widget.title),
            value: widget.value,
            onChanged: (value) {
                setState(() {
                    widget.value = value;
                    return widget.isChecked(value);
                });
            },
            controlAffinity: (widget.controlAffinity) ? ListTileControlAffinity.leading : ListTileControlAffinity.trailing,
        );
    }
}