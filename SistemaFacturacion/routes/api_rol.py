from flask import Blueprint, jsonify, make_response, request
from controllers.rolControl import RolControl
from controllers.utiles.errors import Errors
from flask_expects_json import expects_json
from controllers.authenticate import token_requerido

api_rol = Blueprint("api_rol", __name__)

rolC = RolControl()
# declaracion de esquema para validacion de datos Persona
schema_rol = {
    "type": "object",
    "properties": {
        "nombre": {"type": "string"},
        "descripcion": {"type": "string",
        "estado": "boolean"},
    },
    "required": ["nombre", "descripcion","estado"],
}

# api para listar rol
@api_rol.route("/rol")
def listar():
    return make_response(
        jsonify(
            {
                "msg": "OK",
                "code": 200,
                "datos": ([i.serialize for i in rolC.listar()]),
            }
        ),
        200,
    )


# api para guardar rol
@api_rol.route("/rol/guardar", methods=["POST"])
@token_requerido
@expects_json(schema_rol)
# guardar rol
def guardar_rol():
    # data en json
    data = request.json
    id = rolC.guardar(data)

    if id >= 0:
        return make_response(
            jsonify({"msg": "OK", "code": 200, "data": {"tag": "Rol guardado"}}), 200
        )
    else:
        return make_response(
            jsonify(
                {"msg": "ERROR", "code": 400, "datos": {"error": Errors.error[str(id)]}}
            ),
            400,
        )


# API para mostrar rol por external_id
@api_rol.route("/rol/<external_id>", methods=["GET"])
def listar_external_id(external_id):
    rol = rolC.obtener_external_id(external_id)
    if rol:
        return make_response(
            jsonify({"msg": "OK", "code": 200, "datos": rol.serialize}), 200
        )
    else:
        return make_response(
            jsonify(
                {
                    "msg": "Error",
                    "code": 404,
                    "data": {"error": "Rol no encontrado"},
                }
            ),
            404,
        )


# api para modificar rol
@api_rol.route("/rol/modificar/<external_id>", methods=["POST"])
@token_requerido
@expects_json(schema_rol)
def modificar(external_id):

    data = request.json
    rol = rolC.modificar(data,external_id)

    if rol:
        return make_response(
            jsonify({"msg": "OK", "code": 200, "data": {"tag": "Datos modificados"}}),
            200,
        )
    else:
        return make_response(
            jsonify(
                {
                    "msg": "ERROR",
                    "code": 400,
                    "datos": {"error": Errors.error[str(rol)]},
                }
            ),
            400,
        )


# api para modificar estado rol
@api_rol.route("/rol/estado/<external_id>", methods=["POST"])
@token_requerido
def cambiar_estado(external_id):

    id = rolC.cambiar_estado(external_id)
    
    if id >= 0:
        return make_response(
            jsonify({"msg": "OK", "code": 200, "data": {"tag": "Estado modificado"}}),
            200,
        )
    else:
        return make_response(
            jsonify(
                {"msg": "ERROR", "code": 400, "datos": {"error": Errors.error[str(id)]}}
            ),
            400,
        )
