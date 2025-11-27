import 'package:flutter/material.dart';

class HotRestartController extends StatefulWidget {
  final Widget child;

  const HotRestartController({super.key, required this.child});

  static void performHotRestart(BuildContext context) {
    final _HotRestartControllerState? state =
        context.findAncestorStateOfType<_HotRestartControllerState>();
    if (state != null) {
      state.performHotRestart();
    } else {
      debugPrint("No ancestor HotRestartController found in the widget tree.");
    }
  }

  @override
  _HotRestartControllerState createState() => _HotRestartControllerState();
}

class _HotRestartControllerState extends State<HotRestartController> {
  late Key _currentKey;

  @override
  void initState() {
    super.initState();
    _currentKey = UniqueKey();
  }

  void performHotRestart() {
    setState(() {
      _currentKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _currentKey,
      child: widget.child,
    );
  }
}
