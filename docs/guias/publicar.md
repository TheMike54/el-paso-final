# Publicar una versión

**Para qué sirve:** exportar el paquete Android firmado y llevarlo a una pista de prueba de Google Play.

**Antes de empezar:** leer `docs/contrato.md`, «Paquete de publicación», y `export_presets.cfg`. El AAB, el keystore y
los datos de firma nunca entran al repositorio.

Hay dos caminos: el workflow `Release` de GitHub (el normal) y la exportación a mano desde el editor (si GitHub falla).

## Con el workflow `Release`

`.github/workflows/release.yml` solo corre si una persona lo lanza desde `main` (Actions → Release → Run workflow).
Un merge nunca publica nada.

1. En un PR normal, actualizar `distribution/whatsnew/whatsnew-es-419`: lo que cambió para el jugador, de 1 a 500
   caracteres. `es-419` es el idioma de la ficha en Play.
2. Lanzar el workflow con:

   | Entrada | Qué poner |
   |---|---|
   | `version_code` | Un entero mayor que el de toda versión ya subida a Play (la consola lo muestra en la pista) |
   | `version_name` | La versión visible, por ejemplo `1.1.0` |
   | `subir` | Apagado para solo armar el AAB; encendido para subirlo después de aprobar |
   | `track` | `internal` o `alpha` (prueba cerrada) |
   | `status` | `draft` deja la versión en borrador en la consola; `completed` la publica en la pista |

3. El job `construir` revisa las entradas, la página de la política y las notas. Después:
   - escribe la versión en `export_presets.cfg` solo dentro del runner, sin commit;
   - exporta «Publicacion» firmado con la clave de subida;
   - revisa que el paquete sea `com.themike54.elpasofinal` y lleve el `versionCode` pedido;
   - revisa que no viajen las herramientas que el preset excluye, que sí viaje la zona de pruebas, y el peso (avisa
     sobre 300 MB y falla sobre 450 MB; el tope de Play es 500 MB).

   El resumen de la corrida da el commit, el peso y el SHA-256. El AAB queda como artefacto `aab-<version_code>` por 14
   días.
4. Si `subir` está encendido, el job `subir` espera la aprobación en el entorno `play`. Al aprobar, sube ese mismo AAB
   (comprueba el SHA-256) sin enviarlo a revisión.
5. En Play Console, revisar la versión y enviar los cambios a revisión desde «Resumen de la publicación».

**Nunca correr `subir` mientras Play Console muestre cambios en revisión.** La acción de subida no le dice a la API qué
hacer en ese caso, y la API, por omisión, cancela la revisión en curso y la reinicia. Esperar a que termine, o subir el
AAB del artefacto a mano.

Mientras la app no tenga una versión aprobada, la API puede aceptar solo `status: draft`.

## Lo que configura la persona dueña del repo (una vez)

En Settings → Environments:

| Entorno | Reglas | Secrets |
|---|---|---|
| `firma` | Deployment branches: solo `main` | `ANDROID_KEYSTORE_BASE64` (el keystore de subida en base64), `ANDROID_KEYSTORE_ALIAS`, `ANDROID_KEYSTORE_PASSWORD` |
| `play` | Solo `main`; Required reviewers: la persona que publica; «Prevent self-review» apagado (si no, no puede aprobar lo que ella lanzó) | `PLAY_SERVICE_ACCOUNT_JSON` |

- La contraseña del almacén y la de la clave tienen que ser la misma (`tutorials/export/exporting_for_android.rst:161`).
- El base64 sale con `[Convert]::ToBase64String([IO.File]::ReadAllBytes('<ruta del keystore>'))` en PowerShell. Se pega
  directo en el secret; no se guarda en un archivo.
- `PLAY_SERVICE_ACCOUNT_JSON`: una cuenta de servicio de Google Cloud, invitada en Play Console (Usuarios y permisos)
  solo para esta app y con permiso para publicar en pistas de prueba, no en producción. Su llave JSON se pega en el
  secret y se borra del equipo.
- Play guarda la clave de firma final (Play App Signing). Si la clave de subida se filtra, se pide su cambio desde
  Play Console.

## A mano, desde el editor

1. Proyecto → Exportar → `Publicacion`: usa Gradle y AAB. Subir `version/code` a un entero mayor que el ya subido y
   `version/name` a la versión visible. No hacer commit de ese cambio: el número lo decide el workflow.
2. `.\herramientas\validar.ps1` con `OK  VALIDACION ... fallos=0`. Exportar en modo release con el preset `Publicacion`
   a un `.aab` fuera del código fuente.
3. En Play Console, crear la versión en la pista, subir el AAB, pegar las notas de `distribution/whatsnew/` y enviar a
   revisión.

## Después de publicar

Instalar desde el enlace de prueba en un teléfono y comprobar arranque, controles, guardado, audio y recorrido
principal. Verificar también la zona de pruebas con el modo desarrollador y el filtro del paquete según
`docs/contrato.md`, «Paquete de publicación».
