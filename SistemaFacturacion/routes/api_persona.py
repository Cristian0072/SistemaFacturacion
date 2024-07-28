from flask import Blueprint, jsonify, make_response, request
from controllers.personaControl import PersonaControl
from controllers.utiles.errors import Errors
from flask_expects_json import expects_json
from controllers.authenticate import token_requerido

api_persona = Blueprint("api_persona", __name__)

personaC = PersonaControl()
# declaracion de esquema para validacion de datos Persona
schema_persona = {
    "type": "object",
    "properties": {
        "nombres": {"type": "string"},
        "apellidos": {"type": "string"},
        "identificacion": {
            "type": "string",
            "pattern": "^[0-9]+$",
            "message": "Solo se permiten numeros",
            "minLength": 10,
            "maxLength": 10,
        },
        "usuario": {
            "type": "string",
            "pattern": "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
            "message": "El usuario debe ser un correo electronico valido",
            "maxLength": 30,
        },
        "clave": {
            "type": "string",
            "pattern": "^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$",
            "message": "La clave debe contener al menos 8 caracteres, una letra mayúscula, una letra minúscula, un número y un carácter especial",
            "minLength": 8,
            "maxLength": 30,
        },
        "rol": {"type": "string"},
    },
    "required": ["nombres", "apellidos", "identificacion", "usuario", "clave", "rol"],
}

schema_informacion_personal = {
    "type": "object",
    "properties": {
        "nombres": {"type": "string"},
        "apellidos": {"type": "string"},
        "identificacion": {
            "type": "string",
            "pattern": "^[0-9]+$",
            "message": "Solo se permiten numeros",
            "minLength": 10,
            "maxLength": 10,
        },
    },
    "required": ["nombres", "apellidos", "identificacion"],
}

schema_sesion = {
    "type": "object",
    "properties": {
        "usuario": {
            "type": "string",
            "pattern": "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
            "message": "El usuario debe ser un correo electronico valido",
        },
        "clave": {
            "type": "string",
        },
    },
    "required": ["usuario", "clave"],
}

schema_credenciales = {
    "type": "object",
    "properties": {
        "usuario_actual": {
            "type": "string",
            "pattern": "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
            "message": "El usuario debe ser un correo electronico valido",
        },
        "clave_actual": {
            "type": "string",
            "pattern": "^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$",
            "message": "La clave debe contener al menos 8 caracteres, una letra mayúscula, una letra minúscula, un número y un carácter especial",
            "minLength": 8,
            "maxLength": 30,
        },
        "nuevo_usuario": {
            "type": "string",
            "pattern": "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
            "message": "El usuario debe ser un correo electronico valido",
        },
        "nueva_clave": {
            "type": "string",
            "pattern": "^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$",
            "message": "La clave debe contener al menos 8 caracteres, una letra mayúscula, una letra minúscula, un número y un carácter especial",
            "minLength": 8,
            "maxLength": 30,
        },
    },
    "required": ["usuario_actual", "clave_actual", "nuevo_usuario", "nueva_clave"],
}


# api para listar personas
@api_persona.route("/persona")
@token_requerido
def listar():
    return make_response(
        jsonify(
            {
                "msg": "OK",
                "code": 200,
                "datos": ([i.serialize for i in personaC.listar()]),
            }
        ),
        200,
    )


# api para listar personas de tipo usuario
@api_persona.route("/persona/usuario")
@token_requerido
def listar_usuarios():
    return make_response(
        jsonify(
            {
                "msg": "OK",
                "code": 200,
                "datos": ([i.serialize for i in personaC.listar_usuario()]),
            }
        ),
        200,
    )


# api para guardar persona
@api_persona.route("/persona/guardar", methods=["POST"])
@token_requerido
@expects_json(schema_persona)
# guardar persona
def guardar():
    # data en json
    data = request.json

    id = personaC.guardar(data)

    if id >= 0:
        return make_response(
            jsonify({"msg": "OK", "code": 200, "datos": {"tag": "Persona guardada"}}),
            200,
        )
    else:
        return make_response(
            jsonify(
                {"msg": "ERROR", "code": 400, "datos": {"error": Errors.error[str(id)]}}
            ),
            400,
        )


# API para mostrar persona por external_id
@api_persona.route("/persona/<external_id>", methods=["GET"])
@token_requerido
def listar_external_id(external_id):
    persona = personaC.obtener_external_id(external_id)
    if persona:
        return make_response(
            jsonify({"msg": "OK", "code": 200, "datos": persona.serialize}), 200
        )
    else:
        return make_response(
            jsonify(
                {
                    "msg": "Error",
                    "code": 404,
                    "datos": {"error": "Persona no encontrado"},
                }
            ),
            404,
        )


# api para obtener archivos de persona
@api_persona.route("/persona/archivo/<external>", methods=["GET"])
@token_requerido
def listar_archivos(external):
    return make_response(
        jsonify(
            {
                "msg": "OK",
                "code": 200,
                "datos": [i.serialize for i in personaC.obtener_archivos(external)],
            }
        ),
        200,
    )


# api para obtener foto de perfil
@api_persona.route("/persona/foto/<external>", methods=["GET"])
@token_requerido
def obtener_foto(external):
    archivo = personaC.obtener_foto(external)

    if isinstance(archivo, int):
        return make_response(
            jsonify(
                {
                    "msg": "Error",
                    "code": 404,
                    "datos": {"error": Errors.error[str(archivo)]},
                }
            ),
            404,
        )
    else:
        return make_response(
            jsonify({"msg": "OK", "code": 200, "datos": archivo.serialize}),
            200,
        )


# api para modificar persona
@api_persona.route("/persona/modificar/<external_id>", methods=["POST"])
@expects_json(schema_informacion_personal)
@token_requerido
def modificar(external_id):

    data = request.json
    persona, external = personaC.modificar(data, external_id)

    if persona >= 0:
        return make_response(
            jsonify(
                {
                    "msg": "OK",
                    "code": 200,
                    "datos": {"tag": "Datos de persona modificados"},
                    "external": external,
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
                    "datos": {"error": Errors.error[str(persona)]},
                }
            ),
            400,
        )


# api para guardar archivo
@api_persona.route("/persona/archivo", methods=["POST"])
@token_requerido
def guardar_archivo():
    archivo = request.files.get("archivo")
    data = request.form.get("external")

    id = personaC.guardar_archivo(data, archivo)

    if id >= 0:
        return make_response(
            jsonify({"msg": "OK", "code": 200, "datos": {"tag": "Archivo guardado"}}),
            200,
        )
    else:
        return make_response(
            jsonify(
                {"msg": "ERROR", "code": 400, "datos": {"error": Errors.error[str(id)]}}
            ),
            400,
        )


# api para modificar estado de cuenta de persona
@api_persona.route("/persona/estado-actualizar/<external>", methods=["POST"])
@token_requerido
def modificar_estado(external):

    persona = personaC.modificar_estado(external)

    if persona:
        return make_response(
            jsonify(
                {
                    "msg": "OK",
                    "code": 200,
                    "datos": {"tag": "Estado de cuenta modificado"},
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
                    "datos": {"error": Errors.error[str(persona)]},
                }
            ),
            400,
        )


# api para modificar credenciales de usuario
@api_persona.route("/persona/credenciales", methods=["POST"])
@token_requerido
@expects_json(schema_credenciales)
def modificar_credenciales():
    data = request.json
    persona = personaC.modificar_credenciales(data)

    if persona:
        return make_response(
            jsonify(
                {
                    "msg": "OK",
                    "code": 200,
                    "datos": {"tag": "Credenciales modificadas"},
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
                    "datos": {"error": Errors.error[str(persona)]},
                }
            ),
            400,
        )


# api_persona para inicar sesion
@api_persona.route("/sesion", methods=["POST"])
@expects_json(schema_sesion)
def iniciar_sesion():
    data = request.json
    persona = personaC.inicio_sesion(data)

    if isinstance(persona, int):
        return make_response(
            jsonify(
                {
                    "msg": "ERROR",
                    "code": 400,
                    "datos": {"error": Errors.error[str(persona)]},
                }
            ),
            400,
        )
    else:
        return make_response(
            jsonify(
                {"msg": "OK", "code": 200, "Mensaje": "Bienvenido :)", "datos": persona}
            ),
            200,
        )
