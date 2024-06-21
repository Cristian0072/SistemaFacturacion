from models.rol import Rol
from app import db
import uuid


class RolControl:
    # self es obligatorio
    def listar(self):
        # devuelve todas las filas de la tabla Producto
        return Rol.query.all()

    def guardar(self, data):
        r = Rol.query.filter_by(nombre=data["nombre"]).first()

        if not r:
            # izq bd, dere datos de vista
            rol = Rol()
            rol.nombre = data["nombre"]
            rol.descripcion = data["descripcion"]
            rol.estado = True
            rol.external_id = uuid.uuid4()

            db.session.add(rol)
            db.session.commit()

            return rol.id
        else:
            return -1

    # Metodo para obtener una rol por external_id
    def obtener_external_id(self, external):
        return Rol.query.filter_by(external_id=external).first()

    # Metodo para modificar rol por external_id
    def modificar(self, data, external):
        # siempre se busca por external
        rol = Rol.query.filter_by(external_id=external).first()

        if rol:
            
            rol.nombre = data["nombre"]
            rol.descripcion = data["descripcion"]
            rol.estado = True
            rol.external_id = uuid.uuid4()
            # merge para pocos datos
            db.session.merge(rol)
            db.session.commit()

            return rol.id
        else:
            return -2

    # metodo para cambiar_estado de manera logica una rol
    def cambiar_estado(self, external):
        rol = Rol.query.filter_by(external_id=external).first()

        if rol:
            rol.estado = False
            
            db.session.merge(rol)
            db.session.commit()
            
            return rol.id
        else:
            return -2
