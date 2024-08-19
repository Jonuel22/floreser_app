import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  _ChangeEmailPageState createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String newEmail = '';
  bool isLoading = true;

  Future<void> fetchUserInfo() async {
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
        username = data['username'] ?? '';
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load user info');
    }
  }

  Future<void> updateEmail() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.put(
        Uri.parse('http://192.168.68.112:3000/change-email'),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': token,
        },
        body: jsonEncode({
          'username': username,
          'new_email': newEmail,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        throw Exception('Failed to update email');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cambiar Correo'),
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
                initialValue: username,
                decoration: InputDecoration(labelText: 'Nombre de Usuario'),
                enabled: false, // Campo no editable
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nuevo Correo Electrónico'),
                onSaved: (value) => newEmail = value ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo requerido';
                  }
                  final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                  if (!emailRegExp.hasMatch(value)) {
                    return 'Correo electrónico inválido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateEmail,
                child: Text('Actualizar Correo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
