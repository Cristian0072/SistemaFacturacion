from models.persona import Persona
from models.rol import Rol
from models.cuenta import Cuenta
from models.archivo import Archivo
from models.Tipo_Archivo import Tipo_Archivo
from app import db
import uuid
from datetime import datetime, timedelta, timezone
import jwt
import hashlib
from flask import current_app
from werkzeug.utils import secure_filename
import os

EXTENSIONES = ["jpg", "jpeg", "gif", "png"]  # extensiones permitidas para imagenes
MAX_TAMANO = 1024 * 1024 * 1  # 1MB


class PersonaControl:
    # self es obligatorioc
    def listar(self):
        # devuelve todas las filas de la tabla Persona
        return Persona.query.all()

    # metodo para listar solo usuarios
    def listar_usuario(self):
        usuario = Rol.query.filter_by(nombre="USUARIO").first()
        return Persona.query.filter_by(rol_id=usuario.id).all()

    def guardar(self, data):
        rol = Rol.query.filter_by(nombre=data["rol"]).first()
        cuenta = Cuenta.query.filter_by(usuario=data["usuario"]).first()

        if rol:
            if not cuenta:
                persona = Persona()
                # izq bd, dere datos de vista
                persona.apellidos = data["apellidos"]
                persona.nombres = data["nombres"]
                persona.rol_id = rol.id
                persona.identificacion = data["identificacion"]
                persona.external_id = uuid.uuid4()
                db.session.add(persona)
                db.session.commit()

                c = Cuenta()
                c.usuario = data["usuario"]
                c.clave = hashlib.sha256(data["clave"].encode()).hexdigest()
                c.estado = True
                c.external_id = uuid.uuid4()
                c.persona_id = persona.id

                db.session.add(c)
                db.session.commit()

                return c.id
            else:
                return -6
        else:
            return -2

    # metodo para guardar archivos de persona
    def guardar_archivo(self, external, archivo):
        # se actualiza el estado de los archivos
        self.actualizar_estado()
        # se crea la carpeta para guardar los archivos
        dir = "galeria/Persona_" + str(external)
        print(dir)
        # se valida si la carpeta existe
        if not os.path.exists(dir):
            # se crea la carpeta
            os.makedirs(dir)

        if archivo:
            # se obtiene el nombre del archivo
            nombre = secure_filename(archivo.filename)
            fecha = datetime.now().strftime("%Y%m%d%H%M%S")
            nombre = fecha + "_" + nombre
            print(nombre)
            # se obtiene la extension del archivo
            extension = nombre.rsplit(".", 1)[1].lower()
            print(extension)
            # se valida si la extension es permitida
            if extension in EXTENSIONES:
                # se valida el tamanio del archivo
                if archivo.content_length <= MAX_TAMANO:
                    # se construye la ruta del archivo
                    ruta_archivo = os.path.join(dir, nombre)
                    # se guarda el archivo en la carpeta de archivos
                    archivo.save(ruta_archivo)
                    # se obtiene el id de la persona
                    id = Persona.query.filter_by(external_id=external).first().id
                    # se crea el registro en la base de datos
                    nuevo_archivo = Archivo()
                    nuevo_archivo.nombre_archivo = nombre
                    nuevo_archivo.ruta_archivo = ruta_archivo
                    nuevo_archivo.tipo_archivo = Tipo_Archivo.IMAGEN
                    nuevo_archivo.persona_id = id
                    nuevo_archivo.estado = True
                    nuevo_archivo.external_id = uuid.uuid4()

                    db.session.add(nuevo_archivo)
                    db.session.commit()
                    return nuevo_archivo.id
                else:
                    return -19
            else:
                return -18
        else:
            return -17

    # metodo para actualizar estado de los archivos
    def actualizar_estado(self):
        estado = Archivo.query.filter_by(estado=True).all()
        for i in estado:
            i.estado = False

            db.session.merge(i)
            db.session.commit()
        return 1

    # metodo para obtener archivos de una persona
    def obtener_archivos(self, external):
        persona = Persona.query.filter_by(external_id=external).first()
        if persona:
            archivos = Archivo.query.filter_by(persona_id=persona.id).all()
            return archivos
        else:
            return -14

    #metodo para obtener foto de perfil
    def obtener_foto(self, external):
        persona = Persona.query.filter_by(external_id=external).first()
        if persona:
            archivo = Archivo.query.filter_by(persona_id=persona.id, estado=True).first()
            if archivo:
                return archivo
            else:
                return -17
        else:
            return -14

    # Metodo para obtener una persona por external id
    def obtener_external_id(self, external):
        return Persona.query.filter_by(external_id=external).first()

    # Metodo para modificar persona por external id
    def modificar(self, data, external):
        # siempre se busca por external
        rol = Rol.query.filter_by(nombre=data["rol"], estado=True).first()

        if rol:
            persona = Persona.query.filter_by(
                external_id=external, rol_id=rol.id
            ).first()

            if persona:
                cuenta = Cuenta.query.filter_by(
                    usuario=data["usuario"], estado=True, persona_id=persona.id
                ).first()
                if cuenta:
                    persona.nombre = data["nombres"]
                    persona.apellido = data["apellidos"]
                    persona.identificacion = data["identificacion"]
                    persona.external_id = uuid.uuid4()
                    persona.rol_id = rol.id
                    db.session.merge(persona)
                    db.session.commit()

                    # se comprueba y se renombra la carpeta existente
                    if os.path.exists("galeria/Persona_" + str(external)):
                        os.rename(
                            "galeria/Persona_" + str(external),
                            "galeria/Persona_" + str(persona.external_id),
                        )

                    return cuenta.id, persona.external_id
                else:
                    return -8
            else:
                return -14
        else:
            return -2

    # metodo para modificar estado de una cuenta de persona
    def modificar_estado(self, external):
        cuenta = Cuenta.query.filter_by(external_id=external).first()

        if cuenta:
            cuenta.estado = False

            # Guardar los cambios en la base de datos
            db.session.merge(cuenta)
            db.session.commit()
            return cuenta.id
        else:
            return -4

    # inicio de sesion
    def inicio_sesion(self, data):
        # obtiene el primer correo que coincida en la bd
        cuentaA = Cuenta.query.filter_by(usuario=data["usuario"]).first()
        per = Persona.query.filter_by(id=cuentaA.persona_id).first()
        rol = Rol.query.filter_by(id=per.rol_id,nombre="ADMINISTRADOR").first()

        if rol:
            if cuentaA:
                # encriptar clave
                clave = hashlib.sha256(data["clave"].encode()).hexdigest()
                # comparar clave
                if cuentaA.clave == clave:
                    if cuentaA.estado == True:
                        # tiempo de expiracion en 2 horas
                        expira = datetime.now(timezone.utc) + timedelta(hours=2)
                        # creacion de token con un tiempo de duracion
                        token = jwt.encode(
                            {
                                "external": cuentaA.external_id,
                                "expira": expira.timestamp(),
                            },
                            key=current_app.config["SECRET_KEY"],
                            algorithm="HS512",
                        )
                        cuenta = Cuenta()
                        persona = cuenta.getPersona(cuentaA.persona_id)

                        info = {
                            "token": token,
                            "usuario": persona.apellidos + " " + persona.nombres,
                            "expira": expira.timestamp(),
                            "external": persona.external_id,
                        }

                        return info
                    else:
                        return -9
                else:
                    return -8
            else:
                return -8
        else:
            return -7
