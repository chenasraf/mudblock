import 'package:flutter/material.dart';
import '../platform_utils.dart';
import '../store.dart';

import 'action.dart';
import 'automation.dart';

class GameButton extends StatefulWidget {
  const GameButton({
    super.key,
    required this.icon,
    required this.pressAction,
    this.iconUp,
    this.iconDown,
    this.iconLeft,
    this.iconRight,
    this.color,
    this.size = defaultSize,
    this.longPressAction,
    this.swipeUpAction,
    this.swipeDownAction,
    this.swipeLeftAction,
    this.swipeRightAction,
  });

  static const defaultSize = 60.0;

  final GameButtonIcon icon;
  final GameButtonIcon? iconUp;
  final GameButtonIcon? iconDown;
  final GameButtonIcon? iconLeft;
  final GameButtonIcon? iconRight;
  final Color? color;
  final double? size;
  final MUDAction pressAction;
  final MUDAction? longPressAction;
  final MUDAction? swipeUpAction;
  final MUDAction? swipeDownAction;
  final MUDAction? swipeLeftAction;
  final MUDAction? swipeRightAction;

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> with GameStoreStateMixin {
  late GameButtonDirection _direction;
  final parentAutomation = Automation.empty();
  Offset? _dragStart;
  Offset? _dragEnd;

  @override
  void initState() {
    _direction = GameButtonDirection.none;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final curIcon = _currentDirectionIcon(context);
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: _color(context),
      ),
      child: _listener(
        context: context,
        child: IconTheme(
          data: _iconTheme(curIcon, context),
          child: Icon(curIcon.icon),
        ),
      ),
    );
  }

  double get _swipeMinDist =>
      (widget.size ??
          IconTheme.of(context).size ??
          const IconThemeData.fallback().size!) /
      2;

  Widget _listener({required BuildContext context, required Widget child}) {
    if (PlatformUtils.isDesktop) {
      return Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        child: child,
      );
    }
    return GestureDetector(
      onTap: _onPressed,
      onLongPress: _onLongPress,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: child,
    );
  }

  GameButtonIcon _currentDirectionIcon(BuildContext context) {
    switch (_direction) {
      case GameButtonDirection.up:
        return widget.iconUp ?? widget.icon;
      case GameButtonDirection.down:
        return widget.iconDown ?? widget.icon;
      case GameButtonDirection.left:
        return widget.iconLeft ?? widget.icon;
      case GameButtonDirection.right:
        return widget.iconRight ?? widget.icon;
      default:
        return widget.icon;
    }
  }

  IconThemeData _iconTheme(GameButtonIcon icon, BuildContext context) =>
      icon.iconTheme ?? IconTheme.of(context);

  Color _color(BuildContext context) =>
      widget.color ??
      Theme.of(context).buttonTheme.colorScheme?.background ??
      Colors.grey;

  void _onPressed() {
    _callCurrentDirection();
  }

  void _onLongPress() {
    _callAction(widget.longPressAction);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (details.delta.dy < 0) {
      setState(() {
        _direction = GameButtonDirection.up;
      });
    } else if (details.delta.dy > 0) {
      setState(() {
        _direction = GameButtonDirection.down;
      });
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (details.delta.dx < 0) {
      setState(() {
        _direction = GameButtonDirection.left;
      });
    } else if (details.delta.dx > 0) {
      setState(() {
        _direction = GameButtonDirection.right;
      });
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_direction == GameButtonDirection.up) {
      _callAction(widget.swipeUpAction);
    } else if (_direction == GameButtonDirection.down) {
      _callAction(widget.swipeDownAction);
    }
    setState(() {
      _direction = GameButtonDirection.none;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_direction == GameButtonDirection.left) {
      _callAction(widget.swipeLeftAction);
    } else if (_direction == GameButtonDirection.right) {
      _callAction(widget.swipeRightAction);
    }
    setState(() {
      _direction = GameButtonDirection.none;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    debugPrint("end drag, direction: $_direction");
    _callCurrentDirection();
    setState(() {
      _direction = GameButtonDirection.none;
    });
  }

  void _onPointerDown(PointerDownEvent event) {
    _dragStart = event.position;
    debugPrint("start drag");
    setState(() {
      _direction = GameButtonDirection.none;
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    _dragEnd = event.position;
    final diff = _dragStart! - _dragEnd!;
    GameButtonDirection direction = _direction;

    if (diff.distance > _swipeMinDist) {
      // detect primary direction
      if (diff.dx.abs() > diff.dy.abs()) {
        if (diff.dx > _swipeMinDist) {
          direction = GameButtonDirection.left;
        } else {
          direction = GameButtonDirection.right;
        }
      } else {
        if (diff.dy > _swipeMinDist) {
          direction = GameButtonDirection.up;
        } else {
          direction = GameButtonDirection.down;
        }
      }
    } else {
      direction = GameButtonDirection.none;
    }

    if (direction != _direction) {
      debugPrint("drag direction: $direction");
      setState(() {
        _direction = direction;
      });
    }
  }

  MUDAction _actionForDirection(GameButtonDirection direction) {
    switch (direction) {
      case GameButtonDirection.up:
        return widget.swipeUpAction ?? widget.pressAction;
      case GameButtonDirection.down:
        return widget.swipeDownAction ?? widget.pressAction;
      case GameButtonDirection.left:
        return widget.swipeLeftAction ?? widget.pressAction;
      case GameButtonDirection.right:
        return widget.swipeRightAction ?? widget.pressAction;
      default:
        return widget.pressAction;
    }
  }

  void _callAction(MUDAction? action) {
    (action ?? _actionForDirection(GameButtonDirection.none))
        .invoke(store, parentAutomation, []);
  }

  void _callCurrentDirection() {
    _callAction(_actionForDirection(_direction));
  }
}

class GameButtonIcon {
  final IconData icon;
  final IconThemeData? iconTheme;

  GameButtonIcon(this.icon, {this.iconTheme});
}

enum GameButtonDirection {
  none,
  up,
  down,
  left,
  right,
}

