import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sistema_facturacion_movil/modelos/RespuestaGenerica.dart';

class Conexion {
  //Url del servidor
  //192.168.1.110 es la direccion ip de la maquina que tiene el servidor (C)
  //10.20.138.24 es la direccion ip de la maquina que tiene el servidor (T)
  //192.168.0.106 casa
  final String URL = "http://192.168.1.110:5000/";

  //metodo asincrono para hacer peticiones get
  Future<RespuestaGenerica> get(String recurso, String token) async {
    //se crea la url con el recurso
    final String url = URL + recurso;
    //se crea una instancia de respuesta generica
    Map<String, String> headers = {
      "Content-type": "application/json",
      //"Accept": "application/json",
    };
    //se añade el token a los headers si no esta vacio
    if (token.isNotEmpty) {
      headers["X-Access-Token"] = token;
    }
    //se crea la url con el recurso
    final uri = Uri.parse(url);
    //se hace la peticion get
    final respuesta = await http.get(uri, headers: headers);
    //se mapea la respuesta
    Map<dynamic, dynamic> body = jsonDecode(respuesta.body);
    //se retorna la respuesta generica
    return _respuesta(body["code"], body["msg"], body["datos"], '');
  }

  //metodo asincrono para hacer peticiones post
  Future<RespuestaGenerica> post(
      String recurso, Map<dynamic, dynamic> mapa, String token) async {
    //se crea la url con el recurso
    final String url = URL + recurso;
    //se crea una instancia de respuesta generica
    Map<String, String> headers = {
      "Content-type": "application/json",
      //"Accept": "application/json",
    };
    //se añade el token a los headers si no esta vacio
    if (token.isNotEmpty) {
      headers["X-Access-Token"] = token;
    }
    //se crea la url con el recurso
    final uri = Uri.parse(url);
    //se hace la peticion post
    final respuesta =
        await http.post(uri, headers: headers, body: jsonEncode(mapa));
    //se mapea la respuesta
    Map<dynamic, dynamic> body = jsonDecode(respuesta.body);
    //se retorna la respuesta generica con el external
    if (body["external"] != null) {
      return _respuesta(
          body["code"], body["msg"], body["datos"], body["external"]);
    }
    //se retorna la respuesta generica con el external vacio
    return _respuesta(body["code"], body["msg"], body["datos"], '');
  }

  //metodo para convertir la respuesta en un objeto de respuesta generica
  RespuestaGenerica _respuesta(
      int code, String msg, dynamic datos, String external) {
    var respuesta = RespuestaGenerica();
    respuesta.code = code;
    respuesta.msg = msg;
    respuesta.datos = datos;
    respuesta.external = external;
    return respuesta;
  }
}
