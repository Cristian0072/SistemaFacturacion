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
        return Producto.query.all()

    def guardar(self, data):
        p = Producto.query.filter_by(codigo=data["codigo"]).first()
        n = Producto.query.filter_by(nombre=data["nombre"], marca=data["marca"]).first()

        if not p:
            if not n:
                producto = Producto()

                # izq bd, dere datos de vista
                if (
                    ProductoControl.verificar_estado(data["fecha_expiracion"]) == Estado.CADUCADO):
                    producto.cantidad_stock = 0
                else:
                    producto.cantidad_stock = data["cantidad_stock"]
                producto.nombre = data["nombre"]
                producto.external_id = uuid.uuid4()
                producto.estado = ProductoControl.verificar_estado(data["fecha_expiracion"])
                producto.marca = data["marca"]
                producto.codigo = data["codigo"]
                producto.descripcion = data["descripcion"]
                db.session.add(producto)
                db.session.commit()
        else:
            return -3
        
        lote = Lote()
        fecha = datetime.strptime(data["fecha_fabricacion"], "%d/%m/%Y").date()
        fecha1 = datetime.strptime(data["fecha_expiracion"], "%d/%m/%Y").date()
        lote.fecha_fabricacion = fecha
        lote.fecha_expiracion = fecha1
        lote.external_id = uuid.uuid4()
        lote.producto_id = producto.id
        db.session.add(lote)
        db.session.commit()
        return lote.id

    def verificar_estado(fecha_exp):
        fecha = datetime.strptime(fecha_exp, "%d/%m/%Y").date()
        print(fecha)
        if fecha == datetime.now().date():
            return Estado.CADUCADO
        elif (fecha - datetime.now().date()) <= timedelta(days=5):
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
                if (ProductoControl.verificar_estado(lote.fecha_expiracion.strftime("%d/%m/%Y")) == Estado.CADUCADO):
                    producto.cantidad_stock = 0
                else:
                    producto.cantidad_stock = data["cantidad_stock"]
                producto.nombre = data["nombre"]
                producto.external_id = uuid.uuid4()
                producto.estado = ProductoControl.verificar_estado(
                    data["fecha_expiracion"]
                )
                producto.marca = data["marca"]
                producto.descripcion = data["descripcion"]
                db.session.merge(producto)
                db.session.commit()

                fecha = datetime.strptime(data["fecha_fabricacion"], "%d/%m/%Y").date()
                fecha1 = datetime.strptime(data["fecha_expiracion"], "%d/%m/%Y").date()
                lote.fecha_fabricacion = fecha
                lote.fecha_expiracion = fecha1
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
        lotes = Lote.query.all()
        
        if lotes:
            for lote in lotes:
                # Actualiza el estado del producto asociado a cada lote
                producto = Producto.query.filter_by(id=lote.producto_id).first()
                if producto:
                    producto.estado = ProductoControl.verificar_estado(lote.fecha_expiracion.strftime("%d/%m/%Y"))
                    if producto.estado == Estado.CADUCADO:
                        producto.cantidad_stock = 0

                    db.session.merge(producto)
                    db.session.commit()
            return 1
        else:
            return -13

    def obtener_productos_por_estado(self, estado):
        # Devuelve todos los productos que tienen el estado ingresado
        return Producto.query.filter_by(estado=estado).all()
