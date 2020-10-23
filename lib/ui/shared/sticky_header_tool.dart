import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vaccineApp/ui/shared/silver_appbar_delegate_tool.dart';

class StickyHeader extends StatelessWidget{
    final String headerText;

    const StickyHeader({Key key, this.headerText}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return SliverPersistentHeader(
            pinned: true,
            delegate: SliverAppBarDelegate(
                minHeight: 60.0,
                maxHeight: 60.0,
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white
                    ),
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    child: Text(
                        headerText,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                        ),
                    ),
                ),
            ),
        );
    }
}