import 'package:flutter/material.dart';
import 'package:sistema_facturacion_movil/modelos/base.dart';

class MenuBar extends StatelessWidget {
  const MenuBar({super.key});

  //metodo para cerrar sesion
  void cerrarSesion(BuildContext context) {
    //se muestra un dialogo de confirmacion
    showDialog(
      //se le da un contexto
      context: context,
      //se le da un constructor
      builder: (BuildContext context) {
        //se retorna un dialogo de alerta
        return AlertDialog(
          title: const Text(
            "Confirmación",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "¿Estás seguro de cerrar sesión?",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 21, 24, 28),
          actions: <Widget>[
            //se le da un boton de cancelar
            TextButton(
              //se le da un texto
              child: const Text(
                "No",
                style: TextStyle(color: Colors.grey),
              ),
              //se le da una accion
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
            //se le da un boton de aceptar
            TextButton(
                //se le da un color al boton de aceptar
                style: TextButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                //se le da un texto
                child: const Text("Si",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                //se le da una accion
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo
                  Navigator.pushReplacementNamed(context,
                      '/'); //redireccion a la vista de inicio de sesion
                  //se elimina el token y el usuario de la base de datos
                  eliminarDatos();
                }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 21, 24, 28),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 21, 24, 28),
            ),
            child: Row(
              children: [
                Icon(Icons.home_rounded, color: Colors.white, size: 30),
                SizedBox(width: 10),
                Text(
                  'Menú',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.greenAccent),
            title: const Text('Mi perfil',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            onTap: () {
              //redireccion
              Navigator.pushNamed(context, '/perfil');
            },
          ),
          ListTile(
            leading: const Icon(Icons.store, color: Colors.greenAccent),
            title: const Text('Sucursal',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            onTap: () {
              // Implementar acción
              Navigator.pushNamed(context, '/sucursal');
            },
          ),
          ListTile(
            leading: const Icon(Icons.map_sharp, color: Colors.greenAccent),
            title: const Text('Mapa Sucursales',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pushNamed(context, '/mapa');
            },
          ),
          const Divider(
            color: Colors.grey,
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Cerrar sesión',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              cerrarSesion(context);
            },
          ),
        ],
      ),
    );
  }
}
