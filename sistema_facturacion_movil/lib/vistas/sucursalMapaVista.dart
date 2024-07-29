import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:sistema_facturacion_movil/controladores/servicioSucursal.dart';
import 'package:latlong2/latlong.dart';

class SucursalMapaVista extends StatefulWidget {
  const SucursalMapaVista({super.key});

  @override
  _SucursalMapaVista createState() => _SucursalMapaVista();
}

class _SucursalMapaVista extends State<SucursalMapaVista> {
  List<Marker> _marcadores = []; // Lista de marcadores para el mapa
  final ServicioSucursal _servicioSucursal =
      ServicioSucursal(); // Servicio de sucursal
  // Método para cargar las sucursales desde el servicio de la vista
  @override
  void initState() {
    super.initState();
    _cargarSucursales();
  }

  void _cargarSucursales() async {
    // Obtener las listas de sucursales desde el servicio de sucursal
    List<Map<String, dynamic>> sucursales =
        await _servicioSucursal.listarSucursales();
    // se actualiza el estado de la vista con los marcadores de las sucursales
    setState(() {
      _marcadores = sucursales.map((sucursal) {
        return Marker(
          width: 200.0,
          height: 200.0,
          point: LatLng(sucursal['latitud'], sucursal['longitud']),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Tamaño principal mínimo
            children: [
              Icon(
                Icons.location_pin,
                color: sucursal['estado']["caducados"] > 0
                    ? Colors.red
                    : Colors.green,
                size: 50.0,
              ),
              // Contenedor con la información de la sucursal
              Container(
                width: 100,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5, // difuminar la sombra
                      offset: Offset(0, 2), // desplazamiento de la sombra
                    ),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 180,
                  ),
                  // Columna con la información de la sucursal
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Alinear el texto a la izquierda
                      children: [
                        Text(
                          sucursal['nombre'],
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "Productos:",
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                        Text(
                          "Buenos: ${sucursal['estado']["buenos"]}",
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "A punto de caducar: ${sucursal['estado']["por_caducar"]}",
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Caducados: ${sucursal['estado']['caducados']}",
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList();
    });
  }

  // Método para construir la vista de la pantalla de sucursales
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 24, 28),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_sharp,
            size: 30,
            color: Colors.white,
          ),
          onPressed: () {
            // Cerrar la pantalla de perfil
            Navigator.pushNamed(context, '/panel');
          },
        ),
        title: const Text(
          'Sucursales',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
        ),
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(-3.972005, -79.202593), // Coordenadas iniciales
          initialZoom: 14, // Zoom inicial
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(markers: _marcadores),
        ],
      ),
    );
  }
}
