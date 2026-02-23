import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart' hide Animation, PaintingStyle;

import '../../../../core/app_language.dart';
import '../../../../core/language_provider.dart';

enum _MascotMood { idle, encourage, celebrate, oops, sleep }

class MascotRive extends ConsumerStatefulWidget {
  const MascotRive({super.key, required this.nodePos, this.onTap});

  final Offset nodePos;
  final VoidCallback? onTap;

  @override
  ConsumerState<MascotRive> createState() => _MascotRiveState();
}

class _MascotRiveState extends ConsumerState<MascotRive>
    with TickerProviderStateMixin {
  static const _foxAsset = 'assets/images/mascot_fox_transparent.png';
  static const _riveAsset = 'assets/images/mascot_fox.riv';

  final Random _random = Random();

  late final AnimationController _idleController;
  late final AnimationController _actionController;
  late final AnimationController _travelController;
  late final AnimationController _blinkController;
  late final AnimationController _sparkleController;
  late final Animation<double> _actionLift;
  late final Animation<double> _actionScaleX;
  late final Animation<double> _actionScaleY;
  late final Animation<double> _actionTilt;
  late final Animation<double> _travelLift;
  FileLoader? _riveFileLoader;

  Timer? _blinkTimer;
  Timer? _lookTimer;
  Timer? _ambientTimer;
  Timer? _bubbleTimer;
  Timer? _lagTimer;
  Timer? _moodResetTimer;

  _MascotMood _mood = _MascotMood.idle;
  DateTime _lastInteraction = DateTime.now();
  bool _isHovering = false;
  bool _isRightSide = false;

  bool _showBubble = false;
  String _bubbleMessage = '';
  int _bubbleRevision = 0;

  double _lookTargetX = 0.0;
  double _lookTargetY = 0.0;
  double _lagTargetX = 0.0;
  double _lagTargetY = 0.0;
  double _actionIntensity = 1.0;
  bool _hasRiveAsset = false;
  bool _riveChecked = false;
  List<double> _sparkAngles = <double>[];
  List<double> _sparkDistances = <double>[];
  List<double> _sparkSizes = <double>[];

  RiveWidgetController? _riveController;
  TriggerInput? _riveCelebrateInput;
  TriggerInput? _riveEncourageInput;
  TriggerInput? _riveOopsInput;
  BooleanInput? _riveSleepInput;
  BooleanInput? _riveHoverInput;
  NumberInput? _riveLookXInput;
  NumberInput? _riveLookYInput;

  @override
  void initState() {
    super.initState();
    _detectRiveAsset();

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
    _actionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    );
    _travelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _actionLift = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 5,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 5,
          end: -26,
        ).chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 36,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -26,
          end: 0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 46,
      ),
    ]).animate(_actionController);

    _actionScaleX = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 0.95,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_actionController);

    _actionScaleY = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.9,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.9,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.08,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_actionController);

    _actionTilt = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: -0.035,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -0.035,
          end: 0.012,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 55,
      ),
    ]).animate(_actionController);

    _travelLift = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: -11,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 48,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -11,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 52,
      ),
    ]).animate(_travelController);

    _scheduleBlink();
    _retargetLook();
    _scheduleLookRetarget();
    _scheduleAmbientEvent();
  }

  @override
  void didUpdateWidget(covariant MascotRive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.nodePos - widget.nodePos).distance > 12) {
      _travelController.forward(from: 0);
      _playMood(_MascotMood.encourage, actionIntensity: 0.24);
      _retargetLook();
    }
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _lookTimer?.cancel();
    _ambientTimer?.cancel();
    _bubbleTimer?.cancel();
    _lagTimer?.cancel();
    _moodResetTimer?.cancel();
    _idleController.dispose();
    _actionController.dispose();
    _travelController.dispose();
    _blinkController.dispose();
    _sparkleController.dispose();
    _riveFileLoader?.dispose();
    super.dispose();
  }

  Future<void> _detectRiveAsset() async {
    var available = false;
    try {
      await rootBundle.load(_riveAsset);
      available = true;
    } catch (_) {
      available = false;
    }
    if (!mounted) return;
    setState(() {
      _riveChecked = true;
      _hasRiveAsset = available;
      if (available && _riveFileLoader == null) {
        _riveFileLoader = FileLoader.fromAsset(
          _riveAsset,
          riveFactory: Factory.flutter,
        );
      }
    });
  }

  void _scheduleBlink() {
    _blinkTimer?.cancel();
    final delayMs = 1300 + _random.nextInt(2600);
    _blinkTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      _blinkController.forward(from: 0);
      _scheduleBlink();
    });
  }

  void _scheduleLookRetarget() {
    _lookTimer?.cancel();
    final delayMs = _isHovering ? 750 : 1700 + _random.nextInt(2300);
    _lookTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      _retargetLook();
      _scheduleLookRetarget();
    });
  }

  void _scheduleAmbientEvent() {
    _ambientTimer?.cancel();
    final delay = Duration(seconds: 7 + _random.nextInt(7));
    _ambientTimer = Timer(delay, () {
      if (!mounted) return;
      final language = ref.read(appLanguageProvider);
      final idleFor = DateTime.now().difference(_lastInteraction);

      if (idleFor > const Duration(seconds: 26)) {
        _setMood(_MascotMood.sleep, triggerRive: false);
        _showSpeechBubble(
          _sleepMessage(language),
          visibleFor: const Duration(milliseconds: 1700),
        );
      } else {
        final roll = _random.nextDouble();
        if (roll < 0.62) {
          _playMood(
            _MascotMood.encourage,
            actionIntensity: 0.45,
            bubbleMessage: _pickEncouragement(language),
            bubbleDuration: const Duration(milliseconds: 1500),
          );
        } else if (roll < 0.78) {
          _playMood(
            _MascotMood.oops,
            actionIntensity: 0.32,
            bubbleMessage: _oopsMessage(language),
            bubbleDuration: const Duration(milliseconds: 1300),
          );
        } else {
          _setMood(_MascotMood.idle, triggerRive: false);
        }
      }

      _retargetLook();
      _scheduleAmbientEvent();
    });
  }

  void _setMood(_MascotMood mood, {required bool triggerRive}) {
    if (_mood != mood) {
      setState(() {
        _mood = mood;
      });
    }
    _pushRiveState(triggerMood: triggerRive);
  }

  void _playMood(
    _MascotMood mood, {
    required double actionIntensity,
    String? bubbleMessage,
    Duration bubbleDuration = const Duration(milliseconds: 1700),
  }) {
    _moodResetTimer?.cancel();
    _actionIntensity = actionIntensity;
    _setMood(mood, triggerRive: true);
    _actionController.forward(from: 0);

    if (bubbleMessage != null && bubbleMessage.isNotEmpty) {
      _showSpeechBubble(bubbleMessage, visibleFor: bubbleDuration);
    }

    if (mood != _MascotMood.sleep) {
      _moodResetTimer = Timer(const Duration(milliseconds: 1150), () {
        if (!mounted || _isHovering || _mood == _MascotMood.sleep) return;
        _setMood(_MascotMood.idle, triggerRive: false);
      });
    }
  }

  void _showSpeechBubble(
    String message, {
    Duration visibleFor = const Duration(milliseconds: 1700),
  }) {
    _bubbleTimer?.cancel();
    setState(() {
      _bubbleMessage = message.replaceAll('\n', ' ');
      _showBubble = true;
      _bubbleRevision += 1;
    });
    _bubbleTimer = Timer(visibleFor, () {
      if (!mounted) return;
      setState(() {
        _showBubble = false;
      });
    });
  }

  String _pickEncouragement(AppLanguage language) {
    final messages = language.mascotEncouragement;
    if (messages.isEmpty) {
      return _fallbackEncouragement(language);
    }
    return messages[_random.nextInt(messages.length)];
  }

  String _fallbackEncouragement(AppLanguage language) {
    switch (language) {
      case AppLanguage.vi:
        return 'On do, tiep tuc nhe!';
      case AppLanguage.ja:
        return 'Sono choshi!';
      case AppLanguage.en:
        return 'Nice pace, keep going!';
    }
  }

  String _sleepMessage(AppLanguage language) {
    switch (language) {
      case AppLanguage.vi:
        return 'Nghi mot nhip nhe...';
      case AppLanguage.ja:
        return 'Chotto hitoyasumi...';
      case AppLanguage.en:
        return 'Quick breather...';
    }
  }

  String _oopsMessage(AppLanguage language) {
    switch (language) {
      case AppLanguage.vi:
        return 'Oi, sua lai phat nao!';
      case AppLanguage.ja:
        return 'Otto, mou ikkai!';
      case AppLanguage.en:
        return 'Oops, let us fix that!';
    }
  }

  void _onTapMascot() {
    _lastInteraction = DateTime.now();
    final language = ref.read(appLanguageProvider);
    _triggerSparkles();
    _playMood(
      _MascotMood.celebrate,
      actionIntensity: 1.0,
      bubbleMessage: _pickEncouragement(language),
      bubbleDuration: const Duration(milliseconds: 1450),
    );
    _retargetLook();
    widget.onTap?.call();
  }

  void _triggerSparkles() {
    const count = 8;
    _sparkAngles = List<double>.generate(count, (index) {
      final base = (2 * pi * index) / count;
      return base + (_random.nextDouble() - 0.5) * 0.34;
    });
    _sparkDistances = List<double>.generate(
      count,
      (_) => 0.72 + _random.nextDouble() * 0.48,
    );
    _sparkSizes = List<double>.generate(
      count,
      (_) => 2.0 + _random.nextDouble() * 2.8,
    );
    _sparkleController.forward(from: 0);
  }

  void _onHoverChanged(bool hovering) {
    if (_isHovering == hovering) return;
    _isHovering = hovering;
    _lastInteraction = DateTime.now();
    _scheduleLookRetarget();

    if (hovering && _mood != _MascotMood.sleep) {
      final language = ref.read(appLanguageProvider);
      _playMood(
        _MascotMood.encourage,
        actionIntensity: 0.28,
        bubbleMessage: _pickEncouragement(language),
        bubbleDuration: const Duration(milliseconds: 1000),
      );
    } else if (_mood != _MascotMood.sleep) {
      _setMood(_MascotMood.idle, triggerRive: false);
    }

    _retargetLook();
    _pushRiveState(triggerMood: false);
  }

  void _retargetLook() {
    final sideBias = _isRightSide ? -0.42 : 0.42;
    final xJitter = (_random.nextDouble() - 0.5) * (_isHovering ? 0.62 : 1.02);
    final yJitter = (_random.nextDouble() - 0.5) * 0.62;
    final x = (sideBias + xJitter).clamp(-1.0, 1.0).toDouble();
    final y = (yJitter + (_isHovering ? -0.15 : 0.0))
        .clamp(-1.0, 1.0)
        .toDouble();

    setState(() {
      _lookTargetX = x;
      _lookTargetY = y;
    });
    _pushRiveState(triggerMood: false);

    _lagTimer?.cancel();
    _lagTimer = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() {
        _lagTargetX = x * 0.58;
        _lagTargetY = y * 0.58;
      });
    });
  }

  RiveWidgetController _createRiveController(File file) {
    const candidates = ['MascotSM', 'State Machine 1'];
    for (final name in candidates) {
      try {
        return RiveWidgetController(
          file,
          stateMachineSelector: StateMachineSelector.byName(name),
        );
      } catch (_) {
        // Try next candidate.
      }
    }
    return RiveWidgetController(file);
  }

  void _bindRiveController(RiveWidgetController controller) {
    if (identical(_riveController, controller)) return;
    _riveController = controller;
    final stateMachine = controller.stateMachine;

    _riveCelebrateInput = _firstTrigger(stateMachine, const [
      'celebrate',
      'success',
      'tap',
      'jump',
    ]);
    _riveEncourageInput = _firstTrigger(stateMachine, const [
      'encourage',
      'wave',
      'cheer',
    ]);
    _riveOopsInput = _firstTrigger(stateMachine, const ['oops', 'fail', 'sad']);
    _riveSleepInput = _firstBoolean(stateMachine, const [
      'sleep',
      'isSleeping',
      'idleSleep',
    ]);
    _riveHoverInput = _firstBoolean(stateMachine, const [
      'hover',
      'isHover',
      'isHovered',
    ]);
    _riveLookXInput = _firstNumber(stateMachine, const ['lookX', 'look_x']);
    _riveLookYInput = _firstNumber(stateMachine, const ['lookY', 'look_y']);

    _pushRiveState(triggerMood: false);
  }

  TriggerInput? _firstTrigger(StateMachine machine, List<String> names) {
    for (final name in names) {
      // ignore: deprecated_member_use
      final input = machine.trigger(name);
      if (input != null) return input;
    }
    return null;
  }

  BooleanInput? _firstBoolean(StateMachine machine, List<String> names) {
    for (final name in names) {
      // ignore: deprecated_member_use
      final input = machine.boolean(name);
      if (input != null) return input;
    }
    return null;
  }

  NumberInput? _firstNumber(StateMachine machine, List<String> names) {
    for (final name in names) {
      // ignore: deprecated_member_use
      final input = machine.number(name);
      if (input != null) return input;
    }
    return null;
  }

  void _pushRiveState({required bool triggerMood}) {
    _riveSleepInput?.value = _mood == _MascotMood.sleep;
    _riveHoverInput?.value = _isHovering;
    _riveLookXInput?.value = _lookTargetX;
    _riveLookYInput?.value = _lookTargetY;

    if (!triggerMood) return;

    switch (_mood) {
      case _MascotMood.celebrate:
        _riveCelebrateInput?.fire();
      case _MascotMood.encourage:
        _riveEncourageInput?.fire();
      case _MascotMood.oops:
        _riveOopsInput?.fire();
      case _MascotMood.idle:
      case _MascotMood.sleep:
        break;
    }
  }

  Widget _buildMascotArt() {
    if (!_riveChecked || !_hasRiveAsset) {
      return _buildFallbackFox();
    }
    final loader = _riveFileLoader;
    if (loader == null) {
      return _buildFallbackFox();
    }
    return RiveWidgetBuilder(
      fileLoader: loader,
      controller: _createRiveController,
      builder: (context, state) {
        if (state is RiveLoaded) {
          _bindRiveController(state.controller);
          return RiveWidget(controller: state.controller, fit: Fit.contain);
        }
        return _buildFallbackFox();
      },
    );
  }

  Widget _buildFallbackFox() {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 620),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(
            _lagTargetX * 5.2,
            _lagTargetY * 3.0,
            0,
          ),
          child: Opacity(
            opacity: 0.2,
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Color(0x66AFC4E7),
                BlendMode.srcATop,
              ),
              child: Image.asset(_foxAsset, fit: BoxFit.contain),
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(
            _lookTargetX * 3.4,
            _lookTargetY * 2.2,
            0,
          ),
          child: Image.asset(
            _foxAsset,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    _isRightSide = widget.nodePos.dx > width / 2;

    final mascotSize = width >= 1200
        ? 100.0
        : width >= 920
        ? 94.0
        : 86.0;
    final mascotX = _isRightSide
        ? widget.nodePos.dx - (mascotSize + 22)
        : widget.nodePos.dx + 42;
    final mascotY = widget.nodePos.dy - mascotSize * 0.36;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 440),
      curve: Curves.easeOutCubic,
      left: mascotX,
      top: mascotY,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: mascotSize,
            height: mascotSize,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => _onHoverChanged(true),
              onExit: (_) => _onHoverChanged(false),
              child: GestureDetector(
                onTap: _onTapMascot,
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _idleController,
                    _actionController,
                    _travelController,
                    _blinkController,
                    _sparkleController,
                  ]),
                  child: _buildMascotArt(),
                  builder: (context, child) {
                    final phase = _idleController.value * pi * 2;
                    final idleFloat = sin(phase) * 3.8;
                    final breathe = 1 + sin(phase + 0.7) * 0.018;
                    final blink = _blinkController.isAnimating
                        ? (1 - sin(_blinkController.value * pi) * 0.12)
                        : 1.0;
                    final swayBase = _isHovering ? 0.022 : 0.016;
                    final sway = sin(phase * 0.72) * swayBase;
                    final moodTilt = switch (_mood) {
                      _MascotMood.sleep => -0.04,
                      _MascotMood.oops => 0.05,
                      _MascotMood.encourage => -0.018,
                      _MascotMood.celebrate => 0.01,
                      _MascotMood.idle => 0.0,
                    };
                    final moodOffsetY = switch (_mood) {
                      _MascotMood.sleep => 2.2,
                      _MascotMood.oops => 1.0,
                      _MascotMood.encourage => -0.4,
                      _MascotMood.celebrate => -0.6,
                      _MascotMood.idle => 0.0,
                    };
                    final actionLift = _actionLift.value * _actionIntensity;
                    final travelLift = _travelLift.value;
                    final scaleX = _actionScaleX.value;
                    final scaleY = _actionScaleY.value;
                    final totalTilt =
                        sway +
                        moodTilt +
                        (_actionTilt.value * _actionIntensity);

                    return Transform.translate(
                      offset: Offset(
                        0,
                        idleFloat + actionLift + moodOffsetY + travelLift,
                      ),
                      child: Transform.rotate(
                        angle: totalTilt,
                        child: Transform.scale(
                          alignment: Alignment.bottomCenter,
                          scaleX: breathe * scaleX,
                          scaleY: breathe * scaleY * blink,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              if (child != null) child,
                              IgnorePointer(
                                child: CustomPaint(
                                  size: Size.square(mascotSize),
                                  painter: _SparkleBurstPainter(
                                    progress: _sparkleController.value,
                                    angles: _sparkAngles,
                                    distances: _sparkDistances,
                                    sizes: _sparkSizes,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            bottom: mascotSize + 3,
            left: _isRightSide ? -18 : -6,
            right: _isRightSide ? -6 : -18,
            child: IgnorePointer(
              child: _MascotSpeechBubble(
                visible: _showBubble,
                message: _bubbleMessage,
                revision: _bubbleRevision,
                isRightSide: _isRightSide,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MascotSpeechBubble extends StatelessWidget {
  const _MascotSpeechBubble({
    required this.visible,
    required this.message,
    required this.revision,
    required this.isRightSide,
  });

  final bool visible;
  final String message;
  final int revision;
  final bool isRightSide;

  @override
  Widget build(BuildContext context) {
    if (message.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 190),
      curve: Curves.easeOut,
      child: AnimatedScale(
        scale: visible ? 1 : 0.93,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        alignment: isRightSide ? Alignment.bottomRight : Alignment.bottomLeft,
        child: Align(
          alignment: isRightSide ? Alignment.bottomRight : Alignment.bottomLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 156),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.98),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE4EAF7)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1C1E293B),
                        blurRadius: 14,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.18),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      message,
                      key: ValueKey<int>(revision),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                        height: 1.22,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -5,
                  left: isRightSide ? null : 16,
                  right: isRightSide ? 16 : null,
                  child: Transform.rotate(
                    angle: pi / 4,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.98),
                        border: Border.all(color: const Color(0xFFE4EAF7)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SparkleBurstPainter extends CustomPainter {
  const _SparkleBurstPainter({
    required this.progress,
    required this.angles,
    required this.distances,
    required this.sizes,
  });

  final double progress;
  final List<double> angles;
  final List<double> distances;
  final List<double> sizes;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || angles.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final t = Curves.easeOutCubic.transform(progress.clamp(0.0, 1.0));
    final fade = (1 - progress).clamp(0.0, 1.0);

    final dotPaint = Paint()
      ..color = const Color(0xFFFFD43B).withValues(alpha: 0.9 * fade)
      ..style = PaintingStyle.fill;
    final ringPaint = Paint()
      ..color = const Color(0xFFFFA500).withValues(alpha: 0.52 * fade)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (var i = 0; i < angles.length; i++) {
      final angle = angles[i];
      final distance = (16 + (18 * distances[i])) * t;
      final point = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance - (4 * t),
      );
      final radius = sizes[i] * (0.85 + 0.25 * (1 - progress));

      canvas.drawCircle(point, radius, dotPaint);
      canvas.drawCircle(point, radius + 1.6, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkleBurstPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.angles != angles ||
        oldDelegate.distances != distances ||
        oldDelegate.sizes != sizes;
  }
}
