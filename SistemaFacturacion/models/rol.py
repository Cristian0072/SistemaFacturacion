from app import db
from datetime import datetime
import copy


class Rol(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(100), unique=True,nullable=False)
    descripcion = db.Column(db.String(100))
    estado = db.Column(db.Boolean, default=True)
    crear = db.Column(db.DateTime, default=datetime.now)
    actualizar = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)
    external_id = db.Column(db.String(60))

    # propiedad es similar a un atributo
    @property
    def serialize(self):
        # devuelve un diccionario
        return {
            "nombre": self.nombre,
            "descripcion": self.descripcion,
            "estado": self.estado,
            #"estado": 1 if self.estado else 0,
            "external_id": self.external_id,
        }

    @property
    def copiar_rol(self):
        return copy.deepcopy(self)
