import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:sistema_facturacion_movil/controladores/servicioPersona.dart';
import 'package:sistema_facturacion_movil/controladores/utiles/mensajeUtil.dart';
import 'package:sistema_facturacion_movil/modelos/base.dart';
import 'package:validators/validators.dart';

class PerfilVista extends StatefulWidget {
  const PerfilVista({super.key});

  @override
  _PerfilVistaState createState() => _PerfilVistaState();
}

class _PerfilVistaState extends State<PerfilVista> {
  //llave global para el formulario
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usuarioControl = TextEditingController();
  final TextEditingController identificacionControl = TextEditingController();
  final TextEditingController nombresControl = TextEditingController();
  final TextEditingController apellidosControl = TextEditingController();
  bool _modoEdicion = false;

  ServicioPersona servicioPersona = ServicioPersona();

  //funcion para obtener los datos del usuario
  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  //funcion para cargar los datos del usuario
  void cargarDatos() {
    servicioPersona.obtenerPersona().then((value) {
      if (value.code == 200) {
        log(value.msg);
        setState(() {
          usuarioControl.text = value.usuario;
          identificacionControl.text = value.identificacion;
          nombresControl.text = value.nombres;
          apellidosControl.text = value.apellidos;
        });
      } else {
        MensajeUtil.mensajeError(value.datos["error"], context);
      }
    });
  }

  //funcion para cambiar el estado de la edicion
  void edicion() {
    setState(() {
      _modoEdicion = !_modoEdicion;
    });
  }

  //funcion para guardar los datos del usuario
  void guardarDatos() {
    if (_formKey.currentState!.validate()) {
      Map<String, String> data = {
        "nombres": nombresControl.text.trim(),
        "apellidos": apellidosControl.text.trim(),
        "identificacion": identificacionControl.text.trim(),
        "rol": "ADMINISTRADOR",
        "usuario": usuarioControl.text.trim()
      };

      servicioPersona.modificarPersona(data).then((value) {
        if (value.code == 200) {
          log(value.msg);
          MensajeUtil.mensajeExito(value.datos["tag"], context);
          edicion();
        } else {
          MensajeUtil.mensajeError(value.datos["error"], context);
        }
      });
    }
  }

  // Función para desactivar la cuenta
  desactivarCuenta(BuildContext context) {
    // Crear un dialogo de confirmación
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Desactivar Cuenta",
              style: TextStyle(color: Colors.red)),
          backgroundColor: const Color.fromARGB(255, 21, 24, 28),
          content: const Text(
              "¿Está seguro que desea desactivar su cuenta? Esta acción no se puede deshacer",
              style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Cerrar el dialogo
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar",
                  style: TextStyle(color: Colors.blueGrey)),
            ),
            TextButton(
                onPressed: () {
                  // Cerrar el dialogo
                  Navigator.of(context).pop();
                  // Llamar a la función para desactivar la cuenta
                  servicioPersona.desactivarCuenta().then((value) {
                    if (value.code == 200) {
                      eliminarDatos();
                      log(value.msg);
                      // Mostrar un mensaje de éxito
                      MensajeUtil.mensajeExito(value.datos["tag"], context);
                      // Redireccionar a la vista de inicio de sesión
                      Navigator.pushNamed(context, '/sesion');
                    } else {
                      // Mostrar un mensaje de error
                      MensajeUtil.mensajeError(value.datos["error"], context);
                    }
                  });
                },
                //se le da un color al boton de desactivar
                style: TextButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text("Desactivar",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white))),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 21, 24, 28),
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.white,
            size: 35,
          ),
          onPressed: () {
            // Cerrar la pantalla de perfil
            Navigator.pushNamed(context, '/panel');
          },
        ),
        actions: [
          // Botones para guarda datos
          if (_modoEdicion)
            IconButton(
              icon: const Icon(Icons.save, color: Colors.greenAccent, size: 35),
              onPressed: () {
                // Llamar a la función para guardar los datos
                guardarDatos();
              },
            ),
          // Botón para editar los datos
          IconButton(
            //
            icon: Icon(_modoEdicion ? Icons.cancel : Icons.edit,
                color: _modoEdicion ? Colors.grey : Colors.greenAccent,
                size: 35),
            onPressed: () {
              // Cambiar el estado de la edición
              edicion();
            },
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 21, 24, 28),
      //cuerpo de la vista de perfil
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Row(
                  children: [
                    Icon(Icons.person, color: Colors.white),
                    SizedBox(width: 10),
                    Text("Nombres:",
                        style: TextStyle(fontSize: 20, color: Colors.white))
                  ],
                ),
                const SizedBox(height: 10),
                _modoEdicion
                    //si esta en modo edicion se muestra un campo de texto
                    ? TextFormField(
                        //llamada al controlador para el campo de texto nombres
                        controller: nombresControl,
                        cursorColor: Colors.white,
                        style: const TextStyle(
                            fontSize: 18, color: Colors.white70),
                        decoration: const InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.greenAccent)),
                        ),
                        validator: (value) {
                          //validacion de campo vacio
                          if (isNull(value) || value!.isEmpty) {
                            return 'Por favor, ingrese sus nombres';
                          }
                          //validacion de solo letras y espacios
                          if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                            return 'Por favor, ingrese un nombre válido';
                          }
                          return null;
                        })
                    //si no esta en modo edicion se muestra un texto
                    : Text(
                        nombresControl.text,
                        style: const TextStyle(
                            fontSize: 18, color: Colors.white70),
                      ),
                const SizedBox(height: 30),

                const Row(
                  children: [
                    Icon(Icons.person, color: Colors.white),
                    SizedBox(width: 10),
                    Text("Apellidos:",
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 10),
                _modoEdicion
                    ?
                    //si esta en modo edicion se muestra un campo de texto
                    TextFormField(
                        //llamada al controlador para el campo de texto apellidos
                        controller: apellidosControl,
                        cursorColor: Colors.white,
                        style: const TextStyle(
                            fontSize: 18, color: Colors.white70),
                        decoration: const InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.greenAccent)),
                        ),
                        validator: (value) {
                          //validacion de campo vacio
                          if (isNull(value) || value!.isEmpty) {
                            return 'Por favor, ingrese sus apellidos';
                          }
                          //validacion de solo letras y espacios
                          if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                            return 'Por favor, ingrese un apellido válido';
                          }
                          return null;
                        })
                    //si no esta en modo edicion se muestra un texto
                    : Text(
                        apellidosControl.text,
                        style: const TextStyle(
                            fontSize: 18, color: Colors.white70),
                      ),
                const SizedBox(height: 30),

                const Row(
                  children: [
                    Icon(Icons.email, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      "Correo:",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                //si no esta en modo edicion se muestra un texto
                Text(
                  usuarioControl.text,
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 30),

                const Row(
                  children: [
                    Icon(Icons.perm_identity, color: Colors.white),
                    SizedBox(width: 10),
                    Text("Identificación:",
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                  ],
                ),
                //espacio entre los campos de texto
                const SizedBox(height: 10),
                _modoEdicion
                    ?
                    //si esta en modo edicion se muestra un campo de texto
                    TextFormField(
                        //llamada al controlador para el campo de texto identificacion
                        controller: identificacionControl,
                        cursorColor: Colors.white,
                        decoration: const InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.greenAccent)),
                        ),
                        style: const TextStyle(
                            fontSize: 18, color: Colors.white70),
                        validator: (value) {
                          //validacion de campo vacio
                          if (isNull(value) || value!.isEmpty) {
                            return 'Por favor, ingrese su identificación';
                          }
                          //validacion de solo numeros
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'Por favor, ingrese una identificación válida';
                          }
                          //validacion de longitud de 10 caracteres
                          if (value.length < 10 || value.length > 10) {
                            return 'Por favor, ingrese una identificación válida';
                          }
                          return null;
                        })
                    :
                    //si no esta en modo edicion se muestra un texto
                    Text(
                        identificacionControl.text,
                        style: const TextStyle(
                            fontSize: 18, color: Colors.white70),
                      ),
                //distancia entre los campos de texto y los botones
                const SizedBox(height: 90),
                // Botones para modificar credenciales y desactivar cuenta solo si no esta en modo edicion
                if (!_modoEdicion) ...[
                  //... se usa para desempaquetar la lista de widgets
                  // Boton para modificar credenciales
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navegar a la pantalla de modificar credenciales
                      Navigator.pushNamed(context, '/credenciales');
                    },
                    icon: const Icon(Icons.lock_open, color: Colors.white),
                    label: const Text("Modificar Credenciales",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 19)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 33, 204, 133),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Boton para desactivar cuenta
                  ElevatedButton.icon(
                    onPressed: () {
                      // Función para desactivar la cuenta
                      desactivarCuenta(context);
                    },
                    icon: const Icon(Icons.delete_forever, color: Colors.white),
                    label: const Text(
                      "Desactivar Cuenta",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 19),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
