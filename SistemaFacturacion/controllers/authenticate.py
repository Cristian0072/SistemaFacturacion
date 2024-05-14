# Proteger rutas
from flask import Flask, request, jsonify, make_response, current_app
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime, timedelta
from functools import wraps
from models.cuenta import Cuenta
import uuid
from controllers.utiles.errors import Errors
import jwt


# creacion de un componente
def token_requerido(f):
    @wraps(f)
    def decodered(*args, **kwargs):
        # los tokens siempre se envian en las cabeceras o headers
        token = None
        if "X-Acces-Token" in request.headers:
            token = request.headers["X-Acces-Token"]

        if not token:
            return make_response(
                jsonify(
                    {
                        "msg": "ERROR",
                        "code": 401,
                        "datos": {"error": Errors.error[str(-10)]},
                    }
                ),
                401,
            )

        try:
            data = jwt.decode(
                token,
                algorithms="HS512",
                verify=True,
                key=current_app.config["SECRET_KEY"],
            )
            usuario = Cuenta.query.filter_by(external_id=data["external"]).first()
            if not usuario:
                return make_response(
                    jsonify(
                        {
                            "msg": "ERROR",
                            "code": 401,
                            "datos": {"error": Errors.error[str(-11)]},
                        }
                    ),
                    401,
                )
        except Exception as error:
            print(error)
            return make_response(
                jsonify(
                    {
                        "msg": "ERROR",
                        "code": 401,
                        "datos": {"error": Errors.error[str(-11)]},
                    }
                ),
                401,
            )
        return f(*args, **kwargs)

    return decodered
