import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Inicializar la base de datos
Future<Database> iniciarDB() async {
  // retorna la base de datos en la ruta especificada
  return openDatabase(
    // Establecer la ruta de la base de datos. Nota: Usando la función `join` del paquete `path`
    join(await getDatabasesPath(), 'sesion_db.db'),
    // Cuando la base de datos se crea por primera vez, crea una tabla para almacenar datos
    onCreate: (db, version) {
      // Crear la tabla sesion con un campo id, un campo token y un campo usuario
      return db.execute(
        'CREATE TABLE sesion(id INTEGER PRIMARY KEY, token TEXT, usuario TEXT, expira REAL, external TEXT)',
      );
    },
    // Establecer la versión. Esto ejecuta la función onCreate
    version: 1,
  );
}

// Guardar un datos
Future<void> guardarDatos(String token, String usuario, double expira, String external) async {
  // Obtener una referencia de la base de datos
  final Database db = await iniciarDB();
  // Insertar el token en la tabla sesion
  await db.insert(
    'sesion',
    {'id': 1, 'token': token, 'usuario': usuario, 'expira': expira, 'external': external},
    // Reemplazar cualquier token existente
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// Leer un dato de la tabla sesion
Future<Map<String,dynamic>?> getDato() async {
  // Obtener una referencia de la base de datos
  final Database db = await iniciarDB();
  // Consultar la tabla para el token
  final List<Map<String, dynamic>> mapa = await db.query('sesion', where: 'id = ?', whereArgs: [1]);
  // Convertir la lista de Mapas en una lista de Tokens
  if (mapa.isNotEmpty) {
    // Si el token existe, devuelve la primera fila de la tabla
    return mapa.first;
  }
  // Si no hay tokens en la tabla, devuelve null
  return null;
}

// Eliminar datos de la tabla sesion
Future<void> eliminarDatos() async {
  // Obtener una referencia de la base de datos
  final db = await iniciarDB();
  // Eliminar todos los datos de la tabla sesion
  await db.delete(
    'sesion'
  );
}

//Eliminar un dato  por id
Future<void> eliminarDato() async {
  // Obtener una referencia de la base de datos
  final db = await iniciarDB();
  // Eliminar el token de la tabla sesion por id
  await db.delete(
    'sesion',
    where: 'id = ?',
    // Pasar el id como un whereArg para prevenir SQL inyección
    whereArgs: [1],
  );
}