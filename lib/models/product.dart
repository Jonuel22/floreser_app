import 'package:flutter/material.dart';

class Product {
  final String title;
  final String description;
  final String image;
  final double price;
  final List<Color> colors;
  final String category;
  final double rate;

  Product({
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    required this.colors,
    required this.category,
    required this.rate,
  });
}

final List<Product> products = [
  Product(
    title: "Arreglo de Rosas",
    description:
        "Arreglo en base a rosas y otras plantas",
    image: "assets/Rosasarreglo.jpg",
    price: 120,
    colors: [
      Colors.black,
      Colors.blue,
      Colors.orange,
    ],
    category: "Arreglos Florales",
    rate: 4.8,
  ),
  Product(
    title: "Arreglo de Lirios",
    description:
    "Arreglo en base a lirios y otras plantas",
    image: "assets/Lirios.jpg",
    price: 120,
    colors: [
      Colors.brown,
      Colors.red,
      Colors.pink,
    ],
    category: "Arreglos Florales",
    rate: 4.8,
  ),
  Product(
    title: "Arreglo de Claveles",
    description:
    "Arreglo en base a claveles y otras plantas",
    image: "assets/Clavelesarreglo.jpeg",
    price: 55,
    colors: [
      Colors.black,
    ],
    category: "Arreglos Florales",
    rate: 4.8,
  ),
];
