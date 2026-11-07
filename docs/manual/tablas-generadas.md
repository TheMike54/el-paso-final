# Tablas generadas del proyecto

Generadas por `herramientas/generar-tablas.ps1` desde los archivos del proyecto.

## Escenas de nucleo y contenido

| Escena |
|---|
| `contenido/cinematicas/cinematica_celda.tscn` |
| `contenido/cinematicas/cinematica_eterno_pluma.tscn` |
| `contenido/npc/eterno/eterno.tscn` |
| `contenido/objetos/celda/aspas.tscn` |
| `contenido/objetos/celda/boquete_raices.tscn` |
| `contenido/objetos/celda/boquete_raices_b.tscn` |
| `contenido/objetos/celda/cables_pelados.tscn` |
| `contenido/objetos/celda/colgante_frente.tscn` |
| `contenido/objetos/celda/fondo_lejana.tscn` |
| `contenido/objetos/celda/fondo_medio.tscn` |
| `contenido/objetos/celda/fondo_profundo.tscn` |
| `contenido/objetos/celda/foso_varillas.tscn` |
| `contenido/objetos/celda/foso_varillas_pasillo.tscn` |
| `contenido/objetos/celda/hueco_piso.tscn` |
| `contenido/objetos/celda/hueco_techo.tscn` |
| `contenido/objetos/celda/lampara_plataforma.tscn` |
| `contenido/objetos/celda/lejana_0.tscn` |
| `contenido/objetos/celda/lejana_1.tscn` |
| `contenido/objetos/celda/lejana_computo_a.tscn` |
| `contenido/objetos/celda/lejana_computo_b.tscn` |
| `contenido/objetos/celda/luz_tubo.tscn` |
| `contenido/objetos/celda/pila_cortable.tscn` |
| `contenido/objetos/celda/pizarron_patas.tscn` |
| `contenido/objetos/celda/polvo_tubo.tscn` |
| `contenido/objetos/celda/puerta_salida.tscn` |
| `contenido/objetos/celda/puerta_salida_b.tscn` |
| `contenido/objetos/celda/puerta_salon.tscn` |
| `contenido/objetos/celda/raices_cortables.tscn` |
| `contenido/salas/celda/celda_1.tscn` |
| `contenido/salas/celda/celda_2.tscn` |
| `contenido/salas/celda/celda_3.tscn` |
| `contenido/salas/celda/celda_4.tscn` |
| `contenido/salas/celda/celda_5.tscn` |
| `contenido/salas/raices/raices_1.tscn` |
| `contenido/zonas/celda/sala_celda.tscn` |
| `contenido/zonas/raices/sala_raices.tscn` |
| `nucleo/banco.tscn` |
| `nucleo/coleccionable.tscn` |
| `nucleo/configuracion.tscn` |
| `nucleo/controles_tactiles.tscn` |
| `nucleo/cortable.tscn` |
| `nucleo/editor_controles.tscn` |
| `nucleo/enemigo.tscn` |
| `nucleo/jugador.tscn` |
| `nucleo/menu.tscn` |
| `nucleo/monedas_sueltas.tscn` |
| `nucleo/npc.tscn` |
| `nucleo/objeto_amuleto.tscn` |
| `nucleo/objeto_habilidad.tscn` |
| `nucleo/pausa.tscn` |
| `nucleo/piezas/foso.tscn` |
| `nucleo/piezas/niebla.tscn` |
| `nucleo/piezas/plataforma_delgada.tscn` |
| `nucleo/proyectil.tscn` |
| `nucleo/puerta.tscn` |
| `nucleo/reto_preguntas.tscn` |

## Autoloads de project.godot

| Nombre | Ruta | Singleton |
|---|---|---|
| `Eventos` | `res://nucleo/eventos.gd` | si |
| `Partida` | `res://nucleo/partida.gd` | si |
| `Arranque` | `res://nucleo/arranque.gd` | si |

## Senales del bus de eventos

Fuente: `nucleo/eventos.gd`. Orden de declaracion.

| Senal | Argumentos |
|---|---|
| `jugador_danado` | `vidas: int` |
| `jugador_muerto` | - |
| `jugador_curado` | `vidas: int` |
| `vidas_cambiadas` | `vidas: int, maximas: int` |
| `inspiracion_cambiada` | `inspiracion: int, maxima: int` |
| `descanso_en_banco` | `banco: StringName` |
| `partida_guardada` | - |
| `guardado_fallido` | `error: int` |
| `enemigo_golpeado` | `enemigo: Node` |
| `objeto_golpeado` | `objeto: Node` |
| `enemigo_vencido` | `enemigo: StringName` |
| `parry` | - |
| `habilidad_obtenida` | `habilidad: StringName` |
| `amuleto_obtenido` | `amuleto: StringName` |
| `util_obtenido` | `util: StringName` |
| `equipo_cambiado` | - |
| `mapa_obtenido` | `zona: String` |
| `coleccionable_obtenido` | `coleccionable: StringName` |
| `monedas_cambiadas` | `monedas: int` |
| `jefe_vencido` | `jefe: StringName` |
| `cambio_de_sala` | `sala: String, puerta: StringName` |
| `jugador_aterrizo` | `velocidad: float, duro: bool, picada: bool` |
| `jugador_salto` | - |
| `jugador_paso` | - |
| `jugador_impulso` | - |
| `jugador_ataco` | - |
| `curacion_empezada` | - |
| `curacion_cortada` | - |
| `muro_roto` | `muro: StringName` |
| `porton_abierto` | `porton: StringName` |
| `fundido_pedido` | `ticks_oscurecer: int, ticks_en_negro: int, ticks_aclarar: int` |
| `mochila_recuperada` | `monto: int` |
| `articulo_comprado` | `articulo: ArticuloTienda` |
| `tienda_abierta` | - |
| `tienda_cerrada` | - |
| `viaje_hecho` | `estacion: String` |
| `dispositivo_cambiado` | `dispositivo: int` |
| `mando_cambiado` | - |
| `ajuste_cambiado` | `clave: StringName` |
