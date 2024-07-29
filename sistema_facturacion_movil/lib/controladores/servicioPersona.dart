import 'package:sistema_facturacion_movil/controladores/conexion.dart';
import 'package:sistema_facturacion_movil/controladores/persona.dart';
import 'package:sistema_facturacion_movil/modelos/RespuestaGenerica.dart';
import 'package:sistema_facturacion_movil/modelos/base.dart';

class ServicioPersona {
  //variable de conexion
  final Conexion _con = Conexion();

  //metodo asincrono para hacer peticiones get y obtener una persona
  Future<Persona> obtenerPersona() async {
    //se obtiene el token y external de la base de datos
    final res = await getDato();
    String token = "";
    String external = "";
    //se asigna el token y external
    if (res == null) {
      throw Exception("No se pudo obtener el token y external");
    } else {
      token = res["token"];
      external = res["external"];
    }

    //se hace la peticion get
    RespuestaGenerica respuesta = await _con.get("persona/$external", token);
    Persona p = Persona();
    //se añade la respuesta a la persona
    p.add(respuesta);
    //si la respuesta es correcta
    if (p.code == 200) {
      p.usuario = p.datos["cuenta"]["usuario"];
      p.nombres = p.datos["nombres"];
      p.apellidos = p.datos["apellidos"];
      p.identificacion = p.datos["identificacion"];
    }
    //se retorna la persona
    return p;
  }

  //metodo para modificar una persona
  Future<Persona> modificarPersona(Map<dynamic, dynamic> mapa) async {
    //se obtiene el token y external de la base de datos
    final res = await getDato();
    String token = "";
    String usuario = "";
    double expira = 0;
    String external = "";
    //se asigna el token y external
    if (res == null) {
      throw Exception("No se pudo obtener el token y external");
    } else {
      token = res["token"];
      usuario = res["usuario"];
      expira = res["expira"];
      external = res["external"];
    }
    //se hace la peticion post
    RespuestaGenerica respuesta =
        await _con.post("persona/modificar/$external", mapa, token);
    Persona p = Persona();
    //se añade la respuesta a la persona
    p.add(respuesta);
    //si la respuesta no es correcta
    if (p.code == 200) {
      //se actualizan los datos de la persona en la base de datos
      await guardarDatos(token, usuario, expira, p.external);
    }
    //se retorna la persona
    return p;
  }

  //metodo para modificar credenciales de una persona
  Future<Persona> modificarCredenciales(Map<dynamic, dynamic> mapa) async {
    //se obtiene el token y external de la base de datos
    final res = await getDato();
    String token = "";
    //se asigna el token y external
    if (res == null) {
      throw Exception("No se pudo obtener el token y external");
    } else {
      token = res["token"];
    }

    //se hace la peticion post
    RespuestaGenerica respuesta =
        await _con.post("persona/credenciales", mapa, token);
    Persona p = Persona();
    //se añade la respuesta a la persona
    p.add(respuesta);
    //se retorna la persona
    return p;
  }

  //metodo para desactivar/activar la cuenta de una persona
  Future<Persona> desactivarCuenta() async {
    //se obtiene el token y external de la base de datos
    final res = await getDato();
    String token = "";
    String external = "";
    //se asigna el token y external
    if (res == null) {
      throw Exception("No se pudo obtener el token y external");
    } else {
      token = res["token"];
      external = res["external"];
    }

    //se hace la peticion post
    RespuestaGenerica respuesta =
        await _con.post("persona/estado-actualizar/$external", {}, token);
    Persona p = Persona();
    //se añade la respuesta a la persona
    p.add(respuesta);
    //se retorna la persona
    return p;
  }
}
