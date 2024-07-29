import 'package:sistema_facturacion_movil/vistas/menuBar.dart' as menu;
import 'package:flutter/material.dart';

class Panel extends StatefulWidget {
  const Panel({super.key});

  @override
  _PanelState createState() => _PanelState();
}

class _PanelState extends State<Panel> {
  @override
  //metodo para construir la vista de panel
  Widget build(BuildContext context) {
    //se retorna un Scaffold
    return Scaffold(
      //se le da un appbar
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 24, 28),
        title: const Text('Panel de control',
            style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 30,
                fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white, size: 40),
      ),
      backgroundColor: const Color.fromARGB(255, 21, 24, 28),
      // menu lateral (amburgesa)
      drawer: const menu.MenuBar(),
      //se le da un cuerpo
      body: const Center(
        child: Text('Bienvenido al panel de control!',
            style: TextStyle(color: Colors.white54, fontSize: 20)),
      ),
    );
  }
}
