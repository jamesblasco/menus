import 'package:menus/src/default_context_menu_layout.dart';
import 'package:menus/src/menu_context_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../context_menu.dart';

const double _kToolbarContentDistance = 8;
const double _kToolbarDefaultWidth = 140.0;

/// Manages a copy/paste text selection toolbar.
class _CascadeContextMenu extends StatefulWidget {
  const _CascadeContextMenu({
    Key? key,
    this.items = const [],
    this.backgroundColor,
    this.elevation,
    this.clipBehavior,
    this.shape,
    this.theme,
    this.width = _kToolbarDefaultWidth,
    required this.controller,
  })   : assert(width != null),
        super(key: key);

  final List<Widget> items;

  // When true, the toolbar fits above its anchor and will be positioned there.

  final double? width;

  final ContextMenuController controller;

  final Color? backgroundColor;
  final double? elevation;

  final Clip? clipBehavior;
  final ShapeBorder? shape;
  final ThemeData? theme;

  @override
  _CascadeContextMenuState createState() => _CascadeContextMenuState();
}

class CascadeTextSelectionToolbarItemBuilder extends ContextMenuItemThemeData {
  @override
  Widget buildItem(BuildContext context, ContextMenuItem item) {
    return ButtonTheme.fromButtonThemeData(
      data: ButtonTheme.of(context).copyWith(
          height: kMinInteractiveDimension,
          minWidth: kMinInteractiveDimension,
          padding: EdgeInsets.symmetric(horizontal: 20)),
      child: FlatButton(
          onPressed: item.onPressed != null
              ? () {
                  final controller = DefaultContextMenuController.of(context);

                  final shouldHide = item.onPressed();
                  if (shouldHide) controller.hide();
                }
              : null,
          padding: EdgeInsets.only(
            // These values were eyeballed to match the native text selection menu
            // on a Pixel 2 running Android 10.
            top: 9.5,
            bottom: 9.5,
            left: 20,
            right: 20,
          ),
          shape: Border.all(width: 0.0, color: Colors.transparent),
          child: item.title),
    );
  }
}

class _CascadeContextMenuState extends State<_CascadeContextMenu>
    with TickerProviderStateMixin {
  // Whether or not the overflow menu is open. When it is closed, the menu
  // items that don't overflow are shown. When it is open, only the overflowing
  // menu items are shown.
  bool _overflowOpen = false;

  // The key for _TextSelectionToolbarContainer.
  UniqueKey _containerKey = UniqueKey();

  // Close the menu and reset layout calculations, as in when the menu has
  // changed and saved values are no longer relevant. This should be called in
  // setState or another context where a rebuild is happening.
  void _reset() {
    // Change _TextSelectionToolbarContainer's key when the menu changes in
    // order to cause it to rebuild. This lets it recalculate its
    // saved width for the new set of children, and it prevents AnimatedSize
    // from animating the size change.
    _containerKey = UniqueKey();
    // If the menu items change, make sure the overflow menu is closed. This
    // prevents an empty overflow menu.
    _overflowOpen = false;
  }

  @override
  void initState() {
    widget.controller.addListener(update);
    super.initState();
  }

  update() {
    setState(() {
      _reset();
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(update);

    super.dispose();
  }

  @override
  void didUpdateWidget(_CascadeContextMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(update);
      widget.controller.addListener(update);
    }
    if (widget.items != oldWidget.items) {
      _reset();
    }
  }

  Widget _getItem(Widget child, bool isFirst, bool isLast) {
    assert(isFirst != null);
    assert(isLast != null);
    return DefaultContextMenuItemTheme(
      data: CascadeTextSelectionToolbarItemBuilder(),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox(width: 0.0, height: 0.0);
    }

    return AnimatedSize(
      alignment: Alignment.topCenter,
      vsync: this,
      // This duration was eyeballed on a Pixel 2 emulator running Android
      // API 28.
      duration: const Duration(milliseconds: 140),
      child: _TextSelectionToolbarContainer(
        key: _containerKey,
        overflowOpen: _overflowOpen,
        child: Material(
          // This value was eyeballed to match the native text selection menu on
          // a Pixel 2 running Android 10.
          borderRadius: widget.shape == null
              ? const BorderRadius.all(Radius.circular(7.0))
              : null,
          shape: widget.shape,
          clipBehavior: widget.clipBehavior ?? Clip.antiAlias,
          elevation: widget.elevation ?? 1.0,
          color: widget.backgroundColor,
          type: MaterialType.card,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              //   isAbove: widget.isAbove,
              children: <Widget>[
                if (DefaultContextMenuController.of(context).nested)
                  for (final item
                      in DefaultContextMenuController.of(context).currentItems)
                    SizedBox(
                      width: widget.width,
                      child: _getItem(item, false, false),
                    )
                else
                  for (int i = 0; i < widget.items.length; i++)
                    SizedBox(
                      width: widget.width,
                      child: _getItem(widget.items[i], i == 0,
                          i == widget.items.length - 1),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// When the overflow menu is open, it tries to align its right edge to the right
// edge of the closed menu. This widget handles this effect by measuring and
// maintaining the width of the closed menu and aligning the child to the right.
class _TextSelectionToolbarContainer extends SingleChildRenderObjectWidget {
  const _TextSelectionToolbarContainer({
    Key? key,
    required Widget child,
    required this.overflowOpen,
  })   : assert(child != null),
        assert(overflowOpen != null),
        super(key: key, child: child);

  final bool overflowOpen;

  @override
  _TextSelectionToolbarContainerRenderBox createRenderObject(
      BuildContext context) {
    return _TextSelectionToolbarContainerRenderBox(overflowOpen: overflowOpen);
  }

  @override
  void updateRenderObject(BuildContext context,
      _TextSelectionToolbarContainerRenderBox renderObject) {
    renderObject.overflowOpen = overflowOpen;
  }
}

class _TextSelectionToolbarContainerRenderBox extends RenderProxyBox {
  _TextSelectionToolbarContainerRenderBox({
    required bool overflowOpen,
  })   : assert(overflowOpen != null),
        _overflowOpen = overflowOpen,
        super();

  // The width of the menu when it was closed. This is used to achieve the
  // behavior where the open menu aligns its right edge to the closed menu's
  // right edge.
  double? _closedHeight;

  bool _overflowOpen;
  bool get overflowOpen => _overflowOpen;
  set overflowOpen(bool value) {
    if (value == overflowOpen) {
      return;
    }
    _overflowOpen = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final child = this.child!;
    child.layout(constraints.loosen(), parentUsesSize: true);

    // Save the width when the menu is closed. If the menu changes, this width
    // is invalid, so it's important that this RenderBox be recreated in that
    // case. Currently, this is achieved by providing a new key to
    // _TextSelectionToolbarContainer.
    if (!overflowOpen && _closedHeight == null) {
      _closedHeight = child.size.height;
    }

    size = constraints.constrain(Size(
      child.size.width,
      // If the open menu is wider than the closed menu, just use its own width
      // and don't worry about aligning the right edges.
      // _closedWidth is used even when the menu is closed to allow it to
      // animate its size while keeping the same right alignment.
      _closedHeight == null || child.size.height > _closedHeight!
          ? child.size.height
          : _closedHeight!,
    ));

    final ToolbarItemsParentData childParentData =
        child.parentData as ToolbarItemsParentData;
    childParentData.offset = Offset(
      0.0,
      size.height - child.size.height,
    );
  }

  // Paint at the offset set in the parent data.
  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child!;
    final ToolbarItemsParentData childParentData =
        child.parentData as ToolbarItemsParentData;
    context.paintChild(child, childParentData.offset + offset);
  }

  // Include the parent data offset in the hit test.
  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final child = this.child!;
    // The x, y parameters have the top left of the node's box as the origin.
    final ToolbarItemsParentData childParentData =
        child.parentData as ToolbarItemsParentData;
    return result.addWithPaintOffset(
      offset: childParentData.offset,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        assert(transformed == position - childParentData.offset);
        return child.hitTest(result, position: transformed);
      },
    );
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ToolbarItemsParentData) {
      child.parentData = ToolbarItemsParentData();
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    final ToolbarItemsParentData childParentData =
        child.parentData as ToolbarItemsParentData;
    transform.translate(childParentData.offset.dx, childParentData.offset.dy);
    super.applyPaintTransform(child, transform);
  }
}

class CascadeContextMenu extends RawContextMenu {
  final WidgetListBuilder actions;

  final Color? backgroundColor;
  final double? elevation;

  final Clip? clipBehavior;
  final ShapeBorder? shape;
  final ThemeData? theme;

  final double width;

  CascadeContextMenu({
    required this.actions,
    this.backgroundColor,
    this.elevation,
    this.clipBehavior,
    this.shape,
    this.theme,
    this.width = _kToolbarDefaultWidth,
  })  : assert(actions != null),
        super(actions: actions);

  @override
  Widget build(BuildContext context) {
    Widget child = _CascadeContextMenu(
      items: actions(context),
      width: width,
      shape: shape,
      backgroundColor: backgroundColor,
      elevation: elevation,
      clipBehavior: clipBehavior,
      controller: DefaultContextMenuController.of(context),
    );

    if (theme != null) {
      child = Theme(data: theme!, child: child);
    }
    return child;
  }
}
