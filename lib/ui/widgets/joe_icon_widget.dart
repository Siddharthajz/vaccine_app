import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class JoeIcon extends StatelessWidget {
    final IconData iconData;
    final String text;
    final VoidCallback onTap;
    final int notificationCount;

    const JoeIcon({
        Key key,
        this.onTap,
        @required this.text,
        @required this.iconData,
        this.notificationCount,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return InkWell(
            onTap: onTap,
            child: Container(
                width: 72,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Stack(
                    alignment: Alignment.center,
                    children: [
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                                Icon(iconData)
                            ],
                        ),
                        (notificationCount > 0) ? Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                                alignment: Alignment.center,
                                child: Text('$notificationCount', style: TextStyle(color: Colors.white),),
                            ),
                        ) : Container(),
                    ],
                ),
            ),
        );
    }
}