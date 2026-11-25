import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_bear_animation/screens/login_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // 10.0.2.2 redirige al localhost de tu computadora desde el emulador Android
  final String apiUrl = 'http://10.0.2.2:8080/products';

  Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // utf8.decode evita problemas con acentos o la letra ñ
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Error al cargar productos: ${response.statusCode}');
    }
  }

  Future<void> _onSignOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Productos'),
        actions: [
          IconButton(
            onPressed: _onSignOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error de conexión: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos registrados.'));
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final item = products[index];
              return ListTile(
                title: Text(item['name']?.toString() ?? 'Sin nombre'),
                subtitle: Text(
                  'Categoría: ${item['category']?['category'] ?? ''} • Stock: ${item['stock'] ?? 0}',
                ),
                trailing: Text('\$${item['price'] ?? '0.00'}'),
              );
            },
          );
        },
      ),
    );
  }
}
