//@dart=2.12
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../context_menu.dart';

const Duration _kMenuDuration = Duration(milliseconds: 200);
const double _kMenuCloseIntervalEnd = 2.0 / 3.0;

/// MOST CODE FROM PopupMenu
class _ContextMenuRoute<T> extends PopupRoute<T> {
  _ContextMenuRoute({
    required this.targetRegion,
    required this.globalRegion,
    required this.theme,
    required this.popupMenuTheme,
    required this.menu,
    this.barrierLabel,
    this.semanticLabel,
    required this.showMenuContext,
    this.captureInheritedThemes = false,
    required this.triggerPosition,
    this.aligment = AlignmentDirectional.topEnd,
    this.originAligment = AlignmentDirectional.topStart,
  });

  final Rect targetRegion;
  final Rect globalRegion;
  final Offset triggerPosition;

  final ThemeData theme;
  final String? semanticLabel;

  final PopupMenuThemeData popupMenuTheme;
  final BuildContext showMenuContext;
  final bool captureInheritedThemes;

  final Widget menu;

  final AlignmentGeometry aligment;
  
  final AlignmentGeometry originAligment;

  @override
  Animation<double> createAnimation() {
    return CurvedAnimation(
      parent: super.createAnimation(),
      curve: Curves.linear,
      reverseCurve: const Interval(0.0, _kMenuCloseIntervalEnd),
    );
  }

  @override
  Duration get transitionDuration => _kMenuDuration;

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => null;

  @override
  final String? barrierLabel;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          child: child,
          opacity: animation.value,
        );
      },
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        removeLeft: true,
        removeRight: true,
        child: DefaultContextMenuController(
          hide: () {
            Navigator.of(context).pop();
          },
          child: ContextMenuLayout(
            globalRegion: globalRegion,
            targetRegion: targetRegion,
            targetOffset: triggerPosition,
            originAligment: originAligment,
            aligment: aligment,
            padding: EdgeInsets.all(12),
            child: menu,
          ),
        ),
      ),
    );
  }
}

/// Show a context menu that contains the `items` at `position`.
Future<T?> showContextMenu<T>({
  required BuildContext context,
  required Rect targetRegion,
  required Offset triggerPosition,
  required Widget menu,
  String? semanticLabel,
  bool captureInheritedThemes = true,
  bool useRootNavigator = false,
  AlignmentGeometry aligment = AlignmentDirectional.topEnd,
  AlignmentGeometry originAligment = AlignmentDirectional.topStart,
}) {
  assert(context != null);
  assert(targetRegion != null);
  assert(useRootNavigator != null);
  assert(menu != null);
  assert(captureInheritedThemes != null);
  assert(debugCheckHasMaterialLocalizations(context));

  String? label = semanticLabel;
  switch (Theme.of(context).platform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      label = semanticLabel;
      break;
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      label = semanticLabel ?? MaterialLocalizations.of(context).popupMenuLabel;
  }
  final RenderBox overlay =
      Overlay.of(context)!.context.findRenderObject() as RenderBox;
  return Navigator.of(context, rootNavigator: useRootNavigator)
      .push(_ContextMenuRoute<T>(
    targetRegion: targetRegion,
    menu: menu,
    triggerPosition: triggerPosition,
    globalRegion: Offset.zero & overlay.size,
    semanticLabel: label,
    theme: Theme.of(context),
    popupMenuTheme: PopupMenuTheme.of(context),
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    showMenuContext: context,
    captureInheritedThemes: captureInheritedThemes,
    originAligment: originAligment,
    aligment: aligment,
  ));
}
