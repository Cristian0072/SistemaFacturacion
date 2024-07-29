import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:sistema_facturacion_movil/controladores/servicioSucursal.dart';
import 'package:sistema_facturacion_movil/controladores/utiles/mensajeUtil.dart';

class ProductoVista extends StatefulWidget {
  // Constructor de la clase ProductoVista
  const ProductoVista({super.key});

  @override
  _ProductoVista createState() => _ProductoVista();
}

class _ProductoVista extends State<ProductoVista> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _codigoController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _marcaController = TextEditingController();
  final _fechaFabricacionController = TextEditingController();
  final _fechaExpiracionController = TextEditingController();
  // Servicio de sucursal
  final ServicioSucursal _servicioSucursal = ServicioSucursal();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es', null);
  }

  //metodo para guardar un producto
  void _guardarProducto(String external) {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> producto = {
        "nombre": _nombreController.text.trim(),
        "descripcion": _descripcionController.text.trim(),
        "codigo": _codigoController.text.trim(),
        "cantidad_stock": int.parse(_cantidadController.text.trim()),
        "marca": _marcaController.text.trim(),
        "fecha_fabricacion": _fechaFabricacionController.text.trim(),
        "fecha_expiracion": _fechaExpiracionController.text.trim(),
      };
      log(external);
      _servicioSucursal.guardarProducto(producto, external).then((value) {
        if (value.code == 200) {
          MensajeUtil.mensajeExito(value.datos["tag"], context);
        } else {
          MensajeUtil.mensajeError(value.datos["error"], context);
        }
        Navigator.pushNamed(context, "/sucursal");
      });
    }
  }

//metodo para seleccionar la fecha
  void _seleccionarFecha(BuildContext context,
      TextEditingController controlador, bool estado) async {
    try {
      DateTime fechaActual = DateTime.now();
      DateTime? fecha = await showDatePicker(
        context: context,
        initialDate:
            estado ? fechaActual : fechaActual.add(const Duration(days: 1)),
        firstDate:
            estado ? DateTime(2022) : fechaActual.add(const Duration(days: 1)),
        lastDate: estado ? fechaActual : DateTime(2040),
        locale: const Locale("es", "ES"),
        confirmText: 'Aceptar',
        cancelText: 'Cancelar',
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color.fromARGB(255, 33, 204, 133),
                onPrimary: Colors.black,
                surface: Color.fromARGB(255, 21, 24, 28),
                onSurface: Colors.white,
              ),
              dialogBackgroundColor: const Color.fromARGB(255, 21, 24, 28),
            ),
            child: child!,
          );
        },
      );
      //verificar si la fecha no es nula
      if (fecha != null) {
        //se actualiza el controlador con la fecha seleccionada
        setState(() {
          controlador.text = DateFormat('dd/MM/yyyy').format(fecha);
        });
      }
    } catch (e) {
      log("El error es: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    //recibir el external de la sucursal
    final String external =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.pushNamed(context, "/sucursal");
            },
          ),
          title: const Text('Producto',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color.fromARGB(255, 21, 24, 28),
        ),
        backgroundColor: const Color.fromARGB(255, 21, 24, 28),
        // vista de lista de sucursales y productos
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _nombreController,
                    cursorColor: Colors.grey,
                    decoration: const InputDecoration(
                      hintText: 'Ingrese el nombre del producto',
                      labelText: 'Nombre',
                      labelStyle: TextStyle(color: Colors.white),
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.label, color: Colors.white),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.greenAccent),
                      ),
                    ),
                    style: const TextStyle(color: Colors.grey),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el nombre del producto';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _descripcionController,
                    cursorColor: Colors.grey,
                    maxLines: 3, //para que el campo de texto sea de 5 lineas
                    decoration: const InputDecoration(
                      hintText: 'Ingrese la descripción del producto',
                      labelText: 'Descripción',
                      labelStyle: TextStyle(color: Colors.white),
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.description, color: Colors.white),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.greenAccent),
                      ),
                    ),
                    style: const TextStyle(color: Colors.grey),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingrese la descripción del producto';
                      }

                      if (value.length > 250) {
                        return 'La descripción del producto supera el límite de 250 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _codigoController,
                    cursorColor: Colors.grey,
                    decoration: const InputDecoration(
                      hintText: 'Ingrese el código del producto',
                      labelText: 'Código de Producto',
                      hintStyle: TextStyle(color: Colors.grey),
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon:
                          Icon(Icons.label_important, color: Colors.white),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.greenAccent),
                      ),
                    ),
                    style: const TextStyle(color: Colors.grey),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el código del producto';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _marcaController,
                    cursorColor: Colors.grey,
                    decoration: const InputDecoration(
                      hintText: 'Ingrese la marca del producto',
                      labelText: 'Marca',
                      hintStyle: TextStyle(color: Colors.grey),
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon:
                          Icon(Icons.branding_watermark, color: Colors.white),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.greenAccent),
                      ),
                    ),
                    style: const TextStyle(color: Colors.grey),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la marca del producto';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _cantidadController,
                    cursorColor: Colors.grey,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      hintText: 'Ingrese la cantidad en stock',
                      hintStyle: TextStyle(color: Colors.grey),
                      labelText: 'Cantidad en stock',
                      prefixIcon: Icon(Icons.inventory, color: Colors.white),
                      labelStyle: TextStyle(color: Colors.white),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.greenAccent),
                      ),
                    ),
                    style: const TextStyle(color: Colors.grey),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la cantidad en stock del producto';
                      }
                      //verificar si tamaño es mayor a 0 y menor a 50000 productos
                      if (int.parse(value) <= 0 || int.parse(value) > 100000) {
                        return 'La cantidad de productos debe ser mayor a 0 y menor a 50000';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _fechaFabricacionController,
                    cursorColor: Colors.grey,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Fecha de fabricación',
                      hintStyle: TextStyle(color: Colors.grey),
                      hintText: 'Ingrese la fecha de fabricación',
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(Icons.date_range, color: Colors.white),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.greenAccent),
                      ),
                    ),
                    style: const TextStyle(color: Colors.grey),
                    onTap: () {
                      _seleccionarFecha(
                          context, _fechaFabricacionController, true);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la fecha de fabricación del producto';
                      }
                      //verificar si la fecha de fabricacion es menor a la fecha actual
                      DateTime fechaFabricacion =
                          DateFormat('dd/MM/yyyy').parseStrict(value);
                      if (fechaFabricacion == DateTime.now() ||
                          fechaFabricacion.isAfter(DateTime.now())) {
                        return 'La fecha de fabricación del producto debe ser menor o igual que la fecha actual';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _fechaExpiracionController,
                    cursorColor: Colors.grey,
                    readOnly: true,
                    decoration: const InputDecoration(
                      hintText: 'Ingrese la fecha de expiración',
                      hintStyle: TextStyle(color: Colors.grey),
                      labelText: 'Fecha de expiración',
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(Icons.date_range, color: Colors.white),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.greenAccent),
                      ),
                    ),
                    style: const TextStyle(color: Colors.grey),
                    onTap: () {
                      _seleccionarFecha(
                          context, _fechaExpiracionController, false);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la fecha de expiración del producto';
                      }
                      DateTime fechaExpiracion =
                          DateFormat('dd/MM/yyyy').parseStrict(value);
                      if (fechaExpiracion.isBefore(DateTime.now())) {
                        return 'La fecha de expiración del producto debe ser mayor que la fecha actual';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      _guardarProducto(external);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 33, 204, 133),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.all(15),
                    ),
                    child: const Text('Guardar producto',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
