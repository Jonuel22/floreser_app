import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EditAddressPage extends StatefulWidget {
  const EditAddressPage({super.key});

  @override
  _EditAddressPageState createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  String street = '';
  String city = '';
  String state = '';
  String postalCode = '';
  String country = '';
  bool isLoading = true;

  Future<void> fetchAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('http://192.168.68.112:3000/user-info'),
      headers: {
        'x-access-token': token,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        street = data['address']['street'] ?? '';
        city = data['address']['city'] ?? '';
        state = data['address']['state'] ?? '';
        postalCode = data['address']['postal_code'] ?? '';
        country = data['address']['country'] ?? '';
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load address');
    }
  }

  Future<void> updateAddress() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.put(
        Uri.parse('http://192.168.68.112:3000/changeAddress'),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': token,
        },
        body: jsonEncode({
          'street': street,
          'city': city,
          'state': state,
          'postal_code': postalCode,
          'country': country,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dirección actualizada exitosamente')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar la dirección: ${response.body}')),
        );
        throw Exception('Failed to update address');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Dirección'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: street,
                decoration: InputDecoration(labelText: 'Calle'),
                onSaved: (value) => street = value ?? '',
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                initialValue: city,
                decoration: InputDecoration(labelText: 'Ciudad'),
                onSaved: (value) => city = value ?? '',
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                initialValue: state,
                decoration: InputDecoration(labelText: 'Estado'),
                onSaved: (value) => state = value ?? '',
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                initialValue: postalCode,
                decoration: InputDecoration(labelText: 'Código Postal'),
                onSaved: (value) => postalCode = value ?? '',
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                initialValue: country,
                decoration: InputDecoration(labelText: 'País'),
                onSaved: (value) => country = value ?? '',
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateAddress,
                child: Text('Actualizar Dirección'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
