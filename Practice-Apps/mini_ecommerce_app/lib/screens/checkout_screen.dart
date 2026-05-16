import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

/// Checkout screen — order summary, animated success, back-to-home.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  bool _orderPlaced = false;
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _placeOrder(CartProvider cart) {
    setState(() => _orderPlaced = true);
    _animCtrl.forward();
    cart.clearCart();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Checkout',
            style: GoogleFonts.playfairDisplay(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: _orderPlaced ? _buildSuccess() : _buildSummary(cart),
    );
  }

  Widget _buildSummary(CartProvider cart) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            itemCount: cart.items.length,
            separatorBuilder: (_, _) => Divider(color: Colors.white.withValues(alpha: 0.07)),
            itemBuilder: (ctx, i) {
              final ci = cart.items[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(ci.product.imageUrl,
                        width: 50, height: 50, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ci.product.name,
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                          Text('x${ci.quantity}',
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54)),
                        ]),
                  ),
                  Text('\$${ci.lineTotal.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFF5A623))),
                ]),
              );
            },
          ),
        ),
        // Total + place order
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Order Total',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70)),
                Text('\$${cart.totalPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                        fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFFF5A623))),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  onPressed: () => _placeOrder(cart),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5A623),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Place Order',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  /// Animated success state after order placement.
  Widget _buildSuccess() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  colors: [const Color(0xFFF5A623), const Color(0xFFE08E0B)]),
              boxShadow: [
                BoxShadow(color: const Color(0xFFF5A623).withValues(alpha: 0.3),
                    blurRadius: 30, spreadRadius: 4),
              ],
            ),
            child: const Icon(Icons.check_rounded, size: 52, color: Colors.black),
          ),
        ),
        const SizedBox(height: 28),
        Text('Order Placed!',
            style: GoogleFonts.playfairDisplay(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        Text('Thank you for shopping with LUXE.',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white54)),
        const SizedBox(height: 36),
        ElevatedButton(
          onPressed: () =>
              Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF5A623),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text('Back to Home',
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }
}
