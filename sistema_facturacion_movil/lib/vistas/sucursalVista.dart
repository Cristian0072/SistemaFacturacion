import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:sistema_facturacion_movil/controladores/servicioSucursal.dart';

class SucursalVista extends StatefulWidget {
  const SucursalVista({super.key});

  @override
  _SucursalVista createState() => _SucursalVista();
}

class _SucursalVista extends State<SucursalVista> {
  // Servicio de sucursal
  final ServicioSucursal _servicioSucursal = ServicioSucursal();
  // Lista de sucursales con sucursalesFiltradas
  List<Map<String, dynamic>> sucursales = [];
  //lista para guardar una copia de los sucursalesFiltradas originales
  List<Map<String, dynamic>> sucursalesFiltradas = [];
  //lista de sucursales originales
  List<Map<String, dynamic>> sucursalesOriginales = [];
  //Mapa para manejar los filtros de seleccion de sucursalesFiltradas
  Map<int, String> filtro = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarSucursales();
  }

//metodo para cargar las sucursales
  _cargarSucursales() async {
    setState(() {
      _cargando = true;
    });
    // Obtener las listas de sucursales desde el servicio de sucursal
    List<dynamic> datos = await _servicioSucursal.listarSucursalesProductos();
    // actualizar la lista de sucursalesFiltradas de la sucursal con los datos obtenidos
    setState(() {
      // Lista de sucursales con los datos obtenidos
      sucursales = List<Map<String, dynamic>>.from(datos);
      // se guarda una copia de los sucursalesFiltradas originales
      sucursalesFiltradas = List<Map<String, dynamic>>.from(datos);
      // se guarda una copia de los sucursales originales
      sucursalesOriginales = List<Map<String, dynamic>>.from(datos);
      filtro = {for (int i = 0; i < sucursales.length; i++) i: 'TODOS'};
      _cargando = false;
    });
  }

  // Método para filtrar sucursalesFiltradas por estado
  void filtrarProductos(int indice, String estado) async {
    // Filtrar sucursalesFiltradas por estado seleccionado
    if (estado == 'TODOS') {
      //buscar la sucursal original por external_id y obtener los productos originales
      final sucursalOriginal = sucursalesOriginales.firstWhere(
          (element) =>
              element['external_id'] == sucursales[indice]['external_id'],
          orElse: () => {});
      //si la sucursal no esta vacia
      if (sucursalOriginal.isNotEmpty) {
        // Actualizar la lista de sucursalesFiltradas de la sucursal con los datos obtenidos
        setState(() {
          sucursalesFiltradas[indice]['productos'] =
              List<Map<String, dynamic>>.from(sucursalOriginal['productos']);
          filtro[indice] = 'TODOS';
        });
      } else {
        // si no se encuentra la sucursal original se limpia la lista de productos
        setState(() {
          sucursalesFiltradas[indice]['productos'] = [];
          filtro[indice] = 'TODOS';
        });
      }
    } else {
      // Obtener los productos de la sucursal filtrados por estado
      List<dynamic> productosFiltrados = await _servicioSucursal
          .obtenerSucursal(
              sucursales[indice]['external_id'], {'estado': estado});
      // actualizar la lista de sucursalesFiltradas de la sucursal con los datos obtenidos
      setState(() {
        sucursalesFiltradas[indice]['productos'] =
            List<Map<String, dynamic>>.from(productosFiltrados);
        filtro[indice] = estado;
      });
    }
  }

  //metodo para convertir la fecha
  String formatearFecha(String fecha) {
    // Inicializar el formato de fecha en español
    initializeDateFormatting('es');
    // Especificar el formato de entrada esperado para la fecha
    DateFormat inputFormat =
        DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", 'en_US');
    // Parsear la fecha en UTC
    DateTime parsedDate = inputFormat.parseUTC(fecha);
    // Formatear la fecha a un formato legible en español
    return DateFormat.yMMMMd('es_ES').format(parsedDate);
  }

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () {
            Navigator.pushNamed(contexto, "/panel");
          },
        ),
        title: const Text('Sucursales y Productos',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 21, 24, 28),
      ),
      backgroundColor: const Color.fromARGB(255, 21, 24, 28),
      // vista de lista de sucursales y sucursalesFiltradas
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.greenAccent,
              ),
            )
          : ListView.builder(
              itemCount: sucursalesFiltradas.length, // Cantidad de sucursales
              itemBuilder: (contexto, indice) {
                // Datos de la sucursal
                final sucursal = sucursalesFiltradas[indice];
                //Productos de la sucursal con filtro
                final productosFiltrados =
                    List<Map<String, dynamic>>.from(sucursal['productos']);
                // expandir la lista de sucursalesFiltradas de la sucursal
                return ExpansionTile(
                  title: Text(sucursal['nombre'],
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  subtitle: Text(
                    sucursal['direccion'],
                    style: const TextStyle(color: Colors.grey),
                  ),
                  // Lista de sucursalesFiltradas de la sucursal
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // Lista de sucursalesFiltradas de la sucursal
                        children: [
                          // Filtro de sucursalesFiltradas por estado
                          Row(
                            // Alinear los elementos de la fila a los extremos
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Filtrar por estado:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              DropdownButton<String>(
                                dropdownColor:
                                    const Color.fromARGB(255, 21, 24, 28),
                                value: filtro[indice] == 'A_PUNTO_DE_CADUCAR'
                                    ? 'A PUNTO DE CADUCAR'
                                    : filtro[indice],
                                items: <String>[
                                  'TODOS',
                                  'BUENO',
                                  'A PUNTO DE CADUCAR',
                                  'CADUCADO'
                                ].map<DropdownMenuItem<String>>((String valor) {
                                  // retornar un item de la lista de estados
                                  return DropdownMenuItem<String>(
                                    value: valor,
                                    child: Text(valor,
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  );
                                }).toList(),
                                // Cambiar el estado de filtro de sucursalesFiltradas por estado
                                onChanged: (String? valor) {
                                  // Filtrar sucursalesFiltradas por estado seleccionado
                                  if (valor != null) {
                                    if (valor == 'A PUNTO DE CADUCAR') {
                                      valor = 'A_PUNTO_DE_CADUCAR';
                                    }
                                    filtrarProductos(indice, valor);
                                  }
                                },
                              ),
                            ],
                          ),
                          // Lista de sucursalesFiltradas de la sucursal
                          ...productosFiltrados.map<Widget>((producto) {
                            // Datos del producto de la sucursal
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Text(producto['nombre'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Descripción: ${producto['descripcion']}",
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                      Text(
                                        "Código: ${producto['codigo']}",
                                        style: const TextStyle(
                                            color: Colors.white70),
                                      ),
                                      Text(
                                          "Cantidad en stock: ${producto['cantidad_stock']}",
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                      Text("Estado: ${producto['estado']}",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          )),
                                      Text(
                                        "Marca: ${producto['marca']}",
                                        style: const TextStyle(
                                            color: Colors.white70),
                                      ),
                                      // Lista de lotes del producto
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: producto['lote']
                                            .map<Widget>((lote) {
                                          // Lista de lotes del producto con fecha de fabricación y expiración
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  "Fecha de fabricación: ${formatearFecha(lote['fecha_fabricacion'])}",
                                                  style: const TextStyle(
                                                      color: Colors.white70)),
                                              Text(
                                                  "Fecha de expiración: ${formatearFecha(lote['fecha_expiracion'])}",
                                                  style: const TextStyle(
                                                      color: Colors.white70)),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navegar a la pantalla de agregar producto
                          Navigator.pushNamed(contexto, '/producto',
                              arguments: sucursal['external_id']);
                        },
                        icon: const Icon(
                          Icons.add_circle_outline_outlined,
                          color: Colors.black,
                        ),
                        label: const Text('Agregar Producto',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                              255, 33, 204, 133), // Color del botón
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(contexto, '/sucursal/nueva');
        },
        label: const Text(
          'Agregar Sucursal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        icon: const Icon(
          Icons.add,
          size: 25,
          color: Colors.black,
        ),
        backgroundColor: const Color.fromARGB(255, 33, 204, 133),
      ),
    );
  }
}
