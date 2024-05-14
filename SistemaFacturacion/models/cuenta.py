from app import db
from datetime import datetime
import copy


class Cuenta(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    estado = db.Column(db.Boolean, default=True)
    usuario = db.Column(db.String(30), unique=True)
    clave = db.Column(db.String(64))
    crear = db.Column(db.DateTime, default=datetime.now)
    actualizar = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)
    external_id = db.Column(db.String(60))
    persona_id = db.Column(db.Integer, db.ForeignKey("persona.id"), unique=True, nullable=False)
   
    def getPersona(self, id_p):
        from models.persona import Persona
        return Persona.query.filter_by(id = id_p).first()
   
    @property
    def serialize(self):
        return{
            "usuario": self.usuario,
            "clave":self.clave,
            "estado":self.estado,
            "external":self.external_id
        }

    @property
    def copiar_cuenta(self):
       return copy.deepcopy(self)