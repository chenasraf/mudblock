import 'package:flutter/material.dart';
import '../platform_utils.dart';
import '../store.dart';

import '../string_utils.dart';
import 'action.dart';
import 'automation.dart';

class GameButtonData {
  GameButtonData({
    required this.id,
    required this.label,
    required this.pressAction,
    this.labelUp,
    this.labelDown,
    this.labelLeft,
    this.labelRight,
    this.color,
    this.size = defaultSize,
    this.longPressAction,
    this.dragUpAction,
    this.dragDownAction,
    this.dragLeftAction,
    this.dragRightAction,
  });

  static const defaultSize = 60.0;

  final String id;
  GameButtonLabelData label;
  GameButtonLabelData? labelUp;
  GameButtonLabelData? labelDown;
  GameButtonLabelData? labelLeft;
  GameButtonLabelData? labelRight;
  Color? color;
  double? size;
  MUDAction pressAction;
  MUDAction? longPressAction;
  MUDAction? dragUpAction;
  MUDAction? dragDownAction;
  MUDAction? dragLeftAction;
  MUDAction? dragRightAction;

  factory GameButtonData.empty() => GameButtonData(
        id: uuid(),
        label: GameButtonLabelData.empty(),
        pressAction: MUDAction.empty(),
      );

  factory GameButtonData.fromJson(Map<String, dynamic> json) {
    return GameButtonData(
      id: json['id'] as String,
      label: GameButtonLabelData.fromJson(json['label']),
      pressAction: MUDAction.fromJson(json['pressAction']),
      labelUp: json['labelUp'] == null
          ? null
          : GameButtonLabelData.fromJson(json['labelUp']),
      labelDown: json['labelDown'] == null
          ? null
          : GameButtonLabelData.fromJson(json['labelDown']),
      labelLeft: json['labelLeft'] == null
          ? null
          : GameButtonLabelData.fromJson(json['labelLeft']),
      labelRight: json['labelRight'] == null
          ? null
          : GameButtonLabelData.fromJson(json['labelRight']),
      color: json['color'] == null ? null : Color(json['color'] as int),
      size: json['size'] == null ? null : json['size']!.toDouble(),
      longPressAction: json['longPressAction'] == null
          ? null
          : MUDAction.fromJson(json['longPressAction']),
      dragUpAction: json['dragUpAction'] == null
          ? null
          : MUDAction.fromJson(json['dragUpAction']),
      dragDownAction: json['dragDownAction'] == null
          ? null
          : MUDAction.fromJson(json['dragDownAction']),
      dragLeftAction: json['dragLeftAction'] == null
          ? null
          : MUDAction.fromJson(json['dragLeftAction']),
      dragRightAction: json['dragRightAction'] == null
          ? null
          : MUDAction.fromJson(json['dragRightAction']),
    );
  }

  GameButtonData copyWith({
    String? id,
    GameButtonLabelData? label,
    GameButtonLabelData? labelUp,
    GameButtonLabelData? labelDown,
    GameButtonLabelData? labelLeft,
    GameButtonLabelData? labelRight,
    Color? color,
    double? size,
    MUDAction? pressAction,
    MUDAction? longPressAction,
    MUDAction? dragUpAction,
    MUDAction? dragDownAction,
    MUDAction? dragLeftAction,
    MUDAction? dragRightAction,
  }) =>
      GameButtonData(
        id: id ?? this.id,
        label: label ?? this.label,
        labelUp: labelUp ?? this.labelUp,
        labelDown: labelDown ?? this.labelDown,
        labelLeft: labelLeft ?? this.labelLeft,
        labelRight: labelRight ?? this.labelRight,
        color: color ?? this.color,
        size: size ?? this.size,
        pressAction: pressAction ?? this.pressAction,
        longPressAction: longPressAction ?? this.longPressAction,
        dragUpAction: dragUpAction ?? this.dragUpAction,
        dragDownAction: dragDownAction ?? this.dragDownAction,
        dragLeftAction: dragLeftAction ?? this.dragLeftAction,
        dragRightAction: dragRightAction ?? this.dragRightAction,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label.toJson(),
        'pressAction': pressAction.toJson(),
        'labelUp': labelUp?.toJson(),
        'labelDown': labelDown?.toJson(),
        'labelLeft': labelLeft?.toJson(),
        'labelRight': labelRight?.toJson(),
        'color': color?.value,
        'size': size,
        'longPressAction': longPressAction?.toJson(),
        'dragUpAction': dragUpAction?.toJson(),
        'dragDownAction': dragDownAction?.toJson(),
        'dragLeftAction': dragLeftAction?.toJson(),
        'dragRightAction': dragRightAction?.toJson(),
      };

  MUDAction getActionOrDefault(GameButtonInteraction interaction) {
    return getAction(interaction) ?? pressAction;
  }

  MUDAction? getAction(GameButtonInteraction interaction) {
    switch (interaction) {
      case GameButtonInteraction.press:
        return pressAction;
      case GameButtonInteraction.longPress:
        return longPressAction;
      case GameButtonInteraction.dragUp:
        return dragUpAction;
      case GameButtonInteraction.dragDown:
        return dragDownAction;
      case GameButtonInteraction.dragLeft:
        return dragLeftAction;
      case GameButtonInteraction.dragRight:
        return dragRightAction;
      default:
        return null;
    }
  }

  void setAction(GameButtonInteraction direction, MUDAction mudAction) {
    switch (direction) {
      case GameButtonInteraction.press:
        pressAction = mudAction;
        break;
      case GameButtonInteraction.longPress:
        longPressAction = mudAction;
        break;
      case GameButtonInteraction.dragUp:
        dragUpAction = mudAction;
        break;
      case GameButtonInteraction.dragDown:
        dragDownAction = mudAction;
        break;
      case GameButtonInteraction.dragLeft:
        dragLeftAction = mudAction;
        break;
      case GameButtonInteraction.dragRight:
        dragRightAction = mudAction;
        break;
    }
  }

  GameButtonLabelData? getLabel(GameButtonInteraction interaction) {
    switch (interaction) {
      case GameButtonInteraction.press:
        return label;
      case GameButtonInteraction.longPress:
        return label;
      case GameButtonInteraction.dragUp:
        return labelUp;
      case GameButtonInteraction.dragDown:
        return labelDown;
      case GameButtonInteraction.dragLeft:
        return labelLeft;
      case GameButtonInteraction.dragRight:
        return labelRight;
      default:
        return label;
    }
  }

  void setLabel(GameButtonInteraction direction, GameButtonLabelData? label) {
    switch (direction) {
      case GameButtonInteraction.press:
        if (label == null) {
          throw ArgumentError('Label cannot be null');
        }
        this.label = label;
        break;
      case GameButtonInteraction.longPress:
        if (label == null) {
          throw ArgumentError('Label cannot be null');
        }
        this.label = label;
        break;
      case GameButtonInteraction.dragUp:
        labelUp = label;
        break;
      case GameButtonInteraction.dragDown:
        labelDown = label;
        break;
      case GameButtonInteraction.dragLeft:
        labelLeft = label;
        break;
      case GameButtonInteraction.dragRight:
        labelRight = label;
        break;
    }
  }
}

class GameButton extends StatefulWidget {
  const GameButton({
    super.key,
    required this.data,
  });

  final GameButtonData data;

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> with GameStoreStateMixin {
  late GameButtonInteraction _direction;
  final parentAutomation = Automation.empty();
  Offset? _dragStart;
  Offset? _dragEnd;

  //
  GameButtonData get data => widget.data;

  @override
  void initState() {
    _direction = GameButtonInteraction.press;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final curLabel = _currentDirectionIcon(context) ?? data.label;
    return _listener(
      context: context,
      child: Container(
        width: data.size,
        height: data.size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _color(context),
        ),
        child: GameButtonLabel(data: curLabel),
      ),
    );
  }

  double get _dragMinDist =>
      (data.size ??
          IconTheme.of(context).size ??
          const IconThemeData.fallback().size!) /
      2;

  Widget _listener({
    required BuildContext context,
    required Widget child,
  }) {
    if (PlatformUtils.isDesktop) {
      return Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        child: child,
      );
    }

    return GestureDetector(
      onTap: _onPressed,
      onLongPress: _onLongPress,
      onVerticalDragStart: _onDragStart,
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: child,
    );
  }

  GameButtonLabelData? _currentDirectionIcon(BuildContext context) {
    switch (_direction) {
      case GameButtonInteraction.dragUp:
        return data.labelUp;
      case GameButtonInteraction.dragDown:
        return data.labelDown;
      case GameButtonInteraction.dragLeft:
        return data.labelLeft;
      case GameButtonInteraction.dragRight:
        return data.labelRight;
      default:
        return data.label;
    }
  }

  Color _color(BuildContext context) =>
      data.color ??
      Theme.of(context).buttonTheme.colorScheme?.background ??
      Colors.grey;

  void _onPressed() {
    _callCurrentDirection();
  }

  void _onLongPress() {
    _callAction(data.longPressAction);
  }

  void _onDragStart(DragStartDetails details) {
    _dragStart = details.globalPosition;
    setState(() {
      _direction = GameButtonInteraction.press;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final pos = details.globalPosition;
    final interaction = _getRelativeDragDirection(_dragStart!, pos);

    if (interaction != _direction) {
      setState(() {
        _direction = interaction;
      });
    }
  }

  void _onDragEnd(DragEndDetails details) {
    _callCurrentDirection();
    setState(() {
      _direction = GameButtonInteraction.press;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    _callCurrentDirection();
    setState(() {
      _direction = GameButtonInteraction.press;
    });
  }

  void _onPointerDown(PointerDownEvent event) {
    _dragStart = event.position;
    setState(() {
      _direction = GameButtonInteraction.press;
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    _dragEnd = event.position;
    final interaction = _getRelativeDragDirection(_dragStart!, _dragEnd!);

    if (interaction != _direction) {
      setState(() {
        _direction = interaction;
      });
    }
  }

  GameButtonInteraction _getRelativeDragDirection(
      Offset start, Offset current) {
    final diff = start - current;
    GameButtonInteraction interaction = _direction;

    if (diff.distance > _dragMinDist) {
      // detect primary interaction
      // horizontal
      if (diff.dx.abs() > diff.dy.abs()) {
        if (diff.dx > _dragMinDist) {
          interaction = GameButtonInteraction.dragLeft;
        } else {
          interaction = GameButtonInteraction.dragRight;
        }
        // vertical
      } else {
        if (diff.dy > _dragMinDist) {
          interaction = GameButtonInteraction.dragUp;
        } else {
          interaction = GameButtonInteraction.dragDown;
        }
      }
      // pos is within button - no interaction
    } else {
      interaction = GameButtonInteraction.press;
    }
    return interaction;
  }

  void _callAction(MUDAction? action) {
    final act = action ?? data.getActionOrDefault(GameButtonInteraction.press);
    act.invoke(store, parentAutomation, []);
  }

  void _callCurrentDirection() {
    _callAction(data.getActionOrDefault(_direction));
  }
}

class GameButtonLabel extends StatelessWidget {
  const GameButtonLabel({super.key, required this.data});

  final GameButtonLabelData data;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: _iconTheme(context),
      child: Icon(data.icon),
    );
  }

  IconThemeData _iconTheme(BuildContext context) =>
      data.iconTheme ?? IconTheme.of(context);
}

class GameButtonLabelData {
  String? label;
  IconData? icon;
  IconThemeData? iconTheme;

  GameButtonLabelData({
    this.label,
    this.icon,
    this.iconTheme,
  }) : assert(label != null || icon != null);

  factory GameButtonLabelData.empty() => GameButtonLabelData(label: '?');

  factory GameButtonLabelData.fromJson(Map<String, dynamic> json) {
    return GameButtonLabelData(
      label: json['label'],
      icon: json['icon'] != null
          ? IconData(
              json['icon'],
              fontFamily: json['iconFontFamily'] ?? 'MaterialIcons',
            )
          : null,
      iconTheme: json['iconTheme'] != null
          ? _iconThemeDataFromJson(json['iconTheme'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'icon': icon?.codePoint,
      'iconFontFamily': icon?.fontFamily,
      'iconTheme': iconTheme != null ? _iconThemeDataToJson(iconTheme!) : null,
    };
  }

  static IconThemeData _iconThemeDataFromJson(Map<String, dynamic> json) =>
      IconThemeData(
        color: json['color'] != null ? Color(json['color']) : null,
        opacity: json['opacity'] ?? 1.0,
        size: json['size'] ?? 24.0,
      );

  static Map<String, dynamic> _iconThemeDataToJson(IconThemeData data) => {
        'color': data.color?.value,
        'opacity': data.opacity,
        'size': data.size,
      };

  GameButtonLabelData copyWith({
    String? label,
    IconData? icon,
    IconThemeData? iconTheme,
  }) {
    return GameButtonLabelData(
      label: label ?? this.label,
      icon: icon ?? this.icon,
      iconTheme: iconTheme ?? this.iconTheme,
    );
  }
}

enum GameButtonInteraction {
  press,
  longPress,
  dragUp,
  dragDown,
  dragLeft,
  dragRight,
}

