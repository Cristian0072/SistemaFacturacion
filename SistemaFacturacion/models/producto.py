from app import db
from models.Estado import Estado
from datetime import datetime
from models.lote import Lote
import copy


class Producto(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    external_id = db.Column(db.String(60))
    cantidad_stock = db.Column(db.Integer)
    marca = db.Column(db.String(50))
    nombre = db.Column(db.String(100))
    descripcion = db.Column(db.String(200))
    codigo = db.Column(db.String(20))
    estado = db.Column(db.Enum(Estado))
    crear = db.Column(db.DateTime, default=datetime.now)
    actualizar = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)
    detalle_id = db.Column(db.Integer, db.ForeignKey("detalle_factura.id"))

    # relacion de uno a muchos con Lote
    lote = db.relationship("Lote", backref="producto", lazy=True)

    # serializar
    @property
    def serialize(self):
        # devuelve un diccionario
        return {
            "nombre": self.nombre,
            "cantidad_stock": self.cantidad_stock,
            "estado": self.estado.value,
            "external_id": self.external_id,
            "marca": self.marca,
            "codigo": self.codigo,
            "descripcion": self.descripcion,
            "lote": [lote.serialize for lote in self.lote]
        }

    # copiar producto
    @property
    def copiar_producto(self):
        return copy.deepcopy(self)
