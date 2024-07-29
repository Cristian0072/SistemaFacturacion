import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sistema_facturacion_movil/controladores/servicioSucursal.dart';
import 'package:sistema_facturacion_movil/controladores/utiles/mensajeUtil.dart';

class sucursalNVista extends StatefulWidget {
  const sucursalNVista({super.key});

  @override
  _sucursalNVistaState createState() => _sucursalNVistaState();
}

class _sucursalNVistaState extends State<sucursalNVista> {
  final _formKey = GlobalKey<FormState>();
  LatLng _seleccionUbicacion =
      const LatLng(-4.00064661, -79.20426114); //Ubicacion por defecto
  String _direccion = '';
  final MapController _mapaController = MapController();
  final _nombreController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  final _direccionController = TextEditingController();
  final ServicioSucursal _servicioSucursal = ServicioSucursal();
  bool _dialogoActivo = false;
  bool _permiso = false;

  @override
  void initState() {
    super.initState();
    _verificarUbicacion();
  }

  //limpiar los controladores
  @override
  void dispose() {
    _nombreController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  // Método para verificar la ubicación y permisos
  void _verificarUbicacion() async {
    // Verificar si el servicio de ubicación está activo
    bool servicioActivo = await Geolocator.isLocationServiceEnabled();
    if (!servicioActivo) {
      if (!_dialogoActivo) {
        _mostrarMensajePermiso();
      }
      return;
    }
    // Verificar si la aplicación tiene permiso para acceder a la ubicación
    var estado = await Permission.location.status;
    // Verificar si el permiso de ubicación ha sido denegado o limitado
    if (estado.isGranted) {
      _permiso = true;
      _obtenerUbicacionActual();
    } else if (estado.isDenied) {
      // Solicitar permiso de ubicación si no se ha concedido
      if (await Permission.location.request().isGranted) {
        setState(() {
          _permiso = true;
        });
        _obtenerUbicacionActual();
      }
    } else if (estado.isPermanentlyDenied) {
      // Si el permiso de ubicación ha sido permanentemente denegado, mostrar un mensaje de advertencia
      _mostrarMensajePermiso();
    }
  }

  // Método para obtener la ubicación actual del dispositivo
  void _obtenerUbicacionActual() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      _actualizarUbicacion(LatLng(position.latitude, position.longitude));
    } catch (e) {
      if (!_dialogoActivo) {
        _mostrarMensajePermiso();
      }
    }
  }

  // Método para obtener la dirección de la ubicación seleccionada
  void _obtenerDireccion(LatLng ubicacion) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          ubicacion.latitude, ubicacion.longitude);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        setState(() {
          _direccion =
              "${placemark.street}, ${placemark.locality}, ${placemark.country}";
          _direccionController.text = _direccion;
          _latitudController.text = ubicacion.latitude.toString();
          _longitudController.text = ubicacion.longitude.toString();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.redAccent, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: const Text(
                "No se puede obtener la dirección",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 21, 24, 28),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Método para seleccionar la ubicación en el mapa
  void _actualizarUbicacion(LatLng ubicacion) {
    setState(() {
      _seleccionUbicacion = ubicacion;
      _obtenerDireccion(ubicacion);
      _mapaController.move(ubicacion, 15);
    });
  }

  // Método para mostrar un mensaje de advertencia cuando el permiso de ubicación ha sido denegado
  void _mostrarMensajePermiso() {
    _dialogoActivo = true;
    showDialog(
      context: context,
      barrierDismissible:
          false, // No se puede cerrar el diálogo haciendo clic fuera de él
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Ubicación desactivada",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Activa la ubicación para continuar",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 21, 24, 28),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                //mostrar un mensaje de error en la pantalla
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.redAccent, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        "No se puede continuar sin habilitar la ubicación",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    backgroundColor: const Color.fromARGB(255, 21, 24, 28),
                    duration: const Duration(seconds: 2),
                  ),
                );

                //esperar 3 segundos para cerrar la pantalla
                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.of(context).pop(); // Cerrar el diálogo
                  _dialogoActivo = false;
                  //navegar a la pantalla de sucursal y cerrar la pantalla actual
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/sucursal', (route) => false);
                });
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 33, 204, 133),
                textStyle: const TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                var estado = await Permission.location.request();
                if (estado.isGranted) {
                  Navigator.of(context).pop(); // Cerrar el diálogo
                  setState(() {
                    _permiso = true;
                    _dialogoActivo = false;
                  });
                  _obtenerUbicacionActual();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    //mostrar un mensaje de error en la pantalla
                    SnackBar(
                      content: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.redAccent, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Text(
                          "No se puede continuar sin habilitar la ubicación",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      backgroundColor: const Color.fromARGB(255, 21, 24, 28),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  Future.delayed(const Duration(seconds: 2), () {
                    Navigator.of(context).pop(); // Cerrar el diálogo
                    _dialogoActivo = false;
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/sucursal', (route) => false);
                  });
                }
              },
              child: const Text(
                "Activar ubicación",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  //metodo para guardar la sucursal en la base de datos
  void _guardarSucursal() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> sucursal = {
        'nombre': _nombreController.text,
        'direccion': _direccion,
        'latitud': _seleccionUbicacion.latitude,
        'longitud': _seleccionUbicacion.longitude,
      };
      // Guardar la sucursal con la dirección obtenida y la ubicación seleccionada
      _servicioSucursal.guardarSucursal(sucursal).then((value) {
        if (value.code == 200) {
          MensajeUtil.mensajeExito(value.datos["tag"], context);
        } else {
          MensajeUtil.mensajeError(value.datos["error"], context);
        }
        Navigator.pushNamed(context, '/sucursal');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Nueva Sucursal',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25)),
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        backgroundColor: const Color.fromARGB(255, 21, 24, 28),
      ),
      backgroundColor: const Color.fromARGB(255, 21, 24, 28),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 400,
                child: FlutterMap(
                  mapController: _mapaController,
                  options: MapOptions(
                    initialCenter: _seleccionUbicacion,
                    initialZoom: 15,
                    onTap:
                        _permiso //si el permiso es verdadero se puede seleccionar la ubicacion
                            ? (tapPosition, punto) {
                                _actualizarUbicacion(punto);
                              }
                            : null,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: _seleccionUbicacion,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      cursorColor: Colors.grey,
                      style: const TextStyle(color: Colors.grey),
                      readOnly: !_permiso, //solo lectura si no hay permiso
                      decoration: const InputDecoration(
                          labelStyle: TextStyle(color: Colors.white),
                          labelText: 'Nombre de la Sucursal',
                          hintText: 'Ingrese el nombre de la sucursal',
                          hintStyle: TextStyle(color: Colors.grey),
                          focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.greenAccent)),
                          prefixIcon: Icon(Icons.store, color: Colors.white)),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingrese el nombre de la sucursal';
                        }
                        return null;
                      },
                      controller: _nombreController,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      style: const TextStyle(color: Colors.grey),
                      controller: _direccionController,
                      decoration: const InputDecoration(
                        labelStyle: TextStyle(color: Colors.white),
                        labelText: 'Dirección',
                        hintText: 'Ingrese la dirección de la sucursal',
                        hintStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.greenAccent)),
                        prefixIcon: Icon(
                          Icons.location_pin,
                          color: Colors.white,
                        ),
                      ),
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por seleccione la ubicación en el mapa';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _latitudController,
                      style: const TextStyle(color: Colors.grey),
                      decoration: const InputDecoration(
                        labelText: 'Latitud',
                        labelStyle: TextStyle(color: Colors.white),
                        hintText: 'Ingrese la latitud de la sucursal',
                        hintStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.greenAccent)),
                        prefixIcon:
                            Icon(Icons.my_location, color: Colors.white),
                      ),
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por seleccione la ubicación en el mapa';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _longitudController,
                      style: const TextStyle(color: Colors.grey),
                      decoration: const InputDecoration(
                        labelText: 'Longitud',
                        labelStyle: TextStyle(color: Colors.white),
                        hintText: 'Ingrese la longitud de la sucursal',
                        hintStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.greenAccent)),
                        prefixIcon:
                            Icon(Icons.my_location, color: Colors.white),
                      ),
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por seleccione la ubicación en el mapa';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _permiso ? _guardarSucursal : null,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _permiso
                              ? const Color.fromARGB(255, 33, 204, 133)
                              : Colors
                                  .grey, //color del boton si hay permiso color verde, si no color gris
                          padding: const EdgeInsets.all(15)),
                      child: const Text('Guardar Sucursal',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
