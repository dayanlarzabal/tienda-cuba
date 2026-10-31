import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const TiendaCubaApp());
}

class TiendaCubaApp extends StatelessWidget {
  const TiendaCubaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tienda Cuba',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1A2E),
          primary: const Color(0xFF1A1A2E),
          secondary: const Color(0xFFE94560),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F2F8),
      ),
      home: const MainShell(),
    );
  }
}

enum ProductKind { app, game, painting, sculpture, craft }

class Product {
  final String id;
  final String name;
  final String subtitle;
  final String description;
  final ProductKind kind;
  final double priceCUP;
  final double priceMLC;
  final double priceUSDT;
  final String imageUrl;
  final String downloadUrl;
  final bool isDigital;
  final String badge;

  const Product({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.kind,
    required this.priceCUP,
    required this.priceMLC,
    required this.priceUSDT,
    this.imageUrl = '',
    this.downloadUrl = '',
    required this.isDigital,
    this.badge = '',
  });

  String get kindLabel {
    switch (kind) {
      case ProductKind.app:
        return 'App';
      case ProductKind.game:
        return 'Juego';
      case ProductKind.painting:
        return 'Cuadro';
      case ProductKind.sculpture:
        return 'Escultura';
      case ProductKind.craft:
        return 'Artesanía';
    }
  }

  Color get accent {
    switch (kind) {
      case ProductKind.app:
        return const Color(0xFF4F46E5);
      case ProductKind.game:
        return const Color(0xFFF59E0B);
      case ProductKind.painting:
        return const Color(0xFFDC2626);
      case ProductKind.sculpture:
        return const Color(0xFF92400E);
      case ProductKind.craft:
        return const Color(0xFF0D9488);
    }
  }

  IconData get icon {
    switch (kind) {
      case ProductKind.app:
        return Icons.phone_android_rounded;
      case ProductKind.game:
        return Icons.sports_esports_rounded;
      case ProductKind.painting:
        return Icons.palette_rounded;
      case ProductKind.sculpture:
        return Icons.architecture_rounded;
      case ProductKind.craft:
        return Icons.handyman_rounded;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subtitle': subtitle,
        'description': description,
        'kind': kind.name,
        'priceCUP': priceCUP,
        'priceMLC': priceMLC,
        'priceUSDT': priceUSDT,
        'imageUrl': imageUrl,
        'downloadUrl': downloadUrl,
        'isDigital': isDigital,
        'badge': badge,
      };

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as String,
        name: j['name'] as String,
        subtitle: (j['subtitle'] as String?) ?? '',
        description: (j['description'] as String?) ?? '',
        kind: ProductKind.values.firstWhere(
          (e) => e.name == j['kind'],
          orElse: () => ProductKind.app,
        ),
        priceCUP: (j['priceCUP'] as num).toDouble(),
        priceMLC: (j['priceMLC'] as num).toDouble(),
        priceUSDT: (j['priceUSDT'] as num).toDouble(),
        imageUrl: (j['imageUrl'] as String?) ?? '',
        downloadUrl: (j['downloadUrl'] as String?) ?? '',
        isDigital: j['isDigital'] as bool? ?? true,
        badge: (j['badge'] as String?) ?? '',
      );
}

class CartItem {
  final Product product;
  int qty;
  CartItem(this.product, [this.qty = 1]);
}

class PaymentConfig {
  String businessName;
  String cupCard;
  String mlcCard;
  String tronAddress;
  String sellerPin;

  PaymentConfig({
    this.businessName = 'Tienda Cuba',
    this.cupCard = '',
    this.mlcCard = '',
    this.tronAddress = '',
    this.sellerPin = '1234',
  });

  bool get hasCup => cupCard.trim().isNotEmpty;
  bool get hasMlc => mlcCard.trim().isNotEmpty;
  bool get hasTron => tronAddress.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
        'businessName': businessName,
        'cupCard': cupCard,
        'mlcCard': mlcCard,
        'tronAddress': tronAddress,
        'sellerPin': sellerPin,
      };

  factory PaymentConfig.fromJson(Map<String, dynamic> j) => PaymentConfig(
        businessName: (j['businessName'] as String?) ?? 'Tienda Cuba',
        cupCard: (j['cupCard'] as String?) ?? '',
        mlcCard: (j['mlcCard'] as String?) ?? '',
        tronAddress: (j['tronAddress'] as String?) ?? '',
        sellerPin: (j['sellerPin'] as String?) ?? '1234',
      );
}

class OrderRecord {
  final String id;
  final List<String> productNames;
  final double totalCUP;
  final String method;
  final String? address;
  final String? phone;
  final DateTime createdAt;
  final bool isDigital;
  final List<String> downloadUrls;

  OrderRecord({
    required this.id,
    required this.productNames,
    required this.totalCUP,
    required this.method,
    this.address,
    this.phone,
    required this.createdAt,
    required this.isDigital,
    this.downloadUrls = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'productNames': productNames,
        'totalCUP': totalCUP,
        'method': method,
        'address': address,
        'phone': phone,
        'createdAt': createdAt.toIso8601String(),
        'isDigital': isDigital,
        'downloadUrls': downloadUrls,
      };

  factory OrderRecord.fromJson(Map<String, dynamic> j) => OrderRecord(
        id: j['id'] as String,
        productNames: List<String>.from(j['productNames'] as List),
        totalCUP: (j['totalCUP'] as num).toDouble(),
        method: j['method'] as String,
        address: j['address'] as String?,
        phone: j['phone'] as String?,
        createdAt: DateTime.parse(j['createdAt'] as String),
        isDigital: j['isDigital'] as bool? ?? true,
        downloadUrls: List<String>.from((j['downloadUrls'] as List?) ?? []),
      );
}

List<Product> seedProducts() => [
      const Product(
        id: 'a1',
        name: 'Gestor de Ventas Pro',
        subtitle: 'Android · Productividad',
        description: 'Tras el pago recibirás el enlace de descarga del APK.',
        kind: ProductKind.app,
        priceCUP: 3500,
        priceMLC: 12,
        priceUSDT: 12,
        downloadUrl: 'https://example.com/gestor-ventas.apk',
        isDigital: true,
        badge: 'Popular',
      ),
      const Product(
        id: 'g1',
        name: 'Habana Runner',
        subtitle: 'Android · Aventura',
        description: 'Descarga el APK después de pagar.',
        kind: ProductKind.game,
        priceCUP: 1500,
        priceMLC: 5,
        priceUSDT: 5,
        downloadUrl: 'https://example.com/habana-runner.apk',
        isDigital: true,
        badge: 'Top',
      ),
      const Product(
        id: 'p1',
        name: 'Esencia cubana',
        subtitle: 'Óleo · 75x50 cm',
        description: 'Pintura original. Envío físico en Cuba.',
        kind: ProductKind.painting,
        priceCUP: 85000,
        priceMLC: 270,
        priceUSDT: 270,
        isDigital: false,
        badge: 'Original',
      ),
      const Product(
        id: 'c1',
        name: 'Set de cerámica',
        subtitle: '4 piezas artesanales',
        description: 'Cerámica hecha a mano. Envío físico en Cuba.',
        kind: ProductKind.craft,
        priceCUP: 9500,
        priceMLC: 30,
        priceUSDT: 30,
        isDigital: false,
        badge: 'Artesanal',
      ),
    ];

class AppStore extends ChangeNotifier {
  List<Product> products = [];
  final List<CartItem> cart = [];
  PaymentConfig pay = PaymentConfig();
  List<OrderRecord> orders = [];
  List<String> unlockedDownloads = [];

  static const _kProducts = 'tc_products';
  static const _kPay = 'tc_pay';
  static const _kOrders = 'tc_orders';
  static const _kUnlocks = 'tc_unlocks';

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kProducts);
    if (raw != null && raw.isNotEmpty) {
      final list = jsonDecode(raw) as List;
      products = list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      products = seedProducts();
      await _saveProducts();
    }
    final payRaw = p.getString(_kPay);
    if (payRaw != null) {
      pay = PaymentConfig.fromJson(jsonDecode(payRaw) as Map<String, dynamic>);
    }
    final ordRaw = p.getString(_kOrders);
    if (ordRaw != null) {
      final list = jsonDecode(ordRaw) as List;
      orders = list.map((e) => OrderRecord.fromJson(e as Map<String, dynamic>)).toList();
    }
    unlockedDownloads = p.getStringList(_kUnlocks) ?? [];
    notifyListeners();
  }

  Future<void> _saveProducts() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kProducts, jsonEncode(products.map((e) => e.toJson()).toList()));
  }

  Future<void> _savePay() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kPay, jsonEncode(pay.toJson()));
  }

  Future<void> _saveOrders() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kOrders, jsonEncode(orders.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveUnlocks() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_kUnlocks, unlockedDownloads);
  }

  Future<void> upsertProduct(Product product) async {
    final i = products.indexWhere((e) => e.id == product.id);
    if (i >= 0) {
      products[i] = product;
    } else {
      products.insert(0, product);
    }
    await _saveProducts();
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    products.removeWhere((e) => e.id == id);
    await _saveProducts();
    notifyListeners();
  }

  Future<void> savePay() async {
    await _savePay();
    notifyListeners();
  }

  void addToCart(Product product) {
    final ex = cart.where((c) => c.product.id == product.id);
    if (ex.isNotEmpty) {
      ex.first.qty++;
    } else {
      cart.add(CartItem(product));
    }
    notifyListeners();
  }

  void changeQty(int index, int delta) {
    final item = cart[index];
    item.qty += delta;
    if (item.qty <= 0) cart.removeAt(index);
    notifyListeners();
  }

  int get cartCount => cart.fold(0, (s, i) => s + i.qty);
  double get totalCUP => cart.fold(0.0, (s, i) => s + i.product.priceCUP * i.qty);
  double get totalMLC => cart.fold(0.0, (s, i) => s + i.product.priceMLC * i.qty);
  double get totalUSDT => cart.fold(0.0, (s, i) => s + i.product.priceUSDT * i.qty);
  bool get cartHasPhysical => cart.any((c) => !c.product.isDigital);

  Future<OrderRecord> completeOrder({
    required String method,
    String? address,
    String? phone,
  }) async {
    final downloads = cart
        .where((c) => c.product.isDigital && c.product.downloadUrl.isNotEmpty)
        .map((c) => c.product.downloadUrl)
        .toList();
    for (final u in downloads) {
      if (!unlockedDownloads.contains(u)) unlockedDownloads.add(u);
    }
    final order = OrderRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productNames: cart.map((c) => '${c.product.name} x${c.qty}').toList(),
      totalCUP: totalCUP,
      method: method,
      address: address,
      phone: phone,
      createdAt: DateTime.now(),
      isDigital: !cartHasPhysical,
      downloadUrls: downloads,
    );
    orders.insert(0, order);
    cart.clear();
    await _saveOrders();
    await _saveUnlocks();
    notifyListeners();
    return order;
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final AppStore store = AppStore();
  bool loading = true;
  int tab = 0;
  String category = 'Todos';
  String search = '';

  @override
  void initState() {
    super.initState();
    store.load().then((_) {
      if (mounted) setState(() => loading = false);
    });
    store.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  List<String> get categories =>
      ['Todos', 'Apps', 'Juegos', 'Cuadros', 'Esculturas', 'Artesanías'];

  List<Product> get filtered {
    var list = store.products.toList();
    final map = {
      'Apps': ProductKind.app,
      'Juegos': ProductKind.game,
      'Cuadros': ProductKind.painting,
      'Esculturas': ProductKind.sculpture,
      'Artesanías': ProductKind.craft,
    };
    if (category != 'Todos') {
      final k = map[category];
      if (k != null) list = list.where((p) => p.kind == k).toList();
    }
    if (search.trim().isNotEmpty) {
      final q = search.toLowerCase();
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.subtitle.toLowerCase().contains(q) ||
              p.kindLabel.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: IndexedStack(
        index: tab,
        children: [
          _ShopTab(
            store: store,
            categories: categories,
            category: category,
            onCategory: (c) => setState(() => category = c),
            search: search,
            onSearch: (s) => setState(() => search = s),
            products: filtered,
          ),
          _CartTab(store: store),
          _DownloadsTab(store: store),
          _MoreTab(store: store),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 68,
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        indicatorColor: const Color(0xFFE94560).withOpacity(0.15),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Tienda',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: store.cartCount > 0,
              label: Text('${store.cartCount}'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: store.cartCount > 0,
              label: Text('${store.cartCount}'),
              child: const Icon(Icons.shopping_bag_rounded),
            ),
            label: 'Carrito',
          ),
          const NavigationDestination(
            icon: Icon(Icons.download_outlined),
            selectedIcon: Icon(Icons.download_rounded),
            label: 'Descargas',
          ),
          const NavigationDestination(
            icon: Icon(Icons.menu_rounded),
            selectedIcon: Icon(Icons.menu_open_rounded),
            label: 'Más',
          ),
        ],
      ),
    );
  }
}

class _ShopTab extends StatelessWidget {
  final AppStore store;
  final List<String> categories;
  final String category;
  final ValueChanged<String> onCategory;
  final String search;
  final ValueChanged<String> onSearch;
  final List<Product> products;

  const _ShopTab({
    required this.store,
    required this.categories,
    required this.category,
    required this.onCategory,
    required this.search,
    required this.onSearch,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        theAppBar(store.pay.businessName, onSearch),
        theBanner(),
        theChips(categories, category, onCategory),
        if (products.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('Sin productos', style: TextStyle(color: Colors.grey))),
          )
        else
          theGrid(products, store),
      ],
    );
  }

  static Widget theAppBar(String title, ValueChanged<String> onSearch) {
    return SliverAppBar(
      expandedHeight: 168,
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
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                  Text('Apps · Juegos · Arte con envío',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                  const Spacer(),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: TextField(
                      onChanged: onSearch,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: 'Buscar…',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget theBanner() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFE94560), Color(0xFF533483)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Expanded(
              child: Text(
                'Digital: paga y descarga\nArte: pago + envío físico en Cuba',
                style: TextStyle(color: Colors.white, fontSize: 13, height: 1.35),
              ),
            ),
            Icon(Icons.auto_awesome, color: Colors.white, size: 32),
          ],
        ),
      ),
    );
  }

  static Widget theChips(
      List<String> categories, String category, ValueChanged<String> onCategory) {
    return theChips2(categories, category, onCategory);
  }

  static Widget theChips2(
      List<String> categories, String category, ValueChanged<String> onCategory) {
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
            final on = c == category;
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
              side: BorderSide(color: on ? const Color(0xFF1A1A2E) : Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            );
          },
        ),
      ),
    );
  }

  static Widget theGrid(List<Product> products, AppStore store) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      sliver: theGridInner(products, store),
    );
  }

  static Widget theGridInner(List<Product> products, AppStore store) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final p = products[i];
          return _ProductCard(
            product: p,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _ProductSheet(
                  product: p,
                  onAdd: () {
                    store.addToCart(p);
                    Navigator.pop(context);
                  },
                ),
              );
            },
            onAdd: () {
              store.addToCart(p);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${p.name} añadido'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          );
        },
        childCount: products.length,
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  const _ProductCard({required this.product, required this.onTap, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagen / icono (altura fija relativa)
              Expanded(
                flex: 4,
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => _iconBox(),
                      )
                    : _iconBox(),
              ),
              // Info + botón (sin overflow)
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${product.kindLabel} · ${product.isDigital ? 'Digital' : 'Envío'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: product.accent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          height: 1.15,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${product.priceCUP.toStringAsFixed(0)} CUP',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${product.priceMLC} MLC',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: FilledButton(
                          onPressed: onAdd,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFE94560),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Añadir',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
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

  Widget _iconBox() {
    return ColoredBox(
      color: product.accent.withOpacity(0.12),
      child: Center(child: Icon(product.icon, size: 42, color: product.accent)),
    );
  }
}

class _ProductSheet extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;
  const _ProductSheet({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 180,
                child: product.imageUrl.isNotEmpty
                    ? Image.network(product.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fb())
                    : _fb(),
              ),
            ),
            const SizedBox(height: 16),
            Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            Text(product.subtitle, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text(
              product.isDigital
                  ? 'Producto digital · descarga tras el pago'
                  : 'Producto físico · envío en Cuba',
              style: TextStyle(color: product.accent, fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Text(product.description, style: const TextStyle(height: 1.45, fontSize: 15)),
            const SizedBox(height: 20),
            Text(
                '${product.priceCUP.toStringAsFixed(0)} CUP  ·  ${product.priceMLC} MLC  ·  ${product.priceUSDT} USDT',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_shopping_cart_rounded),
                label: const Text('Añadir al carrito', style: TextStyle(fontWeight: FontWeight.w700)),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE94560),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fb() =>
      Container(color: product.accent.withOpacity(0.15), child: Icon(product.icon, size: 72, color: product.accent));
}

class _CartTab extends StatelessWidget {
  final AppStore store;
  const _CartTab({required this.store});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16, bottom: 16, left: 20, right: 20),
          color: const Color(0xFF1A1A2E),
          child: const Text('Carrito',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        ),
        if (store.cart.isEmpty)
          const Expanded(
              child: Center(
                  child: Text('Carrito vacío', style: TextStyle(color: Colors.grey, fontSize: 16))))
        else ...[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: store.cart.length,
              itemBuilder: (_, i) {
                final item = store.cart[i];
                final p = item.product;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: p.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(p.icon, color: p.accent),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(
                                '${p.priceCUP.toStringAsFixed(0)} CUP · ${p.isDigital ? 'Digital' : 'Físico'}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      IconButton(
                          onPressed: () => store.changeQty(i, -1),
                          icon: const Icon(Icons.remove_circle_outline)),
                      Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.w800)),
                      IconButton(
                          onPressed: () => store.changeQty(i, 1),
                          icon: const Icon(Icons.add_circle_outline)),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('${store.totalCUP.toStringAsFixed(0)} CUP',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => _CheckoutSheet(store: store),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE94560),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Pagar',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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

class _CheckoutSheet extends StatefulWidget {
  final AppStore store;
  const _CheckoutSheet({required this.store});
  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  final addressCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  @override
  void dispose() {
    addressCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final needAddress = store.cartHasPhysical;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              const Text('Pagar pedido', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              Text('Total: ${store.totalCUP.toStringAsFixed(0)} CUP',
                  style: TextStyle(color: Colors.grey.shade600)),
              if (needAddress) ...[
                const SizedBox(height: 16),
                const Text('Datos de envío (arte)', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: _dec('Teléfono / WhatsApp')),
                const SizedBox(height: 8),
                TextField(
                    controller: addressCtrl,
                    maxLines: 2,
                    decoration: _dec('Dirección (provincia, municipio, calle)')),
              ],
              const SizedBox(height: 18),
              const Text('Método de pago', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              _method(context, 'Transfermóvil CUP', store.pay.hasCup, Colors.green,
                  () => _pay(context, 'CUP', store.totalCUP, store.pay.cupCard)),
              _method(context, 'Transfermóvil MLC', store.pay.hasMlc, Colors.blue,
                  () => _pay(context, 'MLC', store.totalMLC, store.pay.mlcCard)),
              _method(context, 'USDT / TRX (TRC20)', store.pay.hasTron, Colors.orange,
                  () => _payCrypto(context)),
              const SizedBox(height: 8),
              Text(
                'El dinero va a TU tarjeta/wallet. La app no cobra sola: tú verificas el pago en BANDEC o en la blockchain.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  Widget _method(
      BuildContext context, String title, bool ok, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: ok ? color.withOpacity(0.1) : Colors.grey.shade100,
        leading: Icon(ok ? Icons.check_circle : Icons.lock_outline, color: ok ? color : Colors.grey),
        title: Text(title,
            style: TextStyle(fontWeight: FontWeight.w600, color: ok ? Colors.black87 : Colors.grey)),
        subtitle: Text(ok ? 'Configurado' : 'Configúralo en Más → Pagos'),
        onTap: () {
          if (!ok) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configura este método en Más → Pagos')));
            return;
          }
          if (widget.store.cartHasPhysical &&
              (addressCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty)) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Completa teléfono y dirección de envío')));
            return;
          }
          onTap();
        },
      ),
    );
  }

  Future<void> _pay(BuildContext context, String currency, double amount, String card) async {
    Navigator.pop(context);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Transfermóvil $currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${amount.toStringAsFixed(2)} $currency',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFFE94560))),
            const SizedBox(height: 10),
            const Text('Transfiere a:'),
            SelectableText(card, style: const TextStyle(fontFamily: 'monospace', fontSize: 15)),
            const SizedBox(height: 10),
            const Text(
              '1. Abre Transfermóvil\n2. Envía el monto exacto\n3. Pulsa «Ya pagué»\n4. El vendedor verifica y entrega',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Clipboard.setData(ClipboardData(text: card)),
              child: const Text('Copiar')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final order = await widget.store.completeOrder(
                method: 'Transfermóvil $currency',
                address: addressCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
              );
              if (!context.mounted) return;
              _afterPay(context, order);
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE94560)),
            child: const Text('Ya pagué'),
          ),
        ],
      ),
    );
  }

  Future<void> _payCrypto(BuildContext context) async {
    Navigator.pop(context);
    final addr = widget.store.pay.tronAddress;
    final amount = widget.store.totalUSDT;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Crypto TRC20'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${amount.toStringAsFixed(2)} USDT',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.orange)),
            const Text('Red TRON (TRC20)'),
            const SizedBox(height: 8),
            SelectableText(addr, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Clipboard.setData(ClipboardData(text: addr)),
              child: const Text('Copiar')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final order = await widget.store.completeOrder(
                method: 'USDT TRC20',
                address: addressCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
              );
              if (!context.mounted) return;
              _afterPay(context, order);
            },
            child: const Text('Ya envié'),
          ),
        ],
      ),
    );
  }

  void _afterPay(BuildContext context, OrderRecord order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pedido registrado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Verifica el pago en tu banco o wallet.\n'),
            if (order.downloadUrls.isNotEmpty)
              const Text(
                  'Digital: el cliente ve el enlace en Descargas (en esta versión al marcar Ya pagué).'),
            if (order.address != null && order.address!.isNotEmpty)
              Text('\nEnvío a: ${order.address}\nTel: ${order.phone}'),
          ],
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Entendido')),
        ],
      ),
    );
  }
}

class _DownloadsTab extends StatelessWidget {
  final AppStore store;
  const _DownloadsTab({required this.store});

  @override
  Widget build(BuildContext context) {
    final urls = store.unlockedDownloads;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16, bottom: 16, left: 20, right: 20),
          color: const Color(0xFF1A1A2E),
          child: const Text('Descargas',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        ),
        if (urls.isEmpty)
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aquí salen los enlaces de apps/juegos tras pagar.\n\nCopia el enlace y ábrelo en el navegador para bajar el APK.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, height: 1.4),
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: urls.length,
              itemBuilder: (_, i) {
                final u = urls[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.android, color: Color(0xFF1A1A2E)),
                    title: Text('Descarga ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(u, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: u));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enlace copiado')),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _MoreTab extends StatelessWidget {
  final AppStore store;
  const _MoreTab({required this.store});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20, bottom: 24, left: 20, right: 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)]),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Más',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              SizedBox(height: 4),
              Text('Pagos, pedidos y panel del vendedor', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.payment),
          title: const Text('Configurar pagos'),
          subtitle: const Text('Tarjetas BANDEC y wallet TRON'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PaymentSettingsPage(store: store)),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.receipt_long),
          title: const Text('Pedidos recibidos'),
          subtitle: Text('${store.orders.length} en este teléfono'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OrdersPage(store: store)),
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.store, color: Color(0xFFE94560)),
          title: const Text('Panel del vendedor'),
          subtitle: const Text('Añadir apps, juegos, arte y foto (URL)'),
          onTap: () => _openSeller(context),
        ),
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Fotos: sube a imgbb.com → URL directa → pégala al crear el producto.\n\n'
            'Apps/juegos: pega el enlace de descarga del APK (Drive, Mega…).\n'
            'Tras pagar, el cliente lo ve en Descargas.\n\n'
            'Arte: el cliente deja dirección; tú envías cuando confirmes el pago en BANDEC.\n\n'
            'IMPORTANTE: el dinero NO lo mueve la app. El cliente transfiere a TU tarjeta; tú verificas.',
            style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  void _openSeller(BuildContext context) {
    final pinCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('PIN del vendedor'),
        content: TextField(
          controller: pinCtrl,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'PIN', hintText: 'Por defecto 1234'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (pinCtrl.text.trim() == store.pay.sellerPin) {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SellerPanelPage(store: store)),
                );
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('PIN incorrecto')));
              }
            },
            child: const Text('Entrar'),
          ),
        ],
      ),
    );
  }
}

class PaymentSettingsPage extends StatefulWidget {
  final AppStore store;
  const PaymentSettingsPage({super.key, required this.store});
  @override
  State<PaymentSettingsPage> createState() => _PaymentSettingsPageState();
}

class _PaymentSettingsPageState extends State<PaymentSettingsPage> {
  late final TextEditingController name;
  late final TextEditingController cup;
  late final TextEditingController mlc;
  late final TextEditingController tron;
  late final TextEditingController pin;

  @override
  void initState() {
    super.initState();
    final p = widget.store.pay;
    name = TextEditingController(text: p.businessName);
    cup = TextEditingController(text: p.cupCard);
    mlc = TextEditingController(text: p.mlcCard);
    tron = TextEditingController(text: p.tronAddress);
    pin = TextEditingController(text: p.sellerPin);
  }

  @override
  void dispose() {
    name.dispose();
    cup.dispose();
    mlc.dispose();
    tron.dispose();
    pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagos')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'El cliente transfiere a estos datos. El dinero llega a tu banco/wallet. '
            'Tú verificas y entregas.',
            style: TextStyle(height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(
              controller: name,
              decoration:
                  const InputDecoration(labelText: 'Nombre de la tienda', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(
              controller: cup,
              decoration:
                  const InputDecoration(labelText: 'Tarjeta CUP BANDEC', border: OutlineInputBorder()),
              keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(
              controller: mlc,
              decoration:
                  const InputDecoration(labelText: 'Tarjeta MLC BANDEC', border: OutlineInputBorder()),
              keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(
              controller: tron,
              decoration: const InputDecoration(
                  labelText: 'Wallet TRON (USDT/TRX)', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(
              controller: pin,
              decoration:
                  const InputDecoration(labelText: 'PIN panel vendedor', border: OutlineInputBorder()),
              keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () async {
              widget.store.pay.businessName =
                  name.text.trim().isEmpty ? 'Tienda Cuba' : name.text.trim();
              widget.store.pay.cupCard = cup.text.trim();
              widget.store.pay.mlcCard = mlc.text.trim();
              widget.store.pay.tronAddress = tron.text.trim();
              widget.store.pay.sellerPin = pin.text.trim().isEmpty ? '1234' : pin.text.trim();
              await widget.store.savePay();
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Guardado')));
                Navigator.pop(context);
              }
            },
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E), minimumSize: const Size.fromHeight(48)),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class OrdersPage extends StatelessWidget {
  final AppStore store;
  const OrdersPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos')),
      body: store.orders.isEmpty
          ? const Center(child: Text('Sin pedidos aún'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: store.orders.length,
              itemBuilder: (_, i) {
                final o = store.orders[i];
                return Card(
                  child: ListTile(
                    title: Text('${o.totalCUP.toStringAsFixed(0)} CUP · ${o.method}'),
                    subtitle: Text(
                      '${o.productNames.join(', ')}\n'
                      '${o.createdAt.toString().substring(0, 16)}'
                      '${o.address != null && o.address!.isNotEmpty ? '\nEnvío: ${o.address} · ${o.phone}' : ''}',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}

class SellerPanelPage extends StatefulWidget {
  final AppStore store;
  const SellerPanelPage({super.key, required this.store});
  @override
  State<SellerPanelPage> createState() => _SellerPanelPageState();
}

class _SellerPanelPageState extends State<SellerPanelPage> {
  @override
  Widget build(BuildContext context) {
    final products = widget.store.products;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis productos'),
        actions: [IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _edit(null))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(null),
        backgroundColor: const Color(0xFFE94560),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo producto'),
      ),
      body: products.isEmpty
          ? const Center(child: Text('Aún no hay productos'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
              itemCount: products.length,
              itemBuilder: (_, i) {
                final p = products[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: p.accent.withOpacity(0.2),
                      backgroundImage: p.imageUrl.isNotEmpty ? NetworkImage(p.imageUrl) : null,
                      onBackgroundImageError: p.imageUrl.isNotEmpty ? (_, __) {} : null,
                      child: p.imageUrl.isEmpty ? Icon(p.icon, color: p.accent) : null,
                    ),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                        '${p.kindLabel} · ${p.isDigital ? 'Digital' : 'Físico'}\n${p.priceCUP.toStringAsFixed(0)} CUP'),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'edit') _edit(p);
                        if (v == 'del') {
                          await widget.store.deleteProduct(p.id);
                          setState(() {});
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Editar')),
                        PopupMenuItem(value: 'del', child: Text('Eliminar')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _edit(Product? existing) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductFormPage(store: widget.store, existing: existing)),
    );
    setState(() {});
  }
}

class ProductFormPage extends StatefulWidget {
  final AppStore store;
  final Product? existing;
  const ProductFormPage({super.key, required this.store, this.existing});
  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  late final TextEditingController name;
  late final TextEditingController subtitle;
  late final TextEditingController description;
  late final TextEditingController priceCUP;
  late final TextEditingController priceMLC;
  late final TextEditingController priceUSDT;
  late final TextEditingController imageUrl;
  late final TextEditingController downloadUrl;
  late final TextEditingController badge;
  late ProductKind kind;
  late bool isDigital;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    name = TextEditingController(text: e?.name ?? '');
    subtitle = TextEditingController(text: e?.subtitle ?? '');
    description = TextEditingController(text: e?.description ?? '');
    priceCUP = TextEditingController(text: e?.priceCUP.toString() ?? '');
    priceMLC = TextEditingController(text: e?.priceMLC.toString() ?? '');
    priceUSDT = TextEditingController(text: e?.priceUSDT.toString() ?? '');
    imageUrl = TextEditingController(text: e?.imageUrl ?? '');
    downloadUrl = TextEditingController(text: e?.downloadUrl ?? '');
    badge = TextEditingController(text: e?.badge ?? '');
    kind = e?.kind ?? ProductKind.app;
    isDigital = e?.isDigital ?? true;
  }

  @override
  void dispose() {
    name.dispose();
    subtitle.dispose();
    description.dispose();
    priceCUP.dispose();
    priceMLC.dispose();
    priceUSDT.dispose();
    imageUrl.dispose();
    downloadUrl.dispose();
    badge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'Nuevo producto' : 'Editar')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField<ProductKind>(
            value: kind,
            decoration: const InputDecoration(labelText: 'Tipo', border: OutlineInputBorder()),
            items: ProductKind.values
                .map((k) => DropdownMenuItem(value: k, child: Text(_label(k))))
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                kind = v;
                isDigital = v == ProductKind.app || v == ProductKind.game;
              });
            },
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Producto digital (app/juego)'),
            subtitle: Text(isDigital ? 'Se entrega por enlace de descarga' : 'Envío físico en Cuba'),
            value: isDigital,
            onChanged: (v) => setState(() => isDigital = v),
          ),
          const SizedBox(height: 8),
          _tf(name, 'Nombre'),
          _tf(subtitle, 'Subtítulo'),
          _tf(description, 'Descripción', lines: 3),
          _tf(priceCUP, 'Precio CUP', number: true),
          _tf(priceMLC, 'Precio MLC', number: true),
          _tf(priceUSDT, 'Precio USDT', number: true),
          _tf(imageUrl, 'URL de la foto (ImgBB, Drive público…)'),
          if (imageUrl.text.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl.text.trim(), height: 140, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Text('No se pudo cargar la imagen')),
            ),
          ],
          if (isDigital) _tf(downloadUrl, 'Enlace de descarga del APK'),
          _tf(badge, 'Etiqueta (opcional)'),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE94560), minimumSize: const Size.fromHeight(50)),
            child: const Text('Guardar producto', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tip foto: imgbb.com → subir → “URL directa” → pegar aquí.',
            style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.35),
          ),
        ],
      ),
    );
  }

  String _label(ProductKind k) {
    switch (k) {
      case ProductKind.app:
        return 'App';
      case ProductKind.game:
        return 'Juego';
      case ProductKind.painting:
        return 'Cuadro';
      case ProductKind.sculpture:
        return 'Escultura';
      case ProductKind.craft:
        return 'Artesanía';
    }
  }

  Widget _tf(TextEditingController c, String label, {int lines = 1, bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: lines,
        keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        onChanged: label.contains('foto') ? (_) => setState(() {}) : null,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  Future<void> _save() async {
    if (name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pon un nombre')));
      return;
    }
    final id = widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final product = Product(
      id: id,
      name: name.text.trim(),
      subtitle: subtitle.text.trim(),
      description: description.text.trim(),
      kind: kind,
      priceCUP: double.tryParse(priceCUP.text.replaceAll(',', '.')) ?? 0,
      priceMLC: double.tryParse(priceMLC.text.replaceAll(',', '.')) ?? 0,
      priceUSDT: double.tryParse(priceUSDT.text.replaceAll(',', '.')) ?? 0,
      imageUrl: imageUrl.text.trim(),
      downloadUrl: downloadUrl.text.trim(),
      isDigital: isDigital,
      badge: badge.text.trim(),
    );
    await widget.store.upsertProduct(product);
    if (mounted) Navigator.pop(context);
  }
}
