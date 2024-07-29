from models.sucursal import Sucursal
from models.Estado import Estado
from controllers.productoControl import ProductoControl
from app import db
import uuid


class SucursalControl:
    # self es obligatorio
    def listar(self):
        return Sucursal.query.all()

    # metodo para listar las sucursales con sus productos
    def listar_sucursal_producto(self):
        sucu = Sucursal.query.all()
        datos = []
        # for para recorrer la lista de sucursales
        for s in sucu:
            caducados = 0
            por_caducar = 0
            buenos = 0
            # for para recorrer la lista de productos de la sucursal
            for produ in s.producto:
                if produ.estado == Estado.BUENO:
                    buenos += 1
                elif produ.estado == Estado.A_PUNTO_DE_CADUCAR:
                    por_caducar += 1
                elif produ.estado == Estado.CADUCADO:
                    caducados += 1
            # se crea un diccionario con los datos de la sucursal
            data = s.serialize
            data["estados"] = {
                "caducados": caducados,
                "por_caducar": por_caducar,
                "buenos": buenos,
            }
            datos.append(data)

        return datos

    def guardar_sucursal(self, data):

        sucu = Sucursal.query.filter_by(
            nombre=data["nombre"], direccion=data["direccion"]
        ).first()
        if sucu:
            return -20
        else:
            sucursal = Sucursal()
            sucursal.direccion = data["direccion"]
            sucursal.nombre = data["nombre"]
            sucursal.latitud = data["latitud"]
            sucursal.longitud = data["longitud"]
            sucursal.external_id = uuid.uuid4()

            db.session.add(sucursal)
            db.session.commit()
            return sucursal.id

    # Metodo para guardar un producto en una sucursal
    def guardar_producto_sucursal(self, data, external):
        sucursal = Sucursal.query.filter_by(external_id=external).first()

        if sucursal:
            data["external_id"] = external
            producto = ProductoControl().guardar(data)

            return producto
        else:
            return -20

    # Metodo para obtener una sucursal con sus productos por external_id y estado
    def obtener_sucursal(self, estado, external):
        sucursal = Sucursal.query.filter_by(external_id=external).first()
        if sucursal:
            res = ProductoControl().obtener_productos_por_estado_sucursal(
                estado, sucursal.id
            )
            return res
        else:
            return -20

    # Metodo para modificar sucursal por external_id
    def modificar(self, data, external):
        # siempre se busca por external
        sucursal = Sucursal.query.filter_by(external_id=external).first()

        if sucursal:
            sucursal.nombre = data["nombre"]
            sucursal.direccion = data["direccion"]
            sucursal.external_id = uuid.uuid4()

            db.session.merge(sucursal)
            db.session.commit()

            return sucursal.id
        else:
            return -20

    # Metodo para desactivar una sucursal por external_id
    def desactivar_sucursal(self, external):
        sucursal = Sucursal.query.filter_by(external_id=external).first()

        if sucursal:
            sucursal.estado = False

            db.session.merge(sucursal)
            db.session.commit()
            return sucursal.id, sucursal.estado
        else:
            return -21
