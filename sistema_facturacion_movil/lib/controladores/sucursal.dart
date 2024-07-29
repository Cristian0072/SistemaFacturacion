import 'package:sistema_facturacion_movil/modelos/RespuestaGenerica.dart';

class Sucursal extends RespuestaGenerica {
  String direccion = "";
  String nombre = "";
  double latitud = 0;
  double longitud = 0;

  //metodo para convertir la respuesta generica por defecto
  void add(RespuestaGenerica respuesta) {
    code = respuesta.code;
    msg = respuesta.msg;
    datos = respuesta.datos;
  }
}
