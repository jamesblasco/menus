//@dart=2.12
import 'package:flutter/material.dart';

const double _kMenuScreenPadding = 8.0;

class ContextMenuLayout extends StatelessWidget {
  final Widget child;
  final Rect globalRegion;
  final Rect targetRegion;
  final Offset targetOffset;
  final EdgeInsets padding;
  final AlignmentGeometry aligment;
  final AlignmentGeometry originAligment;

  const ContextMenuLayout({
    Key? key,
    required this.child,
    required this.globalRegion,
    required this.targetRegion,
    required this.targetOffset,
    this.padding = const EdgeInsets.all(12),
    this.aligment = AlignmentDirectional.topEnd,
    this.originAligment = AlignmentDirectional.topStart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomSingleChildLayout(
      delegate: _ContextMenuLayoutDelegate(
        aligment: aligment,
        originAligment: originAligment,
        position: padding.inflateRect(targetRegion),
        textDirection: Directionality.of(context),
      ),
      child: child,
    );
  }
}

class _ContextMenuLayoutDelegate extends SingleChildLayoutDelegate {
  _ContextMenuLayoutDelegate({
   required this.originAligment,
   required this.aligment,
   required this.position,
   required this.textDirection,
  });

  final AlignmentGeometry aligment;

  final AlignmentGeometry originAligment;

  // Rectangle of underlying button, relative to the overlay's dimensions.
  final Rect position;

  // Whether to prefer going to the left or to the right.
  final TextDirection textDirection;

  // We put the child wherever position specifies, so long as it will fit within
  // the specified parent size padded (inset) by 8. If necessary, we adjust the
  // child's position so that it fits.

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The menu can be at most the size of the overlay minus 8.0 pixels in each
    // direction.
    return BoxConstraints.loose(
      constraints.biggest -
          const Offset(
            _kMenuScreenPadding * 2.0,
            _kMenuScreenPadding * 2.0,
          ) as Size,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final targetAligment = this.aligment.resolve(textDirection);
    final menuAligment = this.originAligment.resolve(textDirection);
    // size: The size of the overlay.
    // childSize: The size of the menu, when fully open, as determined by
    // getConstraintsForChild.

    // Find the ideal vertical position.
    double y = position.center.dy + targetAligment.y * position.height / 2;

    // Find the ideal horizontal position.
    double x = position.center.dx + targetAligment.x * position.width / 2;

    // Align menu in that position
    y = y - childSize.height / 2 - menuAligment.y * childSize.height / 2;
    x = x - childSize.width / 2 - menuAligment.x * childSize.width / 2;

    // Avoid going outside an area defined as the rectangle 8.0 pixels from the
    // edge of the screen in every direction.
    if (x < _kMenuScreenPadding)
      x = _kMenuScreenPadding;
    else if (x + childSize.width > size.width - _kMenuScreenPadding)
      x = size.width - childSize.width - _kMenuScreenPadding;
    if (y < _kMenuScreenPadding)
      y = _kMenuScreenPadding;
    else if (y + childSize.height > size.height - _kMenuScreenPadding)
      y = size.height - childSize.height - _kMenuScreenPadding;
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_ContextMenuLayoutDelegate oldDelegate) {
    // If called when the old and new itemSizes have been initialized then
    // we expect them to have the same length because there's no practical
    // way to change length of the items list once the menu has been shown.

    return position != oldDelegate.position ||
        textDirection != oldDelegate.textDirection;
  }
}
