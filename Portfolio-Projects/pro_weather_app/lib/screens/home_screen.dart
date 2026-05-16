import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/stats_grid_widget.dart';
import '../widgets/hourly_chart_widget.dart';
import '../widgets/sunrise_sunset_widget.dart';
import '../widgets/weekly_forecast_widget.dart';
import '../widgets/ai_tip_widget.dart';
import '../widgets/loading_skeleton.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Floating orb animation controllers
  late AnimationController _orbController1;
  late AnimationController _orbController2;
  late AnimationController _orbController3;

  // Content stagger animation
  late AnimationController _staggerController;
  final List<Animation<double>> _fadeAnimations = [];
  final List<Animation<Offset>> _slideAnimations = [];

  static const int _sectionCount = 8;

  @override
  void initState() {
    super.initState();

    // Orb animations (slow floating loops)
    _orbController1 = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
    _orbController2 = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
    _orbController3 = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat(reverse: true);

    // Stagger animation for content sections
    _staggerController = AnimationController(
      duration: Duration(milliseconds: 300 + (_sectionCount * 60)),
      vsync: this,
    );

    for (int i = 0; i < _sectionCount; i++) {
      final startDelay = (i * 60) / (300 + (_sectionCount * 60));
      final endDelay =
          ((i * 60) + 300) / (300 + (_sectionCount * 60));

      _fadeAnimations.add(
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(startDelay.clamp(0, 1), endDelay.clamp(0, 1),
                curve: Curves.easeOut),
          ),
        ),
      );
      _slideAnimations.add(
        Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(startDelay.clamp(0, 1), endDelay.clamp(0, 1),
                curve: Curves.easeOut),
          ),
        ),
      );
    }

    // Load weather data — default city (Islamabad) directly
    // GPS is available on-demand via the location button
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WeatherProvider>();
      provider.loadDefault();
      _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _orbController1.dispose();
    _orbController2.dispose();
    _orbController3.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _replayStagger() {
    _staggerController.reset();
    _staggerController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        final weather = provider.weather;
        final hour = DateTime.now().hour;
        final weatherCode = weather?.weatherCode ?? 0;

        final gradient = AppTheme.getBackgroundGradient(weatherCode, hour);
        final accentColor = AppTheme.getAccentColor(weatherCode, hour);

        return Scaffold(
          backgroundColor: gradient.first,
          body: Stack(
            children: [
              // LAYER 1: Animated background
              _buildAnimatedBackground(gradient, accentColor),

              // LAYER 2: Content
              _buildContent(provider, accentColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground(List<Color> gradient, Color accentColor) {
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradient,
        ),
      ),
      child: Stack(
        children: [
          // Floating orb 1
          AnimatedBuilder(
            animation: _orbController1,
            builder: (context, _) {
              final t = Curves.easeInOut.transform(_orbController1.value);
              return Positioned(
                top: 80 + (t * 60),
                right: -40 + (t * 30),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: 0.08),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.06),
                        blurRadius: 80,
                        spreadRadius: 40,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Floating orb 2
          AnimatedBuilder(
            animation: _orbController2,
            builder: (context, _) {
              final t = Curves.easeInOut.transform(_orbController2.value);
              return Positioned(
                top: 300 + (t * 80),
                left: -60 + (t * 40),
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: 0.06),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.04),
                        blurRadius: 60,
                        spreadRadius: 30,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Floating orb 3
          AnimatedBuilder(
            animation: _orbController3,
            builder: (context, _) {
              final t = Curves.easeInOut.transform(_orbController3.value);
              return Positioned(
                bottom: 200 + (t * 50),
                right: 20 + (t * 60),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: 0.05),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.03),
                        blurRadius: 50,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(WeatherProvider provider, Color accentColor) {
    if (provider.status == WeatherStatus.loading && provider.weather == null) {
      return const LoadingSkeleton();
    }

    if (provider.status == WeatherStatus.error && provider.weather == null) {
      return _buildErrorView(provider, accentColor);
    }

    return RefreshIndicator(
      color: accentColor,
      backgroundColor: const Color(0xFF1E293B),
      onRefresh: () async {
        await provider.refresh();
        _replayStagger();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // ── Top Bar ──
                  _buildTopBar(provider, accentColor),
                  const SizedBox(height: 8),

                  // ── Section A: Hero Card ──
                  _animatedSection(0, CurrentWeatherCard(accentColor: accentColor)),
                  const SizedBox(height: 32),

                  // ── Section B: Stats Grid ──
                  _animatedSection(1, StatsGridWidget(accentColor: accentColor)),
                  const SizedBox(height: 16),

                  // ── Section C: UV Index ──
                  _animatedSection(2, UvIndexCard(accentColor: accentColor)),
                  const SizedBox(height: 24),

                  // ── Section D: Hourly Chart ──
                  _animatedSection(3, HourlyChartWidget(accentColor: accentColor)),
                  const SizedBox(height: 24),

                  // ── Section E: Sunrise & Sunset ──
                  _animatedSection(4, SunriseSunsetWidget(accentColor: accentColor)),
                  const SizedBox(height: 24),

                  // ── Section F: 7-Day Forecast ──
                  _animatedSection(5, WeeklyForecastWidget(accentColor: accentColor)),
                  const SizedBox(height: 24),

                  // ── Section G: AI Tip ──
                  _animatedSection(6, AiTipWidget(accentColor: accentColor)),
                  const SizedBox(height: 24),

                  // ── Section H: Footer ──
                  _animatedSection(
                    7,
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Text(
                        'Data: Open-Meteo.com',
                        style: AppTheme.label(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _animatedSection(int index, Widget child) {
    if (index >= _fadeAnimations.length) return child;
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: child,
      ),
    );
  }

  Widget _buildTopBar(WeatherProvider provider, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Search button
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (c1, a1, a2) => const SearchScreen(),
                  transitionsBuilder: (c2, anim, a3, child) {
                    return FadeTransition(opacity: anim, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
            icon: const Icon(Icons.search, color: AppTheme.textPrimary, size: 24),
          ),

          // City name + country
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on,
                        color: accentColor, size: 16),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        provider.cityName,
                        style: AppTheme.cityName(),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                if (provider.country.isNotEmpty)
                  Text(
                    provider.country,
                    style: AppTheme.label(),
                  ),
              ],
            ),
          ),

          // GPS + Settings
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  await provider.useGps();
                  _replayStagger();
                },
                icon: const Icon(Icons.my_location,
                    color: AppTheme.textPrimary, size: 22),
              ),
              IconButton(
                onPressed: () => _showSettingsSheet(provider, accentColor),
                icon: const Icon(Icons.tune,
                    color: AppTheme.textPrimary, size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(WeatherProvider provider, Color accentColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, color: AppTheme.textSecondary, size: 64),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: AppTheme.heading(),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage,
              style: AppTheme.subtitle(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                provider.loadDefault();
                _replayStagger();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet(WeatherProvider provider, Color accentColor) {
    final apiKeyController = TextEditingController(text: provider.apiKey);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: AppTheme.cardBorder),
              left: BorderSide(color: AppTheme.cardBorder),
              right: BorderSide(color: AppTheme.cardBorder),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text('Settings', style: AppTheme.heading()),
              const SizedBox(height: 24),

              // Unit toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.glassCard(borderRadius: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Temperature Unit', style: AppTheme.body()),
                    Consumer<WeatherProvider>(
                      builder: (context, p, _) {
                        return GestureDetector(
                          onTap: () => p.toggleUnit(),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: accentColor.withValues(alpha: 0.3)),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                p.isCelsius ? '°C' : '°F',
                                key: ValueKey(p.isCelsius),
                                style: AppTheme.dataNumber(color: accentColor),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // API Key
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.glassCard(borderRadius: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Claude API Key', style: AppTheme.body()),
                    const SizedBox(height: 4),
                    Text(
                      'Get free key at console.anthropic.com',
                      style: AppTheme.label(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: apiKeyController,
                      obscureText: true,
                      style: AppTheme.body(),
                      cursorColor: accentColor,
                      decoration: InputDecoration(
                        hintText: 'sk-ant-...',
                        hintStyle: AppTheme.subtitle(),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) {
                        provider.setApiKey(value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // App info
              Center(
                child: Column(
                  children: [
                    Text(
                      'Aurora Weather v1.0',
                      style: AppTheme.subtitle(color: accentColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Data by Open-Meteo  •  AI by Anthropic Claude',
                      style: AppTheme.label(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
