from models.lote import Lote
from models.producto import Producto
from models.Estado import Estado
from app import db
from datetime import datetime, timedelta
import uuid


class ProductoControl:
    # self es obligatorio
    def listar(self):
        # devuelve todas las filas de la tabla Producto
        self.actualizar_estado()
        return Producto.query.all()

    def guardar(self, data):
        p = Producto.query.filter_by(codigo=data["codigo"]).first()
        n = Producto.query.filter_by(nombre=data["nombre"], marca=data["marca"]).first()

        fecha_fabri = datetime.strptime(data["fecha_fabricacion"], "%d/%m/%Y").date()
        fecha_exp = datetime.strptime(data["fecha_expiracion"], "%d/%m/%Y").date()
        # Verificar si la fecha de fabricación es una fecha futura
        if fecha_fabri > datetime.now().date():
            return -15
        # Verificar si la fecha de expiración es anterior a la fecha actual
        if fecha_exp < datetime.now().date():
            return -5
        # Verificar si la fecha de fabricación es posterior a la fecha de expiración
        if fecha_fabri > fecha_exp:
            return -16

        if not p:
            if not n:
                producto = Producto()

                # izq bd, dere datos de vista
                if ProductoControl.verificar_estado(fecha_exp) == Estado.CADUCADO:
                    producto.cantidad_stock = 0
                else:
                    producto.cantidad_stock = data["cantidad_stock"]
                producto.nombre = data["nombre"]
                producto.external_id = uuid.uuid4()
                producto.estado = ProductoControl.verificar_estado(fecha_exp)
                producto.marca = data["marca"]
                producto.codigo = data["codigo"]
                producto.descripcion = data["descripcion"]

                db.session.add(producto)
                db.session.commit()
        else:
            return -3

        lote = Lote()
        lote.fecha_fabricacion = fecha_fabri
        lote.fecha_expiracion = fecha_exp
        lote.external_id = uuid.uuid4()
        lote.producto_id = producto.id

        db.session.add(lote)
        db.session.commit()
        return lote.id

    def verificar_estado(fecha):
        print(fecha)
        if fecha == datetime.now().date():
            return Estado.CADUCADO
        elif timedelta(days=0) < (fecha - datetime.now().date()) <= timedelta(days=5):
            return Estado.A_PUNTO_DE_CADUCAR
        elif (fecha - datetime.now().date()) > timedelta(days=5):
            return Estado.BUENO
        else:
            return None

    # Metodo para obtener una producto por external_id
    def obtener_external_id(self, external):
        return Producto.query.filter_by(external_id=external).first()

    # Metodo para modificar producto por external_id
    def modificar(self, data, external):
        # siempre se busca por external
        producto = Producto.query.filter_by(external_id=external).first()
        if producto:
            lote = Lote.query.filter_by(producto_id=producto.id).first()
            if lote:

                fecha_fabri = datetime.strptime(
                    data["fecha_fabricacion"], "%d/%m/%Y"
                ).date()
                fecha_exp = datetime.strptime(
                    data["fecha_expiracion"], "%d/%m/%Y"
                ).date()

                # Verificar si la fecha de fabricación es una fecha futura
                if fecha_fabri > datetime.now().date():
                    return -15

                # Verificar si la fecha de expiración es anterior a la fecha actual
                if fecha_exp < datetime.now().date():
                    return -5

                # Verificar si la fecha de fabricación es posterior a la fecha de expiración
                if fecha_fabri > fecha_exp:
                    return -16
                if (
                    ProductoControl.verificar_estado(lote.fecha_expiracion)
                    == Estado.CADUCADO
                ):
                    producto.cantidad_stock = 0
                else:
                    producto.cantidad_stock = data["cantidad_stock"]
                producto.nombre = data["nombre"]
                producto.external_id = uuid.uuid4()
                producto.estado = ProductoControl.verificar_estado(fecha_exp)
                producto.marca = data["marca"]
                producto.descripcion = data["descripcion"]
                db.session.merge(producto)
                db.session.commit()

                lote.fecha_fabricacion = fecha_fabri
                lote.fecha_expiracion = fecha_exp
                lote.external_id = uuid.uuid4()
                lote.producto_id = producto.id
                db.session.add(lote)
                db.session.commit()

                return lote.id
            else:
                return -2
        else:
            return -4

    # metodo para actualizar estado  de producto
    def actualizar_estado(self):
        # Busca todos los lotes
        fecha_actual = datetime.now().date()
        fecha_límite = fecha_actual + timedelta(days=5)
        lotes = Lote.query.filter(Lote.fecha_expiracion.between(fecha_actual, fecha_límite)).all()

        if lotes:
            for lote in lotes:
                # Actualiza el estado del producto asociado a cada lote
                producto = Producto.query.filter_by(id=lote.producto_id).first()
                if producto:
                    producto.estado = ProductoControl.verificar_estado(
                        lote.fecha_expiracion
                    )
                    if producto.estado == Estado.CADUCADO:
                        producto.cantidad_stock = 0

                    db.session.merge(producto)
                    db.session.commit()
            return 1
        else:
            return -13

    def obtener_productos_por_estado(self, estado):
        # Devuelve todos los productos que tienen el estado ingresado
        self.actualizar_estado()
        return Producto.query.filter_by(estado=estado).all()
