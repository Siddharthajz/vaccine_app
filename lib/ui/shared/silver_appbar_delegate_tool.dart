import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
    SliverAppBarDelegate(
        {@required this.minHeight, @required this.maxHeight, @required this.child, @required this.paddingTop});

    final double minHeight;
    final double maxHeight;
    final Widget child;
    final double paddingTop;

    @override
    double get minExtent => minHeight;

    @override
    double get maxExtent => math.max(maxHeight, minHeight);

    @override
    Widget build(BuildContext context,
        double shrinkOffset,
        bool overlapsContent) {
        return new SizedBox.expand(child: child);
    }

    @override
    bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
        return maxHeight != oldDelegate.maxHeight ||
            minHeight != oldDelegate.minHeight || child != oldDelegate.child;
    }
}