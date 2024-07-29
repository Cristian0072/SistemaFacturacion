import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SesionUtil {
  //variable de almacenamiento
  final almacenamiento = const FlutterSecureStorage();
  //metodo para escribir un valor
  void add(llave, valor) async {
    await almacenamiento.write(key: llave, value: valor);
  }

  //metodo para eliminar un valor
  void removeItem(llave) async {
    await almacenamiento.delete(key: llave);
  }

  //metodo para eliminar todos los valores
  void removeAll() async {
    await almacenamiento.deleteAll();
  }

  //metodo para obtener un valor
  Future<String?> getValue(llave) async {
    return await almacenamiento.read(key: llave);
  }
}
