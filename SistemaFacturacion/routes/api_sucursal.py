from flask import Blueprint, jsonify, make_response, request
from controllers.sucursalControl import SucursalControl
from controllers.utiles.errors import Errors
from flask_expects_json import expects_json
from controllers.authenticate import token_requerido

api_sucursal = Blueprint("api_sucursal", __name__)

sucursalC = SucursalControl()
# declaracion de esquema para validacion de datos Persona
schema_sucursal = {
    "type": "object",
    "properties": {
        "nombre": {"type": "string"},
        "direccion": {"type": "string"},
        "latitud": {
            "type": "number",
            "pattern": "^[0-9]+.[0-9]+$",
            "message": "Solo se permiten numeros",
        },
        "longitud": {
            "type": "number",
            "pattern": "^[0-9]+.[0-9]+$",
            "message": "Solo se permiten numeros",
        },
    },
    "required": ["nombre", "latitud", "longitud", "direccion"],
}

schema_producto = {
    "type": "object",
    "properties": {
        "nombre": {"type": "string"},
        "fecha_fabricacion": {
            "type": "string",
            "pattern": "^([0-2][0-9]|3[0-1])/(0[1-9]|1[0-2])/([1-2][0-9]{3})$",
            "message": "Fecha no valida",
        },
        "fecha_expiracion": {
            "type": "string",
            "pattern": "^([0-2][0-9]|3[0-1])/(0[1-9]|1[0-2])/([1-2][0-9]{3})$",
            "message": "Fecha no valida",
        },
        "cantidad_stock": {
            "type": "integer",
            "pattern": "^[0-9]+$",
            "message": "Solo se permiten numeros",
        },
        "marca": {"type": "string"},
        "codigo": {
            "type": "string",
            "pattern": "^[A-Za-z0-9-]+$",
            "message": "Solo se permiten letras, guiones y numeros",
        },
        "descripcion": {"type": "string"},
    },
    "required": [
        "nombre",
        "fecha_fabricacion",
        "fecha_expiracion",
        "cantidad_stock",
        "marca",
        "codigo",
        "descripcion",
    ],
}


# api para listar sucursal
@api_sucursal.route("/sucursal")
@token_requerido
def listar():
    return make_response(
        jsonify(
            {
                "msg": "OK",
                "code": 200,
                "datos": ([i.serialize for i in sucursalC.listar()]),
            }
        ),
        200,
    )


# api para listar sucursal y productos
@api_sucursal.route("/sucursal/producto")
@token_requerido
def listar_productos_sucursal():
    datos = sucursalC.listar_sucursal_producto()
    return make_response(
        jsonify(
            {
                "msg": "OK",
                "code": 200,
                "datos": datos,
            }
        ),
        200,
    )


# api para guardar sucursal
@api_sucursal.route("/sucursal/guardar", methods=["POST"])
@token_requerido
@expects_json(schema_sucursal)
# guardar sucursal
def guardar_sucursal():
    # data en json
    data = request.json
    id = sucursalC.guardar_sucursal(data)

    if id >= 0:
        return make_response(
            jsonify({"msg": "OK", "code": 200, "datos": {"tag": "Sucursal guardada"}}),
            200,
        )
    else:
        return make_response(
            jsonify(
                {"msg": "ERROR", "code": 400, "datos": {"error": Errors.error[str(id)]}}
            ),
            400,
        )


# api para guardar producto por sucursal
@api_sucursal.route("/sucursal/guardar-producto/<external>", methods=["POST"])
@token_requerido
@expects_json(schema_producto)
def guardar_producto_sucursal(external):
    data = request.json
    producto = sucursalC.guardar_producto_sucursal(data, external)

    if producto >= 0:
        return make_response(
            jsonify({"msg": "OK", "code": 200, "datos": {"tag": "Producto guardado"}}),
            200,
        )
    else:
        return make_response(
            jsonify(
                {
                    "msg": "ERROR",
                    "code": 400,
                    "datos": {"error": Errors.error[str(producto)]},
                }
            ),
            400,
        )


# API para mostrar productos por sucursal y estado
@api_sucursal.route("/sucursal/<external>", methods=["POST"])
@token_requerido
def listar_external_id(external):
    data = request.json
    sucursal = sucursalC.obtener_sucursal(data["estado"], external)
    # verifica si sucursal es un objeto o un entero
    if type(sucursal) is not int:
        return make_response(
            jsonify(
                {
                    "msg": "OK",
                    "code": 200,
                    "datos": [sucur.serialize for sucur in sucursal],
                }
            ),
            200,
        )
    else:
        return make_response(
            jsonify(
                {
                    "msg": "Error",
                    "code": 404,
                    "datos": {"error": Errors.error[str(sucursal)]},
                }
            ),
            404,
        )


# api para modificar sucursal
@api_sucursal.route("/sucursal/modificar/<external>", methods=["POST"])
@token_requerido
@expects_json(schema_sucursal)
def modificar(external):

    data = request.json
    sucursal = sucursalC.modificar(data, external)

    if sucursal:
        return make_response(
            jsonify({"msg": "OK", "code": 200, "datos": {"tag": "Datos modificados"}}),
            200,
        )
    else:
        return make_response(
            jsonify(
                {
                    "msg": "ERROR",
                    "code": 400,
                    "datos": {"error": Errors.error[str(sucursal)]},
                }
            ),
            400,
        )


# api para desactivar/activar sucursal
@api_sucursal.route("/sucursal/estado/<external>", methods=["POST"])
@token_requerido
def desactivar_sucursal(external):
    sucursal, estado = sucursalC.desactivar_sucursal(external)

    if sucursal:
        return make_response(
            jsonify(
                {
                    "msg": "OK",
                    "code": 200,
                    "datos": {
                        "tag": "Sucursal " + ("ACTIVADA" if estado else "DESACTIVADA")
                    },
                }
            ),
            200,
        )
    else:
        return make_response(
            jsonify(
                {
                    "msg": "ERROR",
                    "code": 400,
                    "datos": {"error": Errors.error[str(sucursal)]},
                }
            ),
            400,
        )
