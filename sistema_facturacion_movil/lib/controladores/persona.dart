import 'package:sistema_facturacion_movil/modelos/RespuestaGenerica.dart';

class Persona extends RespuestaGenerica {
  String nombres = '';
  String apellidos = '';
  String identificacion = '';
  String usuario = '';
  //metodo para convertir la respuesta generica por defecto
  void add(RespuestaGenerica respuesta) {
    code = respuesta.code;
    msg = respuesta.msg;
    datos = respuesta.datos;
    external = respuesta.external;
  }
}
