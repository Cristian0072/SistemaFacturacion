from app import db
from datetime import datetime
import copy


class Sucursal(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    estado = db.Column(db.Boolean, default=True)
    nombre = db.Column(db.String(100))
    direccion = db.Column(db.String(200))
    latitud = db.Column(db.Numeric(12, 8))
    longitud = db.Column(db.Numeric(12, 8))
    crear = db.Column(db.DateTime, default=datetime.now)
    actualizar = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)
    external_id = db.Column(db.String(60))

    # relacion de uno a muchos con Producto
    producto = db.relationship("Producto", backref="sucursal", lazy=True)

    @property
    def serialize(self):
        return {
            "nombre": self.nombre,
            "direccion": self.direccion,
            "external_id": self.external_id,
            "latitud": float(self.latitud),
            "longitud": float(self.longitud),
            "estado": self.estado,
            "productos": [produ.serialize for produ in self.producto],
        }

    @property
    def copiar_sucursal(self):
        return copy.deepcopy(self)
