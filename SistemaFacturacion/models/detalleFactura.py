from app import db
from datetime import datetime
from models.producto import Producto


class DetalleFactura(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    external_id = db.Column(db.String(60))
    cantidad = db.Column(db.Integer)
    subtotal = db.Column(db.Float)
    total = db.Column(db.Float)
    IVA = db.Column(db.Float)
    precio = db.Column(db.Float)
    crear = db.Column(db.DateTime, default=datetime.now)
    actualizar = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)
    factura_id = db.Column(db.Integer, db.ForeignKey("factura.id"), nullable=False)

    # relacion de uno a muchos con producto
    producto = db.relationship("Producto", backref="detalle_factura", lazy=True)

    @property
    def serialize(self):
        return {
            "external": self.external_id,
            "precio": self.precio,
            "cantidad": self.cantidad,
            "total": self.total,
            "subtotal": self.subtotal,
            "IVA": self.IVA,
        }
