# README

## Setup del proyecto (se necesita tener Docker instalado en la máquina)
1. Ejecutar `docker compose build` para construir las imágenes de Docker con todas las dependencias del proyecto.
2. Ejecutar `docker compose run web bin/rails db:prepare` para crear la base de datos, correr las migraciones y popular los datos.
3. Ejecutar `docker compose up` para levantar la aplicación y sus servicios localmente (TO DO: Entorno productivo). Este paso quedará corriendo infinitamente hasta que se apague la computadora/servidor que lo corra o se haga un `CTRL C` sobre la consola y terminarlo. Nota: Actualmente quedará corriendo en `http://localhost:3000`

## ¿Con qué está armado el sistema?
- Lenguaje: Ruby.
- Framework: Rails.
- Base de datos: SQLite3.
- Librerías de interés: WickedPDF, Tailwind, Turbo.