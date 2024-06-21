from app import db
import uuid
from models.lote import Lote


class LoteControl:
    # self es obligatorio
    def listar(self):
        # devuelve todas las filas de la tabla Lote
        return Lote.query.all()

    def guardar(self, data):
        lote = Lote()
        # izq bd, dere datos de vista
        lote._fecha_expiracion = data["fecha_expiracion"]
        lote._fecha_fabricacion = data["fecha_fabricacion"]
        lote._external_id = uuid.uuid4()

        db.session.add(lote)
        db.session.commit()

        return lote._id

    # Metodo para obtener una lote por external_id
    def obtener_external_id(self, external_id):
        return Lote.query.filter_by(_external_id=external_id).first()

    # Metodo para modificar lote por external_id
    def modificar(self, data):

        # siempre se busca por external
        lote = Lote.query.filter_by(_external_id=data["external"]).first()
        if lote:
            lote._fecha_expiracion = data["fecha_expiracion"]
            lote._fecha_fabricacion = data["fecha_fabricacion"]
            lote._external_id = uuid.uuid4()
            # merge para pocos datos
            # update para varios datos masivos
            db.session.merge(lote)
            db.session.commit()

            return lote._id
        else:
            return -3
