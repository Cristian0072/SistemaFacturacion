from app import db
from datetime import datetime
from models.detalleFactura import DetalleFactura


class Factura(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    external_id = db.Column(db.String(60))
    fecha = db.Column(db.Date)
    n_factura = db.Column(db.Integer, unique=True, nullable=False)
    detalle_id = db.Column(
        db.Integer, db.ForeignKey("detalle_factura.id"), unique=True, nullable=False
    )
    persona_id = db.Column(db.Integer, db.ForeignKey("persona.id"), nullable=False)
    crear = db.Column(db.DateTime, default=datetime.now)
    actualizar = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)
    #realcion de uno a uno con detalle factura
    detalle = db.relationship("DetalleFactura", backref="factura", foreign_keys=detalle_id,uselist= False, lazy=True)

    @property
    def serialize(self):
        return {
            "external": self.external_id,
            "n_factura": self.n_factura,
            "fecha": self.fecha,
        }
