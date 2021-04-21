//@dart=2.12
import 'package:flutter/material.dart';

class ContextMenuController extends ChangeNotifier {
  final VoidCallback hide;

  ContextMenuController({
    required this.hide,
  });

  int get depth => _depth.length;
  bool get nested => _depth.isNotEmpty;

  final List<List<Widget>> _depth = [];

  void push(List<Widget> children) {
    assert(children.isNotEmpty, 'Only items with children can be nested');
    _depth.add(children);
    notifyListeners();
  }

  void pop() {
    if (_depth.isNotEmpty) {
      _depth.removeLast();
    } else {
      hide();
    }
    notifyListeners();
  }

  List<Widget> get currentItems => _depth.last;

  static ContextMenuController of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<MenuContextControllerScope>()!
      .controller;
}

class DefaultContextMenuController extends StatefulWidget {
  final VoidCallback hide;
  final Widget child;

  const DefaultContextMenuController({
    Key? key,
    required this.hide,
    required this.child,
  }) : super(key: key);

  @override
  _DefaultContextMenuControllerState createState() =>
      _DefaultContextMenuControllerState();

  static ContextMenuController of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<MenuContextControllerScope>()!
      .controller;
}

class _DefaultContextMenuControllerState
    extends State<DefaultContextMenuController> {
  late ContextMenuController controller;

  @override
  void initState() {
    controller = ContextMenuController(
      hide: widget.hide,
    );

    controller.addListener(update);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MenuContextControllerScope(
      controller: controller,
      child: widget.child,
    );
  }

  update() {
    setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(update);
    controller.dispose();
    super.dispose();
  }
}

class MenuContextControllerScope extends InheritedWidget {
  final ContextMenuController controller;

  MenuContextControllerScope({required this.controller, required Widget child})
      : super(child: child);

  @override
  bool updateShouldNotify(covariant MenuContextControllerScope oldWidget) {
    return oldWidget.controller.depth != oldWidget.controller.depth;
  }
}
