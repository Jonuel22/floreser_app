import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _securityAnswer1Controller = TextEditingController();
  final TextEditingController _securityAnswer2Controller = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  String? _securityQuestion1;
  String? _securityQuestion2;
  bool _showSecurityQuestions = false;

  Future<void> recoverPassword() async {
    final response = await http.post(
      Uri.parse('http://192.168.68.110:3000/forgot-password'), // Reemplaza con la IP de tu servidor backend
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': _emailController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _securityQuestion1 = data['security_question_1'];
        _securityQuestion2 = data['security_question_2'];
        _showSecurityQuestions = true;
      });
    } else if (response.statusCode == 404) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Correo no encontrado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al recuperar preguntas de seguridad')),
      );
    }
  }

  Future<void> verifySecurityAnswers() async {
    final response = await http.post(
      Uri.parse('http://192.168.68.112:3000/verify-security-answers'), // Reemplaza con la IP de tu servidor backend
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': _emailController.text,
        'security_answer_1': _securityAnswer1Controller.text,
        'security_answer_2': _securityAnswer2Controller.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      resetPassword(data['token']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Respuestas incorrectas')),
      );
    }
  }

  Future<void> resetPassword(String token) async {
    final response = await http.post(
      Uri.parse('http://192.168.0.104:3000/reset-password'), // Reemplaza con la IP de tu servidor backend
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'new_password': _newPasswordController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contraseña cambiada exitosamente')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cambiar la contraseña')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recuperar contraseña'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
              ),
            ),
            if (_showSecurityQuestions) ...[
              Text(_securityQuestion1 ?? ''),
              TextField(
                controller: _securityAnswer1Controller,
                decoration: InputDecoration(
                  labelText: 'Respuesta de seguridad 1',
                ),
              ),
              Text(_securityQuestion2 ?? ''),
              TextField(
                controller: _securityAnswer2Controller,
                decoration: InputDecoration(
                  labelText: 'Respuesta de seguridad 2',
                ),
              ),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                ),
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showSecurityQuestions ? verifySecurityAnswers : recoverPassword,
              child: Text(_showSecurityQuestions ? 'Verificar respuestas' : 'Recuperar contraseña'),
            ),
          ],
        ),
      ),
    );
  }
}
