// Vista de inicio de sesion
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:sistema_facturacion_movil/controladores/servicio.dart';
import 'package:sistema_facturacion_movil/controladores/utiles/mensajeUtil.dart';
import 'package:sistema_facturacion_movil/modelos/base.dart';
import 'package:validators/validators.dart';

class SesionVista extends StatefulWidget {
  const SesionVista({super.key});

  @override
  _SesionVistaState createState() => _SesionVistaState();
}

//estado de la vista
class _SesionVistaState extends State<SesionVista> {
  //llave global para el formulario
  final _formKey = GlobalKey<FormState>();
  //controladores para los campos de texto
  final TextEditingController correoControl = TextEditingController();
  final TextEditingController claveControl = TextEditingController();
  final ValueNotifier<bool> _claveVisible = ValueNotifier<bool>(false);
  bool _clave = false;

  //funcion de inicio de sesion
  void inicio(BuildContext context) {
    //estado
    setState(() {
      //si esta validado
      if (_formKey.currentState!.validate()) {
        //se crea un mapa para los valores de correo y clave
        Map<String, String> data = {
          "usuario": correoControl.text.trim(),
          "clave": claveControl.text.trim()
        };
        log(data.toString());
        //se crea una instancia de servicio
        Servicio servicio = Servicio();
        //se hace la peticion post para iniciar sesion
        servicio.sesion(data).then((value) async {
          if (value.code == 200) {
            log(value.msg);
            //se muestra un mensaje de bienvenida
            MensajeUtil.mensajeExito(
                "Hola ${value.usuario}! Bienvenido ;)", context);
            //redireccion a la vista de panel
            Navigator.pushNamed(context, '/panel');
            //se guarda el token y el usuario en la base de datos
            await guardarDatos(
                value.token, value.usuario, value.expira, value.external);
          } else {
            log(value.datos["error"]);
            //se muestra un mensaje de error
            MensajeUtil.mensajeError(value.datos["error"], context);
          }
        });
      }
    });
  }

  //se inicializa el controlador de la clave para mostrarla
  @override
  void initState() {
    super.initState();
    claveControl.addListener(() {
      //si la clave no esta vacia se muestra
      _claveVisible.value = claveControl.text.isNotEmpty;
      //si la clave esta vacia se oculta
      if (claveControl.text.isEmpty) {
        _clave = false; //si la clave esta vacia se oculta
      }
    });
  }

  //se libera el controlador de la clave al cerrar la vista
  @override
  void dispose() {
    correoControl.dispose();
    _claveVisible.dispose();
    super.dispose();
  }

  //vista de inicio de sesion
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 21, 24, 28),
        body: ListView(
          padding: const EdgeInsets.all(32),
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text("SISTEMA DE FACTURACION MOVIL",
                    style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 40))),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(40),
                child: const Text("Inicio de sesión",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white))),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.alternate_email, color: Colors.grey),
                  labelText: 'Correo',
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.greenAccent)),
                  hintStyle: TextStyle(color: Colors.grey),
                  hintText: 'Ingrese su correo',
                ),

                validator: (value) {
                  //si no es nulo !
                  if (value!.isEmpty) {
                    return "Por favor ingrese su correo";
                  }
                  //negacion de true o false !
                  if (!isEmail(value.toString().trim())) {
                    return "Ingrese un correo valido";
                  }
                  return null;
                },
                //llamada al controlador para el campo de texto correo
                controller: correoControl,
              ),
            ),
            Container(
              //espacio entre los campos de texto
              padding: const EdgeInsets.all(10),
              child: ValueListenableBuilder<bool>(
                valueListenable: _claveVisible,
                builder: (context, value, child) {
                  return TextFormField(
                    obscureText: !_clave,
                    obscuringCharacter: '*',
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(Icons.lock_outline, color: Colors.grey),
                      labelText: 'Clave',
                      focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.greenAccent)),
                      labelStyle: const TextStyle(color: Colors.grey),
                      hintStyle: const TextStyle(color: Colors.grey),
                      hintText: 'Ingrese su clave',
                      suffixIcon: value
                          ? IconButton(
                              icon: Icon(
                                  _clave
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _clave = !_clave;
                                });
                              },
                            )
                          : null,
                    ),
                    validator: (value) {
                      //si no es nulo !
                      if (value!.trim().isEmpty) {
                        return "Por favor ingrese una clave valida";
                      }
                      return null;
                    },
                    //llamada al controlador para el campo de texto clave
                    controller: claveControl,
                  );
                },
              ),
            ),
            Container(
              height: 200,
              padding: const EdgeInsets.only(
                  top: 70, left: 85, right: 85, bottom: 60),
              //boton de inicio de sesion
              child: ElevatedButton(
                //llamar a funcion de inicio
                onPressed: () => inicio(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 33, 204, 133),
                ),
                child: const Text("Inicar sesión",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
