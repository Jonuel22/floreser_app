import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EditUsernamePage extends StatefulWidget {
  final String username;

  EditUsernamePage({required this.username});

  @override
  _EditUsernamePageState createState() => _EditUsernamePageState();
}

class _EditUsernamePageState extends State<EditUsernamePage> {
  final TextEditingController _usernameController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.username;
  }

  Future<void> editUsername() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? ''; // Obtén el ID del usuario

    // Verifica si el nombre de usuario no está vacío
    if (_usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El nombre de usuario no puede estar vacío')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    final response = await http.put(
      Uri.parse('http://192.168.68.112:3000/cambiar-usuario'), // Asegúrate de que esta URL sea correcta
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': _usernameController.text,
        'userId': userId,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, _usernameController.text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al editar el nombre de usuario')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Nombre de Usuario'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Nombre de Usuario'),
              textInputAction: TextInputAction.done,
              onEditingComplete: editUsername, // Editar cuando el usuario presione "hecho"
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : editUsername,
              child: isLoading
                  ? CircularProgressIndicator()
                  : Text('Editar'),
            ),
          ],
        ),
      ),
    );
  }
}


