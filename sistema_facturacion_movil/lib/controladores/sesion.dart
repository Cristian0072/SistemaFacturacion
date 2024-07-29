import 'package:sistema_facturacion_movil/modelos/RespuestaGenerica.dart';

class Sesion extends RespuestaGenerica {
  String token = '';
  String usuario = '';
  double expira = 0;
  //metodo para convertir la respuesta en un objeto de respuesta generica por defecto
  void add(RespuestaGenerica respuesta) {
    code = respuesta.code;
    msg = respuesta.msg;
    datos = respuesta.datos;
  }
}
