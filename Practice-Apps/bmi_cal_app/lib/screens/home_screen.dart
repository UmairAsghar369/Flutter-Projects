import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/bmi_history.dart';
import '../widgets/glass_card.dart';
import '../widgets/gender_selector.dart';
import 'result_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  // State
  bool _isMetric = true;
  String _gender = 'Male';

  // Metric values
  double _weightKg = 70;
  double _heightCm = 170;

  // Imperial values
  double _weightLbs = 154;
  double _heightFt = 5;
  double _heightIn = 7;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  double get _currentBMI {
    if (_isMetric) {
      final heightM = _heightCm / 100;
      if (heightM <= 0) return 0;
      return _weightKg / (heightM * heightM);
    } else {
      final totalInches = (_heightFt * 12) + _heightIn;
      if (totalInches <= 0) return 0;
      return (_weightLbs * 703) / (totalInches * totalInches);
    }
  }

  void _calculateBMI() {
    final bmi = _currentBMI;
    if (bmi <= 0 || bmi.isNaN || bmi.isInfinite) return;

    final category = BMICategory.fromBMI(bmi);
    final record = BMIRecord(
      bmi: bmi,
      category: category.label,
      date: DateTime.now().toIso8601String(),
      weight: _isMetric ? _weightKg : _weightLbs,
      height: _isMetric ? _heightCm : (_heightFt * 12 + _heightIn),
      isMetric: _isMetric,
      gender: _gender,
    );

    BMIHistory.addRecord(record);

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, a, b) => ResultScreen(bmi: bmi, record: record),
        transitionsBuilder: (_, animation, a, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bmiPreview = _currentBMI;
    final previewValid =
        bmiPreview > 0 && !bmiPreview.isNaN && !bmiPreview.isInfinite;
    final previewCategory =
        previewValid ? BMICategory.fromBMI(bmiPreview) : null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // BMI Live Preview
                        if (previewValid)
                          _buildLivePreview(bmiPreview, previewCategory!),

                        const SizedBox(height: 20),

                        // Unit Toggle
                        _buildUnitToggle(),

                        const SizedBox(height: 20),

                        // Gender Selector
                        _buildSectionLabel('Gender'),
                        const SizedBox(height: 10),
                        GenderSelector(
                          selectedGender: _gender,
                          onChanged: (g) => setState(() => _gender = g),
                        ),

                        const SizedBox(height: 24),

                        // Height Slider
                        _buildSectionLabel(_isMetric ? 'Height (cm)' : 'Height'),
                        const SizedBox(height: 8),
                        _buildHeightSlider(),

                        const SizedBox(height: 24),

                        // Weight Slider
                        _buildSectionLabel(
                            _isMetric ? 'Weight (kg)' : 'Weight (lbs)'),
                        const SizedBox(height: 8),
                        _buildWeightSlider(),

                        const SizedBox(height: 32),

                        // Calculate Button
                        _buildCalculateButton(),

                        const SizedBox(height: 24),
                      ],
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPurple.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.monitor_weight_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BMI Calculator',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Track your health journey',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500),
                pageBuilder: (_, a, b) => const HistoryScreen(),
                transitionsBuilder: (_, animation, a, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  );
                },
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(Icons.history_rounded,
                  color: AppColors.textSecondary, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivePreview(double bmi, BMICategory category) {
    return Hero(
      tag: 'bmi_result',
      child: Material(
        color: Colors.transparent,
        child: GlassCard(
          borderColor: category.color.withValues(alpha: 0.3),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      category.color.withValues(alpha: 0.3),
                      category.color.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Live Preview',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: category.color,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      category.color.withValues(alpha: 0.25),
                      category.color.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  bmi.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: category.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitToggle() {
    return GlassCard(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isMetric = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: _isMetric ? AppColors.primaryGradient : null,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: _isMetric
                      ? [
                          BoxShadow(
                            color:
                                AppColors.accentPurple.withValues(alpha: 0.3),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Metric',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          _isMetric ? FontWeight.w700 : FontWeight.w500,
                      color: _isMetric
                          ? Colors.white
                          : AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isMetric = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: !_isMetric ? AppColors.primaryGradient : null,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: !_isMetric
                      ? [
                          BoxShadow(
                            color:
                                AppColors.accentPurple.withValues(alpha: 0.3),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Imperial',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          !_isMetric ? FontWeight.w700 : FontWeight.w500,
                      color: !_isMetric
                          ? Colors.white
                          : AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildHeightSlider() {
    if (_isMetric) {
      return _buildSliderCard(
        value: _heightCm,
        min: 100,
        max: 250,
        displayValue: '${_heightCm.round()} cm',
        icon: Icons.height_rounded,
        onChanged: (v) => setState(() => _heightCm = v),
        activeColor: AppColors.accentCyan,
      );
    } else {
      return Column(
        children: [
          _buildSliderCard(
            value: _heightFt,
            min: 3,
            max: 8,
            displayValue: '${_heightFt.round()} ft',
            icon: Icons.height_rounded,
            onChanged: (v) => setState(() => _heightFt = v.roundToDouble()),
            activeColor: AppColors.accentCyan,
            divisions: 5,
          ),
          const SizedBox(height: 10),
          _buildSliderCard(
            value: _heightIn,
            min: 0,
            max: 11,
            displayValue: '${_heightIn.round()} in',
            icon: Icons.straighten_rounded,
            onChanged: (v) => setState(() => _heightIn = v.roundToDouble()),
            activeColor: AppColors.accentCyan,
            divisions: 11,
          ),
        ],
      );
    }
  }

  Widget _buildWeightSlider() {
    if (_isMetric) {
      return _buildSliderCard(
        value: _weightKg,
        min: 30,
        max: 200,
        displayValue: '${_weightKg.round()} kg',
        icon: Icons.fitness_center_rounded,
        onChanged: (v) => setState(() => _weightKg = v),
        activeColor: AppColors.accentPurple,
      );
    } else {
      return _buildSliderCard(
        value: _weightLbs,
        min: 66,
        max: 440,
        displayValue: '${_weightLbs.round()} lbs',
        icon: Icons.fitness_center_rounded,
        onChanged: (v) => setState(() => _weightLbs = v),
        activeColor: AppColors.accentPurple,
      );
    }
  }

  Widget _buildSliderCard({
    required double value,
    required double min,
    required double max,
    required String displayValue,
    required IconData icon,
    required ValueChanged<double> onChanged,
    required Color activeColor,
    int? divisions,
  }) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: activeColor, size: 20),
              const SizedBox(width: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  displayValue,
                  key: ValueKey(displayValue),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: activeColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: activeColor,
              inactiveTrackColor: AppColors.sliderInactive,
              thumbColor: activeColor,
              overlayColor: activeColor.withValues(alpha: 0.15),
              trackHeight: 6,
              thumbShape: _CustomThumbShape(activeColor),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  min.round().toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                Text(
                  max.round().toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton() {
    return GestureDetector(
      onTap: _calculateBMI,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPurple.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calculate_rounded, color: Colors.white, size: 24),
            SizedBox(width: 10),
            Text(
              'CALCULATE BMI',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  final Color color;

  _CustomThumbShape(this.color);

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size(24, 24);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, 14, glowPaint);

    // White border
    canvas.drawCircle(center, 11, Paint()..color = Colors.white);

    // Inner color
    canvas.drawCircle(center, 8, Paint()..color = color);
  }
}
