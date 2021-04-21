import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'menu_context_controller.dart';

typedef WidgetListBuilder = List<Widget> Function(BuildContext context);

@immutable
abstract class RawContextMenu extends StatelessWidget {
  final WidgetListBuilder actions;

  RawContextMenu({required this.actions});
}

@immutable
abstract class ContextMenuItemThemeData {
  Widget buildItem(BuildContext context, ContextMenuItem item);
}

class DefaultContextMenuItemTheme extends InheritedWidget {
  final ContextMenuItemThemeData data;

  DefaultContextMenuItemTheme({required this.data, required Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(covariant DefaultContextMenuItemTheme oldWidget) {
    return data != oldWidget.data;
  }

  static ContextMenuItemThemeData of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<DefaultContextMenuItemTheme>()!
      .data;
}

typedef ContextMenuItemTapCallback = bool Function();

// Intermediate data used for building menu items with the _getItems method.
@immutable
class ContextMenuItem extends StatelessWidget {
  final ContextMenuItemThemeData? theme;

  final ContextMenuItemTapCallback onPressed;
  final Widget title;

  final List<Widget>? children;

  const ContextMenuItem({
    required this.onPressed,
    required this.title,
    this.theme,
  }) : this.children = null;

  static ContextMenuItemWithSublist sublist(
          {required List<Widget> children,
          required Widget title,
          ContextMenuItemThemeData? theme}) =>
      ContextMenuItemWithSublist(
        title: title,
        theme: theme,
        children: children,
      );

  ContextMenuItem._sublist({
    required this.children,
    required this.title,
    this.theme,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    assert(onPressed != null);
    assert(title != null);
    final builder = this.theme ?? DefaultContextMenuItemTheme.of(context);
    return builder.buildItem(context, this);
  }
}

@immutable
class ContextMenuItemWithSublist extends StatelessWidget {
  final ContextMenuItemThemeData? theme;

  final Widget title;

  final List<Widget> children;

  const ContextMenuItemWithSublist({
    required this.title,
    this.theme,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ContextMenuItem._sublist(
      theme: theme,
      title: title,
      children: children,
      onPressed: () {
        final controller = ContextMenuController.of(context);
        controller.push(children);
        return false;
      },
    );
  }
}
