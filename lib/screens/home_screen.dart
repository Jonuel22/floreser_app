import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../constants.dart';
import '../widgets/categories.dart';
import '../widgets/home_appbar.dart';
import '../widgets/home_slider.dart';
import '../widgets/product_card.dart';
import '../widgets/search_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentSlide = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco para una apariencia limpia
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0), // Espaciado general
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado estilizado con una imagen local
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Image.asset(
                    'assets/Logo.png', // Ruta de la imagen local
                    width: double.infinity, // Ajusta el ancho de la imagen
                    height: 150, // Ajusta la altura de la imagen según sea necesario
                    fit: BoxFit.cover, // Ajusta la imagen para que cubra el área disponible
                  ),
                ),
                const SizedBox(height: 15),
                // Campo de búsqueda estilizado
                const SearchField(),
                const SizedBox(height: 15),
                // Slider con un diseño atractivo
                HomeSlider(
                  onChange: (value) {
                    setState(() {
                      currentSlide = value;
                    });
                  },
                  currentSlide: currentSlide,
                ),
                const SizedBox(height: 20),
                // Categorías en un diseño tipo Shein
                const Categories(),
                const SizedBox(height: 20),
                // Título de bienvenida
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Bienvenido",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Color de texto oscuro
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Contenedor de bienvenida con diseño tipo Shein
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent, // Color vibrante al estilo Shein
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    "¡Estamos encantados de tenerte aquí! Explora nuestros productos y encuentra lo que más te guste. Si necesitas ayuda, no dudes en contactarnos.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // Texto blanco para contraste
                    ),
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
