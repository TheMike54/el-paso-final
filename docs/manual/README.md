# Manual de El Paso Final

Para quien llega de fuera y va a continuar el juego sin haber participado en él. Revisado el 2-nov-2026 contra el código de la rama de cierre de auditoría.

## Por dónde empezar

1. Dejar el proyecto corriendo con `README.md` (raíz) y `docs/guias/empezar.md`.
2. Leer [arquitectura.md](arquitectura.md): cómo se reparte el código y cómo viaja una sala, un evento y un guardado.
3. Leer [mecanicas.md](mecanicas.md): qué mecánica existe y en qué estado.
4. Leer [continuar.md](continuar.md) antes de planear trabajo: dice qué falta en el repositorio y qué no se puede rehacer desde un clon.
5. Para construir, ir a `docs/guias/README.md`, que tiene una receta por tarea.

## Índice

| Archivo | Qué responde |
|---|---|
| [arquitectura.md](arquitectura.md) | Bloques, autoloads, bus de eventos, cambio de sala, guardado y paquete |
| [mecanicas.md](mecanicas.md) | Cada mecánica, si está hecha, diseñada o pendiente |
| [tablas-generadas.md](tablas-generadas.md) | Escenas, autoloads y señales; las genera `herramientas/generar-tablas.ps1` |
| [decisiones.md](decisiones.md) | Qué ya se decidió y por qué, y qué sigue abierto |
| [glosario.md](glosario.md) | Términos del juego y del proyecto |
| [continuar.md](continuar.md) | Lo que no está en el repositorio y cómo suplirlo, límites conocidos y publicar desde cero |
| [permisos.md](permisos.md) | Qué se puede usar: licencia del código, arte y recursos de terceros |

## Historia y diseño

Estos dos archivos cuentan la historia completa, incluido el final, y no tienen la licencia del resto (`permisos.md`).

| Archivo | Qué responde |
|---|---|
| [recorrido.md](recorrido.md) | El juego de principio a fin como está hoy, y lo previsto, por separado |
| [diseno.md](diseno.md) | Historia, mundo, zonas y sistemas previstos, con lo que ya existe en código |

## Cómo leer los estados

| Palabra | Significa |
|---|---|
| Hecho | Existe en el repositorio y se comprobó leyendo el código, las escenas o sus guiones |
| Previsto | Forma parte del diseño y no está construido |
| Pendiente | Falta decidirlo o terminarlo. Si lleva número, es una decisión abierta de la tabla de [decisiones.md](decisiones.md) |
| Sin comprobar | Nadie lo verificó en esta revisión; no debe darse por cierto |

«Hecho» dice que el sistema existe, no que el jugador lo encuentre en la campaña: varios sistemas solo se usan hoy en la zona de pruebas (`docs/salas-de-prueba.md`).

## Si este manual y el código difieren

Manda el código. Después mandan `docs/contrato.md` y sus archivos por tema, que se actualizan en el mismo cambio que el código. Este manual no copia valores numéricos que ya estén en `docs/jugador.md` o en las fichas, salvo los que explican una decisión.

## Mantenerlo al día

- `.\herramientas\revisar-enlaces.ps1` revisa los enlaces y las rutas de los `.md`.
- `.\herramientas\generar-tablas.ps1` rehace `tablas-generadas.md`; esa tabla no se edita a mano.
- Una decisión nueva se anota en [decisiones.md](decisiones.md) con su porqué; un límite nuevo, en [continuar.md](continuar.md).
