import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A84FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const StoreHome(),
    );
  }
}

class Product {
  final String id;
  final String name;
  final String category;
  final String description;
  final double priceCUP;
  final double priceMLC;
  final Color color;
  final IconData icon;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.priceCUP,
    required this.priceMLC,
    required this.color,
    required this.icon,
  });
}

const List<Product> demoProducts = [
  Product(
    id: '1',
    name: 'Licuadora Oster 10 vel.',
    category: 'Electro',
    description: 'Vaso de vidrio, 10 velocidades.',
    priceCUP: 18500,
    priceMLC: 45,
    color: Color(0xFF5B8DEF),
    icon: Icons.blender,
  ),
  Product(
    id: '2',
    name: 'Aire Split 1 tonelada',
    category: 'Electro',
    description: '12000 BTU, eficiente.',
    priceCUP: 95000,
    priceMLC: 280,
    color: Color(0xFF4ECDC4),
    icon: Icons.ac_unit,
  ),
  Product(
    id: '3',
    name: 'Camiseta Polo hombre',
    category: 'Ropa',
    description: 'Algodón premium, varias tallas.',
    priceCUP: 2800,
    priceMLC: 8,
    color: Color(0xFFFF6B6B),
    icon: Icons.checkroom,
  ),
  Product(
    id: '4',
    name: 'Arroz 5 kg',
    category: 'Alimentos',
    description: 'Grano largo, paquete 5 kg.',
    priceCUP: 1200,
    priceMLC: 3.5,
    color: Color(0xFFFFB347),
    icon: Icons.rice_bowl,
  ),
  Product(
    id: '5',
    name: 'Aceite vegetal 1L',
    category: 'Alimentos',
    description: 'Aceite refinado 1 litro.',
    priceCUP: 950,
    priceMLC: 2.8,
    color: Color(0xFF95E1D3),
    icon: Icons.opacity,
  ),
  Product(
    id: '6',
    name: 'Zapatillas deportivas',
    category: 'Ropa',
    description: 'Cómodas y ligeras.',
    priceCUP: 6500,
    priceMLC: 18,
    color: Color(0xFFA78BFA),
    icon: Icons.directions_run,
  ),
  Product(
    id: '7',
    name: 'Televisor 32 LED',
    category: 'Electro',
    description: 'HD, HDMI y USB.',
    priceCUP: 42000,
    priceMLC: 120,
    color: Color(0xFF60A5FA),
    icon: Icons.tv,
  ),
  Product(
    id: '8',
    name: 'Café molido 250g',
    category: 'Alimentos',
    description: 'Café cubano, tueste medio.',
    priceCUP: 1800,
    priceMLC: 5,
    color: Color(0xFFD4A373),
    icon: Icons.coffee,
  ),
];

class CartItem {
  final Product product;
  int qty;
  CartItem(this.product, [this.qty = 1]);
}

class StoreHome extends StatefulWidget {
  const StoreHome({super.key});

  @override
  State<StoreHome> createState() => _StoreHomeState();
}

class _StoreHomeState extends State<StoreHome> {
  final List<CartItem> cart = [];
  String selectedCategory = 'Todos';
  int tab = 0;

  List<String> get categories {
    final set = <String>{};
    for (final p in demoProducts) {
      set.add(p.category);
    }
    return ['Todos', ...set];
  }

  List<Product> get filtered {
    if (selectedCategory == 'Todos') return demoProducts;
    return demoProducts.where((p) => p.category == selectedCategory).toList();
  }

  int get cartCount {
    var n = 0;
    for (final i in cart) {
      n += i.qty;
    }
    return n;
  }

  double get cartTotal {
    var t = 0.0;
    for (final i in cart) {
      t += i.product.priceCUP * i.qty;
    }
    return t;
  }

  void addToCart(Product p) {
    setState(() {
      final existing = cart.where((c) => c.product.id == p.id);
      if (existing.isNotEmpty) {
        existing.first.qty++;
      } else {
        cart.add(CartItem(p));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${p.name} añadido'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: tab,
        children: [
          _buildHome(),
          _buildCart(),
          _buildProfile(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Tienda',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Carrito',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Cuenta',
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          expandedHeight: 140,
          pinned: true,
          backgroundColor: Color(0xFF0A84FF),
          foregroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Tienda Cuba',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            background: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A84FF), Color(0xFF0055CC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
        // Banner
        theBanner(),
        // Categorías
        theCategories(),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        // Productos
        theProducts(),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget theBanner() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Envío a toda Cuba',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Transfermóvil · TRX · USDT',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.local_shipping, color: Colors.white, size: 40),
          ],
        ),
      ),
    );
  }

  Widget theCategories() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final c = categories[i];
            final selected = c == selectedCategory;
            return ChoiceChip(
              label: Text(c),
              selected: selected,
              onSelected: (_) => setState(() => selectedCategory = c),
              selectedColor: const Color(0xFF0A84FF),
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget theProducts() {
    return theGrid();
  }

  Widget theGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: theSliverGrid(),
    );
  }

  Widget theSliverGrid() {
    return theGridDelegate();
  }

  Widget theGridDelegate() {
    return theActualGrid();
  }

  Widget theActualGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final p = filtered[i];
          return ProductCard(product: p, onAdd: () => addToCart(p));
        },
        childCount: filtered.length,
      ),
    );
  }

  Widget _buildCart() {
    if (cart.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Tu carrito está vacío',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        AppBar(
          title: const Text('Carrito'),
          backgroundColor: const Color(0xFF0A84FF),
          foregroundColor: Colors.white,
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cart.length,
            itemBuilder: (_, i) {
              final item = cart[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: item.product.color.withOpacity(0.2),
                    child: Icon(item.product.icon, color: item.product.color),
                  ),
                  title: Text(
                    item.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${item.product.priceCUP.toStringAsFixed(0)} CUP x ${item.qty}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() {
                            if (item.qty > 1) {
                              item.qty--;
                            } else {
                              cart.removeAt(i);
                            }
                          });
                        },
                      ),
                      Text(
                        '${item.qty}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setState(() => item.qty++),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${cartTotal.toStringAsFixed(0)} CUP',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A84FF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _showCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A84FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Pagar ahora',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfile() {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A84FF), Color(0xFF0055CC)],
            ),
          ),
          child: const Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, size: 48, color: Colors.white),
              ),
              SizedBox(height: 12),
              Text(
                'Cliente Tienda Cuba',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'cliente@ejemplo.cu',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const ListTile(
          leading: Icon(Icons.receipt_long),
          title: Text('Mis pedidos'),
          subtitle: Text('Historial de compras'),
        ),
        const ListTile(
          leading: Icon(Icons.payment),
          title: Text('Métodos de pago'),
          subtitle: Text('Transfermóvil · TRX · USDT'),
        ),
        const ListTile(
          leading: Icon(Icons.help_outline),
          title: Text('Ayuda'),
          subtitle: Text('Soporte y preguntas'),
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Tienda Cuba v1.0\nPagos: Transfermóvil BANDEC + TRX/USDT',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }

  void _showCheckout() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Elige método de pago',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ${cartTotal.toStringAsFixed(0)} CUP',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              PayOption(
                icon: Icons.phone_android,
                title: 'Transfermóvil CUP',
                subtitle: 'BANDEC · aprobación manual',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(ctx);
                  _showTransfermovil('CUP', cartTotal);
                },
              ),
              const SizedBox(height: 10),
              PayOption(
                icon: Icons.currency_exchange,
                title: 'Transfermóvil MLC',
                subtitle: 'BANDEC · aprobación manual',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(ctx);
                  _showTransfermovil('MLC', cartTotal / 300);
                },
              ),
              const SizedBox(height: 10),
              PayOption(
                icon: Icons.currency_bitcoin,
                title: 'USDT TRC20 / TRX',
                subtitle: 'Confirmación automática',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(ctx);
                  _showCrypto(cartTotal / 300);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showTransfermovil(String currency, double amount) {
    const card = '9225 XXXX XXXX XXXX';
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Transfermóvil $currency'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monto: ${amount.toStringAsFixed(2)} $currency',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A84FF),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Tarjeta BANDEC:'),
              const SelectableText(
                card,
                style: TextStyle(fontFamily: 'monospace', fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Abre Transfermóvil\n'
                '2. Transfiere el monto exacto\n'
                '3. Guarda el SMS\n'
                '4. El admin verificará tu pago',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: card));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tarjeta copiada')),
                );
              },
              child: const Text('Copiar tarjeta'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => cart.clear());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pedido registrado. Esperando verificación.'),
                  ),
                );
              },
              child: const Text('Ya pagué'),
            ),
          ],
        );
      },
    );
  }

  void _showCrypto(double usdt) {
    const address = 'TXxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Pago Crypto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monto: ${usdt.toStringAsFixed(2)} USDT',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const Text(
                'Red: TRC20 (Tron)',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              const Text('Dirección:'),
              const SelectableText(
                address,
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              const SizedBox(height: 8),
              const Text(
                'Envía el monto exacto. Confirmación automática.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: address));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dirección copiada')),
                );
              },
              child: const Text('Copiar dirección'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => cart.clear());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Pedido registrado. Esperando blockchain.',
                    ),
                  ),
                );
              },
              child: const Text('Ya envié'),
            ),
          ],
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Container(
              color: product.color.withOpacity(0.15),
              child: Icon(product.icon, size: 56, color: product.color),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${product.priceCUP.toStringAsFixed(0)} CUP',
                    style: const TextStyle(
                      color: Color(0xFF0A84FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${product.priceMLC} MLC',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: FilledButton(
                      onPressed: onAdd,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0A84FF),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Añadir',
                        style: TextStyle(fontSize: 13),
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
}

class PayOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const PayOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
