import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';

import '../constants.dart';
import 'CartPage.dart';
import 'ContactPage.dart';
import 'ProductListPage.dart';
import 'cart_screen.dart';
import 'RegisterProductPage.dart';
import 'home_screen.dart';
import 'users_menu_screen.dart'; // Importa la pantalla del menú de usuario

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentTab = 2;
  List screens = const [
    RegisterProductPage(),
    ContactPage(),
    HomeScreen(),
    ProductListPage(),
    UserMenuPage(), // Cambia esta línea para mostrar UsersMenuScreen en la posición 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            currentTab = 2;
          });
        },
        shape: const CircleBorder(),
        backgroundColor: kprimaryColor,
        child: const Icon(
          Iconsax.home,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        height: 70,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 5,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => setState(() {
                currentTab = 0;
              }),
              icon: Icon(
                Ionicons.grid_outline,
                color: currentTab == 0 ? Colors.purple : Colors.purple, // Morado para el ícono de cuadritos
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                currentTab = 1;
              }),
              icon: Icon(
                Ionicons.chatbubble_outline, // Ícono de mensaje
                color: currentTab == 1 ? Colors.green : Colors.green, // Verde para el ícono de mensaje
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                currentTab = 3;
              }),
              icon: Icon(
                Ionicons.cart_outline,
                color: currentTab == 3 ? Colors.red : Colors.red, // Rojo para el ícono de compras
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                currentTab = 4; // Cambia a 4 para mostrar UsersMenuScreen
              }),
              icon: Icon(
                Ionicons.person_outline,
                color: currentTab == 4 ? kprimaryColor : Colors.blue,
              ),
            ),
          ],
        ),
      ),
      body: screens[currentTab],
    );
  }
}
