import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'screens/product_list_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';

void main() {
  runApp(
    // Wrap the entire app with the cart state provider
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: const BestShopApp(),
    ),);
}

/// Root widget — dark luxury theme with named routes.
class BestShopApp extends StatelessWidget {
  const BestShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Best Shop',
      debugShowCheckedModeBanner: false,
      // ── Dark luxury theme ──
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF5A623),
          surface: Color(0xFF1A1A2E),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D0D0D),
          elevation: 0,
        ),
      ),
      initialRoute: '/home',
      // ── Named routes with custom transitions ──
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(
                builder: (_) => const ProductListScreen());
          case '/details':
            return MaterialPageRoute(
                builder: (_) => const ProductDetailsScreen(),
                settings: settings); // pass arguments through
          case '/cart':
            // Slide-up entrance for the cart screen
            return _slideUpRoute(const CartScreen(), settings);
          case '/checkout':
            return _slideUpRoute(const CheckoutScreen(), settings);
          default:
            return MaterialPageRoute(
                builder: (_) => const ProductListScreen());
        }
      },
    );
  }

  /// Custom PageRouteBuilder with a slide-up + fade transition.
  static Route _slideUpRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        final tween = Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}
