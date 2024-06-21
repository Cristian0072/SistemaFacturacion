from app import db
from datetime import datetime
import copy


class Lote(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    external_id = db.Column(db.String(60))
    fecha_expiracion = db.Column(db.Date)
    fecha_fabricacion = db.Column(db.Date)
    crear = db.Column(db.DateTime, default=datetime.now)
    actualizar = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)
    producto_id = db.Column(db.Integer, db.ForeignKey("producto.id"), nullable=False)

    # serializar
    @property
    def serialize(self):
        # devuelve un diccionario
        return {
            "fecha_expiracion": self.fecha_expiracion,
            "fecha_fabricacion": self.fecha_fabricacion,
            "external_id": self.external_id,
        }

    # copiar producto
    @property
    def copiar_producto(self):
        return copy.deepcopy(self)
