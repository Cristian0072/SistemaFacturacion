from app import db
from datetime import datetime
from models.factura import Factura
from models.rol import Rol
from models.cuenta import Cuenta
import copy


class Persona(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    external_id = db.Column(db.String(60))
    nombres = db.Column(db.String(100))
    apellidos = db.Column(db.String(100))
    identificacion = db.Column(db.String(20))
    crear = db.Column(db.DateTime, default=datetime.now)
    actualizar = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)
    rol_id = db.Column(db.Integer, db.ForeignKey("rol.id"))
    # relacion de uno a muchos con Factura
    factura = db.relationship("Factura", backref="persona", lazy = True)
    # relacion de uno a muchos con Rol
    rol = db.relationship("Rol", backref="persona", lazy = True)
    # relacion de uno a uno con Cuenta
    cuenta = db.relationship("Cuenta", backref="persona", uselist=False, lazy = True)
   
    @property
    def serialize(self):
        # devuelve un diccionario
        return {
            "nombres": self.nombres,
            "apellidos": self.apellidos,
            "identificacion": self.identificacion,
            "external_id": self.external_id,
            "cuenta": self.cuenta.serialize if self.cuenta else None,
            "rol": self.rol.serialize if self.rol else None,
        }

    # copiar persona
    @property
    def copiar_persona(self):
        return copy.deepcopy(self)
