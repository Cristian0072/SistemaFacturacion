import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MensajeUtil{
  //metodo para mostrar un mensaje de exito
  static void mensajeExito(String msg, BuildContext context) {
    //se crea una instancia de FToast
    FToast ftoast = FToast();
    //se inicializa el contexto
    ftoast.init(context);
    //se muestra un mensaje de exito
    ftoast.showToast(
      //se crea un contenedor con el mensaje
      child: Container(
        //se le da un espacio alrededor
        padding: const EdgeInsets.all(32),
        //se le da un borde redondeado
        decoration: BoxDecoration(
          //se le da un angulo de 25 de redondeado
          borderRadius: BorderRadius.circular(10),
          color: Colors.green.shade300,
        ),
        //se muestra el mensaje
        child: Text(
          //se muestra el mensaje
          msg,
          //se le da un estilo al texto
          style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      //se le da una posicion al mensaje
      gravity: ToastGravity.CENTER,
      //se le da una duracion al mensaje
      toastDuration: const Duration(seconds: 3),
    );
  }
  //metodo para mostrar un mensaje de error
  static void mensajeError(String msg, BuildContext context) {
    //se crea una instancia de FToast
    FToast ftoast = FToast();
    //se inicializa el contexto
    ftoast.init(context);
    //se muestra un mensaje de error
    ftoast.showToast(
      //se crea un contenedor con el mensaje
      child: Container(
        //se le da un espacio alrededor
        padding: const EdgeInsets.all(32),
        //se le da un borde redondeado
        decoration: BoxDecoration(
          //se le da un angulo de 25 de redondeado
          borderRadius: BorderRadius.circular(10),
          //se le da un color rojo
          color: Colors.red.shade300,
        ),
        //se muestra el mensaje
        child: Text(
          //se muestra el mensaje
          msg,
          //se le da un estilo al texto
          style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      //se le da una posicion al mensaje
      gravity: ToastGravity.CENTER,
      //se le da una duracion al mensaje
      toastDuration: const Duration(seconds: 3),
    );
  }
}
