from flask import Blueprint, jsonify, make_response, request
from controllers.productoControl import ProductoControl
from controllers.utiles.errors import Errors
from flask_expects_json import expects_json
from models.Estado import Estado
from controllers.authenticate import token_requerido

api_producto = Blueprint("api_producto", __name__)

productoC = ProductoControl()
# declaracion de esquema para validacion de datos Producto
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

schema_produ = {
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
        "descripcion": {"type": "string"},
    },
    "required": [
        "nombre",
        "fecha_expiracion",
        "cantidad_stock",
        "marca",
        "descripcion",
    ],
}


# api para producto
@api_producto.route("/producto")
@token_requerido
# listar producto
def listar():
    return make_response(
        jsonify(
            {
                "msg": "OK",
                "code": 200,
                "datos": ([i.serialize for i in productoC.listar()]),
            }
        ),
        200,
    )


# api para guardar producto
@api_producto.route("/producto/guardar", methods=["POST"])
@token_requerido
@expects_json(schema_producto)
# guardar producto
def guardar_producto():
    # data en json
    data = request.json
    id = productoC.guardar(data)

    if id >= 0:
        return make_response(
            jsonify({"msg": "OK", "code": 200, "data": {"tag": "Producto guardado"}}),
            200,
        )
    else:
        return make_response(
            jsonify(
                {"msg": "ERROR", "code": 400, "datos": {"error": Errors.error[str(id)]}}
            ),
            400,
        )


# API para mostrar producto por external_id
@api_producto.route("/producto/<external_id>", methods=["GET"])
@token_requerido
# mostrar producto por external_id
def listar_external_id(external_id):
    producto = productoC.obtener_external_id(external_id)
    if producto:
        return make_response(
            jsonify({"msg": "OK", "code": 200, "datos": producto.serialize}), 200
        )
    else:
        return make_response(
            jsonify(
                {
                    "msg": "Error",
                    "code": 404,
                    "datos": {"error": "Producto no encontrada"},
                }
            ),
            404,
        )


# api para modificar Producto
@api_producto.route("/producto/modificar/<external>", methods=["POST"])
@expects_json(schema_produ)
@token_requerido
# modificar producto
def modificar(external):

    data = request.json
    producto = productoC.modificar(data, external)

    if producto:
        return make_response(
            jsonify({"msg": "OK", "code": 200, "data": {"tag": "Producto modificado"}}),
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


# api para modificar estado de producto
@api_producto.route("/producto/estado-actualizar", methods=["POST"])
@token_requerido
# modificar censador
def actualizar_estado():
    id = productoC.actualizar_estado()

    if id >= 0:
        return make_response(
            jsonify(
                {
                    "msg": "OK",
                    "code": 200,
                    "data": {"tag": "Estados de productos actualizados"},
                }
            ),
            200,
        )
    else:
        return make_response(
            jsonify(
                {"msg": "ERROR", "code": 400, "datos": {"error": Errors.error[str(id)]}}
            ),
            400,
        )


# api para listar los productos por estados
@api_producto.route("/producto/estado", methods=["POST"])
@token_requerido
# listar estados de producto
def listar_estado_producto():
    data = request.json
    estado = Estado(data["estado"])
    producto = productoC.obtener_productos_por_estado(estado)
    return make_response(
        jsonify(
            {
                "msg": "OK",
                "code": 200,
                "datos": ([i.serialize for i in producto]),
            }
        ),
        200,
    )
