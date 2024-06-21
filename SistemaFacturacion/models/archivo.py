from app import db
from datetime import datetime
from app import db
from models.Tipo_Archivo import Tipo_Archivo

class Archivo(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    external_id = db.Column(db.String(60))
    nombre_archivo = db.Column(db.String(100))
    tipo_archivo = db.Column(db.Enum(Tipo_Archivo))
    ruta_archivo = db.Column(db.String(200))
    estado = db.Column(db.Boolean, default=False)
    crear = db.Column(db.DateTime, default=datetime.now)
    actualizar = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)
    # relacion de uno a muchos con Persona
    persona_id = db.Column(db.Integer, db.ForeignKey("persona.id"), nullable=True)


    @property
    def serialize(self):
        # devuelve un diccionario
        return {
            "nombre_archivo": self.nombre_archivo,
            "external": self.external_id,
            "tipo_archivo": self.tipo_archivo.name if self.tipo_archivo else None,
            "estado": self.estado,
            "ruta_archivo": self.ruta_archivo
        }