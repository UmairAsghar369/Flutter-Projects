import '../models/product.dart';

/// Static dummy product data — 8 products across Electronics & Fashion.
final List<Product> dummyProducts = [
  // ── Electronics ──
  const Product(
    id: 'e1',
    name: 'Wireless Headphones',
    price: 129.99,
    description:
        'Premium noise-cancelling wireless headphones with 30-hour battery life, '
        'deep bass, and ultra-comfortable memory foam ear cushions.',
    imageUrl:
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&q=80&fit=crop',
    category: 'Electronics',
  ),
  const Product(
    id: 'e2',
    name: 'Smart Watch Pro',
    price: 249.99,
    description:
        'Next-gen smartwatch with AMOLED display, heart-rate monitoring, '
        'GPS tracking, and 7-day battery life.',
    imageUrl:
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&q=80&fit=crop',
    category: 'Electronics',
  ),
  const Product(
    id: 'e3',
    name: 'Bluetooth Speaker',
    price: 79.99,
    description:
        'Portable waterproof Bluetooth speaker with 360° surround sound '
        'and 12-hour playtime. Perfect for outdoor adventures.',
    imageUrl:
        'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400&q=80&fit=crop',
    category: 'Electronics',
  ),
  const Product(
    id: 'e4',
    name: 'Mechanical Keyboard',
    price: 159.99,
    description:
        'RGB mechanical gaming keyboard with hot-swappable switches, '
        'aircraft-grade aluminum frame, and per-key lighting.',
    imageUrl:
        'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=400&q=80&fit=crop',
    category: 'Electronics',
  ),

  // ── Fashion ──
  const Product(
    id: 'f1',
    name: 'Leather Backpack',
    price: 189.99,
    description:
        'Handcrafted genuine leather backpack with padded laptop compartment, '
        'antique brass hardware, and adjustable straps.',
    imageUrl:
        'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&q=80&fit=crop',
    category: 'Fashion',
  ),
  const Product(
    id: 'f2',
    name: 'Designer Sunglasses',
    price: 99.99,
    description:
        'Polarized UV400 designer sunglasses with titanium frame '
        'and gradient lenses. Includes premium carrying case.',
    imageUrl:
        'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=400&q=80&fit=crop',
    category: 'Fashion',
  ),
  const Product(
    id: 'f3',
    name: 'Classic Sneakers',
    price: 139.99,
    description:
        'Minimalist premium leather sneakers with cushioned insole, '
        'hand-stitched detailing, and non-slip rubber sole.',
    imageUrl:
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&q=80&fit=crop',
    category: 'Fashion',
  ),
  const Product(
    id: 'f4',
    name: 'Luxury Wrist Watch',
    price: 349.99,
    description:
        'Swiss-movement luxury wristwatch with sapphire crystal glass, '
        'genuine crocodile leather strap, and luminous hands.',
    imageUrl:
        'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=400&q=80&fit=crop',
    category: 'Fashion',
  ),
];

