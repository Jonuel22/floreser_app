import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'ProductListPage.dart';
import 'main_screen.dart'; // Ajusta la ruta según la ubicación de tu archivo

class CartPage extends StatelessWidget {
  final List<Map<String, dynamic>> cart;

  const CartPage({super.key, required this.cart});

  Future<void> _showPaymentDialog(BuildContext context) async {
    final _paymentMethod = ValueNotifier<String?>(null);
    final _cashAmountController = TextEditingController();
    final _cardNumberController = TextEditingController();
    final _expiryDateController = TextEditingController();
    final _cvvController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Método de Pago'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<String?>(
                  valueListenable: _paymentMethod,
                  builder: (context, paymentMethod, _) {
                    return Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('Efectivo'),
                          value: 'cash',
                          groupValue: paymentMethod,
                          onChanged: (value) {
                            _paymentMethod.value = value;
                          },
                          activeColor: Colors.pinkAccent,
                        ),
                        RadioListTile<String>(
                          title: const Text('Tarjeta'),
                          value: 'card',
                          groupValue: paymentMethod,
                          onChanged: (value) {
                            _paymentMethod.value = value;
                          },
                          activeColor: Colors.pinkAccent,
                        ),
                        if (paymentMethod == 'cash') ...[
                          TextFormField(
                            controller: _cashAmountController,
                            decoration: const InputDecoration(
                              labelText: 'Cantidad de Efectivo',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.money_off, color: Colors.pinkAccent),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese la cantidad de efectivo';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Ingrese una cantidad válida';
                              }
                              return null;
                            },
                          ),
                        ] else if (paymentMethod == 'card') ...[
                          TextFormField(
                            controller: _cardNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Número de Tarjeta',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.credit_card, color: Colors.pinkAccent),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese el número de tarjeta';
                              }
                              if (value.length < 16) {
                                return 'Número de tarjeta inválido';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _expiryDateController,
                            decoration: const InputDecoration(
                              labelText: 'Fecha de Vencimiento (MM/AA)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today, color: Colors.pinkAccent),
                            ),
                            keyboardType: TextInputType.datetime,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese la fecha de vencimiento';
                              }
                              final parts = value.split('/');
                              if (parts.length != 2 || parts[0].length != 2 || parts[1].length != 2) {
                                return 'Ingrese una fecha válida (MM/AA)';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _cvvController,
                            decoration: const InputDecoration(
                              labelText: 'CVV',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.lock, color: Colors.pinkAccent),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese el CVV';
                              }
                              if (value.length != 3) {
                                return 'CVV inválido';
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.pinkAccent,
              ),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  if (_paymentMethod.value == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Seleccione un método de pago')),
                    );
                    return;
                  }
                  Navigator.of(context).pop();
                  _processPurchase(
                    context,
                    _paymentMethod.value!,
                    _cashAmountController.text,
                    _cardNumberController.text,
                    _expiryDateController.text,
                    _cvvController.text,
                  );
                }
              },
              child: const Text('Procesar Compra'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.pinkAccent,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processPurchase(
      BuildContext context,
      String paymentMethod,
      String cashAmount,
      String cardNumber,
      String expiryDate,
      String cvv,
      ) async {
    final url = Uri.parse('http://192.168.68.112:3000/api/process-purchase');
    double? cash = paymentMethod == 'cash' ? double.tryParse(cashAmount) : null;

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'products': cart.map((product) => {
            'id': product['id'],
            'cantidad': product['cantidad'],
          }).toList(),
          'paymentMethod': paymentMethod,
          'cashAmount': cash,
          'cardNumber': paymentMethod == 'card' ? cardNumber : null,
          'expiryDate': paymentMethod == 'card' ? expiryDate : null,
          'cvv': paymentMethod == 'card' ? cvv : null,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => InvoicePage(
              cart: cart,
              total: cart.fold(0.0, (sum, item) {
                final precio = (item['precio'] as num).toDouble();
                final cantidad = (item['cantidad'] as int).toDouble();
                return sum + (precio * cantidad);
              }),
              paymentMethod: paymentMethod,
              cashAmount: cash,
            ),
          ),
              (route) => route.settings.name == '/product-list-page', // Cambia '/product-list-page' por el nombre de la ruta de ProductListPage
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al procesar la compra')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de red')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = cart.fold(0.0, (sum, item) {
      final precio = (item['precio'] as num).toDouble();
      final cantidad = (item['cantidad'] as int).toDouble();
      return sum + (precio * cantidad);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: cart.isEmpty
          ? const Center(child: Text('El carrito está vacío'))
          : SingleChildScrollView(
        child: Column(
          children: [
            ...cart.map((product) {
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Eliminado el widget de imagen
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['nombre'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Cantidad: ${product['cantidad']}'),
                            Text('Precio: \$${product['precio'].toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: ElevatedButton(
                onPressed: () => _showPaymentDialog(context),
                child: const Text('Pagar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class InvoicePage extends StatelessWidget {
  final List<Map<String, dynamic>> cart;
  final double total;
  final String paymentMethod;
  final double? cashAmount;

  const InvoicePage({
    super.key,
    required this.cart,
    required this.total,
    required this.paymentMethod,
    this.cashAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Factura'),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => MainScreen()), // Ajusta según la ubicación de ProductListPage
                    (route) => route.isFirst,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información de contacto en el encabezado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Floreser',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Las flores mejoran cualquier ambiente'),
                    Text('WhatsApp: 1 829-660-9165'),
                    Text('Correo: floreser_info@gmail.com'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Factura de Compra',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            ...cart.map((product) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(product['nombre']),
                    Text('\$${((product['precio'] as num) * (product['cantidad'] as int)).toStringAsFixed(2)}'),
                  ],
                ),
              );
            }).toList(),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            if (paymentMethod == 'cash') ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Efectivo Recibido:'),
                    Text('\$${cashAmount?.toStringAsFixed(2) ?? '0.00'}'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Cambio:'),
                    Text('\$${(cashAmount != null ? cashAmount! - total : 0.00).toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ],
            if (paymentMethod == 'card') ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pago con Tarjeta'),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Gracias por su compra!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
