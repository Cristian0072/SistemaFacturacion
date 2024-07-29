import 'package:sistema_facturacion_movil/controladores/conexion.dart';
import 'package:sistema_facturacion_movil/controladores/sesion.dart';
import 'package:sistema_facturacion_movil/modelos/RespuestaGenerica.dart';

class Servicio {
  //variable de conexion
  final Conexion _con = Conexion();

  //metodo asincrono para hacer peticiones post e iniciar sesion
  Future<Sesion> sesion(Map<dynamic, dynamic> mapa) async {
    //se hace la peticion post
    RespuestaGenerica respuesta = await _con.post("sesion", mapa, "");
    Sesion s = Sesion();
    //se añade la respuesta a la sesion
    s.add(respuesta);
    //si la respuesta es correcta
    if (s.code == 200) {
      s.token = s.datos["token"];
      s.usuario = s.datos["usuario"];
      s.expira = s.datos["expira"];
      s.external = s.datos["external"];
    }
    //se retorna la sesion
    return s;
  }
}
