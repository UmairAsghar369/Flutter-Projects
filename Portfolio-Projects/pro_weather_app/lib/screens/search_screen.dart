import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../services/geocoding_service.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final GeocodingService _geocodingService = GeocodingService();
  List<GeocodingResult> _results = [];
  bool _isSearching = false;
  String _errorMsg = '';
  Timer? _debounce;

  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _search(query);
    });
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _errorMsg = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMsg = '';
    });

    try {
      final results = await _geocodingService.searchCity(query);
      setState(() {
        _results = results;
        _isSearching = false;
        if (results.isEmpty) {
          _errorMsg = 'City not found. Try another name.';
        }
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _errorMsg = 'Search failed. Check your connection.';
      });
    }
  }

  void _selectResult(GeocodingResult result) {
    final provider = context.read<WeatherProvider>();
    provider.fetchWeatherByCoords(
      result.lat,
      result.lon,
      result.city,
      result.country,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = AppTheme.accentCold;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: FadeTransition(
        opacity: _fadeIn,
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios,
                          color: AppTheme.textPrimary, size: 20),
                    ),
                    Expanded(
                      child: Container(
                        decoration: AppTheme.glassCard(borderRadius: 16),
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          style: AppTheme.body(),
                          cursorColor: accentColor,
                          decoration: InputDecoration(
                            hintText: 'Search for any city worldwide...',
                            hintStyle: AppTheme.subtitle(),
                            prefixIcon: Icon(Icons.search,
                                color: AppTheme.textSecondary, size: 20),
                            suffixIcon: _controller.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _controller.clear();
                                      setState(() {
                                        _results = [];
                                        _errorMsg = '';
                                      });
                                    },
                                    icon: const Icon(Icons.close,
                                        color: AppTheme.textSecondary,
                                        size: 18),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                          onChanged: _onSearchChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Results
              Expanded(
                child: _buildContent(accentColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color accentColor) {
    if (_isSearching) {
      return Center(
        child: CircularProgressIndicator(color: accentColor, strokeWidth: 2),
      );
    }

    if (_errorMsg.isNotEmpty && _results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off,
                color: AppTheme.textSecondary, size: 48),
            const SizedBox(height: 12),
            Text(_errorMsg, style: AppTheme.subtitle()),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Search for any city worldwide',
              style: AppTheme.subtitle(),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _selectResult(result),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.glassCard(borderRadius: 16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.location_on,
                          color: accentColor, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.city,
                            style: AppTheme.body(color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            [
                              if (result.state != null) result.state!,
                              result.country,
                            ].join(', '),
                            style: AppTheme.label(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        color: AppTheme.textSecondary, size: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
