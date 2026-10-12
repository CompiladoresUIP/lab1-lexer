# Guía del estudiante — cómo trabajar el laboratorio

Todo se hace en el navegador. No instales nada.

## 1. Cuenta de GitHub

Crea una cuenta gratuita en https://github.com (si ya tienes una, úsala). Usa tu correo `@uip.edu.pa` si puedes: te da beneficios para estudiantes. Escribe tu nombre de usuario de GitHub en la actividad de Moodle.

## 2. Crear tu repositorio desde la plantilla (un repo por equipo)

1. Abre el enlace de la plantilla que el instructor publicó en Moodle.
2. Pulsa el botón verde **Use this template → Create a new repository**.
3. **Owner:** tu cuenta personal (no la organización). **Repository name:** `lab1-lexer-apellido1-apellido2`.
4. Elige **Private** (privado) y pulsa **Create repository**.
5. En tu repositorio: **Settings → Collaborators → Add people** y agrega a `adrianmarinuip` (el instructor) y a tus compañeros de equipo.

## 3. Abrir el entorno de programación

1. En tu repositorio pulsa **Code → Codespaces → Create codespace on main**.
2. Espera 1–2 minutos: se abre VS Code en el navegador con Flex y GCC ya instalados.
3. Abre una terminal (**Terminal → New Terminal**) y escribe `make test`. Al inicio todos los casos fallan: es lo normal.

## 4. Trabajar

- Edita `src/lexer.l` siguiendo los comentarios `TODO`.
- Escribe tu letra de variante en el archivo `VARIANT`.
- Corre `make test` cada vez que avances. Para ver un caso solo: `make test-one T=a03`.
- Para ver los tokens de tu propio archivo: `make run F=mi_prueba.src`.

## 5. Guardar y entregar

En la terminal:

```bash
git add -A
git commit -m "Parte A: palabras reservadas y numeros"
git push
```

(O usa el panel **Source Control** de VS Code.) Después ve a la pestaña **Actions** de tu repositorio y confirma que las pruebas corrieron. Entrega en Moodle el **enlace de tu repositorio**.

## 6. Cuidar tus horas de Codespaces

Los Codespaces tienen un cupo mensual de horas gratis. Cuando termines, **detén el entorno**: en https://github.com/codespaces pulsa los tres puntos del Codespace → **Stop codespace**. (Se detiene solo tras un rato inactivo, pero conviene hacerlo tú.)

## 7. Problemas frecuentes

| Problema | Qué hacer |
|---|---|
| `make: flex: command not found` | Espera a que termine de crearse el Codespace, o ejecuta `sudo apt-get install -y flex`. |
| El push pide usuario y clave | Estás fuera de Codespaces. Trabaja desde Codespaces, que ya viene autenticado. |
| Las Actions no corren | Revisa la pestaña Actions; si pide habilitarlas, pulsa **I understand my workflows, go ahead and enable them**. |
| Pasa todo en tu máquina pero falla en Actions | Compara con `make test` en Codespaces; los casos son idénticos. |
