# Idea y alcance de la primera versión

*El Paso Final* es un juego de plataformas y exploración en 2D para teléfonos Android. Un alumno de ESCOM se
queda dormido ensayando su presentación de Trabajo Terminal y despierta debajo de la escuela: para titularse
tiene que subir, zona por zona, hasta su salón y vencer a los tres sinodales que le cierran el paso.

## Ficha

| Campo | Contenido |
|---|---|
| Usuario y contexto | Alumnos de ESCOM que juegan en su teléfono Android en ratos cortos: entre clases o en el transporte público |
| Problema observable | En esos ratos buscan algo para entretenerse desde el teléfono |
| Alternativa actual | Redes sociales u otros juegos |
| Tarea principal | Avanzar y descubrir zonas, guardando en bancos para continuar en otro momento |
| Criterio de éxito | Una persona que nunca lo ha jugado entiende los controles sin que nadie le explique y vence al jefe de la primera zona |
| Hipótesis sin validar | Los alumnos de ESCOM jugarían El Paso Final para entretenerse en sus ratos libres |

## Historia de usuario y criterio de aceptación

Como alumno de ESCOM con ratos libres cortos, quiero explorar el mundo bajo la escuela en sesiones de pocos
minutos y retomar donde me quedé, para entretenerme sin perder mi avance.

Dado que descansé en un banco y cerré la app, cuando la vuelvo a abrir, toco Jugar y elijo mi ranura, entonces aparezco en
ese mismo banco con las mismas vidas y las mismas habilidades.

## Qué entra en la primera versión

| Área | Entra |
|---|---|
| Inicio | Elegir personaje (mujer u hombre) y escribir su nombre; menú con cuatro ranuras de partida (nueva o continuar), con estados vacío, dañado y de otra versión |
| Historia | Intro con imágenes fijas y escena de los sinodales |
| Zonas | Las dos primeras, completas: tres enemigos, raíces con espinas, un mini jefe opcional y el jefe de la zona |
| Progresión | La habilidad de impulso, el arma base y un amuleto |
| Sistemas | Cuatro vidas, curación, bancos y guardado, mochila, y un reto de preguntas para recuperar lo perdido al morir |
| Personajes | Un personaje guía que entrega el arma y el mapa de la primera zona |
| Teléfono | Controles táctiles personalizables y modo de bajo detalle para gama baja |
| Desarrollo | Zona de pruebas básica: pasillo de mecánicas, arena de jefes y panel de trucos. Viaja también en la versión publicada y aparece con el modo desarrollador (`docs/contrato.md`, «Paquete de publicación») |

## Qué se aplaza a propósito

Las zonas restantes y el final con los sinodales; las demás habilidades; la tienda y el minijuego de apuestas;
las mejoras del arma; el viaje rápido entre estaciones; los personajes secundarios restantes; la música
completa; el fondo animado del menú.

## Cómo se construye

Núcleo común y contenido como datos: el núcleo (jugador, cámara, salas, guardado, entrada, eventos) se escribe
una vez, y las zonas, enemigos y personajes se agregan como escenas y fichas sin tocarlo. Primero todo con
cajas grises; el arte entra después, con sus herramientas de IA registradas en `docs/uso-de-ia.md`.
