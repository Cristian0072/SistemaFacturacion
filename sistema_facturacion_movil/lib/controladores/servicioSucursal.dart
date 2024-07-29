import 'package:sistema_facturacion_movil/controladores/conexion.dart';
import 'package:sistema_facturacion_movil/controladores/sucursal.dart';
import 'package:sistema_facturacion_movil/modelos/RespuestaGenerica.dart';
import 'package:sistema_facturacion_movil/modelos/base.dart';

class ServicioSucursal {
  //variable de conexion
  final Conexion _con = Conexion();

  //metodo para hacer peticiones get y obtener una sucursal
  Future<List<dynamic>> obtenerSucursal(
      String external, Map<String, dynamic> estado) async {
    //se obtiene el token y external de la base de datos
    final res = await getDato();
    String token = "";
    //se asigna el token y external
    if (res == null) {
      throw Exception("No se pudo obtener el token y external");
    } else {
      token = res["token"];
    }
    //se hace la peticion get
    RespuestaGenerica respuesta =
        await _con.post("sucursal/$external", estado, token);

    List<dynamic> data = respuesta.datos;

    return data;
  }

  //metodo para guardar una sucursal
  Future<Sucursal> guardarSucursal(Map<dynamic, dynamic> mapa) async {
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
        await _con.post("sucursal/guardar", mapa, token);
    Sucursal s = Sucursal();
    //se añade la respuesta a la sucursal
    s.add(respuesta);
    //se retorna la sucursal
    return s;
  }

  //metodo para desactivar/activar una sucursal
  Future<Sucursal> actualizarEstado(String external) async {
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
        await _con.post("sucursal/estado/$external", {}, token);
    Sucursal s = Sucursal();
    //se añade la respuesta a la sucursal
    s.add(respuesta);
    //se retorna la sucursal
    return s;
  }

  //metodo para guardar productos en una sucursal
  Future<Sucursal> guardarProducto(
      Map<dynamic, dynamic> mapa, String external) async {
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
        await _con.post("sucursal/guardar-producto/$external", mapa, token);
    Sucursal s = Sucursal();
    //se añade la respuesta a la sucursal
    s.add(respuesta);
    //se retorna la sucursal
    return s;
  }

  //metodo para listar todas las sucursales y sus productos
  Future<List<Map<String, dynamic>>> listarSucursales() async {
    //se obtiene el token y external de la base de datos
    final res = await getDato();
    String token = "";
    //se asigna el token y external
    if (res == null) {
      throw Exception("No se pudo obtener el token y external");
    } else {
      token = res["token"];
    }
    //se hace la peticion get
    RespuestaGenerica respuesta = await _con.get("sucursal/producto", token);
    final List<dynamic> data = respuesta.datos;
    //se retorna la lista de sucursales activas
    return data.where((e) => e["estado"] == true).map((e) {
      return {
        "nombre": e["nombre"],
        "latitud": e["latitud"],
        "longitud": e["longitud"],
        "estado": e["estados"],
      };
    }).toList();
  }

  //metodo para listar todas las sucursales y sus productos
  Future<List<dynamic>> listarSucursalesProductos() async {
    //se obtiene el token y external de la base de datos
    final res = await getDato();
    String token = "";
    //se asigna el token y external
    if (res == null) {
      throw Exception("No se pudo obtener el token y external");
    } else {
      token = res["token"];
    }
    //se hace la peticion get
    RespuestaGenerica respuesta = await _con.get("sucursal", token);
    final List<dynamic> data = respuesta.datos;
    //se retorna la lista de sucursales activas
    return data;
  }
}
