import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const DiceGuessApp());

// ══════════════════════════════════════════════════════════════
//  APP ROOT
// ══════════════════════════════════════════════════════════════
class DiceGuessApp extends StatelessWidget {
  const DiceGuessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dice Guess',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D1C),
      ),
      home: const DiceGameScreen(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  GAME STATE ENUM
// ══════════════════════════════════════════════════════════════
enum GameState { idle, rolling, win, lose }

// ══════════════════════════════════════════════════════════════
//  MAIN GAME SCREEN
// ══════════════════════════════════════════════════════════════
class DiceGameScreen extends StatefulWidget {
  const DiceGameScreen({super.key});

  @override
  State<DiceGameScreen> createState() => _DiceGameScreenState();
}

class _DiceGameScreenState extends State<DiceGameScreen>
    with TickerProviderStateMixin {

  // ── Game Logic State ──
  int _diceValue  = 1;
  int _userGuess  = 1;
  int _wins       = 0;
  int _attempts   = 0;
  GameState _state = GameState.idle;

  final Random _rng = Random();

  // ── 3-D Rotation Controllers ──
  late AnimationController _rollCtrl;   // drives the tumble
  late Animation<double>   _rotX;
  late Animation<double>   _rotY;
  late Animation<double>   _rotZ;

  // ── Idle "breathing" float ──
  late AnimationController _idleCtrl;
  late Animation<double>   _idleFloat;

  // ── Scale pulse on result ──
  late AnimationController _pulseCtrl;
  late Animation<double>   _pulse;

  // ── Glow intensity ──
  late AnimationController _glowCtrl;
  late Animation<double>   _glow;

  // ── Resting angles (updated each roll) ──
  double _restX = -0.3;
  double _restY =  0.5;

  @override
  void initState() {
    super.initState();

    // ── Roll: 1.4 s tumble ──
    _rollCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _rotX = Tween<double>(begin: 0, end: 6 * pi)
        .animate(CurvedAnimation(parent: _rollCtrl, curve: Curves.easeInOutBack));
    _rotY = Tween<double>(begin: 0, end: 5 * pi)
        .animate(CurvedAnimation(parent: _rollCtrl, curve: Curves.easeInOut));
    _rotZ = Tween<double>(begin: 0, end: 2 * pi)
        .animate(CurvedAnimation(parent: _rollCtrl, curve: Curves.easeIn));

    // ── Idle float ──
    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _idleFloat = Tween<double>(begin: -6, end: 6)
        .animate(CurvedAnimation(parent: _idleCtrl, curve: Curves.easeInOut));

    // ── Pulse ──
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pulse = Tween<double>(begin: 1, end: 1.12)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));

    // ── Glow ──
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _glow = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _rollCtrl.dispose();
    _idleCtrl.dispose();
    _pulseCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  //  ROLL LOGIC
  // ══════════════════════════════════════════════════════════════
  Future<void> _roll() async {
    if (_state == GameState.rolling) return;

    setState(() => _state = GameState.rolling);
    _glowCtrl.reset();
    _pulseCtrl.reset();

    // Animate the 3-D tumble
    _rollCtrl.reset();
    _rollCtrl.forward();

    // Flash random dice faces while rolling
    for (int i = 0; i < 12; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      setState(() => _diceValue = _rng.nextInt(6) + 1);
    }

    // Final result
    final int result = _rng.nextInt(6) + 1;
    final bool isWin  = result == _userGuess;

    // Pick a nice resting angle so the dice looks tilted differently every time
    _restX = -0.25 + _rng.nextDouble() * 0.3;
    _restY =  0.3  + _rng.nextDouble() * 0.5;

    setState(() {
      _diceValue = result;
      _attempts++;
      if (isWin) _wins++;
      _state = isWin ? GameState.win : GameState.lose;
    });

    _pulseCtrl.forward();
    _glowCtrl.forward();

    // Auto-reset after 2 s
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _state = GameState.idle);
      _glowCtrl.reverse();
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diceSize = (size.width * 0.38).clamp(130.0, 200.0);

    return Scaffold(
      body: Stack(
        children: [
          // ── Ambient background gradients ──
          _buildBackground(),

          // ── Main content ──
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                _buildHeader(),
                const Spacer(),
                _buildDice(diceSize),
                const SizedBox(height: 18),
                _buildResultMessage(),
                const Spacer(),
                _buildGuessPicker(),
                const SizedBox(height: 28),
                _buildRollButton(),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Background
  // ─────────────────────────────────────────────
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.6, -0.8),
          radius: 1.4,
          colors: [Color(0xFF1A1040), Color(0xFF0D0D1C)],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Header
  // ─────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFF8B7FFF), Color(0xFFFF7EB3)],
            ).createShader(b),
            child: const Text(
              'DICE  GUESS',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: Colors.white,
              ),
            ),
          ),
          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E40),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFF8B7FFF).withOpacity(.4)),
            ),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                children: [
                  TextSpan(
                    text: '$_wins',
                    style: const TextStyle(
                      color: Color(0xFF00E5A0),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const TextSpan(
                    text: ' / ',
                    style: TextStyle(color: Colors.white38),
                  ),
                  TextSpan(
                    text: '$_attempts',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  3-D Dice
  // ─────────────────────────────────────────────
  Widget _buildDice(double size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rollCtrl, _idleCtrl, _pulseCtrl, _glowCtrl]),
      builder: (context, _) {
        // While rolling: use tumble angles; otherwise use resting angles + idle float
        final bool isRolling = _rollCtrl.isAnimating;

        final double rx = isRolling ? _rotX.value : _restX;
        final double ry = isRolling ? _rotY.value : _restY;
        final double rz = isRolling ? _rotZ.value : 0.0;

        // Glow color
        final Color glowColor = _state == GameState.win
            ? const Color(0xFF00E5A0)
            : _state == GameState.lose
            ? const Color(0xFFFF4D6D)
            : const Color(0xFF8B7FFF);

        return Transform.translate(
          // idle float
          offset: Offset(0, isRolling ? 0 : _idleFloat.value),
          child: Transform.scale(
            scale: _pulse.value,
            child: Container(
              width: size + 40,
              height: size + 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withOpacity(_glow.value * 0.55),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: _Dice3D(
                  value: _diceValue,
                  size: size,
                  rotX: rx,
                  rotY: ry,
                  rotZ: rz,
                  gameState: _state,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  //  Result Message
  // ─────────────────────────────────────────────
  Widget _buildResultMessage() {
    final config = switch (_state) {
      GameState.win     => ('🎉  You nailed it!',     const Color(0xFF00E5A0)),
      GameState.lose    => ('😅  It was $_diceValue — try again!', const Color(0xFFFF4D6D)),
      GameState.rolling => ('🎲  Rolling...',          const Color(0xFF8B7FFF)),
      GameState.idle    => ('👆  Pick a number & roll!', const Color(0xFF606090)),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        config.$1,
        key: ValueKey(_state),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: config.$2,
          letterSpacing: .5,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Guess Picker
  // ─────────────────────────────────────────────
  Widget _buildGuessPicker() {
    return Column(
      children: [
        const Text(
          'YOUR GUESS',
          style: TextStyle(
            color: Color(0xFF505080),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            final int n = i + 1;
            final bool active = _userGuess == n;
            return GestureDetector(
              onTap: _state == GameState.rolling
                  ? null
                  : () => setState(() => _userGuess = n),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: active
                      ? const LinearGradient(
                    colors: [Color(0xFF8B7FFF), Color(0xFFFF7EB3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : null,
                  color: active ? null : const Color(0xFF1E1E38),
                  border: Border.all(
                    color: active
                        ? Colors.transparent
                        : const Color(0xFF8B7FFF).withOpacity(.25),
                    width: 1.5,
                  ),
                  boxShadow: active
                      ? [
                    BoxShadow(
                      color: const Color(0xFF8B7FFF).withOpacity(.4),
                      blurRadius: 14,
                      spreadRadius: 1,
                    )
                  ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$n',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: active ? Colors.white : const Color(0xFF606090),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  Roll Button
  // ─────────────────────────────────────────────
  Widget _buildRollButton() {
    final bool disabled = _state != GameState.idle;

    return GestureDetector(
      onTap: disabled ? null : _roll,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 230,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: disabled
              ? null
              : const LinearGradient(
            colors: [Color(0xFF8B7FFF), Color(0xFFFF7EB3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          color: disabled ? const Color(0xFF1E1E38) : null,
          boxShadow: disabled
              ? null
              : [
            BoxShadow(
              color: const Color(0xFF8B7FFF).withOpacity(.45),
              blurRadius: 22,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            disabled ? 'Wait...' : '🎲  ROLL DICE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: disabled ? const Color(0xFF404060) : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  3-D DICE WIDGET  (CSS-style 6-face cube via Transform stack)
// ══════════════════════════════════════════════════════════════
class _Dice3D extends StatelessWidget {
  final int   value;
  final double size;
  final double rotX, rotY, rotZ;
  final GameState gameState;

  const _Dice3D({
    required this.value,
    required this.size,
    required this.rotX,
    required this.rotY,
    required this.rotZ,
    required this.gameState,
  });

  // Face colors: top-lit feel
  static const Map<String, Color> _faceColors = {
    'front':  Color(0xFF252550),
    'back':   Color(0xFF18183A),
    'left':   Color(0xFF1E1E45),
    'right':  Color(0xFF2C2C58),
    'top':    Color(0xFF32326A),
    'bottom': Color(0xFF141430),
  };

  @override
  Widget build(BuildContext context) {
    final double half = size / 2;

    // State-based accent color
    final Color accent = gameState == GameState.win
        ? const Color(0xFF00E5A0)
        : gameState == GameState.lose
        ? const Color(0xFFFF4D6D)
        : const Color(0xFF8B7FFF);

    // We simulate 3-D perspective using a Transform.
    // Flutter doesn't have a true CSS preserve-3d context, so we paint
    // the six faces layered with 3D matrix transforms to give the cube illusion.
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0012)   // perspective
        ..rotateX(rotX)
        ..rotateY(rotY)
        ..rotateZ(rotZ),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            // Bottom
            _buildFace(
              'bottom', size, half, accent,
              Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateX(pi / 2)
                ..translate(0.0, 0.0, -half),
              value: 5,
            ),
            // Back
            _buildFace(
              'back', size, half, accent,
              Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY(pi)
                ..translate(0.0, 0.0, -half),
              value: 6,
            ),
            // Left
            _buildFace(
              'left', size, half, accent,
              Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY(-pi / 2)
                ..translate(0.0, 0.0, -half),
              value: 4,
            ),
            // Right
            _buildFace(
              'right', size, half, accent,
              Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY(pi / 2)
                ..translate(0.0, 0.0, -half),
              value: 3,
            ),
            // Top
            _buildFace(
              'top', size, half, accent,
              Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateX(-pi / 2)
                ..translate(0.0, 0.0, -half),
              value: 2,
            ),
            // Front — shows the result
            _buildFace(
              'front', size, half, accent,
              Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..translate(0.0, 0.0, half),
              value: value,
              isFront: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFace(
      String face,
      double size,
      double half,
      Color accent,
      Matrix4 transform, {
        required int value,
        bool isFront = false,
      }) {
    final Color faceColor = isFront && gameState == GameState.win
        ? const Color(0xFF0A2E20)
        : isFront && gameState == GameState.lose
        ? const Color(0xFF2E0A14)
        : _faceColors[face]!;

    return Transform(
      alignment: Alignment.center,
      transform: transform,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: faceColor,
          borderRadius: BorderRadius.circular(size * 0.14),
          border: Border.all(
            color: isFront
                ? accent.withOpacity(.6)
                : Colors.white.withOpacity(.06),
            width: isFront ? 2 : 1,
          ),
          boxShadow: isFront
              ? [
            BoxShadow(
              color: accent.withOpacity(.3),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ]
              : null,
        ),
        child: _DiceDots(value: value, color: accent, size: size),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  DICE DOTS  (CustomPainter with 3-D sphere-like dots)
// ══════════════════════════════════════════════════════════════
class _DiceDots extends StatelessWidget {
  final int   value;
  final Color color;
  final double size;

  const _DiceDots({
    required this.value,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DotsPainter(value: value, color: color),
    );
  }
}

class _DotsPainter extends CustomPainter {
  final int   value;
  final Color color;

  _DotsPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double r   = size.width * 0.088;  // dot radius
    final double w   = size.width;
    final double h   = size.height;
    final double p   = w * 0.23;            // padding from edge

    // All 9 possible positions
    final positions = {
      'tl': Offset(p,       p),
      'tc': Offset(w / 2,   p),
      'tr': Offset(w - p,   p),
      'ml': Offset(p,       h / 2),
      'mc': Offset(w / 2,   h / 2),
      'mr': Offset(w - p,   h / 2),
      'bl': Offset(p,       h - p),
      'bc': Offset(w / 2,   h - p),
      'br': Offset(w - p,   h - p),
    };

    // Which dots are shown per value
    const layout = {
      1: ['mc'],
      2: ['tr', 'bl'],
      3: ['tr', 'mc', 'bl'],
      4: ['tl', 'tr', 'bl', 'br'],
      5: ['tl', 'tr', 'mc', 'bl', 'br'],
      6: ['tl', 'tr', 'ml', 'mr', 'bl', 'br'],
    };

    final keys = layout[value] ?? [];

    for (final key in keys) {
      final Offset center = positions[key]!;

      // Outer dot — base color
      final basePaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.35),
          colors: [Colors.white.withOpacity(.95), color],
        ).createShader(Rect.fromCircle(center: center, radius: r));

      canvas.drawCircle(center, r, basePaint);

      // Inner highlight — makes it look like a sphere
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

      canvas.drawCircle(
        center.translate(-r * 0.28, -r * 0.28),
        r * 0.32,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) =>
      old.value != value || old.color != color;
}
