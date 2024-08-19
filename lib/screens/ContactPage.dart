import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Paquete para abrir enlaces en el navegador

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  // Método para lanzar la URL de WhatsApp
  Future<void> _launchWhatsApp() async {
    const url = 'https://wa.me/18296609165'; // Reemplaza con tu número de WhatsApp
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacta con Nosotros'),
        backgroundColor: Colors.pinkAccent, // Color de fondo del AppBar en tonos rosados
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¿Tienes alguna pregunta o necesitas ayuda?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Color del texto
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _launchWhatsApp,
                child: const Text(
                  'Contáctanos por WhatsApp',
                  style: TextStyle(
                    color: Colors.white, // Color del texto dentro del botón
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent, // Color de fondo del botón
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
