import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:sistema_facturacion_movil/controladores/servicioPersona.dart';
import 'package:sistema_facturacion_movil/controladores/utiles/mensajeUtil.dart';
import 'package:validators/validators.dart';
import 'package:sistema_facturacion_movil/modelos/base.dart';

class CredencialesVista extends StatefulWidget {
  const CredencialesVista({super.key});

  @override
  _CredencialesVistaState createState() => _CredencialesVistaState();
}

class _CredencialesVistaState extends State<CredencialesVista> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usuarioControl = TextEditingController();
  final TextEditingController nuevoUsuarioControl = TextEditingController();
  final TextEditingController claveControl = TextEditingController();
  final TextEditingController nuevaClaveControl = TextEditingController();
  bool _esVisible = false;
  bool _esVisibleN = false;

  ServicioPersona servicioPersona = ServicioPersona();

  //funcion para cambiar las credenciales
  void cambiarCredenciales() {
    if (_formKey.currentState!.validate()) {
      Map<String, String> data = {
        "usuario_actual": usuarioControl.text.trim(),
        "nuevo_usuario": nuevoUsuarioControl.text.trim(),
        "clave_actual": claveControl.text.trim(),
        "nueva_clave": nuevaClaveControl.text.trim(),
      };

      servicioPersona.modificarCredenciales(data).then((value) {
        if (value.code == 200) {
          log(value.msg);
          eliminarDatos();
          MensajeUtil.mensajeExito(value.datos["tag"], context);
          // Volver a la pantalla de sesion
          Navigator.pushNamed(context, "/sesion");
        } else {
          MensajeUtil.mensajeError(value.datos["error"], context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modificar Credenciales',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 21, 24, 28),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            // Volver a la pantalla de perfil
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 21, 24, 28),
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
                    Icon(Icons.alternate_email_rounded, color: Colors.white),
                    SizedBox(width: 10),
                    Text("Correo actual:",
                        style: TextStyle(fontSize: 20, color: Colors.white))
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  cursorColor: Colors.white70,
                  controller: usuarioControl,
                  decoration: const InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.greenAccent)),
                  ),
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su correo actual';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                const Row(
                  children: [
                    Icon(Icons.alternate_email, color: Colors.white),
                    SizedBox(width: 10),
                    Text("Nuevo correo:",
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: nuevoUsuarioControl,
                  cursorColor: Colors.white70,
                  decoration: const InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.greenAccent)),
                  ),
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su nuevo correo';
                    }
                    if (!isEmail(value)) {
                      return 'Ingrese un correo válido';
                    }
                    if (value == usuarioControl.text) {
                      return 'El nuevo correo no puede ser igual al actual';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                const Row(
                  children: [
                    Icon(Icons.lock_outline, color: Colors.white),
                    SizedBox(width: 10),
                    Text("Clave actual:",
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: claveControl,
                  obscureText: !_esVisible,
                  obscuringCharacter: '*',
                  cursorColor: Colors.white70,
                  decoration: InputDecoration(
                    focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.greenAccent)),
                    suffixIcon: IconButton(
                        icon: Icon(
                            _esVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white70),
                        onPressed: () {
                          // Cambiar la visibilidad de la clave
                          setState(() {
                            _esVisible = !_esVisible;
                          });
                        }),
                  ),
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su clave actual';
                    }
                    if (value.length < 8 || value.length > 30) {
                      return 'La clave debe tener al menos 8 caracteres y no más de 30 caracteres';
                    }
                    if (!RegExp(
                            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
                        .hasMatch(value)) {
                      return 'La clave debe tener al menos: \nUna letra mayúscula.\nUna letra minúscula.\nUn número.\nUn caracter especial.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                const Row(
                  children: [
                    Icon(Icons.lock_outline, color: Colors.white),
                    SizedBox(width: 10),
                    Text("Nueva clave:",
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: nuevaClaveControl,
                  obscuringCharacter: '*',
                  obscureText: !_esVisibleN,
                  cursorColor: Colors.white70,
                  decoration: InputDecoration(
                    focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.greenAccent)),
                    suffixIcon: IconButton(
                        icon: Icon(
                            _esVisibleN
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white70),
                        onPressed: () {
                          // Cambiar la visibilidad de la clave
                          setState(() {
                            _esVisibleN = !_esVisibleN;
                          });
                        }),
                  ),
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su nueva clave';
                    }
                    if (value.length < 8 || value.length > 30) {
                      return 'La clave debe tener al menos 8 caracteres y no más de 30 caracteres';
                    }
                    if (value == claveControl.text) {
                      return 'La nueva clave no puede ser igual a la actual';
                    }
                    if (!RegExp(
                            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
                        .hasMatch(value)) {
                      return 'La clave debe tener al menos una letra mayúscula, una letra minúscula, un número y un caracter especial';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 100),

                // Boton para cambiar credenciales
                ElevatedButton.icon(
                  onPressed: () {
                    // Llamar a la función para cambiar credenciales
                    cambiarCredenciales();
                  },
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text("Guardar credenciales",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 33, 204, 133),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
