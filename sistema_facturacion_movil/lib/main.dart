import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sistema_facturacion_movil/vistas/credencialesVista.dart';
import 'package:sistema_facturacion_movil/vistas/panel.dart';
import 'package:sistema_facturacion_movil/vistas/perfilVista.dart';
import 'package:sistema_facturacion_movil/vistas/productoVista.dart';
import 'package:sistema_facturacion_movil/vistas/sesionVista.dart';
import 'package:sistema_facturacion_movil/vistas/sucursalMapaVista.dart';
import 'package:sistema_facturacion_movil/vistas/sucursalNVista.dart';
import 'package:sistema_facturacion_movil/vistas/sucursalVista.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de facturación móvil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 0, 0)),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate //para el idioma de material
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      locale: const Locale('es', 'ES'),
      //llamamos a la vista de inicio de sesion
      home: const SesionVista(),
      routes: {
        '/panel': (context) => const Panel(),
        '/perfil': (context) => const PerfilVista(),
        '/credenciales': (context) => const CredencialesVista(),
        '/mapa': (context) => const SucursalMapaVista(),
        '/sucursal': (context) => const SucursalVista(),
        '/producto': (context) => const ProductoVista(),
        '/sucursal/nueva': (context) => const sucursalNVista(),
      },
    );
  }
}
