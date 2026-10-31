import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const TiendaCubaApp());
}

// ═══════════════════════════════════════════════════════════
// APP
// ═══════════════════════════════════════════════════════════

class TiendaCubaApp extends StatelessWidget {
  const TiendaCubaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tienda Cuba',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1A2E),
          primary: const Color(0xFF1A1A2E),
          secondary: const Color(0xFFE94560),
          surface: const Color(0xFFF8F9FC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F2F8),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Color(0xFF1A1A2E),
          foregroundColor: Colors.white,
        ),
      ),
      home: const MainShell(),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// MODELOS
// ═══════════════════════════════════════════════════════════

enum ProductType { app, game, painting, sculpture, craft }

class Product {
  final String id;
  final String name;
  final String subtitle;
  final String description;
  final ProductType type;
  final double priceCUP;
  final double priceMLC;
  final double priceUSDT;
  final Color accent;
  final IconData icon;
  final String badge;
  final double rating;

  const Product({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.type,
    required this.priceCUP,
    required this.priceMLC,
    required this.priceUSDT,
    required this.accent,
    required this.icon,
    this.badge = '',
    this.rating = 4.8,
  });

  String get typeLabel {
    switch (type) {
      case ProductType.app:
        return 'App';
      case ProductType.game:
        return 'Juego';
      case ProductType.painting:
        return 'Cuadro';
      case ProductType.sculpture:
        return 'Escultura';
      case ProductType.craft:
        return 'Artesanía';
    }
  }
}

class CartItem {
  final Product product;
  int qty;
  CartItem(this.product, [this.qty = 1]);
}

class PaymentConfig {
  String cupCard;
  String mlcCard;
  String tronAddress;
  String businessName;

  PaymentConfig({
    this.cupCard = '',
    this.mlcCard = '',
    this.tronAddress = '',
    this.businessName = 'Tienda Cuba',
  });

  bool get hasCup => cupCard.trim().isNotEmpty;
  bool get hasMlc => mlcCard.trim().isNotEmpty;
  bool get hasTron => tronAddress.trim().isNotEmpty;
}

// ═══════════════════════════════════════════════════════════
// DATOS DEMO — Apps, Juegos y Arte
// ═══════════════════════════════════════════════════════════

const List<Product> catalog = [
  // APPS
  Product(
    id: 'a1',
    name: 'Gestor de Ventas Pro',
    subtitle: 'Android · Productividad',
    description:
        'Aplicación profesional para controlar inventario, clientes y ventas diarias. Ideal para emprendedores cubanos.',
    type: ProductType.app,
    priceCUP: 3500,
    priceMLC: 12,
    priceUSDT: 12,
    accent: Color(0xFF4F46E5),
    icon: Icons.point_of_sale_rounded,
    badge: 'Popular',
    rating: 4.9,
  ),
  Product(
    id: 'a2',
    name: 'Cursos Offline',
    subtitle: 'Android · Educación',
    description:
        'Plataforma de cursos descargables. Funciona sin internet después de la compra.',
    type: ProductType.app,
    priceCUP: 2800,
    priceMLC: 9,
    priceUSDT: 9,
    accent: Color(0xFF0EA5E9),
    icon: Icons.school_rounded,
    rating: 4.7,
  ),
  Product(
    id: 'a3',
    name: 'Finanzas Personales',
    subtitle: 'Android · Finanzas',
    description:
        'Controla gastos en CUP y MLC, metas de ahorro y reportes mensuales.',
    type: ProductType.app,
    priceCUP: 2200,
    priceMLC: 7,
    priceUSDT: 7,
    accent: Color(0xFF10B981),
    icon: Icons.account_balance_wallet_rounded,
    badge: 'Nuevo',
    rating: 4.8,
  ),
  // JUEGOS
  Product(
    id: 'g1',
    name: 'Habana Runner',
    subtitle: 'Android · Aventura',
    description:
        'Corre por las calles de La Habana evitando obstáculos. Gráficos ligeros y jugabilidad adictiva.',
    type: ProductType.game,
    priceCUP: 1500,
    priceMLC: 5,
    priceUSDT: 5,
    accent: Color(0xFFF59E0B),
    icon: Icons.sports_esports_rounded,
    badge: 'Top',
    rating: 4.6,
  ),
  Product(
    id: 'g2',
    name: 'Dominó Cubano 3D',
    subtitle: 'Android · Mesa',
    description:
        'El clásico dominó con reglas cubanas, multijugador local y torneos.',
    type: ProductType.game,
    priceCUP: 1800,
    priceMLC: 6,
    priceUSDT: 6,
    accent: Color(0xFFEF4444),
    icon: Icons.casino_rounded,
    rating: 4.9,
  ),
  Product(
    id: 'g3',
    name: 'Puzzle Caribe',
    subtitle: 'Android · Puzzle',
    description:
        'Rompecabezas de paisajes y arte cubano. Cientos de niveles.',
    type: ProductType.game,
    priceCUP: 1200,
    priceMLC: 4,
    priceUSDT: 4,
    accent: Color(0xFF8B5CF6),
    icon: Icons.extension_rounded,
    rating: 4.5,
  ),
  // CUADROS
  Product(
    id: 'p1',
    name: 'Esencia cubana',
    subtitle: 'Óleo sobre lienzo · 75×50 cm',
    description:
        'Pintura original al óleo. Retrato de la identidad y el color de Cuba. Obra firmada por el artista.',
    type: ProductType.painting,
    priceCUP: 85000,
    priceMLC: 270,
    priceUSDT: 270,
    accent: Color(0xFFDC2626),
    icon: Icons.palette_rounded,
    badge: 'Original',
    rating: 5.0,
  ),
  Product(
    id: 'p2',
    name: 'Mirada que pregunta',
    subtitle: 'Óleo · 160×100 cm',
    description:
        'Obra de gran formato. Expresión intensa y pincelada contemporánea.',
    type: ProductType.painting,
    priceCUP: 180000,
    priceMLC: 550,
    priceUSDT: 550,
    accent: Color(0xFF7C3AED),
    icon: Icons.brush_rounded,
    badge: 'Única',
    rating: 5.0,
  ),
  Product(
    id: 'p3',
    name: 'Bodegón caribeño',
    subtitle: 'Óleo · 70×50 cm',
    description:
        'Naturaleza muerta con frutas y objetos típicos. Ideal para salas y comedores.',
    type: ProductType.painting,
    priceCUP: 42000,
    priceMLC: 130,
    priceUSDT: 130,
    accent: Color(0xFFD97706),
    icon: Icons.image_rounded,
    rating: 4.8,
  ),
  // ESCULTURAS
  Product(
    id: 's1',
    name: 'Figura en madera',
    subtitle: 'Talla artesanal · 40 cm',
    description:
        'Escultura tallada a mano en madera local. Acabado natural barnizado.',
    type: ProductType.sculpture,
    priceCUP: 28000,
    priceMLC: 90,
    priceUSDT: 90,
    accent: Color(0xFF92400E),
    icon: Icons.architecture_rounded,
    badge: 'Hecho a mano',
    rating: 4.9,
  ),
  Product(
    id: 's2',
    name: 'Busto contemporáneo',
    subtitle: 'Cerámica · 35 cm',
    description:
        'Busto estilizado en cerámica esmaltada. Pieza decorativa de autor.',
    type: ProductType.sculpture,
    priceCUP: 35000,
    priceMLC: 110,
    priceUSDT: 110,
    accent: Color(0xFF64748B),
    icon: Icons.account_balance_rounded,
    rating: 4.7,
  ),
  // ARTESANÍAS
  Product(
    id: 'c1',
    name: 'Set de cerámica',
    subtitle: '4 piezas · Esmalte mate',
    description:
        'Juego de platos y cuencos hechos a mano. Colores tierra y azul.',
    type: ProductType.craft,
    priceCUP: 9500,
    priceMLC: 30,
    priceUSDT: 30,
    accent: Color(0xFF0D9488),
    icon: Icons.coffee_rounded,
    badge: 'Artesanal',
    rating: 4.8,
  ),
  Product(
    id: 'c2',
    name: 'Bolso de yarey',
    subtitle: 'Tejido tradicional',
    description:
        'Bolso tejido con fibra natural. Resistente y con diseño cubano clásico.',
    type: ProductType.craft,
    priceCUP: 6500,
    priceMLC: 20,
    priceUSDT: 20,
    accent: Color(0xFFCA8A04),
    icon: Icons.shopping_bag_rounded,
    rating: 4.6,
  ),
  Product(
    id: 'c3',
    name: 'Collar de seeds',
    subtitle: 'Bisutería artesanal',
    description:
        'Collar con semillas y cuentas naturales. Diseño único por pieza.',
    type: ProductType.craft,
    priceCUP: 3200,
    priceMLC: 10,
    priceUSDT: 10,
    accent: Color(0xFFDB2777),
    icon: Icons.diamond_rounded,
    rating: 4.7,
  ),
];

// ═══════════════════════════════════════════════════════════
// SHELL PRINCIPAL
// ═══════════════════════════════════════════════════════════

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;
  final List<CartItem> _cart = [];
  final PaymentConfig _pay = PaymentConfig();
  String _category = 'Todos';
  String _search = '';

  List<String> get _categories => [
        'Todos',
        'Apps',
        'Juegos',
        'Cuadros',
        'Esculturas',
        'Artesanías',
      ];

  List<Product> get _filtered {
    var list = catalog.toList();
    if (_category != 'Todos') {
      final map = {
        'Apps': ProductType.app,
        'Juegos': ProductType.game,
        'Cuadros': ProductType.painting,
        'Esculturas': ProductType.sculpture,
        'Artesanías': ProductType.craft,
      };
      final t = map[_category];
      if (t != null) list = list.where((p) => p.type == t).toList();
    }
    if (_search.trim().isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.subtitle.toLowerCase().contains(q) ||
              p.typeLabel.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  int get _cartCount => _cart.fold(0, (s, i) => s + i.qty);

  double get _cartTotalCUP =>
      _cart.fold(0.0, (s, i) => s + i.product.priceCUP * i.qty);

  double get _cartTotalMLC =>
      _cart.fold(0.0, (s, i) => s + i.product.priceMLC * i.qty);

  double get _cartTotalUSDT =>
      _cart.fold(0.0, (s, i) => s + i.product.priceUSDT * i.qty);

  void _add(Product p) {
    setState(() {
      final ex = _cart.where((c) => c.product.id == p.id);
      if (ex.isNotEmpty) {
        ex.first.qty++;
      } else {
        _cart.add(CartItem(p));
      }
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${p.name} añadido al carrito'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          _ShopTab(
            categories: _categories,
            selected: _category,
            onCategory: (c) => setState(() => _category = c),
            search: _search,
            onSearch: (s) => setState(() => _search = s),
            products: _filtered,
            onAdd: _add,
            onOpen: _openDetail,
          ),
          _CartTab(
            cart: _cart,
            totalCUP: _cartTotalCUP,
            onChanged: () => setState(() {}),
            onCheckout: _checkout,
          ),
          _AccountTab(
            config: _pay,
            onSaveConfig: () => setState(() {}),
            cartCount: _cartCount,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 68,
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        indicatorColor: const Color(0xFFE94560).withOpacity(0.15),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Tienda',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _cartCount > 0,
              label: Text('$_cartCount'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: _cartCount > 0,
              label: Text('$_cartCount'),
              child: const Icon(Icons.shopping_bag_rounded),
            ),
            label: 'Carrito',
          ),
          const NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }

  void _openDetail(Product p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductSheet(product: p, onAdd: () {
        Navigator.pop(context);
        _add(p);
      }),
    );
  }

  void _checkout() {
    if (_cart.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CheckoutSheet(
        config: _pay,
        totalCUP: _cartTotalCUP,
        totalMLC: _cartTotalMLC,
        totalUSDT: _cartTotalUSDT,
        onPaid: () {
          setState(() => _cart.clear());
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pedido registrado. Revisa el pago en Ajustes.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onNeedConfig: () {
          Navigator.pop(context);
          setState(() => _tab = 2);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Configura tus tarjetas en Ajustes primero'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// TIENDA
// ═══════════════════════════════════════════════════════════

class _ShopTab extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onCategory;
  final String search;
  final ValueChanged<String> onSearch;
  final List<Product> products;
  final void Function(Product) onAdd;
  final void Function(Product) onOpen;

  const _ShopTab({
    required this.categories,
    required this.selected,
    required this.onCategory,
    required this.search,
    required this.onSearch,
    required this.products,
    required this.onAdd,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 178,
          pinned: true,
          backgroundColor: const Color(0xFF1A1A2E),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tienda Cuba',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Apps · Juegos · Arte & Artesanía',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: TextField(
                          onChanged: onSearch,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            hintText: 'Buscar apps, juegos, cuadros…',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            prefixIcon: Icon(Icons.search_rounded,
                                color: Colors.white.withOpacity(0.7)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Banner premium
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE94560), Color(0xFF533483)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE94560).withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Arte original + software',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Paga con Transfermóvil o crypto',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.auto_awesome, color: Colors.white, size: 36),
              ],
            ),
          ),
        ),
        // Categorías
        theChips(categories, selected, onCategory),
        // Grid
        if (products.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text('No hay resultados', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final p = products[i];
                  return _ProductCard(
                    product: p,
                    onTap: () => onOpen(p),
                    onAdd: () => onAdd(p),
                  );
                },
                childCount: products.length,
              ),
            ),
          ),
      ],
    );
  }

  static Widget theChips(
    List<String> categories,
    String selected,
    ValueChanged<String> onCategory,
  ) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final c = categories[i];
            final on = c == selected;
            return FilterChip(
              label: Text(c),
              selected: on,
              onSelected: (_) => onCategory(c),
              selectedColor: const Color(0xFF1A1A2E),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: on ? Colors.white : const Color(0xFF1A1A2E),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: on ? const Color(0xFF1A1A2E) : Colors.grey.shade300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    gradient: LinearGradient(
                      colors: [
                        product.accent.withOpacity(0.2),
                        product.accent.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(product.icon, size: 52, color: product.accent),
                      ),
                      if (product.badge.isNotEmpty)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A2E),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.badge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.typeLabel.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: product.accent,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          height: 1.2,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${product.priceCUP.toStringAsFixed(0)} CUP',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        '${product.priceMLC} MLC · ${product.priceUSDT} USDT',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 34,
                        child: FilledButton(
                          onPressed: onAdd,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFE94560),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Añadir',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// DETALLE PRODUCTO
// ═══════════════════════════════════════════════════════════

class _ProductSheet extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;

  const _ProductSheet({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      product.accent.withOpacity(0.25),
                      product.accent.withOpacity(0.08),
                    ],
                  ),
                ),
                child: Icon(product.icon, size: 72, color: product.accent),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.typeLabel,
                      style: TextStyle(
                        color: product.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.star_rounded, color: Colors.amber.shade600, size: 20),
                  Text(
                    ' ${product.rating}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                product.subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                product.description,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  height: 1.5,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _PricePill('CUP', product.priceCUP.toStringAsFixed(0)),
                  const SizedBox(width: 8),
                  _PricePill('MLC', product.priceMLC.toString()),
                  const SizedBox(width: 8),
                  _PricePill('USDT', product.priceUSDT.toString()),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: const Text(
                    'Añadir al carrito',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE94560),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PricePill extends StatelessWidget {
  final String label;
  final String value;
  const _PricePill(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// CARRITO
// ═══════════════════════════════════════════════════════════

class _CartTab extends StatelessWidget {
  final List<CartItem> cart;
  final double totalCUP;
  final VoidCallback onChanged;
  final VoidCallback onCheckout;

  const _CartTab({
    required this.cart,
    required this.totalCUP,
    required this.onChanged,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            bottom: 16,
            left: 20,
            right: 20,
          ),
          color: const Color(0xFF1A1A2E),
          child: const Text(
            'Carrito',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (cart.isEmpty)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 72, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Tu carrito está vacío',
                      style: TextStyle(fontSize: 17, color: Colors.grey)),
                  SizedBox(height: 4),
                  Text('Explora apps, juegos y arte',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        else ...[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cart.length,
              itemBuilder: (_, i) {
                final item = cart[i];
                final p = item.product;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: p.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(p.icon, color: p.accent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 14)),
                            Text(
                              '${p.priceCUP.toStringAsFixed(0)} CUP',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (item.qty > 1) {
                            item.qty--;
                          } else {
                            cart.removeAt(i);
                          }
                          onChanged();
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('${item.qty}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                      IconButton(
                        onPressed: () {
                          item.qty++;
                          onChanged();
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(
                        '${totalCUP.toStringAsFixed(0)} CUP',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: onCheckout,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE94560),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Continuar al pago',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// AJUSTES / CONFIGURACIÓN DE PAGOS
// ═══════════════════════════════════════════════════════════

class _AccountTab extends StatefulWidget {
  final PaymentConfig config;
  final VoidCallback onSaveConfig;
  final int cartCount;

  const _AccountTab({
    required this.config,
    required this.onSaveConfig,
    required this.cartCount,
  });

  @override
  State<_AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<_AccountTab> {
  late final TextEditingController _name;
  late final TextEditingController _cup;
  late final TextEditingController _mlc;
  late final TextEditingController _tron;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.config.businessName);
    _cup = TextEditingController(text: widget.config.cupCard);
    _mlc = TextEditingController(text: widget.config.mlcCard);
    _tron = TextEditingController(text: widget.config.tronAddress);
  }

  @override
  void dispose() {
    _name.dispose();
    _cup.dispose();
    _mlc.dispose();
    _tron.dispose();
    super.dispose();
  }

  void _save() {
    widget.config.businessName = _name.text.trim().isEmpty
        ? 'Tienda Cuba'
        : _name.text.trim();
    widget.config.cupCard = _cup.text.trim();
    widget.config.mlcCard = _mlc.text.trim();
    widget.config.tronAddress = _tron.text.trim();
    widget.onSaveConfig();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración guardada'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 20,
            bottom: 28,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ajustes de la tienda',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Configura cómo recibes los pagos',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Datos del negocio',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _field(
                controller: _name,
                label: 'Nombre de la tienda',
                hint: 'Ej: Galería Dayan / Apps Cuba',
                icon: Icons.store_rounded,
              ),
              const SizedBox(height: 28),
              const Text(
                'Transfermóvil BANDEC',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                'Estas tarjetas se muestran al cliente al pagar',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 12),
              _field(
                controller: _cup,
                label: 'Tarjeta CUP',
                hint: '9225…',
                icon: Icons.credit_card,
                keyboard: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _field(
                controller: _mlc,
                label: 'Tarjeta MLC',
                hint: '9225…',
                icon: Icons.credit_card,
                keyboard: TextInputType.number,
              ),
              const SizedBox(height: 28),
              const Text(
                'Crypto TRC20',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                'Wallet para recibir USDT y TRX',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 12),
              _field(
                controller: _tron,
                label: 'Dirección TRON',
                hint: 'TX… o T…',
                icon: Icons.currency_bitcoin,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text(
                    'Guardar configuración',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A2E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFED7AA)),
                ),
                child: const Text(
                  'Importante: los pagos Transfermóvil son de aprobación manual. '
                  'Revisa tu estado de cuenta BANDEC y confirma cada pedido. '
                  'Los pagos crypto se verifican con el txid en la blockchain.',
                  style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF9A3412)),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'Tienda Cuba · Apps, Juegos y Arte\nv2.0 premium',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1A1A2E), width: 1.5),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// CHECKOUT
// ═══════════════════════════════════════════════════════════

class _CheckoutSheet extends StatelessWidget {
  final PaymentConfig config;
  final double totalCUP;
  final double totalMLC;
  final double totalUSDT;
  final VoidCallback onPaid;
  final VoidCallback onNeedConfig;

  const _CheckoutSheet({
    required this.config,
    required this.totalCUP,
    required this.totalMLC,
    required this.totalUSDT,
    required this.onPaid,
    required this.onNeedConfig,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Método de pago',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Total: ${totalCUP.toStringAsFixed(0)} CUP',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
          const SizedBox(height: 20),
          _payTile(
            context,
            icon: Icons.phone_android_rounded,
            title: 'Transfermóvil CUP',
            subtitle: config.hasCup
                ? 'Tarjeta configurada'
                : 'Configura la tarjeta en Ajustes',
            color: const Color(0xFF16A34A),
            enabled: config.hasCup,
            onTap: () {
              if (!config.hasCup) {
                onNeedConfig();
                return;
              }
              Navigator.pop(context);
              _showTransfer(context, 'CUP', totalCUP, config.cupCard);
            },
          ),
          const SizedBox(height: 10),
          _payTile(
            context,
            icon: Icons.currency_exchange_rounded,
            title: 'Transfermóvil MLC',
            subtitle: config.hasMlc
                ? 'Tarjeta configurada'
                : 'Configura la tarjeta en Ajustes',
            color: const Color(0xFF2563EB),
            enabled: config.hasMlc,
            onTap: () {
              if (!config.hasMlc) {
                onNeedConfig();
                return;
              }
              Navigator.pop(context);
              _showTransfer(context, 'MLC', totalMLC, config.mlcCard);
            },
          ),
          const SizedBox(height: 10),
          _payTile(
            context,
            icon: Icons.currency_bitcoin,
            title: 'USDT / TRX (TRC20)',
            subtitle: config.hasTron
                ? 'Wallet configurada'
                : 'Configura la wallet en Ajustes',
            color: const Color(0xFFEA580C),
            enabled: config.hasTron,
            onTap: () {
              if (!config.hasTron) {
                onNeedConfig();
                return;
              }
              Navigator.pop(context);
              _showCrypto(context, totalUSDT, config.tronAddress);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _payTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: enabled ? color.withOpacity(0.08) : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    enabled ? color.withOpacity(0.2) : Colors.grey.shade300,
                child: Icon(icon, color: enabled ? color : Colors.grey),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: enabled ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: enabled ? Colors.grey.shade600 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                enabled ? Icons.chevron_right_rounded : Icons.lock_outline,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransfer(
    BuildContext context,
    String currency,
    double amount,
    String card,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Transfermóvil $currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${amount.toStringAsFixed(2)} $currency',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFFE94560),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Transfiere a:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            SelectableText(
              card,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '1. Abre Transfermóvil (BANDEC)\n'
              '2. Transfiere el monto exacto\n'
              '3. Guarda el SMS de confirmación\n'
              '4. El vendedor verificará el pago',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: card));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tarjeta copiada')),
              );
            },
            child: const Text('Copiar tarjeta'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onPaid();
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE94560),
            ),
            child: const Text('Ya pagué'),
          ),
        ],
      ),
    );
  }

  void _showCrypto(BuildContext context, double usdt, String address) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Pago crypto TRC20'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${usdt.toStringAsFixed(2)} USDT',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFFEA580C),
              ),
            ),
            const Text('Red: TRON (TRC20)', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 14),
            const Text('Dirección:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            SelectableText(
              address,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            const SizedBox(height: 12),
            Text(
              'Envía el monto exacto. Guarda el hash (txid) de la transacción.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: address));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dirección copiada')),
              );
            },
            child: const Text('Copiar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onPaid();
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEA580C),
            ),
            child: const Text('Ya envié'),
          ),
        ],
      ),
    );
  }
}
