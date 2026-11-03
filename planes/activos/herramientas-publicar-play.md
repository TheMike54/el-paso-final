ACTIVO

# Publicar en Google Play desde GitHub y endurecer el CI

Aprobado por la persona el 2-nov-2026 (fase A). Rama `chore/play-release`. Toca `.github/`: pasa por el `revisor`.

## Por qué
Se revisaron los workflows del curso con una app de Kotlin que sube sola a Play en cada merge (dos lecturas: Codex Sol y
Claude). Lo que sirve se adapta; lo que choca con las reglas del repo no entra:
- No en cada merge: la subida la lanza y la aprueba una persona.
- Sin commits automáticos a `main` (descartado el aumento de versión por bot).
- La acción `r0adkll/upload-google-play` v1.1.5 confirma la edición sin `changesInReviewBehavior` (su archivo edits.ts), y la
  API por omisión cancela lo que está en revisión y lo reenvía (`edits.commit`, «CANCEL_IN_REVIEW_AND_SUBMIT»). Por eso la
  subida nunca se corre con una revisión abierta y siempre deja los cambios sin enviar (`changesNotSentForReview`): el
  envío a revisión se hace a mano en Play Console.

## Fase A (esta rama)
1. `.github/workflows/release.yml`, solo `workflow_dispatch`:
   - Entradas: `version_code`, `version_name`, `subir`, `track` (`internal`/`alpha`) y `status` (`draft`/`completed`).
   - Job `construir`, en el entorno `firma` (solo `main`):
     - revisa la política y las notas;
     - instala JDK 17 y Godot 4.7.2 con plantillas, sin caché;
     - escribe la versión solo en el runner y firma con los secrets del entorno;
     - exporta «Publicacion»;
     - revisa paquete, versión, peso y que no viajen las herramientas excluidas;
     - deja el AAB como artefacto por 14 días.
   - Job `subir`, solo si `subir`, en el entorno `play` (solo `main`, la persona aprueba): sube ese mismo AAB, comprobado
     por su SHA-256.
2. Notas de versión en `distribution/whatsnew/whatsnew-es-419` (idioma de la ficha: es-419).
3. `.github/dependabot.yml`, solo acciones, semanal.
4. Acciones fijadas por SHA con su versión en comentario, en todos los workflows.
5. `ci.yml`: corrida semanal y manual; pasos de enlaces (`revisar-enlaces.ps1`) y tablas (`generar-tablas.ps1`, que no
   cambie el archivo).
6. `actionlint.yml`: job de zizmor sin code scanning. `seguridad.yml`: gitleaks sobre el historial, sin ser check obligatorio.
7. `docs/guias/publicar.md`: cómo se publica, los secrets, los entornos y qué no hacer con una revisión abierta.

## Fase B (cuando Google apruebe la prueba cerrada)
- La persona crea la cuenta de servicio, la invita en Play Console solo para esta app y guarda su JSON en el entorno `play`.
- Primera subida por la API: `internal` en `draft`, revisada en la consola.

## Lo que hace la persona
- Secrets del entorno `firma`: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_ALIAS`, `ANDROID_KEYSTORE_PASSWORD`.
- Entornos `firma` y `play` limitados a `main`; `play` con la persona como revisora y «Prevent self-review» apagado.
- Secret del entorno `play`: `PLAY_SERVICE_ACCOUNT_JSON` (fase B).

## Comprobación
- `actionlint` y zizmor en verde en el PR; `validar` en verde con los pasos nuevos.
- Una corrida de `release.yml` en `main` con `subir` apagado produce el AAB y su resumen (tras fusionar; antes no hay
  entorno ni secrets).

## Sin comprobar
- Que Godot exporte con Gradle en el runner con la configuración del editor escrita a mano.
- Que la API rechace estados distintos de `draft` mientras la app no esté aprobada (solo reportes de foros).
