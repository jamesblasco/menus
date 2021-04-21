//@dart=2.12
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'context_menu.dart';
import 'context_menu_route.dart';
import 'menu_context_controller.dart';

enum ContextMenuTriggerGesture {
  onTap,
  onLongPress,
  onSecondaryTap,
  onSecondaryPress
}

/// Displays a menu when pressed
class ContextMenuButton<T> extends StatefulWidget {
  /// Creates a button that shows a popup menu.
  ///
  /// The [itemBuilder] argument must not be null.
  const ContextMenuButton({
    Key? key,
    required this.menu,
    this.tooltip,
    this.padding = const EdgeInsets.all(8.0),
    this.child,
    this.icon,
    this.offset = Offset.zero,
    this.enabled = true,
    this.aligment = AlignmentDirectional.topEnd,
    this.originAligment = AlignmentDirectional.topStart,
  })  : assert(!(child != null && icon != null),
            'You can only pass [child] or [icon], not both.'),
        super(key: key);

  final RawContextMenu menu;

  /// Text that describes the action that will occur when the button is pressed.
  ///
  /// This text is displayed when the user long-presses on the button and is
  /// used for accessibility.
  final String? tooltip;

  /// Matches IconButton's 8 dps padding by default. In some cases, notably where
  /// this button appears as the trailing element of a list item, it's useful to be able
  /// to set the padding to zero.
  final EdgeInsetsGeometry padding;

  /// If provided, [child] is the widget used for this button
  /// and the button will utilize an [InkWell] for taps.
  final Widget? child;

  /// If provided, the [icon] is used for this button
  /// and the button will behave like an [IconButton].
  final Widget? icon;

  /// The offset applied to the Popup Menu Button.
  ///
  /// When not set, the Popup Menu Button will be positioned directly next to
  /// the button that was used to create it.
  final Offset offset;

  /// Whether this popup menu button is interactive.
  ///
  /// Must be non-null, defaults to `true`
  ///
  /// If `true` the button will respond to presses by displaying the menu.
  ///
  /// If `false`, the button is styled with the disabled color from the
  /// current [Theme] and will not respond to presses or show the popup
  /// menu and [onSelected], [onCanceled] and [itemBuilder] will not be called.
  ///
  /// This can be useful in situations where the app needs to show the button,
  /// but doesn't currently have anything to show in the menu.
  final bool enabled;

  final AlignmentGeometry aligment;
  final AlignmentGeometry originAligment;

  @override
  ContextMenuButtonState<T> createState() => ContextMenuButtonState<T>();
}

/// The [State] for a [ContextMenuButton].
///
/// See [showButtonMenu] for a way to programmatically open the popup menu
/// of your button state.
class ContextMenuButtonState<T> extends State<ContextMenuButton<T>> {
  /// A method to show a popup menu with the items supplied to
  /// [ContextMenuButton.itemBuilder] at the position of your [ContextMenuButton].
  ///
  /// By default, it is called when the user taps the button and [ContextMenuButton.enabled]
  /// is set to `true`. Moreover, you can open the button by calling the method manually.
  ///
  /// You would access your [ContextMenuButtonState] using a [GlobalKey] and
  /// show the menu of the button with `globalKey.currentState.showButtonMenu`.
  void showButtonMenu(Offset triggerPosition) {
    
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final Rect targetRegion = Rect.fromPoints(
      button.localToGlobal(widget.offset, ancestor: overlay),
      button.localToGlobal(button.size.bottomRight(Offset.zero),
          ancestor: overlay),
    );

    // Only show the menu if there is something to show
    if (widget.menu.actions(context).isNotEmpty) {
      showContextMenu<T>(
        context: context,
        menu: widget.menu,
        targetRegion: targetRegion,
        triggerPosition: triggerPosition,
        originAligment: widget.originAligment,
        aligment: widget.aligment,
      ).then<void>((T? newValue) {
        if (!mounted) return null;
      });
    }
  }

  Icon _getIcon(TargetPlatform platform) {
    assert(platform != null);
    switch (platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const Icon(Icons.more_vert);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return const Icon(Icons.more_horiz);
    }
  }

  bool get _canRequestFocus {
    final NavigationMode mode = MediaQuery.maybeOf(context)?.navigationMode ??
        NavigationMode.traditional;
    switch (mode) {
      case NavigationMode.traditional:
        return widget.enabled;
      case NavigationMode.directional:
        return true;
    }
    assert(false, 'Navigation mode $mode not handled');
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));

    if (widget.child != null) {
      return Tooltip(
        message:
            widget.tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
        child: InkWell(
          onTap: () {},
          onTapDown: widget.enabled
              ? (details) {
                  showButtonMenu(details.localPosition);
                }
              : null,
          canRequestFocus: _canRequestFocus,
          child: widget.child,
        ),
      );
    }

    return IconButton(
      icon: widget.icon ?? _getIcon(Theme.of(context).platform),
      padding: widget.padding,
      tooltip:
          widget.tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
      onPressed: widget.enabled ? () => showButtonMenu(Offset.zero) : null,
    );
  }
}
