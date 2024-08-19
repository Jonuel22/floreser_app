import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // Importa para File
import 'package:image_picker/image_picker.dart'; // Importa para ImagePicker

class RegisterProductPage extends StatefulWidget {
  const RegisterProductPage({super.key});

  @override
  _RegisterProductPageState createState() => _RegisterProductPageState();
}

class _RegisterProductPageState extends State<RegisterProductPage> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';
  String _descripcion = '';
  String _precio = '';
  String _idCategoria = '';
  String _cantidad = '';
  File? _image; // Agregado para la imagen

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _registerProduct() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.68.112:3000/api/registerProduct'),
    );

    request.fields['nombre'] = _nombre;
    request.fields['descripcion'] = _descripcion;
    request.fields['precio'] = _precio;
    request.fields['id_categoria'] = _idCategoria;
    request.fields['cantidad'] = _cantidad;

    if (_image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto registrado exitosamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar el producto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Producto'),
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Registrar un nuevo producto',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField('Nombre', (value) => _nombre = value),
                  SizedBox(height: 16),
                  _buildTextField('Descripción', (value) => _descripcion = value),
                  SizedBox(height: 16),
                  _buildTextField('Precio', (value) => _precio = value, keyboardType: TextInputType.number),
                  SizedBox(height: 16),
                  _buildTextField('ID Categoría', (value) => _idCategoria = value, keyboardType: TextInputType.number),
                  SizedBox(height: 16),
                  _buildTextField('Cantidad', (value) => _cantidad = value, keyboardType: TextInputType.number),
                  SizedBox(height: 24),
                  _buildImagePicker(),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _registerProduct();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child: Text('Registrar Producto'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.black38),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese $label';
        }
        return null;
      },
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Selecciona una imagen',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        SizedBox(height: 16),
        _image == null
            ? TextButton(
          onPressed: _pickImage,
          child: Text('Seleccionar Imagen'),
        )
            : Column(
          children: [
            Image.file(_image!, height: 150, width: 150, fit: BoxFit.cover),
            TextButton(
              onPressed: _pickImage,
              child: Text('Cambiar Imagen'),
            ),
          ],
        ),
      ],
    );
  }
}
