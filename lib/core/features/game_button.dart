import 'package:flutter/material.dart';
import '../color_utils.dart';
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

  @override
  String toString() {
    return 'GameButtonData(id: $id, label: $label)';
  }
}

class GameButton extends StatefulWidget {
  const GameButton({
    super.key,
    required this.data,
    this.enabled = true,
  });

  final GameButtonData data;
  final bool enabled;

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> with GameStoreStateMixin {
  late GameButtonInteraction _direction;
  final parentAutomation = Automation.empty();
  Offset? _dragStart;
  Offset? _dragEnd;
  bool isHovering = false;
  bool isClicking = false;
  DateTime? _startDragTime;

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
    // final tooltip = Tooltip(
    //   message: [
    //     GameButtonInteraction.press,
    //     GameButtonInteraction.longPress,
    //     GameButtonInteraction.dragUp,
    //     GameButtonInteraction.dragDown,
    //     GameButtonInteraction.dragLeft,
    //     GameButtonInteraction.dragRight,
    //   ]
    //       .map((dir) {
    //         final content = data.getAction(_direction)?.content;
    //         if (content == null || content.isEmpty) {
    //           return '';
    //         }
    //         final label = dir.name.capitalize();
    //         return '$label: $content';
    //       })
    //       .where((s) => s.isNotEmpty)
    //       .join('\n'),
    // );
    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: data.size,
      height: data.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isClicking
            ? _dragColor(context)
            : isHovering
                ? _hoverColor(context)
                : _color(context),
      ),
      child: GameButtonLabel(data: curLabel),
    );
    if (!widget.enabled) {
      return child;
    }
    return _listener(
      context: context,
      child: child,
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
      return MouseRegion(
        onEnter: (_) => setState(() => isHovering = true),
        onExit: (_) => setState(() => isHovering = false),
        cursor: SystemMouseCursors.click,
        child: Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          child: child,
        ),
      );
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
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

  Color _hoverColor(BuildContext context) {
    final source = _color(context);
    if (ColorUtils.isDark(source)) {
      return ColorUtils.lighten(source, 0.05);
    }
    return ColorUtils.darken(source, 0.05);
  }

  Color _dragColor(BuildContext context) {
    final source = _color(context);
    if (ColorUtils.isDark(source)) {
      return ColorUtils.lighten(source, 0.1);
    }
    return ColorUtils.darken(source, 0.1);
  }

  void _onPressed() {
    _callCurrentDirection();
  }

  void _onLongPress() {
    _callAction(data.longPressAction);
    setState(() {
      isClicking = false;
      isHovering = false;
    });
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      isClicking = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      isClicking = false;
      isHovering = false;
    });
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
      isHovering = false;
      isClicking = false;
    });
  }

  void _onPointerDown(PointerDownEvent event) {
    _dragStart = event.position;
    setState(() {
      isClicking = true;
      _direction = GameButtonInteraction.press;
      _startDragTime = DateTime.now();
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    final moveDist = (_dragStart! - event.position).distance;
    final timeDiff = DateTime.now().difference(_startDragTime!);

    // TODO currently this waits for mouse up,
    //      but it should be changed to detect if mouse is still down
    //      and still call the action after the timeout, if min dist is reached
    if (timeDiff > const Duration(milliseconds: 200) &&
        moveDist < _dragMinDist) {
      _callAction(data.longPressAction);
    } else {
      _callCurrentDirection();
    }

    setState(() {
      isClicking = false;
      isHovering = false;
      _direction = GameButtonInteraction.press;
      _startDragTime = null;
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
    act.invoke(store, []);
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
    if (data.isText) {
      return Center(child: Text(data.label!, textScaleFactor: 1.2));
    } else {
      return IconTheme(
        data: _iconTheme(context),
        child: Icon(data.icon),
      );
    }
  }

  IconThemeData _iconTheme(BuildContext context) =>
      data.iconTheme ?? IconTheme.of(context);
}

class GameButtonLabelData {
  String? label;
  IconData? icon;
  String? iconName;
  IconThemeData? iconTheme;

  bool get isIcon => icon != null;
  bool get isText => label != null;

  GameButtonLabelData({
    this.label,
    this.icon,
    this.iconName,
    this.iconTheme,
  })  : assert(label != null || icon != null),
        assert(icon == null || iconName != null);

  factory GameButtonLabelData.empty() => GameButtonLabelData(label: '');

  factory GameButtonLabelData.fromJson(Map<String, dynamic> json) {
    return GameButtonLabelData(
      label: json['label'],
      icon: json['icon'] != null
          ? IconData(
              json['icon'],
              fontFamily: json['iconFontFamily'] ?? 'MaterialIcons',
            )
          : null,
      iconName: json['iconName'] ?? '',
      iconTheme: json['iconTheme'] != null
          ? _iconThemeDataFromJson(json['iconTheme'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'icon': icon?.codePoint,
      'iconName': iconName,
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
    String? iconName,
    IconThemeData? iconTheme,
  }) {
    label = icon != null ? null : label ?? this.label;
    icon = label != null ? null : icon ?? this.icon;
    return GameButtonLabelData(
      label: label ?? this.label,
      icon: icon ?? this.icon,
      iconName: iconName ?? this.iconName,
      iconTheme: iconTheme ?? this.iconTheme,
    );
  }

  @override
  String toString() {
    return 'GameButtonLabel(${isText ? 'label:' : 'icon:'} ${isText ? label! : iconName!})';
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

