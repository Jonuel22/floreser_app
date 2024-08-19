import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'AddAddressPage.dart';
import 'ChangePasswordPage.dart';
import 'EditAddressPage.dart';
import 'EditEmailPage.dart';
import 'EditUsernamePage.dart'; // Importar la página de editar nombre de usuario
import 'login_screen.dart';
import 'forgot_password_page.dart';

class UserMenuPage extends StatefulWidget {
  const UserMenuPage({super.key});

  @override
  _UserMenuPageState createState() => _UserMenuPageState();
}

class _UserMenuPageState extends State<UserMenuPage> {
  String username = '';
  String email = '';
  String street = '';
  String city = '';
  String state = '';
  String postalCode = '';
  String country = '';
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
        username = data['username'];
        email = data['email'];
        street = data['address']['street'] ?? 'No registrado';
        city = data['address']['city'] ?? 'No registrado';
        state = data['address']['state'] ?? 'No registrado';
        postalCode = data['address']['postal_code'] ?? 'No registrado';
        country = data['address']['country'] ?? 'No registrado';
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load user info');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menú de Usuario',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pinkAccent,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del Usuario',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      leading: Icon(Icons.person, color: Colors.blue),
                      title: Text('Nombre de Usuario'),
                      subtitle: Text(username.isNotEmpty ? username : 'Cargando...'),
                    ),
                    ListTile(
                      leading: Icon(Icons.email, color: Colors.blue),
                      title: Text('Correo Electrónico'),
                      subtitle: Text(email.isNotEmpty ? email : 'Cargando...'),
                      trailing: IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ChangeEmailPage()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dirección',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      leading: Icon(Icons.location_on, color: Colors.blue),
                      title: Text('Dirección'),
                      subtitle: Text(
                          '${street.isNotEmpty ? street : 'No registrado'}, ${city.isNotEmpty ? city : 'No registrado'}, ${state.isNotEmpty ? state : 'No registrado'}, ${postalCode.isNotEmpty ? postalCode : 'No registrado'}, ${country.isNotEmpty ? country : 'No registrado'}'
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.add_location, color: Colors.blue),
                      title: Text('Agregar Dirección'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterAddressPage()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.edit_location, color: Colors.blue),
                      title: Text('Editar Dirección'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditAddressPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seguridad',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      leading: Icon(Icons.lock, color: Colors.blue),
                      title: Text('Cambiar Contraseña'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChangePasswordPage(email: email)),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.exit_to_app, color: Colors.blue),
                      title: Text('Cerrar Sesión'),
                      onTap: () {
                        logout();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: UserMenuPage(),
  ));
}
