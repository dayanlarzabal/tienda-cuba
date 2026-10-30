import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/payment_transfermovil_screen.dart';
import 'screens/payment_crypto_screen.dart';
import 'screens/orders_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';

void main() {
  runApp(const TiendaCubaApp());
}

class TiendaCubaApp extends StatelessWidget {
  const TiendaCubaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp.router(
        title: 'Tienda Cuba',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0066CC),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        routerConfig: _router,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
    GoRoute(path: '/checkout', builder: (context, state) => const CheckoutScreen()),
    GoRoute(
      path: '/payment/transfermovil/:orderId',
      builder: (context, state) => PaymentTransfermovilScreen(
        orderId: state.pathParameters['orderId']!,
      ),
    ),
    GoRoute(
      path: '/payment/crypto/:orderId',
      builder: (context, state) => PaymentCryptoScreen(
        orderId: state.pathParameters['orderId']!,
      ),
    ),
    GoRoute(path: '/orders', builder: (context, state) => const OrdersScreen()),
  ],
);
